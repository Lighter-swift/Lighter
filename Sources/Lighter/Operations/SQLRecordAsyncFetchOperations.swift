//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

// Same like `SQLRecordFetchOperations`, async/await variant if available.

#if swift(>=5.5) && canImport(_Concurrency)

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLRecordFetchOperations
                   where Ops: SQLDatabaseAsyncOperations
{

  /**
   * Asynchronously runs the given block in the ``asyncDatabaseQueue``.
   *
   * - Parameters:
   *   - block: The block to execute in the queue.
   * - Returns: The return value of the block.
   * - Throws:  Rethrows any errors the block throws.
   */
  @inlinable
  func runOnDatabaseQueue<R>(block: @escaping () throws -> R) async throws -> R
  {
    try await operations.runOnDatabaseQueue(block: block)
  }

  /**
   * Fetch records of a view/table unfiltered, unsorted.
   *
   * Example:
   * ```swift
   * let persons = await try db.fetch(\.person)
   * ```
   */
  @inlinable
  func fetch(limit: Int? = nil) async throws -> [ T ] {
    try await runOnDatabaseQueue { try fetch(limit: limit) }
  }

  /**
   * Fetch records of a view/table unfiltered, but in a sorted manner.
   *
   * Example:
   * ```swift
   * let persons = try await db.persons.fetch(orderBy: \.name)
   * let persons = try await db.persons.fetch(orderBy: \.name, .descending)
   * ```
   *
   * - Parameters:
   *   - limit:     An optional fetch limit (defaults to no limit)
   *   - column:    The column to sort the results by.
   *   - direction: The sort direction (ascending or descending)
   * - Returns:     An array of ``SQLRecord``s matching the type specified.
   */
  @inlinable
  func fetch<SC>(limit           : Int? = nil,
                 orderBy  column : KeyPath<T.Schema, SC>,
                 _     direction : SQLSortOrder = .ascending)
         async throws -> [ T ]
         where SC: SQLColumn, SC.T == T
  {
    try await runOnDatabaseQueue {
      try fetch(limit: limit, orderBy: column, direction)
    }
  }

  /**
   * Fetch filtered records of a view/table in a sorted manner.
   *
   * Example:
   * ```swift
   * let persons = try await db.persons.fetch(orderBy: \.name) {
   *   $0.name.hasPrefix("Du")
   * }
   * ```
   *
   * - Parameters:
   *   - limit:     An optional fetch limit (defaults to no limit)
   *   - column:    The column to sort the results by.
   *   - direction: The sort direction (ascending or descending)
   *   - predicate: A closure returning a filter predicate, receives the record
   *                schema as the first argument (e.g. `$0.personId == 10`).
   * - Returns:     An array of ``SQLRecord``s matching the type specified.
   */
  @inlinable
  func fetch<SC, P>(limit           : Int? = nil,
                    orderBy  column : KeyPath<T.Schema, SC>,
                    _     direction : SQLSortOrder = .ascending,
                    where predicate : @escaping ( T.Schema ) -> P)
         async throws -> [ T ]
         where SC: SQLColumn, SC.T == T, P: SQLPredicate
  {
    try await runOnDatabaseQueue {
      try fetch(limit: limit, orderBy: column, direction, where: predicate)
    }
  }

  /**
   * Fetch filtered records of a view/table in a sorted manner.
   *
   * Example:
   * ```swift
   * let persons = try await db.persons.fetch(orderBy: \.lastname,  .ascending,
   *                                                   \.firstname, .descending)
   * {
   *   $0.name.hasPrefix("Du")
   * }
   * ```
   *
   * - Parameters:
   *   - limit:      An optional fetch limit (defaults to no limit)
   *   - column1:    The first column to sort the results by.
   *   - direction1: The first sort direction (ascending or descending)
   *   - column2:    The second column to sort the results by.
   *   - direction2: The second sort direction (ascending or descending)
   *   - predicate:  A closure returning a filter predicate, receives the record
   *                 schema as the first argument (e.g. `$0.personId == 10`).
   * - Returns:      An array of ``SQLRecord``s matching the type specified.
   */
  @inlinable
  func fetch<SC1, SC2, P>(limit            : Int? = nil,
                          orderBy  column1 : KeyPath<T.Schema, SC1>,
                          _     direction1 : SQLSortOrder, // can't be optional!
                          _        column2 : KeyPath<T.Schema, SC2>,
                          _     direction2 : SQLSortOrder = .ascending,
                          where  predicate : @escaping ( T.Schema ) -> P)
         async throws -> [ T ]
         where SC1: SQLColumn, SC1.T == T, SC2: SQLColumn, SC2.T == T,
               P: SQLPredicate
  {
    try await runOnDatabaseQueue {
      try fetch(limit: limit,
                orderBy: column1, direction1, column2, direction2,
                where: predicate)
    }
  }
  
  /**
   * Fetch filtered records of a view/table w/o any sorting.
   *
   * Example:
   * ```swift
   * let persons = try await db.persons.fetch { $0.personId == 2 }
   * ```
   *
   * - Parameters:
   *   - limit: An optional fetch limit (defaults to no limit)
   *   - where: A closure that returns a ``SQLPredicate``, i.e. the part of
   *            the SQL `WHERE` statement.
   * - Returns: An array of ``SQLRecord``s matching the type specified.
   */
  @inlinable
  func fetch<P>(limit           : Int? = nil,
                where predicate : @escaping ( T.Schema ) -> P)
         async throws -> [ T ]
         where P: SQLPredicate
  {
    try await runOnDatabaseQueue { try fetch(limit: limit, where: predicate) }
  }
  
  
  // MARK: - Find Operations
  
  /**
   * Fetch a single record where a specific column has a certain value.
   *
   * Example:
   * ```
   * let person = try await db.persons.find(by: \.personId, 2)
   * ```
   * 
   * - Parameters:
   *   - matchColumn: The column to check, e.g. `\.personId`.
   *   - value:       The value the column should have, e.g. `10`.
   * - Returns:       A ``SQLRecord`` matching the type specified, if found.
   */
  @inlinable
  func find<C>(by matchColumn: KeyPath<T.Schema, C>, _ value: C.Value)
         async throws -> T?
         where C: SQLColumn, T == C.T
  {
    try await runOnDatabaseQueue { try find(by: matchColumn, value) }
  }
  
  /**
   * Fetch a single record with the specified primary key.
   *
   * Example:
   * ```swift
   * let person = try db.persons.find(2)
   * ```
   * 
   * - Parameters:
   *   - primaryKey: The value of the primary key, e.g. `2`.
   * - Returns:      A ``SQLRecord`` matching the type specified, if found.
   */
  @inlinable
  func find(_ primaryKey: T.Schema.PrimaryKeyColumn.Value)
         async throws -> T?
         where T: SQLRecord, T.Schema: SQLKeyedTableSchema
  {
    try await runOnDatabaseQueue { try find(primaryKey) }
  }
  
  
  // MARK: - Fetch Counts

  /**
   * Fetch the number of all records in a table.
   *
   * Example:
   * ```swift
   * let persons = try await db.persons.fetchCount()
   * ```
   *
   * - Returns: The number of all records in the table.
   */
  @inlinable
  func fetchCount() async throws -> Int {
    try await runOnDatabaseQueue { try fetchCount() }
  }

  /**
   * Fetch the number of records stored in a table, qualified by a predicate.
   *
   * Example:
   * ```swift
   * let persons = try wait db.persons.fetchCount { $0.personId == 2 }
   * ```
   *
   * - Parameters:
   *   - where: A closure that returns a ``SQLPredicate``, i.e. the part of
   *            the SQL `WHERE` statement.
   * - Returns: The number of records matching the predicate.
   */
  @inlinable
  func fetchCount<P>(where predicate: @escaping ( T.Schema ) -> P)
         async throws -> Int
         where P: SQLPredicate
  {
    try await runOnDatabaseQueue { try fetchCount(where: predicate) }
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLRecordFetchOperations
                   where Ops: SQLDatabaseAsyncOperations
{
  // MARK: - Destination Multi Fetch

  /**
   * Fetch the records associated with the foreign keys in the destinations.
   *
   * ```swift
   * let personsToAddresses : [ Person : [ Address ] ]
   *     = try await db.address.fetch(for: \.personId, in: persons)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to the ``SQLForeignKeyColumn`` (e.g. `\.personId`)
   *   - destinationRecords: A sequence of records matching the destination of
   *                 the foreign key (e.g. `[ donald, dagobert ]`.
   *   - omitEmpty:  Whether to omit destination records that have no values
   *                 in the foreign key table.
   *   - limit:      An optional limit on the results.
   */
  @inlinable
  func fetch<FK, S>(for        foreignKey : KeyPath<T.Schema, FK>,
                    in destinationRecords : S,
                    omitEmpty             : Bool = false,
                    limit                 : Int? = nil)
         async throws -> [ FK.Destination : [ T ] ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value,
               S: Sequence, S.Element == FK.Destination
  {
    try await runOnDatabaseQueue {
      try fetch(for: foreignKey, in: destinationRecords,
                omitEmpty: omitEmpty, limit: limit)
    }
  }
  
  /**
   * Fetch the records associated with the foreign keys.
   *
   * ```swift
   * let personIDsToAddresses : [ Int : [ Address ] ]
   *     = try await db.address.fetch(for: \.personId, in: personIDs)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to the ``SQLForeignKeyColumn`` (e.g. `\.personId`)
   *   - destinationsColumns: A sequence of records matching the destination of
   *                 the foreign key (e.g. `[ donald, dagobert ]`.
   *   - omitEmpty:  Whether to omit destination records that have no values
   *                 in the foreign key table.
   *   - limit:      An optional limit on the results.
   */
  @inlinable
  func fetch<FK, S>(for foreignKey: KeyPath<T.Schema, FK>,
                    in destinationsColumns: S,
                    omitEmpty : Bool = false,
                    limit     : Int? = nil)
         async throws -> [ FK.DestinationColumn.Value : [ T ] ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value,
               S: Sequence, S.Element == FK.DestinationColumn.Value
  {
    try await runOnDatabaseQueue {
      try fetch(for: foreignKey, in: destinationsColumns,
                omitEmpty: omitEmpty, limit: limit)
    }
  }


  // MARK: - Destination Fetch
  
  /**
   * Fetch the records associated with the foreign key in the destination.
   *
   * ```swift
   * let addresses = try db.address.fetch(for: \.personId, in: person)
   * ```
   */
  @inlinable
  func fetch<FK>(for foreignKey: KeyPath<T.Schema, FK>,
                 in destinationRecord: FK.Destination,
                 limit: Int? = nil)
         async throws -> [ T ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value
  {
    try await runOnDatabaseQueue {
      try fetch(for: foreignKey, in: destinationRecord, limit: limit)
    }
  }
  
  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses = try await db.address.fetch(for: \.personId, in: person)
   * ```
   */
  @inlinable
  func fetch<FK>(for foreignKey: KeyPath<T.Schema, FK>,
                 in destinationRecord: FK.Destination,
                 limit: Int? = nil)
         async throws -> [ T ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value?
  {
    try await runOnDatabaseQueue {
      try fetch(for: foreignKey, in: destinationRecord, limit: limit)
    }
  }

  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses = try await db.address.fetch(for: \.personId, in: person)
   * ```
   */
  @inlinable
  func fetch<FK>(for foreignKey: KeyPath<T.Schema, FK>,
                 in destinationRecord: FK.Destination,
                 limit: Int? = nil)
         async throws -> [ T ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value? == FK.DestinationColumn.Value
  {
    try await runOnDatabaseQueue {
      try fetch(for: foreignKey, in: destinationRecord, limit: limit)
    }
  }
  

  // MARK: - Source Find
  
  /**
   * Locate the record connected to a specific foreign key.
   *
   * Example:
   * ```swift
   * let person = try await db.address.findTarget(for: \.personId, in: address)
   * ```
   */
  @inlinable
  func findTarget<FK>(for foreignKey: KeyPath<T.Schema, FK>, in record: T)
         async throws -> FK.Destination?
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value
  {
    try await runOnDatabaseQueue { try findTarget(for: foreignKey, in: record) }
  }
  
  /**
   * Locate the record connected to a specific foreign key.
   *
   * Example:
   * ```swift
   * let person = try await db.address.findTarget(for: \.personId, in: address)
   * ```
   */
  @inlinable
  func findTarget<FK>(for foreignKey: KeyPath<T.Schema, FK>, in record: T)
         async throws -> FK.Destination?
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == Optional<FK.DestinationColumn.Value>
  {
    try await runOnDatabaseQueue { try findTarget(for: foreignKey, in: record) }
  }
  
  /**
   * Locate the record connected to a specific foreign key.
   *
   * Example:
   * ```swift
   * let person = try await db.address.findTarget(for: \.personId, in: address)
   * ```
   */
  @inlinable
  func findTarget<FK>(for foreignKey: KeyPath<T.Schema, FK>, in record: T)
         async throws -> FK.Destination?
         where FK: SQLForeignKeyColumn, FK.T == T,
               Optional<FK.Value> == FK.DestinationColumn.Value
  {
    try await runOnDatabaseQueue { try findTarget(for: foreignKey, in: record) }
  }
}

#endif // 5.5 + Concurrency
