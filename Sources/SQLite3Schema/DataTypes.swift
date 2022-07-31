//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import func Darwin.strcasestr
#else
import Foundation // using `NSString.contains`...
#endif

extension Schema {
  
  /**
   * The allowed types in a STRICT mode table.
   *
   * STRICT mode is available in SQLite 3.37.0 and later.
   * Without STRICT mode, SQLite actually allows any type to be stored in any
   * column, regardless of the type.
   */
  public enum StrictType: String, Hashable {
    
    case integer = "INTEGER"  // or INT!
    case real    = "REAL"
    case text    = "TEXT"
    case blob    = "BLOB"
    case any     = "ANY"
    
    /// Initialize the structure with a String representation.
    public init?(rawValue: String) {
      switch rawValue {
        case "INT", "INTEGER": self = .integer
        case "REAL" : self = .real
        case "TEXT" : self = .text
        case "BLOB" : self = .blob
        case "ANY"  : self = .any
        default     : return nil
      }
    }
  }
  
  /**
   * The SQLite type affinitiy.
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
  public enum TypeAffinity: String, Hashable {
    
    case text    = "TEXT"
    case numeric = "NUMERIC" // either INTEGER or REAL
    case integer = "INTEGER"
    case real    = "REAL"
    case blob    = "BLOB"
  }
}

extension Schema {

  /**
   * A set of types this library can detect and parse.
   * 
   * Not all of those types are actual types supported by SQLite, but they get
   * assigned a proper ``TypeAffinity`` by SQLite.
   * For example `VARCHAR(255)` is not a SQLite type, but SQLite detects it
   * properly and assigns it ``TypeAffinity/text``.
   */
  public enum ColumnType: Hashable, RawRepresentable {
    
    // strict types
    case integer
    case real
    case text
    case blob
    case any
    
    // common SQL types
    case boolean
    case varchar(width: Int?)
    case date
    case datetime
    case timestamp
    case decimal

    // E.g. one can (and the OGo schema does) use own datatype names, e.g.
    // `CREATE TABLE B ( col MYTYPE );` works!
    case custom(String)
    
    /**
     * The ``Schema/TypeAffinity`` of the type.
     *
     * This is determined as described in
     * https://www.sqlite.org/datatype3.html#determination_of_column_affinity
     *
     * Note that if no type is specified, the affinity is
     * ``Schema/TypeAffinity/blob``.
     */
    public var affinity : TypeAffinity {
      switch self {
        case .integer : return .integer
        case .real    : return .real
        case .text    : return .text
        case .blob    : return .blob
        case .any     : return .numeric // TBD
        
        // common SQL types
        case .boolean : return .numeric
        case .date, .datetime, .timestamp: return .numeric // TBD
        case .varchar : return .numeric
        case .decimal : return .numeric
        
        // E.g. one can (and the OGo schema does) use own datatype names, e.g.
        // `CREATE TABLE B ( col MYTYPE );` works!
        case .custom(let s): // according to SQLite rules!
          #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && swift(>=5.6)
          return s.withCString { cstr in
            if strcasestr(cstr, "INT")  != nil { return .integer }
            if strcasestr(cstr, "CHAR") != nil { return .text }
            if strcasestr(cstr, "CLOB") != nil { return .text }
            if strcasestr(cstr, "TEXT") != nil { return .text }
            if strcasestr(cstr, "BLOB") != nil { return .blob }
            if strcasestr(cstr, "REAL") != nil { return .real }
            if strcasestr(cstr, "FLOA") != nil { return .real }
            if strcasestr(cstr, "DOUB") != nil { return .real }
            return .numeric
          }
          #else // Linux etc, strcasestr not exposed in Swift
          let lc = s.uppercased()
          if lc.contains("INT")  { return .integer }
          if lc.contains("CHAR") { return .text }
          if lc.contains("CLOB") { return .text }
          if lc.contains("TEXT") { return .text }
          if lc.contains("BLOB") { return .blob }
          if lc.contains("REAL") { return .real }
          if lc.contains("FLOA") { return .real }
          if lc.contains("DOUB") { return .real }
          return .numeric
          #endif
      }
    }
    
    /// Initialize a `ColumnType` from a String. If it doesn't match any known,
    /// a `.custom` case will be used.
    public init?(rawValue: String) {
      guard !rawValue.isEmpty else { return nil }
      
      let uc = rawValue.uppercased()
      switch uc {
        // Note: Do not add aliases here, we want to preserve types not
        //       directly supported! (e.g. CLOB to .text)
        case "INT", "INTEGER"  : self = .integer
        case "REAL"            : self = .real
        case "TEXT"            : self = .text
        case "BLOB"            : self = .blob
        case "ANY"             : self = .any
        
        case "BOOLEAN", "BOOL" : self = .boolean
        // Note: Not the `WITH TIME ZONE` variants!
        case "DATE"            : self = .date
        case "DATETIME"        : self = .datetime
        case "TIMESTAMP"       : self = .timestamp
        case "DECIMAL"         : self = .decimal
        case "DOUBLE"          : self = .real

        case "VARCHAR"         : self = .varchar(width: nil)

        default:
          if rawValue.hasPrefix("VARCHAR("),
             let idx = rawValue.firstIndex(of: ")"),
             let width = Int(rawValue[..<idx].dropFirst(8))
          {
            self = .varchar(width: width)
          }
          else {
            self = .custom(rawValue)
          }
      }
    }
    
    /// Returns the String value for the type.
    public var rawValue: String {
      switch self {
        case .integer   : return "INTEGER"
        case .real      : return "REAL"
        case .text      : return "TEXT"
        case .blob      : return "BLOB"
        case .any       : return "ANY"
        
        case .boolean   : return "BOOLEAN"
        case .varchar(let width):
          if let width = width { return "VARCHAR(\(width))" }
          else                 { return "VARCHAR" }
        case .date      : return "DATE"
        case .datetime  : return "DATETIME"
        case .timestamp : return "TIMESTAMP"
        case .decimal   : return "DECIMAL"

        case .custom(let string): return string
      }
    }
  }
}
