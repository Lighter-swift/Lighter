//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3Schema

/**
 * Represents a table or a view in the SQL database.
 *
 * The ordering of the properties needs to stay constant, it has importance
 * for the (SQL) code generation features, which is based around indices.
 */
public final class EntityInfo {
  
  /**
   * The type of the entity, either a `VIEW` or a `TABLE`.
   */
  public enum EntityType: Equatable {
    case view, table
  }
  
  /// Whether it is a View or Table
  public let type          : EntityType
  
  /// The name of the associated Swift structure, e.g. `Person`
  public var name          : String
  
  /// The name of the associated Swift "container" reference, as in:
  /// `select(from: \.people, \.lastname)`
  /// or:
  /// `db.persons.find(1)`
  public var referenceName : String
  
  /// `sqlite3_person_insert()`
  public var singularRawName : String

  /// `sqlite3_people_insert()`
  public var pluralRawName   : String

  /// The SQL name of the table/view, e.g. `person`
  public let externalName  : String
  
  /// The properties of the structure being generated, correspond to the
  /// table/view columns.
  public var properties   : [ Property ] = []
  
  /// Raw SQL to create the table or view.
  public let createSQL    : String?
  /// Raw SQL to create the triggers associated with the table.
  public let triggersSQL  : [ String ]
  /// Raw SQL to create the indices associated with the table.
  public let indiciesSQL  : [ String ]
  
  /// Whether the entity is either a table, or has an `INSTEAD OF INSERT`
  /// trigger.
  public let canInsert    : Bool
  /// Whether the entity is either a table, or has an `INSTEAD OF UPDATE`
  /// trigger.
  public let canUpdate    : Bool
  /// Whether the entity is either a table, or has an `INSTEAD OF DELETE`
  /// trigger.
  public let canDelete    : Bool
  
  public var isReadOnly   : Bool {
    return !(type == .table) && !(canInsert || canUpdate || canDelete)
  }
  
  /// Relationships where this entity owns the foreign key
  public var toOneRelationships  = [ ToOne  ]()
  /// Relationships where this entity is the target of a foreign key
  public var toManyRelationships = [ ToMany ]()

  
  // MARK: - Initializer

  public init(type            : EntityType   = .table,
              name            : String,
              referenceName   : String?      = nil,
              singularRawName : String?      = nil,
              pluralRawName   : String?      = nil,
              externalName    : String?      = nil,
              properties      : [ Property ] = [],
              createSQL       : String?      = nil,
              triggersSQL     : [ String ]   = [],
              indiciesSQL     : [ String ]   = [])
  {
    self.type            = type
    self.name            = name
    self.referenceName   = referenceName   ?? name
    self.singularRawName = singularRawName ?? name.singularized
    self.pluralRawName   = pluralRawName   ?? name.pluralized
    self.externalName    = externalName    ?? name
    self.properties      = properties
    self.createSQL       = createSQL
    self.triggersSQL     = triggersSQL
    self.indiciesSQL     = indiciesSQL
    
    canInsert = type == .table || triggersSQL.contains(where: { sql in
      containsInsteadOfTrigger(in: sql) == "INSERT"
    })
    canUpdate = type == .table || triggersSQL.contains(where: { sql in
      containsInsteadOfTrigger(in: sql) == "UPDATE"
    })
    canDelete = type == .table || triggersSQL.contains(where: { sql in
      containsInsteadOfTrigger(in: sql) == "DELETE"
    })
  }
  
  
  // MARK: - Accessors
  
  public subscript(_ name: String) -> Property? {
    properties.first(where: { $0.name == name })
  }
  public subscript(externalName name: String) -> Property? {
    properties.first(where: { $0.externalName == name })
  }
  public subscript(toOne name: String) -> ToOne? {
    toOneRelationships.first(where: { $0.name == name })
  }
  public subscript(toMany name: String) -> ToMany? {
    toManyRelationships.first(where: { $0.name == name })
  }

  public var hasPrimaryKey : Bool {
    properties.contains(where: \.isPrimaryKey)
  }
  public var hasCompoundPrimaryKey : Bool {
    var seenKey = false
    for property in properties where property.isPrimaryKey {
      if seenKey { return true }
      seenKey = true
    }
    return false
  }
  
  public var primaryKeyProperties : [ Property ] {
    properties.filter(\.isPrimaryKey)
  }
  
  public func indexOfProperty(_ property: Property) -> Int {
    properties.firstIndex(where: { property.externalName == $0.externalName })
    ?? -1
  }
  public func indicesForProperties(_ properties: [ Property ]) -> [ Int ] {
    properties.map { indexOfProperty($0) }
  }
  
  /// Returns the primaryKeys if set, otherwise all properties!
  var recordMatchProperties: [ Property ] {
    assert(!properties.isEmpty)
    let pkeys = primaryKeyProperties
    return pkeys.isEmpty ? properties : pkeys
  }
}

extension EntityInfo: CustomStringConvertible {
  
  public var description: String {
    var ms = "<EntityInfo[\(name)]:"
    if externalName != name { ms += " ext=\"\(externalName)\"" }
    
    ms += " " + properties.map(\.description).joined(separator: ", ")
    ms += ">"
    return ms
  }
}

private func containsInsteadOfTrigger(in sql: String) -> String? {
  // CREATE TRIGGER cust_addr_chng
  // INSTEAD OF UPDATE OF <column> ON <view>
  // INSTEAD OF INSERT ON <view>
  // INSTEAD OF DELETE ON <view>
  let upper = sql.uppercased() // yes, preserves create case!
  
  guard let range = upper.range(of: "INSTEAD") else { return nil }
  
  let parts = upper[range.upperBound...].split(
    maxSplits: 4,
    omittingEmptySubsequences: true,
    whereSeparator: { $0 == "\n" || $0 == " " || $0 == "\t" }
  )
  // "OF", operation, "OF"|"ON"
  guard parts.count > 3 else { return nil }
  guard parts.first == "OF",
        let inner = parts.dropFirst(2).first, inner == "ON" || inner == "OF",
        let operation = parts.dropFirst().first
   else { return nil }
  guard operation == "INSERT" || operation == "UPDATE" || operation == "DELETE"
   else { return nil}
  
  return String(operation)
}
