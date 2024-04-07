//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

#if canImport(Foundation)
  import Foundation
#endif

/**
 * A helper struct to build SQL queries.
 */
public struct SQLBuilder<Base: SQLRecord>: Sendable {
  // Called `SQLExpression` in ZeeQL/EOF
  
  @usableFromInline var sql      = ""
  @usableFromInline var bindings = [ SQLiteValueType ]()
  
  @usableFromInline
  var quotedAndEscapedColumns : [ String ]?
  var sortFragments           : [ String ]?
  
  var aliases       : [ ObjectIdentifier : ( alias: String, table: String ) ]?
  var aliasCounter  = 0
  
  @usableFromInline
  var isSQLEmptyOrTrue : Bool { sql.isEmpty || sql == SQLTruePredicate.sql }
  
  @inlinable
  public init() {}
  
  
  // MARK: - Appending to the raw SQL
  
  /// Raw append to the SQL string in this builder
  mutating func append(_ sql: String) {
    self.sql += sql
  }
  
  /// Escaped append to the SQL string in this builder
  mutating func appendEscaped(_ unescaped: String, escape: Character = "'") {
    append(unescaped
      .replacingOccurrences(of: "\(escape)", with: "\(escape)\(escape)"))
  }
  
  /// Escape the `id` (e.g. a column or table name) and surround it by quotes.
  @inlinable
  public func escapeAndQuoteIdentifier(_ id: String) -> String {
    guard id.contains("\"") else { return "\"\(id)\"" }

    #if canImport(Foundation)
      return "\"\(id.replacingOccurrences(of: "\"", with: "\"\""))\""
    #else
      if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
        // Tie to Swift version on Linux?
        return id.replacing("\"", with: "\"\"")
      }
      else {
        fatalError("Can't escape identifier w/o Foundation.")
      }
    #endif
  }

  
  // MARK: - Statement Generators
  
  @usableFromInline
  @discardableResult
  mutating func generateUpdate<P: SQLPredicate>(
    _ table         : String,
    set values      : SQLiteValueType...,
    where predicate : P
  ) -> String
  {
    assert(quotedAndEscapedColumns != nil)
    append("UPDATE \(escapeAndQuoteIdentifier(table)) SET ")
    
    var isFirst = true
    for ( column, value ) in zip(quotedAndEscapedColumns ?? [], values) {
      if isFirst { isFirst = false } else { append(", ") }
      append(column)
      append(" = ")
      append(sqlString(for: value))
    }
    append(" WHERE ")
    predicate.generateSQL(into: &self)
    return sql
  }
  
  @discardableResult
  @usableFromInline
  mutating func generateDelete<P: SQLPredicate>(from table: String,
                                                where predicate: P)
                -> String
  {
    append("DELETE FROM \(escapeAndQuoteIdentifier(table)) WHERE ")
    predicate.generateSQL(into: &self)
    return sql
  }
  
  @discardableResult
  @usableFromInline
  mutating func generateInsert(into table : String, values: SQLiteValueType...)
                -> String
  {
    assert(quotedAndEscapedColumns != nil)
    append("INSERT INTO \(escapeAndQuoteIdentifier(table)) ( ")
    var isFirst = true
    for columnName in quotedAndEscapedColumns ?? [] {
      if isFirst { isFirst = false } else { append(", ") }
      append(columnName)
    }
    append(" ) VALUES ( ")
    isFirst = true
    for value in values {
      if isFirst { isFirst = false } else { append(", ") }
      append(sqlString(for: value))
    }
    append(" )")
    return sql
  }

  /**
   * - Parameters:
   *   - sortFragments: Set of raw SQL parameters, if present ORDER BY is
   *                    generated
   *   - limit:         An optional limit, can be nil for not LIMIT
   *   - predicate:     The predicate for a WHERE.
   */
  @discardableResult
  @usableFromInline
  mutating func generateSelect<P: SQLPredicate>(limit: Int?, predicate: P)
                -> String
  {
    var sql : String
    if let columns = quotedAndEscapedColumns, !columns.isEmpty {
      sql  = "SELECT "
      sql += columns.joined(separator: ", ")
      sql += " FROM "
      sql += escapeAndQuoteIdentifier(Base.Schema.externalName)
    }
    else {
      sql = Base.Schema.select
    }

    predicate.generateSQL(into: &self)
    if !isSQLEmptyOrTrue {
      sql += " WHERE "
      sql += self.sql
    }
    
    if let sortFragments = sortFragments, !sortFragments.isEmpty {
      sql += " ORDER BY \(sortFragments.joined(separator: ", "))"
    }
    
    if let limit = limit {
      // possible, but likely a bug :-)
      assert(limit >= 0 && limit < 100_000_000)
      sql += " LIMIT \(limit)"
    }
    
    self.sql = sql
    return sql
  }
  
  /**
   * - Parameters:
   *   - predicate: The predicate for a WHERE.
   */
  @discardableResult
  @usableFromInline
  mutating func generateCount<P: SQLPredicate>(predicate: P) -> String {
    var sql  = "SELECT COUNT(*) FROM "
    sql += escapeAndQuoteIdentifier(Base.Schema.externalName)

    predicate.generateSQL(into: &self)
    if !isSQLEmptyOrTrue {
      sql += " WHERE "
      sql += self.sql
    }
    self.sql = sql
    return sql
  }

  
  // MARK: - Adding Columns Fragments
  
  @inlinable
  public mutating func addColumn<C: SQLColumn>(_ column: C) where C.T == Base {
    let sql = sqlString(for: column)
    if quotedAndEscapedColumns?.append(sql) == nil {
      quotedAndEscapedColumns = [ sql ]
    }
  }
  @inlinable
  public mutating func addColumn<C: SQLColumn>(_ column: KeyPath<C.T.Schema, C>)
                          where C.T == Base
  {
    addColumn(C.T.schema[keyPath: column])
  }

  @usableFromInline
  mutating func addSort<C: SQLColumn>(_ column: C, _ direction: SQLSortOrder)
                  where C.T == Base
  {
    let sql = direction == .ascending
            ?  sqlString(for: column)
            : (sqlString(for: column) + " DESC")
    if sortFragments?.append(sql) == nil { sortFragments = [ sql ] }
  }
  @usableFromInline
  mutating func addSort<C: SQLColumn>(_ column: KeyPath<C.T.Schema, C>,
                                      _ direction: SQLSortOrder)
                  where C.T == Base
  {
    addSort(C.T.schema[keyPath: column], direction)
  }

  // This returns aliases by OID, which is not quite correct as there can be
  // self-joins. But well, keep it simple.
  @usableFromInline
  mutating func alias<C: SQLColumn>(for column: C) -> String {
    let oid = ObjectIdentifier(C.T.self)
    if let alias = aliases?[oid] { return alias.alias }
    if aliases == nil { aliases = [:] }
    aliasCounter += 1
    let alias = "T\(aliasCounter)"
    aliases?[oid] = ( alias, column.externalName )
    return alias
  }
  
  
  // MARK: - Column References

  /// Returns and escaped and quoted SQL string for the column.
  @inlinable
  public func sqlString<C>(for column: C) -> String
                where C: SQLColumn, C.T == Base
  {
    escapeAndQuoteIdentifier(column.externalName)
  }

  /// Returns and escaped and quoted SQL string for the column.
  @inlinable
  public mutating func sqlString<C: SQLColumn>(for column: C) -> String {
    let oid = ObjectIdentifier(C.T.self)
    let ext = escapeAndQuoteIdentifier(column.externalName)
    guard oid != ObjectIdentifier(Base.self) else { return ext }
    return "\(alias(for: column)).\(ext)"
  }
  
  /// Returns the external name for the column addressed by the keypath
  @inlinable
  public func sqlString<C: SQLColumn>(for column: KeyPath<C.T.Schema, C>)
              -> String where C.T == Base
  {
    return sqlString(for: C.T.schema[keyPath: column])
  }

  /// Returns the external name for the column addressed by the keypath
  @inlinable
  public mutating func sqlString<C: SQLColumn>(for column: KeyPath<C.T.Schema, C>)
                       -> String
  {
    return sqlString(for: C.T.schema[keyPath: column])
  }

  
  // MARK: - Column Values
  
  /// Returns the SQL literal representation for the value.
  func sqlLiteral<V: SQLiteValueType>(for value: V?) -> String {
    value.sqlStringValue
  }
  /// Returns the SQL literal representation for the value.
  func sqlLiteral(for value: SQLiteValueType?) -> String {
    value?.sqlStringValue ?? "NULL"
  }

  /// If the value requires a binding (texts, blobs), this returns the parameter
  /// placeholder (`?`) and registers the value with the builder
  /// (for later binding).
  /// For basic values this returns the SQL literal representation.
  mutating func sqlString<V: SQLiteValueType>(for value: V?) -> String {
    guard let value = value else { return "NULL" }
    if value.requiresSQLBinding {
      bindings.append(value)
      return "?"
    }
    else {
      return value.sqlStringValue
    }
  }
  
  /// If the value requires a binding (texts, blobs), this returns the parameter
  /// placeholder (`?`) and registers the value with the builder
  /// (for later binding).
  /// For basic values this returns the SQL literal representation.
  mutating func sqlString(for value: SQLiteValueType) -> String {
    if value.requiresSQLBinding {
      bindings.append(value)
      return "?"
    }
    else {
      return value.sqlStringValue
    }
  }
}
