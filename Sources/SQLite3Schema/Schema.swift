//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * The full schema of a SQLite3 database.
 *
 * Tables, views, triggers and indices.
 * Plus two version markers, one maintained by SQLite on each change and one
 * settable by the user (useful for migrations).
 */
public struct Schema: Hashable {
  
  /**
   * SQLite bumps the schema version everytime the schema is altered.
   * Can be used as a change indicator.
   */
  public let version        : Int

  /**
   * The user-version can be set by the client code and can be used for
   * migrations (`PRAGMA user_version = X`). Defaults to `0`.
   */
  public let userVersion    : Int
  
  /// The ``Table``s in the database.
  public let tables         : [ Table ]
  
  /// The ``View``s in the database.
  public let views          : [ View  ]
  
  /// The indices in the database keyed on the name of the table the index is
  /// on.
  public let indices        : [ String : [ CatalogObject ] ] // table name 2 idx
  
  /// The triggers in the database keyed on the name of the table the index is
  /// on.
  public let triggers       : [ String : [ CatalogObject ] ]

  /// Initialize a new Schema structure.
  public init(version        : Int       = 0,
              userVersion    : Int       = 0,
              tables         : [ Table ] = [],
              views          : [ View  ] = [],
              indices        : [ String : [ CatalogObject ] ] = [:],
              triggers       : [ String : [ CatalogObject ] ] = [:])
  {
    self.version     = version
    self.userVersion = userVersion
    self.tables      = tables
    self.views       = views
    self.indices     = indices
    self.triggers    = triggers
  }

  /// Lookup the ``Table`` with the given name.
  @inlinable
  subscript(table name: String) -> Table? {
    tables.first(where: { $0.name == name })
  }
  /// Lookup the ``View`` with the given name.
  @inlinable
  subscript(view name: String) -> View? {
    views.first(where: { $0.name == name })
  }
}


// MARK: - Fetching

import SQLite3

public extension Schema {
  
  /**
   * Fetch the schema. Well, the parts we support.
   *
   * - Parameters:
   *   - db: An open SQLite3 database handle.
   * - Returns: The ``Schema`` of the database, if the fetch was successful.
   */
  static func fetch(in db: OpaquePointer?) -> Schema? {
    func fetch_int(_ db: OpaquePointer?, _ sql: String) -> Int? {
      var stmt : OpaquePointer?
      guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
        return nil
      }
      defer { sqlite3_finalize(stmt); stmt = nil }
      let rc = sqlite3_step(stmt)
      guard rc == SQLITE_ROW else { return nil }
      return Int(sqlite3_column_int64(stmt, 0))
    }

    let version = fetch_int(db, "PRAGMA main.schema_version")
    assert(version != nil)
    let userVersion = fetch_int(db, "PRAGMA main.user_version")
    assert(userVersion != nil)

    guard let catalogObjects = CatalogObject.fetch(in: db) else {
      assertionFailure("Could not fetch catalog objects?")
      return nil
    }

    var tables   = [ Table ]()
    var views    = [ View  ]()
    var indices  = [ String : [ CatalogObject ] ]()
    var triggers = [ String : [ CatalogObject ] ]()
    
    for info in catalogObjects {
      assert(!info.tableName.isEmpty)
      switch info.type {
        case .table:
          guard let columns = Column.fetch(for: info.name, in: db) else {
            assert(info.type == .view, "Could not fetch columns of table?")
            return nil
          }
          let fkeys = ForeignKey.fetch(for: info.name, in: db) ?? []
          
          tables.append(Table(info: info, columns: columns, foreignKeys: fkeys))
        
        case .view:
          guard let columns = Column.fetch(for: info.name, in: db) else {
            assert(info.type == .view, "Could not fetch columns of view?")
            return nil
          }
          
          views.append(View(info: info, columns: columns))
        
        case .index:
          if nil == indices[info.tableName]?.append(info) {
            indices[info.tableName] = [ info ]
          }
        case .trigger:
          if nil == triggers[info.tableName]?.append(info) {
            triggers[info.tableName] = [ info ]
          }
      }
    }
    
    return Schema(
      version     : version     ?? 0,
      userVersion : userVersion ?? 0,
      tables      : tables,
      views       : views,
      indices     : indices,
      triggers    : triggers
    )
  }
}


// MARK: - Description

extension Schema: CustomStringConvertible {
  
  /// Returns a debug description for the database schema.
  public var description: String {
    var ms = "<Schema[v\(version)/\(userVersion)]:"
    
    if tables.isEmpty { ms += " NO-TABLES?" }
    else {
      for table in tables {
        ms += " "
        ms += table.description
      }
    }
    
    if !views   .isEmpty {
      ms += " views=" + views.map(\.name).joined(separator: ",")
    }
    if !indices .isEmpty { ms += " has-indices"  }
    if !triggers.isEmpty { ms += " has-triggers" }

    ms += ">"
    return ms
  }
}
