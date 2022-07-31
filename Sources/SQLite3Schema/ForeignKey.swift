//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  #if swift(>=5.6)
    import func Darwin.strcasestr
  #else
    import func Darwin.strstr
  #endif
#elseif canImport(Glibc)
  import func Glibc.strstr
#else
  import Foundation
#endif

extension Schema {
  
  /**
   * The foreign key information returned by `PRAGMA foreign_key_list($table)`.
   *
   * Note that to enforce foreign key constraints, the setting must be
   * esplicitly enabled on a connection, via `PRAGMA foreignkeys = ON;`.
   */
  public struct ForeignKey: Hashable, Identifiable {

    /**
     * The action to take on updates/deletes affecting a constraint.
     */
    public enum Action: String {

      /// No action is performed, the foreign key might become a "dangling"
      /// pointer.
      case noAction   = "NO ACTION"
      
      /// If the associated record is deleted in the destination table, all
      /// related records will be deleted in source table.
      case cascade    = "CASCADE"
      
      /// If the source table still has an entry for the destination record
      /// being deleted, the delete will be rejected w/ a constraint error.
      case restrict   = "RESTRICT" // deny
      
      /// If an associated record in the destination table is deleted, all
      /// matching foreign keys will be set to `NULL` in the source table.
      case setNull    = "SET NULL"
      
      /// If an associated record in the destination table is deleted, all
      /// matching foreign keys will be set to the default value in the source
      /// table.      
      case setDefault = "SET DEFAULT"
    }
    
    /// The foreign key match strategy.
    /// SQLite can only do `simple`, this has no actual effect (as of today).
    public enum Match: String {
      
      case none    = "NONE"
      case simple  = "SIMPLE"
      case partial = "PARTIAL"
      case full    = "FULL"
    }
    
    /// The id of the foreign key.
    public let id                : Int64
    /// A sequence associated with the foreign key.
    public let seq               : Int64
    
    /// The actual foreign key column in the table.
    public let sourceColumn      : String
    /// The table that is targetted by the foreign key.
    public let destinationTable  : String
    /// The destinatiion table column that is targetted by the foreign key.
    public let destinationColumn : String
    
    /// The `Action` to perform if updates affect the foreign key.
    public let updateAction      : Action
    /// The `Action` to perform if deletes affect the foreign key.
    /// E.g. if a `person` record is dropped, all attached rows can be deleted
    /// if the ``Action`` is set to ``Action/cascade``.
    public let deleteAction      : Action
    
    // Note: SQLite doesn't actually apply the match but always uses .simple
    public let match             : Match
    
    /// Initialize a new `ForeignKey` structure.
    public init(id: Int64, seq: Int64 = 0,
                sourceColumn      : String,
                destinationTable  : String,
                destinationColumn : String? = nil,
                updateAction      : Action = .noAction,
                deleteAction      : Action = .noAction, match: Match = .simple)
    {
      self.id                = id
      self.seq               = seq
      self.sourceColumn      = sourceColumn
      self.destinationTable  = destinationTable
      self.destinationColumn = destinationColumn ?? sourceColumn
      self.updateAction      = updateAction
      self.deleteAction      = deleteAction
      self.match             = match
    }
  }
}


// MARK: - Fetching

import SQLite3

public extension Schema.ForeignKey {
  
  /**
   * Fetch the foreign key information for a table.
   *
   * - Parameters:
   *   - table: The unescaped table name.
   *   - db:    An open SQLite3 database handle.
   * - Returns: An array with the foreign keys defined on the table,
   *            or nil on error
   */
  static func fetch(for table: String, in db: OpaquePointer?)
              -> [ Schema.ForeignKey ]?
  {
    guard let db = db else { return [] }
    let table = table.contains("\"") // escape " with ""
      ? table.split(separator: "\"").joined(separator: "\"\"")
      : table

    let sql = "PRAGMA foreign_key_list(\"\(table)\")"
    var maybeStmt : OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &maybeStmt, nil) == SQLITE_OK,
          let stmt = maybeStmt else
    {
      assertionFailure("Failed to prepare SQL!")
      return nil
    }
    defer { sqlite3_finalize(stmt) }

    var keys = [ Schema.ForeignKey ]()
    
    while true {
      let rc = sqlite3_step(stmt)
      if rc == SQLITE_DONE { break }
      else if rc != SQLITE_ROW { return nil }
      if let fkey = Schema.ForeignKey(stmt) {
        keys.append(fkey)
      }
      else {
        assertionFailure("Could not create foreign key?!")
      }
    }
    return keys
  }
}


// MARK: - Description

extension Schema.ForeignKey: CustomStringConvertible {
  
  /// Returns a debug description for the `ForeignKey`.
  public var description: String {
    var ms = "<ForeignKey[\(id):\(seq)]:"
    ms += " \(sourceColumn)=\(destinationTable).\(destinationColumn)"
    if updateAction != .noAction { ms += " onUpdate=\(updateAction.rawValue)" }
    if deleteAction != .noAction { ms += " onDelete=\(deleteAction.rawValue)" }
    if match != .simple { ms += " match=\(match.rawValue)" }
    ms += ">"
    return ms
  }
}


// MARK: - Statement Initializers

fileprivate extension Schema.ForeignKey {
  
  /**
   * Initialize a `ForeignKey` from a prepared SQLite3 statement handle that
   * was prepared w/ a `PRAGMA foreign_key_list` call.
   *
   * - Parameters:
   *   - pragmaForeignKeyListStatement: A SQLite3 prepared statement handle.
   */
  init?(_ pragmaForeignKeyListStatement: OpaquePointer?) {
    guard let stmt = pragmaForeignKeyListStatement else { return nil }
    // TBD: is the ordering stable? Presumably?
    id  = sqlite3_column_int64(stmt, 0)
    seq = sqlite3_column_int64(stmt, 1)
    
    if let s = sqlite3_column_text (stmt, 2) {
      destinationTable = String(cString: s)
    }
    else {
      assertionFailure("Missing destination table?")
      return nil
    }
    if let s = sqlite3_column_text (stmt, 3) {
      sourceColumn = String(cString: s)
    }
    else {
      assertionFailure("Missing sourceColumn?")
      return nil
    }
    if let s = sqlite3_column_text (stmt, 4) {
      destinationColumn = String(cString: s)
    }
    else {
      assertionFailure("Missing destinationColumn?")
      return nil
    }
    
    self.updateAction = Action(sqlite3_column_text(stmt, 5)) ?? .noAction
    self.deleteAction = Action(sqlite3_column_text(stmt, 6)) ?? .noAction
    self.match        = Match (sqlite3_column_text(stmt, 7)) ?? .simple
  }
}

fileprivate extension Schema.ForeignKey.Action {
    
  /**
   * Initialize a ``Schema/ForeignKey/Action`` from a raw C string.
   */
  init?(_ cstr: UnsafePointer<UInt8>?) {
    if let cstr = cstr, cstr.pointee != 0 { // pretty forgiving
      switch UnicodeScalar(Int(cstr.pointee)) {
      case "n", "N": self = .noAction
      case "r", "R": self = .restrict
      case "c", "C": self = .cascade
      case "s", "S":
        #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && swift(>=5.6)
          if strcasestr(cstr, "NULL") != nil {
            self = .setNull
          }
          else if strcasestr(cstr, "DEFAULT") != nil {
            self = .setDefault
          }
          else {
            assertionFailure(
              "Unexpected action: \(String(cString: cstr))")
            return nil
          }
        #else // Linux etc
          let s = String(cString: cstr).uppercased() // no strcasestr on Linux
          if      strstr(s, "NULL")    != nil { self = .setNull    }
          else if strstr(s, "DEFAULT") != nil { self = .setDefault }
          else {
            assertionFailure(
              "Unexpected action: \(String(cString: cstr))")
            return nil
          }
        #endif
      default:
        assertionFailure("Unexpected action: \(String(cString: cstr))")
        return nil
      }
    }
    else { self = .noAction }
  }
}

fileprivate extension Schema.ForeignKey.Match {
  
  /**
   * Initialize a ``Schema/ForeignKey/Match`` from a raw C string.
   */
  init?(_ cstr: UnsafePointer<UInt8>?) {
    if let cstr = cstr, cstr.pointee != 0 { // pretty forgiving
      switch UnicodeScalar(Int(cstr.pointee)) {
      case "s", "S": self = .simple
      case "n", "N": self = .none
      case "p", "P": self = .partial
      case "f", "F": self = .full
      default:
        assertionFailure("Unexpected match: \(String(cString: cstr))")
        return nil
      }
    }
    else { self = .simple }
  }
}
