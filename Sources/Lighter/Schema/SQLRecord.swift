//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A `SQLRecord` is an abstract protocol representing a set of columns fetched
 * from a database.
 *
 * Concrete derived protocols:
 * - ``SQLTableRecord`` (for tables w/o a primary key or a compound one)
 *   - ``SQLKeyedTableRecord`` (for tables w/ a single primary key)
 * - ``SQLViewRecord`` (for SQL views)
 *
 * It has an associated ``SQLEntitySchema`` that can be accessed using the
 * static ``SQLRecord/schema-swift.type.property`` property.
 * The schema allows for query building.
 *
 * Note that all `SQLRecord`s are always `Hashable`, because all the SQLite base
 * types are `Hashable`.
 */
public protocol SQLRecord: Hashable {
  
  /// The ``SQLEntitySchema`` associated with the record. The schema contains
  /// the static type information for the SQL schema.
  associatedtype Schema: SQLEntitySchema
  
  /**
   * Returns the statically typed schema information associated with this
   * record.
   */
  static var schema: Schema { get }
  
  /**
   * Initialize the record with result data contained in a SQLite3 prepared
   * statement handle.
   *
   * Example:
   * ```swift
   * var statement : OpaquePointer?
   * sqlite3_prepare_v2(dbHandle, "SELECT * FROM person", -1, &statement, nil)
   * if sqlite3_step(statement) == SQLITE_ROW {
   *   let person = Person(statement)
   * }
   * sqlite3_finalize(statement)
   * ```
   *
   * - Parameters:
   *   - statement: A SQLite3 statement handle as returned by the
   *                `sqlite3_prepare*` functions.
   *   - indices:   An optional set of column positions for bindings.
   *                If missing, the property indices are looked up by name.
   */
  init(_ statement: OpaquePointer!, indices: Schema.PropertyIndices?)
  
  /**
   * Bind all record values to a SQLite3 prepared statement and call a closure.
   *
   * *Important*: The bindings are only valid within the closure being executed!
   *
   * UPDATE Example:
   * ```
   * var statement : OpaquePointer?
   * sqlite3_prepare_v2(
   *   dbHandle,
   *   "UPDATE person SET lastname = ?, firstname = ? WHERE person_id = ?",
   *   -1, &statement, nil
   * )
   *
   * let donald = Person(personId: 1, lastname: "Duck", firstname: "Donald")
   * donald.bind(to: statement,
   *   indices: ( idx_id: 3, idx_lastname: 1, idx_firstname: 2 )
   * ) {
   *   sqlite3_step(statement)
   * }
   *
   * sqlite3_finalize(statement)
   * ```
   *
   * INSERT Example:
   * ```
   * var statement : OpaquePointer?
   * sqlite3_prepare_v2(
   *   dbHandle,
   *   "INSERT INTO person ( lastname, firstname ) VALUES ( ?, ? )",
   *   -1, &statement, nil
   * )
   *
   * let donald = Person(personId: 0, lastname: "Duck", firstname: "Donald")
   * donald.bind(to: statement,
   *   indices: ( idx_id: -1, idx_lastname: 1, idx_firstname: 2 )
   * ) {
   *   sqlite3_step(statement)
   * }
   *
   * sqlite3_finalize(statement)
   * ```
   *
   * - Parameters:
   *   - statement: A SQLite3 statement handle as returned by the
   *                `sqlite3_prepare*` functions.
   *   - indices:   The parameter positions for the bindings.
   *   - execute:   A closure to execute when all bindings have been applied,
   *                the bindings are _only_ valid within that closure!
   */
  func bind<R>(to statement: OpaquePointer!,
               indices: Schema.PropertyIndices,
               then execute: () throws -> R) rethrows -> R
}

// Those exist to account for modifiable VIEWs:
/**
 * A ``SQLRecord`` that supports insertion.
 */
public protocol SQLInsertableRecord : SQLRecord
                  where Schema: SQLInsertableSchema {}
/**
 * A ``SQLRecord`` that supports updates.
 */
public protocol SQLUpdatableRecord  : SQLRecord
                  where Schema: SQLUpdatableSchema {}
/**
 * A ``SQLRecord`` that supports deletion.
 */
public protocol SQLDeletableRecord  : SQLRecord
                  where Schema: SQLDeletableSchema {}

/**
 * A `SQLViewRecord` is a ``SQLRecord`` that is tied to a table specifically.
 *
 * It has an associated ``SQLViewSchema`` that can be accessed using the
 * static ``SQLRecord/schema-swift.type.property`` property.
 * The schema allows for query building.
 *
 * A `SQLViewRecord` is different from a ``SQLTableRecord`` in that a table
 * can be updated.
 * (Views are just named queries in this API, though they can be made updatable
 *  using triggers).
 */
public protocol SQLViewRecord: SQLRecord where Schema: SQLViewSchema {}

/**
 * A `SQLTableRecord` is a ``SQLRecord`` that is tied to a table specifically.
 *
 * It has an associated ``SQLTableSchema`` that can be accessed using the
 * static ``SQLRecord/schema-swift.type.property`` property.
 * The schema allows for query building.
 *
 * A `SQLTableRecord` is different from a ``SQLViewRecord`` in that a table
 * can be updated.
 * (Views are just named queries in this API, though they can be made updatable
 *  using triggers).
 */
public protocol SQLTableRecord: SQLInsertableRecord, SQLDeletableRecord
                  where Schema: SQLTableSchema
{
}

/**
 * A `SQLKeyedTableRecord` is a ``SQLTableRecord``(a ``SQLRecord``)
 * that is tied to a table with a single primary key.
 *
 * It has an associated ``SQLKeyedTableSchema`` that can be accessed using the
 * static ``SQLRecord/schema-swift.type.property`` property.
 * The schema allows for query building.
 */
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public protocol SQLKeyedTableRecord: SQLTableRecord, SQLUpdatableRecord,
                                     Identifiable
                  where Schema: SQLKeyedTableSchema,
                        ID   == Schema.PrimaryKeyColumn.Value,
                        Self == Schema.PrimaryKeyColumn.T
{
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLKeyedTableRecord {
  
  /// Returns the primary key of the ``SQLKeyedTableRecord`` as the
  /// `Identifiable` identifier.
  @inlinable
  var id : ID { self[keyPath: Schema.primaryKeyColumn.keyPath] }
}
