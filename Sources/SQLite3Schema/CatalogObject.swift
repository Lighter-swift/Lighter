//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension Schema {

  /**
   * The type of an object in the SQLite catalog: table, view, index or trigger.
   */
  enum CatalogObjectType: String {
    case table
    case view
    case index
    case trigger
  }

  /**
   * An object in the database catalog, i.e. a table, view, index or trigger.
   * (i.e. the ``CatalogObjectType``).
   *
   * All objects have a name and associated "tableName" (same like the name for
   * tables and views).
   *
   * Most objects store the SQL used to create the table.
   */
  struct CatalogObject: Hashable {
    
    /**
     * The type of the object: table, view, index or trigger.
     */
    public let type      : CatalogObjectType
    
    /**
     * The name of the catalog object (i.e. view, table, index or trigger).
     */
    public let name      : String
    
    /**
     * For a table or a view, this is the same like ``name``.
     * For triggers or indices, it contains the table they correspond to.
     */
    public let tableName : String // or viewName for views
    
    /// The root page of the type.
    public let rootPage  : Int64
    
    /**
     * The catalog usually keeps and up-to-date SQL create statement that can
     * be used to recreate a table.
     *
     * It is usually set, but not always, e.g. for auto-indices.
     */
    public let sql       : String
    
    /**
     * Create a new `CatalogObject`.
     *
     * - Parameters:
     *   - type:      The type of the object: table, view, index or trigger,
     *                defaults to `.table`.
     *   - name:      The name of the table, view, index or trigger.
     *   - tableName: The table name associated w/ the object. Same like `name`
     *                for table/view, but the table a trigger or index is
     *                referring to.
     *   - rootPage:  The root page index.
     *   - sql:       Optionally the SQL used to create the object (e.g. the
     *                `CREATE TABLE` statement).
     */
    public init(type: CatalogObjectType = .table,
                name: String, tableName: String? = nil, rootPage: Int64 = 1,
                sql: String = "")
    {
      self.type      = type
      self.name      = name
      self.tableName = tableName ?? name
      self.rootPage  = rootPage
      self.sql       = sql
    }
  }
}


// MARK: - Fetching

import SQLite3

public extension Schema.CatalogObject {

  /**
   * Fetch the names of the tables, views and indices contained in the database.
   * Plus a little extra information, most importantly the SQL that had been
   * used to construct the respective object.
   *
   * - Parameters:
   *   - db: An open SQLite3 database handle.
   */
  static func fetch(in db: OpaquePointer?) -> [ Schema.CatalogObject ]? {
    guard let db = db else { return nil }
    
    let sql = "SELECT type, name, tbl_name, rootpage, sql FROM sqlite_master"
    var maybeStmt : OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &maybeStmt, nil) == SQLITE_OK,
          let stmt = maybeStmt else
    {
      assertionFailure("Failed to prepare SQL \(sql)")
      return nil
    }
    defer { sqlite3_finalize(stmt) }

    // TBD: could make this generic, like `SQLiteStatementInitializable`
    var objects = [ Schema.CatalogObject ]()
    
    while true {
      let rc = sqlite3_step(stmt)
      if      rc == SQLITE_DONE { break }
      else if rc != SQLITE_ROW  { return nil }

      if let object = Schema.CatalogObject(stmt) {
        objects.append(object)
      }
      else {
        assertionFailure("Could not create column?!")
      }
    }
    return objects
  }
}


// MARK: - Description

extension Schema.CatalogObject: CustomStringConvertible {
  
  public var description: String {
    var ms = "<"
    switch type {
      case .table   : ms += "Table"
      case .view    : ms += "View"
      case .index   : ms += "Index"
      case .trigger : ms += "Trigger"
    }
    ms += " '\(name)'"
    if name != tableName { ms += " table='\(tableName)'" }
    ms += " root=\(rootPage)"
    if sql.isEmpty { ms += " NO-SQL"            } // but not NoSQL ;->
    else           { ms += " sql=#\(sql.count)" }
    ms += ">"
    return ms
  }
}


// MARK: - Statement Initializers

fileprivate extension Schema.CatalogObject {
  
  init?(_ sqliteMasterFetchStatement: OpaquePointer?) {
    guard let stmt = sqliteMasterFetchStatement else { return nil }
    
    if let s = sqlite3_column_text(stmt, 0) {
      #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && swift(>=5.6)
      if      strcasecmp(s, "table")   == 0 { type = .table   }
      else if strcasecmp(s, "view")    == 0 { type = .view    }
      else if strcasecmp(s, "index")   == 0 { type = .index   }
      else if strcasecmp(s, "trigger") == 0 { type = .trigger }
      else {
        assertionFailure("Unsupported catalog object: \(String(cString: s))")
        return nil
      }
      #else // no strcasecmp exposed on Linux, casting issues on macOS
      switch String(cString: s).lowercased() {
        case "table"   : type = .table
        case "view"    : type = .view
        case "index"   : type = .index
        case "trigger" : type = .trigger
        default:
          assertionFailure("Unsupported catalog object: \(String(cString: s))")
          return nil
      }
      #endif
    }
    else {
      assertionFailure("Missing type column?!"); return nil
    }
    
    if let s = sqlite3_column_text(stmt, 1), s.pointee != 0 {
      name = String(cString: s)
    }
    else {
      assertionFailure("Catalog object w/o name?"); return nil
    }
    
    tableName = sqlite3_column_text(stmt, 2).flatMap(String.init(cString:))
             ?? name
    
    rootPage  = sqlite3_column_int64(stmt, 3)
    assert(rootPage >= 0, "Negative root page")

    sql = sqlite3_column_text(stmt, 4).flatMap(String.init(cString:)) ?? ""
    assert(!sql.isEmpty || name.hasPrefix("sqlite_autoindex_"), "SQL not set?")
  }
}
