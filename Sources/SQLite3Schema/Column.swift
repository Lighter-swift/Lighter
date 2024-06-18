//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

extension Schema {
  
  /**
   * Information about the columns of a table or view.
   *
   * The information as-is returned by `PRAGMA table_info($table)`.
   */
  public struct Column: Hashable, Identifiable {

    /**
     * An enum that represents a default value set for a SQLite column.
     *
     * Can be `null`, an `integer`, a `real`, a `text` or a `blob` (the
     * possible types returned by `sqlite3_column_type`).
     */
    public enum DefaultValue: Hashable {
      
      case null
      
      // 0...8 bytes depending on the magnitude of the value
      case integer(Int64)
      
      case real(Double)
      case text(String)
      case blob([ UInt8 ])
    }

    /// The internal SQLite3 identifier of the column.
    public let id           : Int64
    /// The SQL name of the column. Can contains spaces and special characters.
    public let name         : String
    
    /// Note: SQLite database are not required to have a column type!
    public let type         : ColumnType?
    
    /// Whether the column has a `NOT NULL` constraint attached.
    public let isNotNull    : Bool
    
    /// The default value of the column, if one is set.
    public let defaultValue : DefaultValue?
    
    /// Whether the column is the / part of the primary key of a table.
    public let isPrimaryKey : Bool
    
    /**
     * Initialize a new `Column` structure.
     *
     * - Parameters:
     *   - id:           The id associated w/ the column in the database.
     *   - name:         The name of the column.
     *   - type:         The type of the column, defaults to `.text`.
     *   - isNotNull:    Whether the column has a not-null constraint.
     *   - defaultValue: The columns default value, if there is one assigned.
     *   - isPrimaryKey: Whether the column is part, or the, primary key.
     */
    @inlinable
    public init(id           : Int64,
                name         : String,
                type         : ColumnType?   = .text,
                isNotNull    : Bool          = false,
                defaultValue : DefaultValue? = nil,
                isPrimaryKey : Bool          = false)
    {
      self.id           = id
      self.name         = name
      self.type         = type
      self.isNotNull    = isNotNull
      self.defaultValue = defaultValue
      self.isPrimaryKey = isPrimaryKey
    }
  }
}

public extension Schema.Column.DefaultValue {
  
  /**
   * Returns the ``Schema/TypeAffinity`` of the column.
   *
   * In SQLite columns can store any type, even if declared otherwise.
   * E.g. you can insert a a TEXT into an INT column, and the TEXT will be
   * preserved as-is.
   *
   * Many non-SQLite types like `VARCHAR` are still detected and get a proper
   * affinity assigned (`TEXT` in this case).
   *
   * To learn more about type affinity:
   * https://www.sqlite.org/datatype3.html#type_affinity
   */
  var affinity : Schema.TypeAffinity? {
    switch self {
      case .null    : return nil
      case .integer : return .integer
      case .real    : return .real
      case .text    : return .text
      case .blob    : return .blob
    }
  }
}


// MARK: - Fetching

import SQLite3

public extension Schema.Column {

  /**
   * Fetch the column information for a table or a view.
   *
   * - Parameters:
   *   - table: The unescaped table/view name.
   *   - db:    An open SQLite3 database handle.
   * - Returns: The columns, or nil on error
   */
  static func fetch(for tableOrView: String, in db: OpaquePointer?)
                -> [ Schema.Column ]?
  {
    guard let db = db else { return [] }
    let tableOrView = tableOrView.contains("\"") // escape " with ""
      ? tableOrView.split(separator: "\"").joined(separator: "\"\"")
      : tableOrView

    let sql = "PRAGMA table_info(\"\(tableOrView)\")"
    var maybeStmt : OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &maybeStmt, nil) == SQLITE_OK,
          let stmt = maybeStmt else
    {
      // This _can_ happen, for VIEWs which miss the underlying tables.
      // I.e. the `CREATE VIEW` runs fine, but table_info fails on such.
      return nil
    }
    defer { sqlite3_finalize(stmt) }

    var columns = [ Schema.Column ]()
    while true {
      let rc = sqlite3_step(stmt)
      if      rc == SQLITE_DONE { break }
      else if rc != SQLITE_ROW  { return nil }
      
      if let fkey = Schema.Column(stmt) {
        columns.append(fkey)
      }
      else {
        assertionFailure("Could not create foreign key?!")
      }
    }
    return columns
  }
}


// MARK: - Description

extension Schema.Column: CustomStringConvertible {
  
  /// Returns a debug description for the Column.
  public var description: String {
    var ms = "<Column[\(id)]: '\(name)'"
    
    if let type = type { ms += " \(type)"     }
    if isNotNull       { ms += " NOT NULL"    }
    if isPrimaryKey    { ms += " PRIMARY KEY" }
    
    if let value = defaultValue { ms += " DEFAULT \(value)" }
    ms += ">"
    return ms
  }
}
extension Schema.ColumnType: CustomStringConvertible {
  
  /// Returns a debug description for the ColumnType.
  public var description: String {
    switch self {
      case .integer : return "INTEGER"
      case .real    : return "REAL"
      case .text    : return "TEXT"
      case .blob    : return "BLOB"
      case .any     : return "ANY"
        
      case .int                       : return "INT"
      case .boolean                   : return "BOOL"
      case .varchar(.some(let width)) : return "VARCHAR(\(width))"
      case .varchar(.none)            : return "VARCHAR"
      case .date                      : return "DATE"
      case .datetime                  : return "DATETIME"
      case .timestamp                 : return "TIMESTAMP"
      case .decimal                   : return "DECIMAL"

      case .custom(let s): return s
    }
  }
}


// MARK: - Statement Initializers

fileprivate extension Schema.Column {
  
  /**
   * Initialize a `Column` from a prepared SQLite3 statement handle that
   * was prepared w/ a `PRAGMA tableinfo` call.
   *
   * - Parameters:
   *   - pragmaTableInfoStatement: A SQLite3 prepared statement handle.
   */
  init?(_ pragmaTableInfoStatement: OpaquePointer?) {
    guard let stmt = pragmaTableInfoStatement else { return nil }

    id = sqlite3_column_int64(stmt, 0)
    
    if let s = sqlite3_column_text(stmt, 1) { // could be empty?
      name = String(cString: s)
      assert(!name.isEmpty)
    }
    else {
      assertionFailure("Missing column name?")
      return nil
    }

    if let cstr = sqlite3_column_text(stmt, 2) {
      let s = String(cString: cstr)
      type = Schema.ColumnType(rawValue: s)
    }
    else {
      type = nil
    }
    
    isNotNull    = sqlite3_column_int64(stmt, 3) != 0

    // Distinguish between an explicit NULL (which defaultValue can't store?),
    // and just NULL (which then the default fallback is)
    let defaultValue = DefaultValue(stmt, 4)
    self.defaultValue = defaultValue == .null ? nil : defaultValue
    
    isPrimaryKey = sqlite3_column_int64(stmt, 5) != 0
  }
}

fileprivate extension Schema.Column.DefaultValue {
  
  /**
   * Extract the a ``DefaultValue`` enum for the given column in the statement.
   *
   * - Parameters:
   *   - stmt: A SQLite API statement handle
   *   - iCol: The column in the result set, 0-based.
   */
  init(_ stmt: OpaquePointer?, _ iCol: Int32) {
    guard iCol >= 0 && iCol < sqlite3_column_count(stmt) else {
      assertionFailure("Column out of range: \(iCol)")
      self = .null
      return
    }
    switch sqlite3_column_type(stmt, iCol) {
      case SQLITE_NULL:
        self = .null
      
      case SQLITE_INTEGER:
        self = .integer(sqlite3_column_int64(stmt, iCol))
        
      case SQLITE_TEXT:
        if let cstr = sqlite3_column_text(stmt, iCol) {
          self = .text(String(cString: cstr))
        }
        else {
          assertionFailure("Unexpected NULL in TEXT affinity default value")
          self = .null
        }
        
      case SQLITE_FLOAT:
        self = .real(sqlite3_column_double(stmt, iCol))
        
      case SQLITE_BLOB:
        if let blob  = sqlite3_column_blob(stmt, iCol) {
          let count  = Int(sqlite3_column_bytes(stmt, iCol))
          let buffer = UnsafeRawBufferPointer(start: blob, count: count)
          self = .blob([UInt8](buffer))
        }
        else {
          assertionFailure("Unexpected NULL in BLOB affinity default value")
          self = .null
        }
      
      default:
        if let cstr = sqlite3_column_text(stmt, iCol) {
          self = .text(String(cString: cstr))
        }
        else {
          assertionFailure("Unexpected NULL in TEXT affinity default value")
          self = .null
        }
    }
  }
}

#if swift(>=5.5)
extension Schema.Column              : Sendable {}
extension Schema.Column.DefaultValue : Sendable {}
#endif
