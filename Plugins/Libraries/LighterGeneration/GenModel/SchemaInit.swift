//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3Schema

public extension DatabaseInfo {
  
  convenience init(name: String, schema: Schema) {
    var entities = [ EntityInfo ]()
    entities.reserveCapacity(schema.tables.count + schema.views.count)
    
    for table in schema.tables {
      let indices  = schema.indices [table.name] ?? []
      let triggers = schema.triggers[table.name] ?? []
      
      let properties = table.columns.map { column in
        EntityInfo.Property(
          schema: column,
          foreignKey: table.foreignKeys.first(where: { fkey in
            fkey.sourceColumn == column.name
          })
        )
      }
      
      let entity = EntityInfo(
        type: .table,
        name: table.name, referenceName: table.name, externalName: table.name,
        properties: properties,
        createSQL: table.creationSQL.isEmpty ? nil : table.creationSQL,
        triggersSQL: triggers.compactMap { $0.sql.isEmpty ? nil : $0.sql },
        indiciesSQL: indices .compactMap { $0.sql.isEmpty ? nil : $0.sql }
      )
      entities.append(entity)
    }
    
    for view in schema.views {
      let triggers = schema.triggers[view.name] ?? []
      
      let properties = view.columns.map {
        EntityInfo.Property(schema: $0, foreignKey: nil)
      }
      
      let entity = EntityInfo(
        type: .view,
        name: view.name, referenceName: view.name, externalName: view.name,
        properties  : properties,
        createSQL   : view.creationSQL.isEmpty ? nil : view.creationSQL,
        triggersSQL : triggers.compactMap { $0.sql.isEmpty ? nil : $0.sql },
        indiciesSQL : []
      )
      entities.append(entity)
    }

    self.init(name: name, userVersion: schema.userVersion, entities: entities)
  }
}

extension EntityInfo.Property {
  
  init(schema: Schema.Column, foreignKey: Schema.ForeignKey?) {
    self.name         = schema.name
    self.externalName = schema.name
    self.columnType   = schema.type
    self.defaultValue = schema.defaultValue
    self.isPrimaryKey = schema.isPrimaryKey
    self.isNotNull    = schema.isNotNull
    self.foreignKey   = foreignKey

    if let type = schema.type {
      switch type {
        case .integer       : self.propertyType = .integer
        case .real          : self.propertyType = .double
        case .text          : self.propertyType = .string
        case .blob          : self.propertyType = .uint8Array
        case .any           : self.propertyType = .string // right?
        case .boolean       : self.propertyType = .bool
        case .varchar       : self.propertyType = .string
        case .date          : self.propertyType = .string // right?
        case .datetime      : self.propertyType = .string // right?
        case .timestamp     : self.propertyType = .date
        case .decimal       : self.propertyType = .decimal
        case .custom("URL") : self.propertyType = .url
        case .custom        : self.propertyType = .string
      }
    }
    else { // No type assigned, use .string
      self.propertyType = .string
    }
  }
}
