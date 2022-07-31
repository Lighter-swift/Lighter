//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * The model object describing a SQLite database mapped to Swift.
 *
 * Has a name, like "Contacts", and a set of ``EntityInfo``s for each table and
 * view.
 * Plus the "userVersion" set in SQLite, which can be useful to implement
 * migrations and detect whether the generated code matches an actual database
 * schema.
 */
public final class DatabaseInfo {
  
  /// The name of the database structure, e.g. `Contacts`
  public var name        : String
  /// The user settable schema version of the database.
  public let userVersion : Int
  /// The set of tables and views in the database.
  public let entities    : [ EntityInfo ]
  
  /// Initialize a new database model object.
  public init(name: String, userVersion: Int = 0, entities: [ EntityInfo ] = [])
  {
    self.name        = name
    self.userVersion = userVersion
    self.entities    = entities
  }
  
  /// Lookup an ``EntityInfo`` by its "Swift name" (e.g. "Person").
  public subscript(_ name: String) -> EntityInfo? {
    entities.first(where: { $0.name == name })
  }
  /// Lookup an ``EntityInfo`` by its "SQL name" (e.g. "person").
  public subscript(externalName name: String) -> EntityInfo? {
    entities.first(where: { $0.externalName == name })
  }
  
  /// The set of the (Swift) names of all tables and views.
  public var entityNames : Set<String> { Set(entities.map(\.name)) }
}

extension DatabaseInfo: CustomStringConvertible {
  
  /// Returns a description of the database information.
  public var description: String {
    var ms = "<DBInfo[v\(userVersion)]: '\(name)'"
    ms += " " + entities.map(\.description).joined(separator: ", ")
    ms += ">"
    return ms
  }
}
