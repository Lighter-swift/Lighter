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
   *
   * - Parameters:
   *   - table: A KeyPath to the table to use, e.g. `\.people`.
   *   - id:    The value of the primary key associated with the row to be
   *            deleted.
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
   *
   * - Parameters:
   *   - table:  A KeyPath to the table to use, e.g. `\.people`.
   *   - column: A KeyPath to the column to use for comparison, e.g. `\.name`.
   *   - value:  Records having this value of the `column` will be deleted.
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
   *
   * - Parameters:
   *   - table:     A KeyPath to the table to use, e.g. `\.people`.
   *   - predicate: The qualifier selecting the records to delete.
   */
  func delete<T, P>(from      table : KeyPath<Self.RecordTypes, T.Type>,
                    where predicate : ( T.Schema ) -> P) throws
         where T: SQLDeletableRecord, P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.generateDelete(from: T.Schema.externalName,
                           where: predicate(T.schema))
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
   *
   * - Parameters:
   *   - record: The record to delete.
   */
  @inlinable
  func delete<T>(_ record: T) throws
         where T: SQLDeletableRecord, T.Schema: SQLKeyedTableSchema
  {
    try connectionHandler.withConnection(readOnly: false) { db in
      try delete(record, from: db)
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
   *
   * - Parameters:
   *   - record: The record to update.
   */
  @inlinable
  func update<T>(_ record: T) throws
         where T: SQLUpdatableRecord, T.Schema: SQLKeyedTableSchema
  {
    try connectionHandler.withConnection(readOnly: false) { db in
      try update(record, in: db)
    }
  }
  
  /**
   * Insert a record into a table.
   *
   * Example:
   * ```swift
   * let donald = try db.insert(Person(firstName: "Donald", lastName: "Duck"))
   * ```
   *
   * If the table has an automatic primary key, the value in the model will be
   * ignored.
   *
   * - Parameters:
   *   - record: The record to insert.
   * - Returns:  The value of the record in the database, e.g. with primary keys
   *             filled in.
   */
  @inlinable
  @discardableResult
  func insert<T>(_ record: T) throws -> T where T: SQLInsertableRecord {
    try connectionHandler.withConnection(readOnly: false) { db in
      try insert(record, into: db)
    }
  }
}

// MARK: - Implementations

extension SQLDatabaseChangeOperations {
  
  @inlinable
  func delete<T>(_ record: T, from db: OpaquePointer) throws
         where T: SQLDeletableRecord, T.Schema: SQLKeyedTableSchema
  {
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

  @usableFromInline
  func update<T>(_ record: T, in db: OpaquePointer) throws
         where T: SQLUpdatableRecord, T.Schema: SQLKeyedTableSchema
  {
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

  @usableFromInline
  func insert<T>(_ record: T, into db: OpaquePointer) throws -> T
         where T: SQLInsertableRecord
  {
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


// MARK: - Operate on arrays of objects

public extension SQLDatabaseChangeOperations {
  // Later: Add `any` variants to update/delete heterogeneous sets.

  /**
   * Delete records from a table.
   *
   * Example:
   * ```swift
   * try db.delete([ donald, mickey ])
   * ```
   *
   * - Parameters:
   *   - records: The records to delete.
   */
  @inlinable
  func delete<S>(_ records: S) throws
         where S: Sequence,
               S.Element: SQLDeletableRecord,
               S.Element.Schema: SQLKeyedTableSchema
  {
    try connectionHandler.withConnection(readOnly: false) { db in
      try records.forEach { try delete($0, from: db) }
    }
  }

  /**
   * Update records in a table.
   *
   * Example:
   * ```swift
   * var donald = try db.find(\.people, 1)!
   * var mickey = try db.find(\.people, 2)!
   * donald.lastname = "Mouse"
   * mickey.age      = 110
   * try db.update([ donald, mickey ])
   * ```
   *
   * - Parameters:
   *   - records: The records to update.
   */
  @inlinable
  func update<S>(_ records: S) throws
         where S: Sequence,
               S.Element: SQLUpdatableRecord,
               S.Element.Schema: SQLKeyedTableSchema
  {
    try connectionHandler.withConnection(readOnly: false) { db in
      try records.forEach { try update($0, in: db) }
    }
  }

  /**
   * Insert a set of records into a table.
   *
   * Example:
   * ```swift
   * let people = try db.insert([
   *   Person(firstName: "Donald", lastName: "Duck"),
   *   Person(firstName: "Mickey", lastName: "Mouse")
   * ])
   * ```
   *
   * The functions stops trying to insert more values once the first insert
   * failed.
   *
   * If the table has an automatic primary key, the value in the model will be
   * ignored.
   *
   * - Parameters:
   *   - records: The records to insert.
   * - Returns:   The values of the record that have been inserted,
   *              e.g. with primary keys filled in.
   */
  @inlinable
  @discardableResult
  func insert<S>(_ records: S) throws -> [ S.Element ]
         where S: Sequence, S.Element: SQLInsertableRecord
  {
    // There could be an `any T` variant, but that would make the return value
    // less convenient on the consuming side.
    return try connectionHandler.withConnection(readOnly: false) { db in
      return try records.map { try insert($0, into: db) }
    }
  }
}


public extension SQLDatabaseChangeOperations where Self: SQLDatabase {

  /**
   * Delete records from a table, in a transaction.
   *
   * Example:
   * ```swift
   * try db.delete([ donald, mickey ])
   * ```
   *
   * - Parameters:
   *   - records: The records to delete.
   */
  @inlinable
  func delete<S>(_ records: S) throws
         where S: Sequence,
               S.Element: SQLDeletableRecord,
               S.Element.Schema: SQLKeyedTableSchema
  {
    try transaction(mode: .immediate) { try $0.delete(records) }
  }

  /**
   * Update records in a table, in a transaction.
   *
   * Example:
   * ```swift
   * var donald = try db.find(\.people, 1)!
   * var mickey = try db.find(\.people, 2)!
   * donald.lastname = "Mouse"
   * mickey.age      = 110
   * try db.update([ donald, mickey ])
   * ```
   *
   * - Parameters:
   *   - records: The records to update.
   */
  @inlinable
  func update<S>(_ records: S) throws
         where S: Sequence,
               S.Element: SQLUpdatableRecord,
               S.Element.Schema: SQLKeyedTableSchema
  {
    try transaction(mode: .immediate) { try $0.update(records) }
  }

  /**
   * Insert a set of records into a table, in a transaction.
   *
   * Example:
   * ```swift
   * let people = try db.insert([
   *   Person(firstName: "Donald", lastName: "Duck"),
   *   Person(firstName: "Mickey", lastName: "Mouse")
   * ])
   * ```
   *
   * The functions stops trying to insert more values once the first insert
   * failed.
   *
   * If the table has an automatic primary key, the value in the model will be
   * ignored.
   *
   * - Parameters:
   *   - records: The records to insert.
   * - Returns:   The values of the record that have been inserted,
   *              e.g. with primary keys filled in.
   */
  @inlinable
  @discardableResult
  func insert<S>(_ records: S) throws -> [ S.Element ]
         where S: Sequence, S.Element: SQLInsertableRecord
  {
    try transaction(mode: .immediate) { try $0.insert(records) }
  }
}
