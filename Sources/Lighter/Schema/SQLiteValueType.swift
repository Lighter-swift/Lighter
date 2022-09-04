//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3
#if canImport(Foundation)
import struct Foundation.URL
import struct Foundation.Date
import struct Foundation.TimeInterval
import class  Foundation.DateFormatter
import struct Foundation.Data
import struct Foundation.Decimal
import func   Foundation.NSDecimalString
import struct Foundation.Locale
import struct Foundation.UUID
#endif

/**
 * A value that can be used in SQLite columns.
 *
 * The base types supported by SQLite3 are:
 * - `Int`       (SQL `INTEGER`)
 * - `Double`    (SQL `REAL`)
 * - `String`    (SQL `TEXT`)
 * - `[ UInt8 ]` (SQL `BLOB`)
 *
 * In addition Lighter has builtin support for a set of common Foundation types:
 * - `URL`     (mapped to the String representation of the `URL`)
 * - `Data`    (as an alternative to `[ UInt8 ]` for `BLOB` columns)
 * - `UUID`    (can be mapped to either a String UUID or a 16-byte BLOB)
 * - `Date`    (either as a String using a formatter, or as a utime stamp)
 * - `Decimal` (make sure you understand what `Decimal` is actually good for)
 *
 * An `Optional` can be used for optional values (e.g. `String?` for
 * `TEXT NULL`).
 *
 * Note: `SQLiteValueType`s are usually `Hashable`, making record types
 *       Hashable too!
 */
public protocol SQLiteValueType {
  
  /**
   * Initialize a SQLite value from a column in the given SQLite3 prepared
   * statement handle.
   *
   * The implementation matches the behaviour of SQLite3 `sqlite3_column_xyz`
   * functions, i.e. if the column index is invalid, the behaviour is undefined.
   * And it the value doesn't match the expectation, a very forgiving type
   * coercion is done.
   */
  init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32) throws
  
  /**
   * Initialize a SQLite value from a value handle as used in SQLite3 custom
   * functions.
   *
   * The implementation matches the behaviour of SQLite3 `sqlite3_value_xyz`
   * And it the value doesn't match the expectation, a very forgiving type
   * coercion is done.
   */
  init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws
  
  // TBD: API wise not ideal as we don't own a type here (i.e. could conflict)
  // Can we tied them to a different type, eg an Entity?
  
  /// Returns the literal SQL string for the given data type.
  var sqlStringValue     : String { get }
  /// Returns true if the value prefers to be "bound" (e.g. texts and blobs).
  var requiresSQLBinding : Bool   { get }
  
  /**
   * Bind the value to the passed in SQLite3 prepared statement to the given
   * index and call a closure.
   *
   * This is used to bind values w/o copying them, i.e. for maximum performance.
   * The binding is only valid within the `execute` closure (i.e. to bind
   * multiple values, they need to nest/recurse).
   * 
   * - Parameters:
   *   - statement: A SQLite3 statement handle.
   *   - index:     The parameter index in the statement, starts at 1.
   *   - execute:   A closure that is executed while the value is bound.
   *                Note: The binding is only valid for this closure!
   */
  func bind(unsafeSQLite3StatementHandle statement: OpaquePointer!,
            index: Int32, then execute: () -> Void)
}

/**
 * This extension allows one to use `RawRepresentable`s that have a
 * `SQLiteValueType` as their raw value, to be `SQLiteValueType`s themselves.
 *
 * Example:
 * ```swift
 * enum BodyTypes: String, SQLiteValueType {
 *   case planet, moon
 * }
 * ```
 */
extension RawRepresentable where Self.RawValue: SQLiteValueType {

  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
           throws
  {
    self.init(rawValue:
      try RawValue(unsafeSQLite3StatementHandle: stmt, column: column)
    )! // Hm, not optimal
  }

  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    self.init(rawValue:
      try RawValue(unsafeSQLite3ValueHandle: value)
    )! // Hm, not optimal
  }
  
  @inlinable public var sqlStringValue     : String { rawValue.sqlStringValue }
  @inlinable public var requiresSQLBinding : Bool {
    rawValue.requiresSQLBinding
  }

  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    rawValue
      .bind(unsafeSQLite3StatementHandle: stmt, index: index, then: execute)
  }
}

extension Int : SQLiteValueType {
  
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
           throws
  {
    self = Int(sqlite3_column_int64(stmt, column))
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    self = Int(sqlite3_value_int64(value))
  }

  @inlinable public var sqlStringValue     : String { String(self) }
  @inlinable public var requiresSQLBinding : Bool   { false        }

  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    sqlite3_bind_int64(stmt, index, Int64(self))
    execute()
  }
}

extension Double : SQLiteValueType {
  
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
           throws
  {
    self = sqlite3_column_double(stmt, column)
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    self = sqlite3_value_double(value)
  }

  @inlinable public var sqlStringValue     : String { String(self) } // TBD!
  @inlinable public var requiresSQLBinding : Bool   { false        }

  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    sqlite3_bind_double(stmt, index, self)
    execute()
  }
}

// This isn't exported towards Swift by the SQLite3 module.
@usableFromInline let SQLITE_STATIC : sqlite3_destructor_type? = nil

extension String : SQLiteValueType {
  
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
  throws
  {
    if let cstr = sqlite3_column_text(stmt, column) { self.init(cString: cstr) }
    else                                            { self = "" }
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    if let cstr = sqlite3_value_text(value) { self.init(cString: cstr) }
    else                                    { self = "" }
  }

  @inlinable public var sqlStringValue : String {
    return contains("'")
    ? self.replacingOccurrences(of: "'", with: "''")
    : self
  }
  @inlinable public var requiresSQLBinding : Bool { true }

  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    withCString { cstr in
      sqlite3_bind_text(stmt, index, cstr, -1, SQLITE_STATIC)
      execute()
    }
  }
}
extension Substring : SQLiteValueType {
  
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
  throws
  {
    self = try String(unsafeSQLite3StatementHandle: stmt, column: column)[...]
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    self = try String(unsafeSQLite3ValueHandle: value)[...]
  }

  @inlinable public var sqlStringValue : String {
    return contains("'")
      ? self.replacingOccurrences(of: "'", with: "''")
      : String(self)
  }
  @inlinable public var requiresSQLBinding : Bool { true }
  
  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    withCString { cstr in
      sqlite3_bind_text(stmt, index, cstr, -1, SQLITE_STATIC)
      execute()
    }
  }
}

extension Optional : SQLiteValueType where Wrapped: SQLiteValueType {

  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
           throws
  {
    if sqlite3_column_type(stmt, column) == SQLITE_NULL { self = .none }
    else {
      self = try Wrapped(unsafeSQLite3StatementHandle: stmt, column: column)
    }
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    if sqlite3_value_type(value) == SQLITE_NULL { self = .none }
    else { self = try Wrapped(unsafeSQLite3ValueHandle: value) }
  }

  @inlinable public var sqlStringValue : String {
    switch self {
      case .some(let value): return value.sqlStringValue
      case .none: return "NULL"
    }
  }
  @inlinable public var requiresSQLBinding : Bool {
    switch self {
      case .some(let value): return value.requiresSQLBinding
      case .none: return false
    }
  }
  
  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    switch self {
      case .some(let value):
      value.bind(unsafeSQLite3StatementHandle: stmt, index: index,
                 then: execute)
      case .none:
        sqlite3_bind_null(stmt, index)
        execute()
    }
  }
}

extension Array: SQLiteValueType where Element == UInt8 {
  
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
  throws
  {
    if let blob  = sqlite3_column_blob(stmt, column) {
      let count  = Int(sqlite3_column_bytes(stmt, column))
      let buffer = UnsafeRawBufferPointer(start: blob, count: count)
      self.init(buffer)
    }
    else {
      self = []
    }
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    if let blob  = sqlite3_value_blob(value) {
      let count  = Int(sqlite3_value_bytes(value))
      let buffer = UnsafeRawBufferPointer(start: blob, count: count)
      self.init(buffer)
    }
    else {
      self = []
    }
  }

  @inlinable public var sqlStringValue : String {
    // X'', hex encoded
    fatalError("Literal BLOBs are not yet supported!")
    // return "?"
  }
  @inlinable public var requiresSQLBinding : Bool { true }
  
  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    withUnsafeBytes { ubp in // UnsafeRawBufferPointer
      sqlite3_bind_blob(stmt, index, ubp.baseAddress, Int32(ubp.count), nil)
      execute()
    }
  }
}


#if canImport(Foundation)

extension Date : SQLiteValueType {
  
  public enum SQLiteDateStorageStyle: Hashable {
    case timeIntervalSince1970
    case formatter(DateFormatter)
  }
  public static var sqlDateStorageStyle =
                      SQLiteDateStorageStyle.timeIntervalSince1970
  public static var defaultSQLiteDateFormatter : DateFormatter = {
    // `SELECT datetime();` gives: `2004-08-19 18:51:06` in UTC
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
    df.locale     = Locale(identifier: "en_US_POSIX")
    return df
  }()
  
  public enum SQLiteDateConversionError: Swift.Error {
    case unexpectedNull
    case couldNotParseDateString(String)
  }
  
  @usableFromInline
  init(sqlite3CString: UnsafePointer<UInt8>?) throws {
    // `SELECT datetime();` gives: `2004-08-19 18:51:06` in UTC
    guard let cstr = sqlite3CString, cstr.pointee != 0 else {
      throw SQLiteDateConversionError.unexpectedNull
    }
    
    let s = String(cString: cstr)
    if case .formatter(let formatter) = Date.sqlDateStorageStyle {
      if let date = formatter.date(from: s) {
        self = date
        return
      }
    }
    if let date = Date.defaultSQLiteDateFormatter.date(from: s) {
      self = date
      return
    }
    throw SQLiteDateConversionError.couldNotParseDateString(s)
  }
  
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
           throws
  {
    switch sqlite3_column_type(stmt, column) {
      case SQLITE_INTEGER:
        let value = sqlite3_column_int(stmt, column)
        self.init(timeIntervalSince1970: TimeInterval(value))
      case SQLITE_FLOAT:
        let value = sqlite3_column_double(stmt, column)
        self.init(timeIntervalSince1970: value)
      case SQLITE_NULL:
        throw SQLiteDateConversionError.unexpectedNull
      default:
        try self.init(sqlite3CString: sqlite3_column_text(stmt, column))
    }
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    switch sqlite3_value_type(value) {
      case SQLITE_INTEGER:
        let value = sqlite3_value_int(value)
        self.init(timeIntervalSince1970: TimeInterval(value))
      case SQLITE_FLOAT:
        let value = sqlite3_value_double(value)
        self.init(timeIntervalSince1970: value)
      case SQLITE_NULL:
        throw SQLiteDateConversionError.unexpectedNull
      default:
      try self.init(sqlite3CString: sqlite3_value_text(value))
    }
  }


  @inlinable
  public var sqlStringValue : String { String(timeIntervalSince1970) }
  @inlinable public var requiresSQLBinding : Bool { false }

  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    switch Date.sqlDateStorageStyle {
      case .timeIntervalSince1970:
        sqlite3_bind_double(stmt, index, self.timeIntervalSince1970)
      execute()
      case .formatter(let formatter):
        let s = formatter.string(from: self)
        s.bind(unsafeSQLite3StatementHandle: stmt, index: index, then: execute)
    }
  }
}

extension Data: SQLiteValueType {
  
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
  throws
  {
    let s = try [ UInt8 ](unsafeSQLite3StatementHandle: stmt, column: column)
    self.init(s)
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    let s = try [ UInt8 ](unsafeSQLite3ValueHandle: value)
    self.init(s)
  }

  @inlinable public var sqlStringValue : String {
    [ UInt8 ](self).sqlStringValue
  }
  @inlinable public var requiresSQLBinding : Bool { true }
    
  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    withUnsafeBytes { ubp /* UnsafeRawBufferPointer */ in
      sqlite3_bind_blob(stmt, index, ubp.baseAddress, Int32(ubp.count), nil)
      execute()
    }
  }
}

extension URL : SQLiteValueType {
  
  public struct SQLCouldNotParseURL: Swift.Error {
    public let string : String
    public init(string: String) { self.string = string }
  }
  
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
    throws
  {
    let s = try String(unsafeSQLite3StatementHandle: stmt, column: column)
    guard let url = URL(string: s) else { throw SQLCouldNotParseURL(string: s) }
    self = url
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    let s = try String(unsafeSQLite3ValueHandle: value)
    guard let url = URL(string: s) else { throw SQLCouldNotParseURL(string: s) }
    self = url
  }

  @inlinable public var sqlStringValue : String {
    absoluteString.sqlStringValue
  }
  @inlinable public var requiresSQLBinding : Bool { true }
  
  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    absoluteString.withCString { cstr in
      sqlite3_bind_text(stmt, index, cstr, -1, SQLITE_STATIC)
      execute()
    }
  }
}

extension Decimal : SQLiteValueType {
  
  public struct SQLCouldNotParseDecimal: Swift.Error {
    public let string : String
    public init(string: String) { self.string = string }
  }
  public static let sqlStringLocale = Locale(identifier: "en_US_POSIX")
  
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
    throws
  {
    switch sqlite3_column_type(stmt, column) {
      case SQLITE_INTEGER : self.init(sqlite3_column_int(stmt, column))
      case SQLITE_FLOAT   : self.init(sqlite3_column_double(stmt, column))
      case SQLITE_NULL    : self.init(0)
      default:
        let s = sqlite3_column_text(stmt, column).flatMap(String.init(cString:))
             ?? ""
        guard let d = Decimal(string: s, locale: Decimal.sqlStringLocale)
         else { throw SQLCouldNotParseDecimal(string: s) }
        self = d
    }
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    switch sqlite3_value_type(value) {
      case SQLITE_INTEGER : self.init(sqlite3_value_int(value))
      case SQLITE_FLOAT   : self.init(sqlite3_value_double(value))
      case SQLITE_NULL    : self.init(0)
      default:
        let s = sqlite3_value_text(value).flatMap(String.init(cString:)) ?? ""
        guard let d = Decimal(string: s, locale: Decimal.sqlStringLocale)
         else { throw SQLCouldNotParseDecimal(string: s) }
        self = d
    }
  }

  @inlinable public var sqlStringValue : String {
    var copy = self
    return NSDecimalString(&copy, Decimal.sqlStringLocale).sqlStringValue
  }
  @inlinable public var requiresSQLBinding : Bool { true }
  
  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    var copy = self
    NSDecimalString(&copy, Decimal.sqlStringLocale)
      .bind(unsafeSQLite3StatementHandle: stmt, index: index, then: execute)
  }
}

extension UUID : SQLiteValueType {
  
  public enum SQLiteUUIDStorageStyle: Hashable {
    case string
    case blob
  }
  public static var sqlUUIDStorageStyle = SQLiteUUIDStorageStyle.blob
  
  public enum SQLCouldNotLoadUUID: Swift.Error {
    case couldNotParseString(String)
    case dataWithInvalidLength(Int)
  }
    
  @inlinable
  public init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
    throws
  {
    switch sqlite3_column_type(stmt, column) {
      
      case SQLITE_BLOB:
        let length = Int(sqlite3_column_bytes(stmt, column))
        guard length == 16, let blob = sqlite3_column_blob(stmt, column) else {
          throw SQLCouldNotLoadUUID.dataWithInvalidLength(length)
        }
        let rbp = UnsafeRawBufferPointer(start: blob, count: length)
        self = UUID(uuid: (
          rbp[0], rbp[1], rbp[2],  rbp[3],  rbp[4],  rbp[5],  rbp[6],  rbp[7],
          rbp[8], rbp[9], rbp[10], rbp[11], rbp[12], rbp[13], rbp[14], rbp[15]
        ))
      
      default:
        let s = sqlite3_column_text(stmt, column).flatMap(String.init(cString:))
             ?? ""
        guard let uuid = UUID(uuidString: s) else {
          throw SQLCouldNotLoadUUID.couldNotParseString(s)
        }
        self = uuid
    }
  }
  @inlinable
  public init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    switch sqlite3_value_type(value) {
      
      case SQLITE_BLOB:
        let length = Int(sqlite3_value_bytes(value))
        guard length == 16, let blob = sqlite3_value_blob(value) else {
          throw SQLCouldNotLoadUUID.dataWithInvalidLength(length)
        }
        let rbp = UnsafeRawBufferPointer(start: blob, count: length)
        self = UUID(uuid: (
          rbp[0], rbp[1], rbp[2],  rbp[3],  rbp[4],  rbp[5],  rbp[6],  rbp[7],
          rbp[8], rbp[9], rbp[10], rbp[11], rbp[12], rbp[13], rbp[14], rbp[15]
        ))
      
      default:
        let s = sqlite3_value_text(value).flatMap(String.init(cString:)) ?? ""
        guard let uuid = UUID(uuidString: s) else {
          throw SQLCouldNotLoadUUID.couldNotParseString(s)
        }
        self = uuid
    }
  }

  @inlinable public var sqlStringValue : String {
    // TBD: support style and encoded as hex-blob
    uuidString.sqlStringValue
  }
  @inlinable public var requiresSQLBinding : Bool { true }
  
  @inlinable
  public func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
                   index: Int32, then execute: () -> Void)
  {
    switch Self.sqlUUIDStorageStyle {
      case .blob:
        let blob : [ UInt8 ] = [
          // Later: we could skip the array creation and just bind the tuple?
          uuid.0, uuid.1, uuid.2,  uuid.3,  uuid.4,  uuid.5,  uuid.6,  uuid.7,
          uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15
        ]
        blob.bind(unsafeSQLite3StatementHandle: stmt, index: index,
                  then: execute)
      case .string:
        uuidString.bind(unsafeSQLite3StatementHandle: stmt, index: index,
                        then: execute)
    }
  }
}
#endif // canImport(Foundation)
