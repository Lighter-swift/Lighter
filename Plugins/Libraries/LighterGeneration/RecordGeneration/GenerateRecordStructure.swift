//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import Foundation
import LighterCodeGenAST

extension EnlighterASTGenerator {
  
  func ivar(_ name: String) -> Expression {
    .variableReference(instance: options.qualifiedSelf ? "self" : nil,
                       name: name)
  }
  
  func generateRecordStructure(for entity: EntityInfo) -> Struct {
    var idProperty   : ComputedPropertyDefinition? = nil
    var compoundPKey : Struct?
    
    // MARK: - Primary Key
    
    if let primaryKey = entity.properties.first(where: \.isPrimaryKey) {
      if entity.hasCompoundPrimaryKey {
        compoundPKey = generateCompoundIDStruct(for: entity)
        idProperty   = generateID(for: entity.primaryKeyProperties, in: entity)
        // Later: add `SQLKeyedTableRecord` once supported
      }
      else if nil == entity["id"] {
        idProperty = generateID(for: primaryKey, in: entity)
      }
    }
        
    return Struct(
      public             : options.public,
      name               : entity.name,
      conformances       : conformancesForRecordType(entity).map { .name($0) },
      structures         : compoundPKey.flatMap({ [ $0 ] }) ?? [],
      typeVariables      : [
        .let("schema", is: .call(name: "Schema"),
             comment:
              "Static SQL type information for the ``\(entity.name)`` record.")
      ],
      variables          : entity.properties.map { property in
          .var(property.name  , type(for: property),
               comment: commentForPropertyVariable(property))
      },
      computedProperties : idProperty.flatMap({ [ $0 ] }) ?? [],
      functions          : [ buildRegularInitForEntity(entity) ],
      comment            : generateCommentForRecordStruct(entity)
    )
  }
  
  
  // MARK: - Initializer
  
  func buildInitParameter(_ property: EntityInfo.Property)
       -> FunctionDeclaration.Parameter
  {
    FunctionDeclaration.Parameter(
      keyword: property.name, name: property.name,
      type: type(for: property),
      defaultValue: defaultValue(for: property) ?? {
        if property.isPrimaryKey {
          if property.propertyType == .uuid {
            // If the primary key is a UUID, generate a default value for that.
            return .call(name: "UUID")
          }
        }
        return nil
      }()
    )
  }
  
  func buildRegularInitForEntity(_ entity: EntityInfo) -> FunctionDefinition {
    return FunctionDefinition(
      declaration: .init(
        public: options.public, name: "init",
        parameters: entity.properties.map { buildInitParameter($0) }
      ),
      statements: entity.properties.map {
        .set(instance: "self", $0.name, .variable($0.name))
      },
      comment: .init(
        headline: "Initialize a new ``\(entity.name)`` record.",
        parameters: entity.properties.map {
          .init(name: $0.name, info: commentForPropertyVariable($0))
        }
      ),
      inlinable: options.inlinable
    )
  }
  
  func commentForPropertyVariable(_ property: EntityInfo.Property) -> String {
    let defaultValue = defaultValue(for: property)
    let prefix       = property.isPrimaryKey ? "Primary key" : "Column"
    let sqlType      = property.columnType ?? .any
    
    var ms = "\(prefix) `\(property.externalName)` (`\(sqlType.rawValue)`), "
    ms += property.isNotNull ? "required"    : "optional"
    switch defaultValue {
      case .none                         : break // no defaults
      case .literal(.nil)                : ms += " (default: `nil`)"
      case .literal(.integer(let value)) : ms += " (default: `\(value)`)"
      case .literal(.double (let value)) : ms += " (default: `\(value)`)"
      case .literal(.string (let value)) :
        if value.isEmpty { ms += " (empty string as default)" }
        else { ms += " (has default string #\(value.count))" }
      default: // this is hit w/ complex expressions!
        ms += " (has default)"
    }
    ms += "."
    return ms
  }
  
  
  // MARK: - Conformances
  
  func conformancesForRecordType(_ entity: EntityInfo) -> [ String ] {
    var conformances  = [ String ]()
    
    if entity.type == .table, entity.properties.contains(where: \.isPrimaryKey)
    {
      conformances.append("Identifiable")
    }
    
    if options.useLighter {
      // MARK: - Lighter Record Type
      switch entity.type {
        case .table:
          // Later: Support compound keys in `SQLKeyedTableRecord`
          if entity.hasPrimaryKey && !entity.hasCompoundPrimaryKey {
            conformances.append(api.keyedTableRecordType)
          }
          else {
            conformances.append(api.tableRecordType) // SQLTableRecord, no keys
          }
          
        case .view:
          conformances.append(options.api.viewRecordType)
          if !options.readOnly {
            if entity.canUpdate { conformances.append(api.updatableRecord)  }
            if entity.canInsert { conformances.append(api.insertableRecord) }
            if entity.canDelete { conformances.append(api.deletableRecord)  }
          }
      }
    }
    else {
      if options.markRawStructsAsHashable { conformances.append("Hashable") }
    }

    conformances.append(contentsOf: options.extraRecordConformances)
    
    return conformances
  }
  
  
  // MARK: - Primary Keys
  
  func generateID(for primaryKey: EntityInfo.Property, in entity: EntityInfo)
       -> ComputedPropertyDefinition
  {
    .var(
      public: options.public, inlinable: options.inlinable,
      "id", type(for: primaryKey),
      comment: "Returns the primary key (``\(primaryKey.name)``)",
      .return(ivar(primaryKey.name))
    )
  }
  
  func generateID(for primaryKeys: [ EntityInfo.Property ],
                  in entity: EntityInfo) -> ComputedPropertyDefinition
  {
    let names = primaryKeys.map { $0.name }.joined(separator: ", ")
    return .var(
      public: options.public, inlinable: options.inlinable, "id", .name("ID"),
      comment: "Returns the compound primary key of ``\(entity.name)`` (\(names)).",
      .return(.call(name: "ID", parameters: primaryKeys.map { property in
        ( nil, ivar(property.name) )
      }))
    )
  }
  
  func generateCompoundIDStruct(for entity: EntityInfo) -> Struct {
    let pkeys = entity.primaryKeyProperties
    return Struct(
      public: options.public, name: "ID",
      conformances: [ .name("Hashable") ],
      variables: pkeys.map { property in
        .let(public: options.public, property.name, type(for: property),
             comment: nil)
      },
      functions: [ // the init of the compound `ID` structure
        FunctionDefinition(
          declaration: FunctionDeclaration(
            public: options.public, name: "init",
            parameters: pkeys.map {
              .init(name: $0.name, type: type(for: $0),
                    defaultValue: defaultValue(for: $0))
            }
          ),
          statements: pkeys.map {
            .variableAssignment(instance: "self", name: $0.name,
                                value: .variable($0.name))
          },
          comment: .init(
            headline: "Initialize a compound ``\(entity.name)`` ``ID``",
            info: nil,
            parameters: pkeys.map {
              .init(name: $0.name,
                    info: "Value of ``\(entity.name)/\($0.name)``.")
            }
          ),
          inlinable: options.inlinable
        )
                 ],
      comment: .init(
        headline:
          "ID structure representing the compound key of ``\(entity.name)``."
      )
    )
  }
  
  
  // MARK: - Comment
  
  func generateCommentForRecordStruct(_ entity: EntityInfo) -> TypeComment {
    let isReadOnly = options.readOnly || entity.isReadOnly
    var examples = [ TypeComment.Example ]()
    
    let attr1 = entity.properties.first(where: { $0.propertyType == .string })?
                      .name
             ?? "textProperty"
    
    if options.useLighter {
      examples.append(.init(
        headline: "Perform record operations on ``\(entity.name)`` records:",
        code:
          isReadOnly
        ? """
          let records = try await db.\(entity.referenceName).filter(orderBy: \\.\(attr1)) {
            $0.\(attr1) != nil
          }
          """
        : """
          let records = try await db.\(entity.referenceName).filter(orderBy: \\.\(attr1)) {
            $0.\(attr1) != nil
          }
          
          try await db.transaction { tx in
            var record = try tx.\(entity.referenceName).find(2) // find by primaryKey
            
            record.\(attr1) = "Hunt"
            try tx.update(record)
          
            let newRecord = try tx.insert(record)
            try tx.delete(newRecord)
          }
          """
      ))
      
      if options.generateSelectExamples {
        examples.append(.init(
          headline:
            "Perform column selects on the `\(entity.externalName)` table:",
          code:
            """
            let values = try await db.select(from: \\.\(entity.referenceName), \\.\(attr1)) {
              $0.in([ 2, 3 ])
            }
            """
        ))
      }
    }
    
    let mode = isReadOnly ? "SQLITE_OPEN_READONLY" : "SQLITE_OPEN_READWRITE"
    switch options.rawFunctions {
      case .omit: break
      case .attachToRecordType:
        var comment =
        """
        var db : OpaquePointer?
        sqlite3_open_v2(path, &db, \(mode), nil)
        
        \(isReadOnly ? "let" : "var") records = \(entity.name).fetch(in: db, orderBy: "\(attr1)", limit: 5) {
          $0.\(attr1) != nil
        }
        """
        
        if !isReadOnly {
          if entity.canUpdate {
            comment +=
            """
            
            records[1].\(attr1) = "Hunt"
            records[1].update(in: db)
            
            """
          }
          if entity.canDelete || entity.canInsert { comment += "\n" }
          if entity.canDelete {
            comment += "records[0].delete(in: db])\n"
          }
          if entity.canInsert {
            comment += "records[0].insert(db) // re-add\n"
          }
        }
        examples.append(.init(
          headline: "Perform low level operations on ``\(entity.name)`` records:",
          code: comment
        ))
      case .globalFunctions(let prefix):
        let rawPrefix = "\(prefix)\(entity.pluralRawName)"

        var comment =
        """
        var db : OpaquePointer?
        sqlite3_open_v2(path, &db, \(mode), nil)
        
        \(isReadOnly ? "let" : "var") records = \(rawPrefix)_fetch(db, orderBy: "\(attr1)", limit: 5) {
          $0.\(attr1) != nil
        }!
        """
        
        if !isReadOnly {
          if entity.canUpdate {
            comment +=
            """
            
            records[1].\(attr1) = "Hunt"
            \(rawPrefix)_update(db, records[1])
            
            """
          }
          if entity.canDelete || entity.canInsert { comment += "\n" }
          if entity.canDelete {
            comment += "\(rawPrefix)_delete(db, records[0])\n"
          }
          if entity.canInsert {
            comment += "\(rawPrefix)_insert(db, records[0]) // re-add\n"
          }
        }
        examples.append(.init(
          headline: "Perform low level operations on ``\(entity.name)`` records:",
          code: comment
        ))
    }
    
    var sqls = [ TypeComment.Example ]()
    if options.includeCreationSQLInComments,
       let sql = entity.createSQL, !sql.isEmpty
    {
      sqls.append(.init(
        headline:
          entity.type == .table
          ? "The SQL used to create the table associated with the record:"
          : "The SQL used to create the view associated with the record:",
        code: sql,
        language: "sql"
      ))
      
      if !entity.triggersSQL.isEmpty {
        sqls += entity.triggersSQL.map {
          .init(
            headline: "Triggers associated with the record:",
            code: $0,
            language: "sql"
          )
        }
      }
      
      if !entity.indiciesSQL.isEmpty {
        sqls += entity.indiciesSQL.map {
          .init(
            headline: "Indices associated with the record:",
            code: $0,
            language: "sql"
          )
        }
      }
    }

    return TypeComment(
      headline: "Record representing the `\(entity.externalName)` SQL \(entity.type == .table ? "table" : "view").",
      info:
        """
        Record types represent rows within tables&views in a SQLite database.
        They are returned by the functions or queries/filters generated by
        Enlighter.
        """,
      examples: examples, sql: sqls
    )
  }
}
