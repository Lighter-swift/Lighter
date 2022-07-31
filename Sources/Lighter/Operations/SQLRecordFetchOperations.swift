//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import func SQLite3.sqlite3_column_int64

/**
 * Runs fetch queries against a certain SQL table/view.
 *
 * Values of this kind are returned by the dynamic member lookup function of
 * ``SQLDatabase``, e.g. `db.people` or `tx.people`.
 * It then provides the applicable functions for the ``SQLRecord`` bound to the
 * property.
 */
public struct SQLRecordFetchOperations<Ops, T: SQLRecord>
                where Ops: SQLDatabaseOperations
{
  
  /// Matches the ``SQLDatabaseOperations/RecordTypes``.
  @inlinable
  public static var recordTypes : Ops.RecordTypes { Ops.recordTypes }

  /// The ``SQLConnectionHandler`` use for the specific
  /// ``SQLDatabaseOperations`` (either database or transaction specific).
  @inlinable
  public var connectionHandler : SQLConnectionHandler {
    operations.connectionHandler
  }
  
  /// The database or transaction object associated with the fetch operations.
  public let operations : Ops
  
  /**
   * Bind new ``SQLRecordFetchOperations`` to the passed in ``SQLDatabase``
   * or ``SQLTransaction``.
   *
   * - Parameters:
   *   - ops: The ``SQLDatabaseOperations`` object to use for queries.
   */
  @inlinable
  public init(_ operations: Ops) { self.operations = operations }
}


public extension SQLDatabaseFetchOperations { // this is what DB/TX conform to
  
  /**
   * Lookup the `SQLRecordFetchOperations` for a certain table using
   * `@dynamicMemberLookup`.
   *
   * Example:
   * ```swift
   * let queryRunner = db.people
   * let queryRunner = tx.people
   * ```
   * Will lookup a `SQLRecordFetchOperations` wrapper for the "persons" table.
   *
   * Note: The protocol itself can't implement `@dynamicMemberLookup`,
   *       that has to be done in the concrete type.
   */
  @inlinable
  subscript<T: SQLRecord>(dynamicMember keyPath: KeyPath<RecordTypes, T.Type>)
    -> SQLRecordFetchOperations<Self, T>
  {
    SQLRecordFetchOperations<Self, T>(self)
  }
}


// MARK: - Fetch Operations

public extension SQLRecordFetchOperations { // the primary fetch op
  
  /**
   * Fetch records of a certain type using a custom query.
   *
   * If no column indices are given, the index positions in the result set are
   * looked up by column name.
   * If the resultset doesn't contain required values, the default values will
   * be used. I.e. this can still be used to fetch records which are derived
   * from fragments.
   *
   * Example:
   * ```
   * let people = try db.people.fetch(verbatim: "SELECT * FROM person LIMIT 3")
   * ```
   *
   * - Parameters:
   *   - from:     A KeyPath leading to a ``SQLRecord`` type, e.g. `\.person`
   *   - sql:      The raw SQL to fetch the records.
   *   - bindings: The values for parameter bindings in the SQL.
   *   - indices:  Optional column indices, if the positions of parameters are
   *               known.
   * - Returns: An array of ``SQLRecord``s matching the type specified.
   */
  @inlinable
  func fetch(verbatim sql: String, bindings: [ SQLiteValueType ]? = nil,
             indices: T.Schema.PropertyIndices? = nil) throws -> [ T ]
  {
    var records = [ T ]()
    
    var indices = indices
    try operations.fetch(sql, bindings) { stmt, _ in
      if indices == nil { indices = T.Schema.lookupColumnIndices(in: stmt) }
      let record = T(stmt, indices: indices)
      records.append(record)
    }
    return records
  }
}

public extension SQLRecordFetchOperations { // sync fetches
  
  /**
   * Fetch records of a view/table unfiltered, unsorted.
   *
   * Example:
   * ```
   * let people = try db.people.fetch()
   * ```
   *
   * - Parameters:
   *   - limit: An optional fetch limit (defaults to no limit)
   * - Returns: An array of ``SQLRecord``s matching the type specified.
   */
  @inlinable
  func fetch(limit: Int? = nil) throws -> [ T ] {
    try fetch(limit: limit, where: { _ in SQLTruePredicate.shared })
  }
  
  /**
   * Fetch filtered records of a view/table w/o any sorting.
   *
   * Example:
   * ```
   * let people = try db.people.fetch { $0.personId == 2 }
   * ```
   *
   * - Parameters:
   *   - limit: An optional fetch limit (defaults to no limit)
   *   - where: A closure that returns a ``SQLPredicate``, i.e. the part of
   *            the SQL `WHERE` statement.
   * - Returns: An array of ``SQLRecord``s matching the type specified.
   */
  func fetch<P>(limit: Int? = nil, where predicate: ( T.Schema ) -> P)
         throws -> [ T ]
         where P: SQLPredicate
  {
    // Note: The predicate is a closure, because we somehow have to pass in the
    //       references to the table columns in a convienent way.
    // the table can have the select set pre-prepared
    var builder = SQLBuilder<T>()
    builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try fetch(verbatim: builder.sql, bindings: builder.bindings,
                     indices: T.Schema.selectColumnIndices)
  }
  
  /**
   * Fetch records of a view/table unfiltered, but in a sorted manner.
   *
   * Example:
   * ```
   * let people = try db.people.fetch(orderBy: \.name)
   * let people = try db.people.fetch(orderBy: \.name, .descending)
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
         throws -> [ T ]
         where SC: SQLColumn, SC.T == T
  {
    try fetch(limit: limit, orderBy: column, direction,
              where: { _ in SQLTruePredicate.shared })
  }
  
  /**
   * Fetch filtered records of a view/table in a sorted manner.
   *
   * Example:
   * ```
   * let people = try db.people.fetch(orderBy: \.name) {
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
  func fetch<SC, P>(limit           : Int? = nil,
                    orderBy  column : KeyPath<T.Schema, SC>,
                    _     direction : SQLSortOrder = .ascending,
                    where predicate : ( T.Schema ) -> P)
         throws -> [ T ]
         where SC: SQLColumn, SC.T == T, P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addSort(column, direction)
    builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try fetch(verbatim: builder.sql, bindings: builder.bindings,
                     indices: T.Schema.selectColumnIndices)
  }
  
  /**
   * Fetch filtered records of a view/table in a sorted manner.
   *
   * Example:
   * ```
   * let persons = try db.fetch(\.people, orderBy: \.lastname,  .ascending,
   *                                               \.firstname, .descending)
   * {
   *   $0.name.hasPrefix("Du")
   * }
   * ```
   *
   * - Parameters:
   *   - from:       A KeyPath leading to a ``SQLRecord`` type, e.g. `\.person`
   *   - limit:      An optional fetch limit (defaults to no limit)
   *   - column1:    The first column to sort the results by.
   *   - direction1: The first sort direction (ascending or descending)
   *   - column2:    The second column to sort the results by.
   *   - direction2: The second sort direction (ascending or descending)
   *   - predicate:  A closure returning a filter predicate, receives the record
   *                 schema as the first argument (e.g. `$0.personId == 10`).
   * - Returns:      An array of ``SQLRecord``s matching the type specified.
   */
  func fetch<SC1, SC2, P>(limit            : Int? = nil,
                          orderBy  column1 : KeyPath<T.Schema, SC1>,
                          _     direction1 : SQLSortOrder, // can't be optional!
                          _        column2 : KeyPath<T.Schema, SC2>,
                          _     direction2 : SQLSortOrder = .ascending,
                          where predicate : ( T.Schema ) -> P)
         throws -> [ T ]
         where SC1: SQLColumn, SC1.T == T, SC2: SQLColumn, SC2.T == T,
               P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addSort(column1, direction1)
    builder.addSort(column2, direction2)
    builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try fetch(verbatim: builder.sql, bindings: builder.bindings,
                     indices: T.Schema.selectColumnIndices)
  }
  
  /**
   * Fetch records of a certain type using a custom query.
   *
   * If the resultset doesn't contain required values, the default values will
   * be used. I.e. this can still be used to fetch records which are derived
   * from fragments.
   *
   * Example:
   * ```swift
   * let people = try db.people.fetch(sql:
   *   "SELECT * FROM person WHERE name = \(name)"
   * )
   * ```
   *
   * - Parameters:
   *   - from:  A KeyPath leading to a ``SQLRecord`` type, e.g. `\.person`
   *   - sql:   A SQL interpolation representing the query
   * - Returns: An array of ``SQLRecord``s matching the type specified.
   */
  @inlinable
  func fetch(sql: SQLExpression) throws -> [ T ] {
    var builder = SQLBuilder<T>()
    sql.generateSQL(into: &builder)
    return try fetch(verbatim: builder.sql, bindings: builder.bindings,
                     indices: nil)
  }
  
}

// MARK: - Find individual records

public extension SQLRecordFetchOperations where T.Schema: SQLKeyedTableSchema {
  
  /**
   * Fetch a single record with the specified primary key.
   *
   * Example:
   * ```
   * let person = try db.people.find(2)
   * ```
   *
   * - Parameters:
   *   - primaryKey: The value of the primary key, e.g. `2`.
   * - Returns:      A ``SQLRecord`` matching the type specified, if found.
   */
  @inlinable
  func find(_ primaryKey : T.Schema.PrimaryKeyColumn.Value) throws -> T? {
    (try fetch(limit: 1) { _ in T.Schema.primaryKeyColumn == primaryKey }).first
  }
}

public extension SQLRecordFetchOperations { // sync finds
  
  /**
   * Fetch a single record where a specific column has a certain value.
   *
   * Example:
   * ```
   * let person = try db.people.find(by: \.id, 2)
   * ```
   *
   * - Parameters:
   *   - matchColumn: The column to check, e.g. `\.personId`.
   *   - value:       The value the column should have, e.g. `10`.
   * - Returns:       A ``SQLRecord`` matching the type specified, if found.
   */
  @inlinable
  func find<C>(by matchColumn : KeyPath<T.Schema, C>,
               _        value : C.Value) throws -> T?
  where C: SQLColumn, T == C.T
  {
    (try fetch(limit: 1) { $0[keyPath: matchColumn] == value }).first
  }
}


// MARK: - Fetch Counts

public extension SQLRecordFetchOperations { // sync counts

  /**
   * Fetch the number of all records in a table.
   *
   * Example:
   * ```
   * let people = try db.people.fetchCount()
   * ```
   *
   * - Returns: The number of all records in the table.
   */
  @inlinable
  func fetchCount() throws -> Int {
    try fetchCount { _ in SQLTruePredicate.shared }
  }

  /**
   * Fetch the number of records stored in a table, qualified by a predicate.
   *
   * Example:
   * ```
   * let people = try db.people.fetchCount() { $0.personId == 2 }
   * ```
   *
   * - Parameters:
   *   - where: A closure that returns a ``SQLPredicate``, i.e. the part of
   *            the SQL `WHERE` statement.
   * - Returns: The number of records matching the predicate.
   */
  @inlinable
  func fetchCount<P>(where predicate: ( T.Schema ) -> P)
         throws -> Int
         where P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.generateCount(predicate: predicate(T.schema))

    var count : Int?
    try operations.fetch(builder.sql, builder.bindings) { stmt, stop in
      count = Int(sqlite3_column_int64(stmt, 0))
      stop = true
    }
    assert(count != nil, "Could not fetch count?!")
    return count ?? 0
  }
}
