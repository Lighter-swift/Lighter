//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3

public extension SQLDatabaseOperations {
  
  /**
   * Set a SQLite3 pragma to a specified value.
   *
   * Example:
   * ```swift
   * try db.set(pragma: "analysis_limit", to: 200)
   * ```
   *
   * More information: [SQLite PRAGMA](https://www.sqlite.org/pragma.html).
   *
   * - Parameters:
   *   - schema: Optional name of schema.
   *   - name:   The name of the pragma, check the SQLite docs for information.
   *   - value:  The value to set the pragma to.
   */
  @inlinable
  func set(schema: String? = nil, pragma name: String,
           to value: SQLiteValueType)
         throws
  {
    let sql = "PRAGMA \(name) = \(value.sqlStringValue);"
    try fetch(sql) { _, stop in stop = true }
  }
  
  /**
   * Fetch the value of a simple SQLite3 pragma.
   *
   * Example:
   * ```swift
   * let limit = try db.get(pragma: "analysis_limit", as: Int.self)
   * ```
   *
   * More information: [SQLite PRAGMA](https://www.sqlite.org/pragma.html).
   *
   * - Parameters:
   *   - schema: Optional name of schema.
   *   - name:   The name of the pragma, check the SQLite docs for information.
   * - Returns:  The value of the pragma as an Any.
   */
  @inlinable
  func get<V>(schema: String? = nil, pragma name: String, as type: V.Type)
         throws -> V
         where V: SQLiteValueType
  {
    let sql = "PRAGMA \(name);"
    var value : V?
    try fetch(sql) { statement, stop in
      value = try type.init(unsafeSQLite3StatementHandle: statement, column: 0)
      stop = true
    }
    guard let result = value else { throw SQLError(SQLITE_ERROR) }
    return result
  }
}

#if swift(>=5.5) && canImport(_Concurrency)

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLDatabaseAsyncOperations {

  /**
   * Set a SQLite3 pragma to a specified value.
   *
   * Example:
   * ```swift
   * try await db.set(pragma: "analysis_limit", to: 200)
   * ```
   *
   * More information: [SQLite PRAGMA](https://www.sqlite.org/pragma.html).
   *
   * - Parameters:
   *   - schema: Optional name of schema.
   *   - name:   The name of the pragma, check the SQLite docs for information.
   *   - value:  The value to set the pragma to.
   */
  @inlinable
  func set(schema: String? = nil, pragma name: String,
           to value: SQLiteValueType) async throws
  {
    try await runOnDatabaseQueue {
      try set(schema: schema, pragma: name, to: value)
    }
  }

  /**
   * Fetch the value of a simple SQLite3 pragma.
   *
   * Example:
   * ```swift
   * let limit = try db.get(pragma: "analysis_limit", as: Int.self)
   * ```
   *
   * More information: [SQLite PRAGMA](https://www.sqlite.org/pragma.html).
   *
   * - Parameters:
   *   - schema: Optional name of schema.
   *   - name:   The name of the pragma, check the SQLite docs for information.
   *   - type:   The type of the simple pragma value, e.g. `Int.self`.
   * - Returns:  The value of the pragma.
   */
  @inlinable
  func get<V>(schema: String? = nil, pragma name: String, as type: V.Type)
         async throws -> V
         where V: SQLiteValueType
  {
    try await runOnDatabaseQueue {
      try get(schema: schema, pragma: name, as: type)
    }
  }
}

#endif // swift(>=5.5) && canImport(_Concurrency)
