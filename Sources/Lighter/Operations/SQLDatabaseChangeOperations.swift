//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3

/**
 * A mixin protocol to add record update/insert/delete functions.
 *
 * Examples:
 * ```swift
 * try db.delete(from: \.people, id: 10)
 *
 * var donald = try db.find(\.people, 1)!
 * donald.lastname = "Mouse"
 * try db.update(donald)
 * 
 * let donald = try db.insert(Person(firstName: "Donald", lastName: "Duck"))
 * ```
 *
 * See also: ``SQLDatabaseAsyncChangeOperations`` for async/await versions.
 */
public protocol SQLDatabaseChangeOperations: SQLDatabaseOperations {}

public extension SQLDatabaseChangeOperations {

  /**
   * Delete a record from a table using the single primary key.
   *
   * Example:
   * ```swift
   * try db.delete(from: \.people, id: 10)
   * ```
   */
  @inlinable
  func delete<T>(from table : KeyPath<Self.RecordTypes, T.Type>,
                 id         : T.Schema.PrimaryKeyColumn.Value)
         throws
         where T: SQLDeletableRecord, T.Schema: SQLKeyedTableSchema
  {
    try delete(from: table) {_ in T.Schema.primaryKeyColumn == id }
  }

  /**
   * Delete records from a table where a column matches a value.
   *
   * Example:
   * ```swift
   * try db.delete(from: \.people, where: \.lastname, is: "Duck")
   * ```
   */
  @inlinable
  func delete<T, C>(from   table : KeyPath<Self.RecordTypes, T.Type>,
                    where column : KeyPath<T.Schema, C>, is value : C.Value)
         throws
         where C: SQLColumn, T == C.T, T: SQLDeletableRecord
  {
    try delete(from: table) { _ in T.schema[keyPath: column] == value }
  }

  /**
   * Delete records from a table that match a certain predicate.
   *
   * Example:
   * ```swift
   * try db.delete(from: \.people) {
   *   $0.isArchived == 1
   * }
   * ```
   */
  func delete<T, P>(from  table : KeyPath<Self.RecordTypes, T.Type>,
                    where     p : ( T.Schema ) -> P) throws
         where T: SQLDeletableRecord, P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.generateDelete(from: T.Schema.externalName, where: p(T.schema))
    try fetch(builder.sql, builder.bindings) { stmt, stop in stop = true }
  }
}

public extension SQLDatabaseChangeOperations {

  /**
   * Delete a record from a table.
   *
   * Example:
   * ```swift
   * try db.delete(donald)
   * ```
   */
  @inlinable
  func delete<T>(_ record: T) throws
         where T: SQLDeletableRecord, T.Schema: SQLKeyedTableSchema
  {
    try connectionHandler.withConnection(readOnly: false) { db in
      
      // DELETE FROM table WHERE pkey
      var statement : OpaquePointer?
      let ok = sqlite3_prepare_v2(db, T.Schema.delete, -1, &statement, nil)
      defer { sqlite3_finalize(statement) }

      guard ok == SQLITE_OK else {
        assert(ok == SQLITE_OK)
        throw LighterError(
          .deleteFailed(record: record), ok, sqlite3_errmsg(db))
      }

      let rok = record.bind(to: statement,
                            indices: T.Schema.deleteParameterIndices)
      {
        sqlite3_step(statement)
      }
      assert(rok == SQLITE_DONE)
      
      // We allow 'row' results, not really an error, we just don't use them
      if rok != SQLITE_ROW && rok != SQLITE_DONE {
        throw LighterError(
          .deleteFailed(record: record), ok, sqlite3_errmsg(db))
      }
    }
  }

  /**
   * Update a record in a table.
   *
   * Example:
   * ```swift
   * var donald = try db.find(\.people, 1)!
   * donald.lastname = "Mouse"
   * try db.update(donald)
   * ```
   */
  @inlinable
  func update<T>(_ record: T) throws
         where T: SQLUpdatableRecord, T.Schema: SQLKeyedTableSchema
  {
    try connectionHandler.withConnection(readOnly: false) { db in
      
      // UPDATE table SET values WHERE pkey
      var statement : OpaquePointer?
      let ok = sqlite3_prepare_v2(db, T.Schema.update, -1, &statement, nil)
      defer { sqlite3_finalize(statement) }

      guard ok == SQLITE_OK else {
        assert(ok == SQLITE_OK)
        throw LighterError(
          .updateFailed(record: record), ok, sqlite3_errmsg(db))
      }

      let rok = record.bind(to: statement,
                            indices: T.Schema.updateParameterIndices)
      {
        sqlite3_step(statement)
      }
      assert(rok == SQLITE_DONE)
      
      // We allow 'row' results, not really and error, we just don't use them
      if rok != SQLITE_ROW && rok != SQLITE_DONE {
        throw LighterError(
          .updateFailed(record: record), ok, sqlite3_errmsg(db))
      }
    }
  }
  
  /**
   * Insert a record in a table.
   *
   * Example:
   * ```swift
   * let donald = try db.insert(Person(firstName: "Donald", lastName: "Duck"))
   * ```
   *
   * If the table has an automatic primary key, the value in the model will be
   * ignored.
   */
  @inlinable
  @discardableResult
  func insert<T>(_ record: T) throws -> T
         where T: SQLInsertableRecord
  {
    try connectionHandler.withConnection(readOnly: false) { db in
      
      // "INSERT INTO table ( names ) WHERE ( ?, ?, ? ) RETURNING *"
      // RETURNING requires SQLite3 3.35.0+ (2021-03-12)
      let supportsReturning = sqlite3_libversion_number() >= 3035000
      let sql = supportsReturning ? T.Schema.insertReturning : T.Schema.insert
      
      var statement : OpaquePointer?
      let ok = sqlite3_prepare_v2(db, sql, -1, &statement, nil)
      defer { sqlite3_finalize(statement) }
      
      guard ok == SQLITE_OK else {
        assert(ok == SQLITE_OK)
        throw LighterError(
          .insertFailed(record: record), ok, sqlite3_errmsg(db))
      }
      
      let rok = record.bind(to: statement,
                            indices: T.Schema.insertParameterIndices)
      {
        return sqlite3_step(statement)
      }
      
      if supportsReturning && rok == SQLITE_ROW {
        return T(statement, indices: T.Schema.selectColumnIndices)
      }
      else if rok == SQLITE_DONE {
        if supportsReturning {
          assertionFailure("Expected new record to be returned")
          return record
        }
          
        // Provide an own "RETURNING" implementation...
        let sql = T.Schema.select + " WHERE ROWID = last_insert_rowid();"
        var statement : OpaquePointer?
        let ok = sqlite3_prepare_v2(db, sql, -1, &statement, nil)
        defer { sqlite3_finalize(statement) }
        guard ok == SQLITE_OK else {
          assert(ok == SQLITE_OK)
          throw LighterError(
            .insertFailed(record: record), ok, sqlite3_errmsg(db))
        }
        let rok = sqlite3_step(statement)
        if rok == SQLITE_ROW {
          return T(statement, indices: T.Schema.selectColumnIndices)
        }
        else if rok == SQLITE_DONE {
          assertionFailure("Expected new record to be returned")
          return record
        }
        else { // Note: It likely has been inserted!
          throw SQLError(db)
        }
      }
      else {
        throw LighterError(
          .insertFailed(record: record), ok, sqlite3_errmsg(db))
      }
    }
  }
}
