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
   */
  @inlinable
  @discardableResult
  func insert<T>(_ record: T) async throws -> T
         where T: SQLInsertableRecord
  {
    try await runOnDatabaseQueue { try insert(record) }
  }
}

#endif // 5.5 + Concurrency
