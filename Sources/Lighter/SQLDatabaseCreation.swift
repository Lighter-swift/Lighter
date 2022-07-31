//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import struct Foundation.URL

public extension SQLDatabase {
  
  static func create(at url: URL, readOnly: Bool = false,
                     copying databaseFileURL: URL) throws -> Self
  {
    let fm = FileManager.default
    if fm.fileExists(atPath: url.path) {
      return Self.init(url: url, readOnly: readOnly)
    }
    try fm.copyItem(at: databaseFileURL, to: url)
    return Self.init(url: url, readOnly: readOnly)
  }
}

/**
 * A type that holds SQL `CREATE` statements in the ``creationSQL`` property.
 */
public protocol SQLCreationStatementsHolder {

  /// SQL `CREATE` statements (e.g. `CREATE TABLE person (...)`).
  static var creationSQL : String { get }
}

import struct Foundation.URL
import class  Foundation.FileManager
import SQLite3

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
   * let db = try Contacts.create(
   *   at: destinationURL,
   *   readOnly: false
   * )
   * ```
   *
   * - Parameters:
   *   - url: The place where the database should be created.
   *   - readOnly: Whether the database object should be returned read-only.
   */
  static func create(at url: URL, readOnly: Bool = false) throws -> Self {
    let fm = FileManager.default
    if fm.fileExists(atPath: url.path) {
      return Self.init(url: url, readOnly: readOnly)
    }

    let flags : Int32 =
      (SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_URI)
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
}


// MARK: - Async/Await

#if swift(>=5.5) && canImport(_Concurrency)
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
   * let db = try await Contacts.create(
   *   at: destinationURL,
   *   readOnly: false,
   *   copying: bundle.url(forResource: "Contacts", withExtension: "db")!
   * )
   * ```
   *
   * - Parameters:
   *   - url: The place where the database should be created.
   *   - readOnly: Whether the database object should be returned read-only.
   *   - databaseFileURL: The "source" database to be copied.
   */
  @inlinable
  static func create(at url: URL, readOnly: Bool = false,
                     copying databaseFileURL: URL) async throws -> Self
  {
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global().async {
        do {
          let db = try self.create(at: url, readOnly: readOnly,
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
   * let db = try await Contacts.create(
   *   at: destinationURL,
   *   readOnly: false
   * )
   * ```
   *
   * - Parameters:
   *   - url: The place where the database should be created.
   *   - readOnly: Whether the database object should be returned read-only.
   */
  @inlinable
  static func create(at url: URL, readOnly: Bool = false) async throws -> Self {
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global().async {
        do {
          let db = try self.create(at: url, readOnly: readOnly)
          continuation.resume(returning: db)
        }
        catch { continuation.resume(throwing: error) }
      }
    }
  }
}

#endif // swift(>=5.5) && canImport(_Concurrency)
