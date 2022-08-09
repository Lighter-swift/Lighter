//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

// Later: Rework to use String pathes by default and only resort to URLs in
//        a canImport section.
import struct Foundation.URL

/**
 * A type representing a SQLite3 database.
 *
 * Besides type information this includes top-level operations that can be
 * performed as part of the ``SQLDatabaseOperations`` protocol (and its
 * associated protocols).
 */
public protocol SQLDatabase: SQLDatabaseOperations {
  
  #if swift(>=5.7)
    /// Returns all ``SQLRecord`` type objects associated with the database.
    static var _allRecordTypes : [ any SQLRecord.Type ] { get }
  #endif

  /**
   * Initialize a database with a ``SQLConnectionHandler``.
   *
   * Connection handlers deal with opening and pooling database handles.
   *
   * Example:
   * ```swift
   * MyDatabase(connectionHandler: .simplePool(url: url, readOnly: readOnly))
   * ```
   *
   * - Parameters:
   *   - connectionHandler: The handler that should be used w/ the database.
   */
  init(connectionHandler: SQLConnectionHandler)
  
  /**
   * Initialize a database with a `URL`.
   *
   * This opens a database using the ``SQLConnectionHandler/SimplePool`` handler.
   * That handler does simple connection pooling so that excessive open
   * operations are avoided.
   *
   * Example:
   * ```swift
   * let db = MyDatabase(
   *   url: bundle.url(forResource: "Contacts", withExtension: "db")!,
   *   readOnly: false
   * )
   * ```
   *
   * - Parameters:
   *   - url: The filesystem `URL` to a SQLite3 database file.
   *   - readOnly: Whether the database should be opened read-only.
   */
  init(url: URL, readOnly: Bool)
  
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
   * let db = try Contacts.create(
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
  static func bootstrap(at url: URL, readOnly: Bool,
                        copying databaseFileURL: URL) throws -> Self
}
