//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A type that holds SQL `CREATE` statements in the ``creationSQL`` property.
 */
public protocol SQLCreationStatementsHolder {

  /// SQL `CREATE` statements (e.g. `CREATE TABLE person (...)`).
  static var creationSQL : String { get }
}


#if canImport(Foundation)
import struct Foundation.URL
import class  Foundation.FileManager
import SQLite3

public extension SQLDatabase {
  
  /**
   * Create the database by copying an existing (usually resource) database
   * to a different place.
   *
   * Example:
   * ```swift
   * let db = try ContactsDB.bootstrap(
   *   at: url,
   *   overwrite: false,
   *   copying: ContactsDB.module.connectionHandler.url
   * )
   * ```
   *
   * - Parameters:
   *   - url:             The path to the destination.
   *   - readOnly:        Whether the database should be opened read only.
   *   - overwrite:       Whether the database should be deleted if it
   *                      exists already (useful during development).
   *   - databaseFileURL: The URL of the database to be copied.
   * - Returns:           The initialized database if successful.
   */
  static func bootstrap(at url: URL, readOnly: Bool = false,
                        overwrite: Bool = false,
                        copying databaseFileURL: URL) throws -> Self
  {
    let fm = FileManager.default
    
    if fm.fileExists(atPath: url.path) {
      if overwrite {
        try fm.removeItem(at: url)
      }
      else {
        return Self.init(url: url, readOnly: readOnly)
      }
    }
    
    let dir = url.deletingLastPathComponent()
    if !fm.fileExists(atPath: dir.path) {
      try fm.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    
    try fm.copyItem(at: databaseFileURL, to: url)
    return Self.init(url: url, readOnly: readOnly)
  }
  
  /**
   * Create the database by copying an existing (usually resource) database
   * to a different place.
   *
   * Example:
   * ```swift
   * let db = try ContactsDB.bootstrap(
   *   copying: ContactsDB.module.connectionHandler.url
   * )
   * ```
   *
   * - Parameters:
   *   - directory:       The `FileManager.SearchPathDirectory` to place the
   *                      copy in, defaults to `applicationSupportDirectory`.
   *   - domains:         The `FileManager.SearchPathDomainMask` to use for the
   *                      lookup of the `directory`.
   *                      Defaults to `userDomainMask`.
   *   - readOnly:        Whether the database should be opened read only.
   *   - overwrite:       Whether the database should be deleted if it
   *                      exists already (useful during development).
   *   - databaseFileURL: The URL of the database to be copied.
   * - Returns:           The initialized database if successful.
   */
  static func bootstrap(into directory : FileManager.SearchPathDirectory
                                       = .applicationSupportDirectory,
                        domains        : FileManager.SearchPathDomainMask
                                       = .userDomainMask,
                        readOnly       : Bool = false,
                        overwrite      : Bool = false,
                        copying databaseFileURL: URL) throws -> Self
  {
    guard let dir = FileManager.default.urls(for: directory, in: domains).first
    else {
      fatalError("Could not get path for \(directory) directory?!")
    }
    
    let url = dir.appendingPathComponent(databaseFileURL.lastPathComponent)
    return try bootstrap(at: url, readOnly: readOnly, overwrite: overwrite,
                         copying: databaseFileURL)
  }
}


public extension SQLDatabase where Self: SQLCreationStatementsHolder {
  
  /**
   * Create or open the SQL database at the given URL.
   *
   * If a file already exists at the URL, the database structure is initialized
   * with that.
   *
   * Otherwise the database is (re)created using the `creationSQL` statements
   * contained in the schema types of the database.
   *
   * Example:
   * ```swift
   * let db = try Contacts.bootstrap(
   *   at: destinationURL,
   *   readOnly: false,
   *   overwrite: false
   * )
   * ```
   *
   * - Parameters:
   *   - url:       The place where the database should be created.
   *   - readOnly:  Whether the database object should be returned read-only.
   *   - overwrite: Whether the database should be deleted if it
   *                exists already (useful during development).
   * - Returns:     The initialized database if successful.
   */
  static func bootstrap(at url: URL, readOnly: Bool = false,
                        overwrite: Bool = false) throws -> Self
  {
    let fm = FileManager.default
    if fm.fileExists(atPath: url.path) {
      if overwrite {
        try fm.removeItem(at: url)
      }
      else {
        return Self.init(url: url, readOnly: readOnly)
      }
    }
    
    let dir = url.deletingLastPathComponent()
    if !fm.fileExists(atPath: dir.path) {
      try fm.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    let flags : Int32
              = (SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_URI)
    var db : OpaquePointer?
    guard sqlite3_open_v2(url.absoluteString, &db, flags, nil) == SQLITE_OK else
    {
      throw SQLError(db)
    }
    defer { sqlite3_close(db) }
    
    guard sqlite3_exec(db, Self.creationSQL, nil, nil, nil) == SQLITE_OK else {
      throw SQLError(db)
    }
    
    return Self(url: url, readOnly: readOnly)
  }
  
  /**
   * Create or open the SQL database at the given URL.
   *
   * If a file already exists at the URL, the database structure is initialized
   * with that.
   *
   * Otherwise the database is (re)created using the `creationSQL` statements
   * contained in the schema types of the database.
   *
   * Example:
   * ```swift
   * let db = try Contacts.bootstrap()
   * ```
   *
   * - Parameters:
   *   - directory: The `FileManager.SearchPathDirectory` to place the
   *                copy in, defaults to `applicationSupportDirectory`.
   *   - domains:   The `FileManager.SearchPathDomainMask` to use for the
   *                lookup of the `directory`.
   *                Defaults to `userDomainMask`.
   *   - filename:  The filename to use, otherwise defaults to the name of
   *                database type (e.g. `Contacts.sqlite`).
   *   - readOnly:  Whether the database object should be returned read-only.
   *   - overwrite: Whether the database should be deleted if it
   *                exists already (useful during development).
   * - Returns:     The initialized database if successful.
   */
  static func bootstrap(into directory : FileManager.SearchPathDirectory
                                       = .applicationSupportDirectory,
                        domains        : FileManager.SearchPathDomainMask
                                       = .userDomainMask,
                        filename       : String? = nil,
                        readOnly       : Bool = false,
                        overwrite      : Bool = false) throws -> Self
  {
    guard let dir = FileManager.default.urls(for: directory, in: domains).first
    else {
      fatalError("Could not get path for \(directory) directory?!")
    }
    
    let filename = filename ?? String(describing: self) + ".sqlite3"
    let url = dir.appendingPathComponent(filename)
    
    return try bootstrap(at: url, readOnly: readOnly, overwrite: overwrite)
  }
}
#endif // canImport(Foundation)


// MARK: - Async/Await

#if swift(>=5.5) && canImport(_Concurrency) && canImport(Foundation)
import Dispatch

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLDatabase where Self: SQLDatabaseAsyncOperations {
  
  /**
   * Create or open the SQL database at the given URL.
   *
   * If a file already exists at the URL, the database structure is initialized
   * with that.
   * Otherwise, the `databaseFileURL` is copied to the `url` destination
   * (using `FileManager.copyItem(at:to:)`).
   *
   * Example:
   * ```swift
   * let db = try await Contacts.bootstrap(
   *   at: destinationURL,
   *   readOnly: false,
   *   copying: bundle.url(forResource: "Contacts", withExtension: "db")!
   * )
   * ```
   *
   * - Parameters:
   *   - url:             The place where the database should be created.
   *   - readOnly:        Whether the database should be returned read-only.
   *   - overwrite:       Whether the database should be deleted if it
   *                      exists already (useful during development).
   *   - databaseFileURL: The "source" database to be copied.
   */
  static func bootstrap(at url: URL, readOnly: Bool = false,
                        overwrite: Bool = false,
                        copying databaseFileURL: URL) async throws -> Self
  {
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global().async {
        do {
          let db = try self.bootstrap(at: url, readOnly: readOnly,
                                      overwrite: overwrite,
                                      copying: databaseFileURL)
          continuation.resume(returning: db)
        }
        catch { continuation.resume(throwing: error) }
      }
    }
  }
  
  /**
   * Create the database by copying an existing (usually resource) database
   * to a different place.
   *
   * Example:
   * ```swift
   * let db = try await ContactsDB.bootstrap(
   *   copying: ContactsDB.module.connectionHandler.url
   * )
   * ```
   *
   * - Parameters:
   *   - directory:       The `FileManager.SearchPathDirectory` to place the
   *                      copy in, defaults to `applicationSupportDirectory`.
   *   - domains:         The `FileManager.SearchPathDomainMask` to use for the
   *                      lookup of the `directory`.
   *                      Defaults to `userDomainMask`.
   *   - readOnly:        Whether the database should be opened read only.
   *   - overwrite:       Whether the database should be deleted if it
   *                      exists already (useful during development).
   *   - databaseFileURL: The URL of the database to be copied.
   * - Returns:           The initialized database if successful.
   */
  static func bootstrap(into directory : FileManager.SearchPathDirectory
                                       = .applicationSupportDirectory,
                        domains        : FileManager.SearchPathDomainMask
                                       = .userDomainMask,
                        readOnly       : Bool = false,
                        overwrite      : Bool = false,
                        copying databaseFileURL: URL) async throws -> Self
  {
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global().async {
        do {
          let db = try self.bootstrap(into: directory, domains: domains,
                                      readOnly: readOnly, overwrite: overwrite,
                                      copying: databaseFileURL)
          continuation.resume(returning: db)
        }
        catch { continuation.resume(throwing: error) }
      }
    }
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLDatabase where Self: SQLCreationStatementsHolder,
                                   Self: SQLDatabaseAsyncOperations
{
  
  /**
   * Create or open the SQL database at the given URL.
   *
   * If a file already exists at the URL, the database structure is initialized
   * with that.
   *
   * Otherwise the database is (re)created using the `creationSQL` statements
   * contained in the schema types of the database.
   *
   * Example:
   * ```swift
   * let db = try await Contacts.bootstrap(
   *   at: destinationURL,
   *   readOnly: false
   * )
   * ```
   *
   * - Parameters:
   *   - url:       The place where the database should be created.
   *   - readOnly:  Whether the database object should be returned read-only.
   *   - overwrite: Whether the database should be deleted if it
   *                exists already (useful during development).
   * - Returns:     The initialized database if successful.
   */
  static func bootstrap(at url: URL, readOnly: Bool = false,
                        overwrite: Bool = false)
                async throws -> Self
  {
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global().async {
        do {
          let db = try self.bootstrap(at: url, readOnly: readOnly,
                                      overwrite: overwrite)
          continuation.resume(returning: db)
        }
        catch { continuation.resume(throwing: error) }
      }
    }
  }
  
  /**
   * Create or open the SQL database at the given URL.
   *
   * If a file already exists at the URL, the database structure is initialized
   * with that.
   *
   * Otherwise the database is (re)created using the `creationSQL` statements
   * contained in the schema types of the database.
   *
   * Example:
   * ```swift
   * let db = try await Contacts.bootstrap()
   * ```
   *
   * - Parameters:
   *   - directory: The `FileManager.SearchPathDirectory` to place the
   *                copy in, defaults to `applicationSupportDirectory`.
   *   - domains:   The `FileManager.SearchPathDomainMask` to use for the
   *                lookup of the `directory`.
   *                Defaults to `userDomainMask`.
   *   - filename:  The filename to use, otherwise defaults to the name of
   *                database type (e.g. `Contacts.sqlite`).
   *   - readOnly:  Whether the database object should be returned read-only.
   *   - overwrite: Whether the database should be deleted if it
   *                exists already (useful during development).
   * - Returns:     The initialized database if successful.
   */
  static func bootstrap(into directory : FileManager.SearchPathDirectory
                                       = .applicationSupportDirectory,
                        domains        : FileManager.SearchPathDomainMask
                                       = .userDomainMask,
                        filename       : String? = nil,
                        readOnly       : Bool = false,
                        overwrite      : Bool = false) async throws -> Self
  {
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global().async {
        do {
          let db = try self.bootstrap(into: directory, domains: domains,
                                      filename: filename, readOnly: readOnly,
                                      overwrite: overwrite)
          continuation.resume(returning: db)
        }
        catch { continuation.resume(throwing: error) }
      }
    }
  }
}

#endif // swift(>=5.5) && canImport(_Concurrency)
