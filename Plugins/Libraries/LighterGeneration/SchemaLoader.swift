//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3
import SQLite3Schema
import Foundation

/**
 * A helper class that can load schemas from SQLite database *and* a set of
 * files containing SQL statements (usually `CREATE VIEW`s and tables).
 */
public final class SchemaLoader {
  
  /// An error that occured during schema loading.
  public enum SchemaLoadError: Swift.Error {
    
    case couldNotCreateInMemoryDB
    
    case fileDoesNotExist          (URL)
    case couldNotOpenDatabase      (URL)
    case couldNotLoadFile          (URL, Swift.Error)
    case invalidSQLInFile          (URL, String?)
    
    case couldNotLoadInMemorySchema(String)
    
    case couldNotRecreateTable     (String, URL, error: String)
    case couldNotRecreateView      (String, URL, error: String)
    case couldNotRecreateIndex     (String, URL, error: String)
    case couldNotRecreateTrigger   (String, URL, error: String)
  }

  var memoryDB : OpaquePointer!
  
  init() throws {
    var memDBMaybe: OpaquePointer?
    guard sqlite3_open_v2(":memory:", &memDBMaybe, SQLITE_OPEN_READWRITE,
                          nil) == SQLITE_OK, let memDB = memDBMaybe else
    {
      throw SchemaLoadError.couldNotCreateInMemoryDB
    }
    self.memoryDB = memDB
  }
  deinit {
    if let memoryDB = memoryDB { sqlite3_close(memoryDB); self.memoryDB = nil }
  }

  /// Looks at each of the file URLs and loads them as either a SQLite database
  /// or a SQL source file that is executed.
  /// All those are combined into a single `Schema`.
  public static func buildSchemaFromURLs(_ urls: [ URL ]) throws -> Schema {
    guard !urls.isEmpty else { return Schema() }
    
    if urls.count == 1, let firstURL = urls.first {
      if hasSQLiteMagicBytes(of: firstURL) {
        return try fetchSchema(for: firstURL)
      }
    }
    
    let loader : SchemaLoader = try SchemaLoader()
    
    for inputURL in urls {
      try loader.load(inputURL)
    }
    
    return try loader.fetchSchema()
  }
  
  static func fetchSchema(for url: URL) throws -> Schema {
    var db : OpaquePointer?
    let rc = sqlite3_open_v2(
      url.absoluteString, &db,
      SQLITE_OPEN_URI | SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_READONLY,
      nil
    )
    guard rc == SQLITE_OK, let db = db else {
      throw SchemaLoadError.couldNotOpenDatabase(url)
    }
    defer { sqlite3_close(db) }

    guard let schema = Schema.fetch(in: db) else {
      let error = sqlite3_errmsg(db).flatMap { String(cString: $0) }
      throw SchemaLoadError.couldNotLoadInMemorySchema(error ?? "Unknown Error")
    }
    
    return schema
  }
  
  func fetchSchema() throws -> Schema {
    guard let db = memoryDB else {
      throw SchemaLoadError.couldNotCreateInMemoryDB
    }
    
    guard let schema = Schema.fetch(in: db) else {
      let error = sqlite3_errmsg(db).flatMap { String(cString: $0) }
      throw SchemaLoadError.couldNotLoadInMemorySchema(error ?? "Unknown Error")
    }
    
    return schema
  }
  
  func load(_ url: URL) throws {
    let fm = FileManager.default
    
    guard fm.isReadableFile(atPath: url.path) else {
      throw SchemaLoadError.fileDoesNotExist(url)
    }
    
    // Note: Opening via `sqlite3_open_v2` doesn't check the readability!
    if hasSQLiteMagicBytes(of: url) {
      var db : OpaquePointer?
      let rc = sqlite3_open_v2(
        url.absoluteString, &db,
        SQLITE_OPEN_URI | SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_READONLY,
        nil
      )
      guard rc == SQLITE_OK, let db = db else {
        throw SchemaLoadError.couldNotOpenDatabase(url)
      }
      defer { sqlite3_close(db) }
      
      try loadIntoMemory(db, url: url)
    }
    else {
      // Try to run as SQL
      
      let sql : String
      do    { sql = try String(contentsOf: url) }
      catch { throw SchemaLoadError.couldNotLoadFile(url, error) }
      
      try executeIntoMemory(sql, url: url)
    }
  }
  
  private func loadIntoMemory(_ db: OpaquePointer, url: URL) throws {
    let schema = try Self.fetchSchema(for: url)

    guard let memoryDB = memoryDB else {
      throw SchemaLoadError.couldNotCreateInMemoryDB
    }

    // SQLite isn't picky, but let's create tables before views
    for table in schema.tables where !table.creationSQL.isEmpty {
      if let error = execute(table.creationSQL, in: memoryDB) {
        throw SchemaLoadError
          .couldNotRecreateTable(table.name, url, error: error)
      }
    }
    for view in schema.views where !view.creationSQL.isEmpty {
      if let error = execute(view.creationSQL, in: memoryDB) {
        throw SchemaLoadError
          .couldNotRecreateView(view.name, url, error: error)
      }
    }
    
    // Well, might make sense to preserve them
    for indices in schema.indices.values {
      for index in indices where !index.sql.isEmpty {
        if let error = execute(index.sql, in: memoryDB) {
          throw SchemaLoadError
            .couldNotRecreateIndex(index.name, url, error: error)
        }
      }
    }
    for triggers in schema.triggers.values {
      for trigger in triggers where !trigger.sql.isEmpty {
        if let error = execute(trigger.sql, in: memoryDB) {
          throw SchemaLoadError
            .couldNotRecreateTrigger(trigger.name, url, error: error)
        }
      }
    }
  }
  
  private func executeIntoMemory(_ sql: String, url: URL) throws {
    guard let db = memoryDB else {
      throw SchemaLoadError.couldNotCreateInMemoryDB
    }
    
    if let error = execute(sql, in: db) {
      throw SchemaLoadError.invalidSQLInFile(url, error)
    }
  }
  
  private func execute(_ sql: String, in db: OpaquePointer!) -> String? {
    var error: UnsafeMutablePointer<CChar>?
    let rc = sqlite3_exec(db, sql, nil, nil, &error)
    if rc == SQLITE_OK { return nil }
    return error.flatMap { String(cString: $0) } ?? "Unknown Error"
  }
}

fileprivate func hasSQLiteMagicBytes(of url: URL) -> Bool {
  guard url.isFileURL else { return false }
  
  // - Magic Bytes: 16 bytes: "SQLite format 3\0"
  //   53 51 4c 69 74 65 20 66  6f 72 6d 61 74 20 33 00  |SQLite format 3.|
  let magicBytes = [ UInt8 ]("SQLite format 3".utf8) + [ 0 ]
  guard let fh = fopen(url.path, "r") else { return false }
  defer { fclose(fh) }
  
  var buf = [ UInt8 ](repeating: 0, count: 16)
  let size = fread(&buf, 16, 1, fh)
  guard size == 1 else { return false }
  
  return buf == magicBytes
}
