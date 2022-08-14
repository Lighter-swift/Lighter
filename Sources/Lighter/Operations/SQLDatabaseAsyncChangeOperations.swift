//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

// Same like `SQLDatabaseChangeOperations`, async/await variant if available.

/**
 * Asynchronous operations that change the database.
 *
 * Note: Often it makes more sense to run such in an async transaction instead!
 *       See ``SQLDatabase/transaction(mode:execute:)-2s7zu``.
 */
public protocol SQLDatabaseAsyncChangeOperations
                : SQLDatabaseAsyncFetchOperations, SQLDatabaseChangeOperations
{}

#if swift(>=5.5) && canImport(_Concurrency)

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLDatabaseAsyncChangeOperations {

  /**
   * Delete a record from a table using the single primary key.
   *
   * Example:
   * ```swift
   * try await db.delete(from: \.people, id: 10)
   * ```
   *
   * Note: Often it makes more sense to run such in an async transaction!
   *
   * - Parameters:
   *   - table: A KeyPath to the table to use, e.g. `\.people`.
   *   - id:    The value of the primary key associated with the row to be
   *            deleted.
   */
  @inlinable
  func delete<T>(from table : KeyPath<Self.RecordTypes, T.Type>,
                 id         : T.Schema.PrimaryKeyColumn.Value)
         async throws
         where T: SQLDeletableRecord, T.Schema: SQLKeyedTableSchema
  {
    try await runOnDatabaseQueue { try delete(from: table, id: id) }
  }

  /**
   * Delete records from a table where a column matches a value.
   *
   * Example:
   * ```swift
   * try await db.delete(from: \.people, where: \.lastname, is: "Duck")
   * ```
   *
   * Note: Often it makes more sense to run such in an async transaction!
   *
   * - Parameters:
   *   - table:  A KeyPath to the table to use, e.g. `\.people`.
   *   - column: A KeyPath to the column to use for comparison, e.g. `\.name`.
   *   - value:  Records having this value of the `column` will be deleted.
   */
  @inlinable
  func delete<T, C>(from   table : KeyPath<Self.RecordTypes, T.Type>,
                    where column : KeyPath<T.Schema, C>, is value : C.Value)
         async throws
         where C: SQLColumn, T == C.T, T: SQLDeletableRecord
  {
    try await runOnDatabaseQueue {
      try delete(from: table, where: column, is: value)
    }
  }

  /**
   * Delete records from a table that match a certain predicate.
   *
   * Example:
   * ```swift
   * try await db.delete(from: \.people) {
   *   $0.isArchived == 1
   * }
   * ```
   *
   * Note: Often it makes more sense to run such in an async transaction!
   *
   * - Parameters:
   *   - table:     A KeyPath to the table to use, e.g. `\.people`.
   *   - predicate: The qualifier selecting the records to delete.
   */
  @inlinable
  func delete<T, P>(from  table : KeyPath<Self.RecordTypes, T.Type>,
                    where     p : @escaping ( T.Schema ) -> P)
         async throws
         where T: SQLDeletableRecord, P: SQLPredicate
  {
    try await runOnDatabaseQueue { try delete(from: table, where: p) }
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLDatabaseAsyncChangeOperations {

  /**
   * Delete a record from a table.
   *
   * Example:
   * ```swift
   * try await db.delete(donald)
   * ```
   *
   * Note: Often it makes more sense to run such in an async transaction!
   *
   * - Parameters:
   *   - record: The record to delete.
   */
  @inlinable
  func delete<T>(_ record: T) async throws
         where T: SQLDeletableRecord, T.Schema: SQLKeyedTableSchema
  {
    try await runOnDatabaseQueue { try delete(record) }
  }

  /**
   * Update a record in a table.
   *
   * Example:
   * ```swift
   * var donald = try await db.find(\.people, 1)!
   * donald.lastname = "Mouse"
   * try await db.update(donald)
   * ```
   *
   * Note: Often it makes more sense to run such in an async transaction!
   *
   * - Parameters:
   *   - record: The record to update.
   */
  @inlinable
  func update<T>(_ record: T) async throws
         where T: SQLUpdatableRecord, T.Schema: SQLKeyedTableSchema
  {
    try await runOnDatabaseQueue { try update(record) }
  }
  
  /**
   * Insert a record in a table and return the database version.
   *
   * Example:
   * ```swift
   * let donald = try await db.insert(
   *                          Person(firstName: "Donald", lastName: "Duck"))
   * ```
   *
   * If the table has an automatic primary key, the value in the model will be
   * ignored.
   *
   * This function returns the new representation, i.e. with the primary key
   * if the database assigned one.
   *
   * Note: Often it makes more sense to run such in an async transaction!
   *
   * - Parameters:
   *   - record: The record to insert.
   * - Returns:  The value of the record in the database, e.g. with primary keys
   *             filled in.
   */
  @inlinable
  @discardableResult
  func insert<T>(_ record: T) async throws -> T
         where T: SQLInsertableRecord
  {
    try await runOnDatabaseQueue { try insert(record) }
  }
}

// MARK: - Operate on arrays of objects

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLDatabaseAsyncChangeOperations {

  /**
   * Delete records from a table.
   *
   * Example:
   * ```swift
   * var donald = try await db.find(\.people, 1)!
   * var mickey = try await db.find(\.people, 2)!
   * try await db.delete([ donald, mickey ])
   * ```
   *
   * - Parameters:
   *   - records: The records to delete.
   */
  @inlinable
  func delete<S>(_ records: S) async throws
         where S: Sequence,
               S.Element: SQLDeletableRecord,
               S.Element.Schema: SQLKeyedTableSchema
  {
    try await runOnDatabaseQueue { try delete(records) }
  }

  /**
   * Update records in a table.
   *
   * Example:
   * ```swift
   * var donald = try await db.find(\.people, 1)!
   * var mickey = try await db.find(\.people, 2)!
   * donald.lastname = "Mouse"
   * mickey.age      = 110
   * try await db.update([ donald, mickey ])
   * ```
   *
   * - Parameters:
   *   - records: The records to update.
   */
  @inlinable
  func update<S>(_ records: S) async throws
         where S: Sequence,
               S.Element: SQLUpdatableRecord,
               S.Element.Schema: SQLKeyedTableSchema
  {
    try await runOnDatabaseQueue { try update(records) }
  }

  /**
   * Insert a set of records into a table.
   *
   * Example:
   * ```swift
   * let people = try await db.insert([
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
  func insert<S>(_ records: S) async throws -> [ S.Element ]
         where S: Sequence, S.Element: SQLInsertableRecord
  {
    try await runOnDatabaseQueue { try insert(records) }
  }
}
#endif // 5.5 + Concurrency
