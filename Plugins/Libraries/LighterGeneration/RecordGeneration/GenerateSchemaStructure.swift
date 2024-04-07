//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {

  /**
   * Returns `idx_lol` for `lol` property. The prefix is configurable
   * using ``Options-swift.struct/propertyIndexPrefix``.
   */
  func tupleUnsafeIndexName(for propertyName: String) -> String {
    // This should be removed
    options.propertyIndexPrefix + propertyName
  }
  
  /**
   * Retrieves the type of the property (using `type(for:)`) and then
   * returns a string for that.
   * Examples:
   * - `String`
   * - `String?`
   * - `[ UInt8 ]?`
   * It only expects named type references w/ optionality or arrays (only
   * thing used in property types).
   */
  private func typeString(for property: EntityInfo.Property) -> String {
    switch type(for: property) {
      case                  .name(let name)   : return name
      case .optional(       .name(let name))  : return name + "?"
      case           .array(.name(let name))  : return "[ \(name) ]"
      case .optional(.array(.name(let name))) : return "[ \(name) ]?"
      default:
        fatalError(
          "Unsupported type for property \(property): \(type(for: property))"
        )
    }
  }

  /// `MappedColumn<Person, Int?>`
  private func mappedColumnTypeName(for property : EntityInfo.Property,
                                    in    entity : EntityInfo) -> String
  {
    let typeString = typeString(for: property) // Hmmm
    return "\(api.mappedColumnType)<\(globalName(of: entity)), \(typeString)>"
  }
  
  private func makeMappedColumn(for property : EntityInfo.Property,
                                in    entity : EntityInfo) -> Expression
  {
    let typeString = typeString(for: property) // Hmmm
    
    // This assumes that the destination of the ForeignKey is indeed not
    // itself an fkey?
    // But otherwise it could recurse?
    if let fkey       = property.foreignKey,
       let destEntity = database[externalName: fkey.destinationTable],
       let destProp   = destEntity[externalName: fkey.destinationColumn],
       destProp.foreignKey == nil // for now
    {
      // Destination column: `MappedColumn<Person, Int>`
      let destTypeName = mappedColumnTypeName(for: destProp, in: destEntity)
      /* Foreign Key w/ destination
       MappedForeignKey<Address, Int, MappedColumn<Person, Int>>(
         externalName: "person_id", defaultValue: -1, keyPath: \.personId,
         destinationColumn: Person.schema.personId
       )
       */
      return .call( // Foreign key!
        name: "\(api.mappedForeignKeyType)"
            + "<\(globalName(of: entity)), \(typeString), \(destTypeName)>",
        parameters: [
          ( "externalName" , .string(property.externalName)              ),
          ( "defaultValue" , nonOptionalDefaultValue(for: property)      ),
          ( "keyPath"      , .keyPath(globalTypeRef(of: entity),property.name)),
          ( "destinationColumn", .variablePath([
            globalName(of: destEntity),
            api.recordSchemaVariableName, destProp.name
          ]))
        ]
      )
    }
    else { // regular column
      return .call(
        name: mappedColumnTypeName(for: property, in: entity),
        parameters: [
          ( "externalName" , .string(property.externalName)              ),
          ( "defaultValue" , nonOptionalDefaultValue(for: property)      ),
          ( "keyPath"      , .keyPath(globalTypeRef(of: entity), property.name))
        ]
      )
    }
  }
  
  func generateSchemaStructure(for entity: EntityInfo) -> Struct {
    var typeVariables = [ Struct.InstanceVariable ]()
    
    // Type Variables
    
    typeVariables += [
      .let("externalName", is: .string(entity.externalName),
           comment:
            "The SQL table name associated with the ``\(entity.name)`` record."),
      .let("columnCount", type: .int32,
           is: .integer(entity.properties.count),
           comment:
            "The number of columns the `\(entity.externalName)` table has.")
    ]

    if options.useLighter && !entity.hasCompoundPrimaryKey,
       let primaryKey = entity.properties.first(where: \.isPrimaryKey)
    {
      typeVariables.append(
        .let("primaryKeyColumn",
             is: makeMappedColumn(for: primaryKey, in: entity),
             comment:
              "Information on the records primary key (``\(entity.name)/\(primaryKey.name)``)."
      ))
    }
    
    if !options.readOnly && !options.omitCreationSQL,
       let sql = entity.createSQL, !sql.isEmpty
    {
      func cleanup(_ sql: String) -> String {
        var trimmed = sql.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.hasSuffix(";") { trimmed += ";" }
        return trimmed
      }
      
      if entity.type == .table {
        typeVariables.append(.let(
          "create", is: .string(cleanup(sql)),
          comment: "The SQL used to create the `\(entity.externalName)` table."
        ))
        if !entity.indiciesSQL.isEmpty {
          typeVariables.append(.let(
            "createIndex",
            is: .string(entity.indiciesSQL.map(cleanup).joined()),
            comment:
              "The SQL used to create the indices for `\(entity.externalName)`."
          ))
        }
      }
      else {
        typeVariables.append(.let(
          "create", is: .string(cleanup(sql)),
          comment: "The SQL used to create the `\(entity.externalName)` view."
        ))
      }
      if !entity.triggersSQL.isEmpty {
        typeVariables.append(.let(
          "createTrigger",
          is: .string(entity.triggersSQL.map(cleanup).joined()),
          comment:
            "The SQL used to create the triggers for `\(entity.externalName)`."
        ))
      }
    }
    
    typeVariables += [
      .let("select", is: .string(entity.selectSQL),
           comment: "SQL to `SELECT` all columns of the `\(entity.externalName)` table."),
      .let("selectColumns", is: .string(entity.selectColumnsSQL),
           comment: "SQL fragment representing all columns."),
      .let("selectColumnIndices", type: .name(api.propertyIndicesType),
           is: .tuple(entity.properties.indices.map { .integer($0) }),
           comment: "Index positions of the properties in ``selectColumns``.")
    ]
    if options.generateSwiftFilters {
      let funcName = matcherFunction(for: entity)
      typeVariables.append(
        .let(
          "matchSelect", is: .string(
            "\(entity.selectSQL) WHERE \(funcName)(\(entity.selectColumnsSQL)) != 0"
          ),
          comment: "SQL to `SELECT` all columns of the `\(entity.externalName)` "
                 + "table using a Swift filter.")
      )
    }

    if options.readOnly {
      if entity.type == .table && options.useLighter {
        // for Lighter, we still need those for table conformance
        let comment = "*Note*: Readonly database, do not use."
        typeVariables += [
          .let("update", is: .string(""), comment: comment),
          .let("updateParameterIndices", type: .name(api.propertyIndicesType),
               is: .tuple(.init(repeating: .integer(-1),
                                count: entity.properties.count)),
               comment: comment),
          .let("insert", is: .string(""), comment: comment),
          .let("insertReturning", is: .string(""), comment: comment),
          .let("insertParameterIndices", type: .name(api.propertyIndicesType),
               is: .tuple(.init(repeating: .integer(-1),
                                count: entity.properties.count)),
               comment: comment),
          .let("delete", is: .string(""), comment: comment),
          .let("deleteParameterIndices", type: .name(api.propertyIndicesType),
               is: .tuple(.init(repeating: .integer(-1),
                                count: entity.properties.count)),
               comment: comment)
        ]
      }
    }
    else {
      if entity.canUpdate, let sql = entity.updateSQL {
        typeVariables += [
          .let("update", is: .string(sql),
               comment:
                "SQL to `UPDATE` all columns of the `\(entity.externalName)` table."),
          .let("updateParameterIndices", type: .name(api.propertyIndicesType),
               is: .tuple(entity.updateParameterIndices.map { .integer($0) }),
               comment: "Property parameter indicies in the ``update`` SQL")
        ]
      }
      if entity.canInsert {
        typeVariables += [
          .let("insert", is: .string(entity.insertSQL),
               comment:
                "SQL to `INSERT` a record into the `\(entity.externalName)` table."),
          .let("insertReturning", is: .string(entity.insertReturningSQL),
               comment:
                "SQL to `INSERT` a record into the `\(entity.externalName)` table."),
          .let("insertParameterIndices", type: .name(api.propertyIndicesType),
               is: .tuple(entity.insertParameterIndices.map { .integer($0) }),
               comment: "Property parameter indicies in the ``insert`` SQL")
        ]
      }
      if entity.canDelete {
        typeVariables += [
          .let("delete", is: .string(entity.deleteSQL),
               comment:
                "SQL to `DELETE` a record from the `\(entity.externalName)` table."),
          .let("deleteParameterIndices", type: .name(api.propertyIndicesType),
               is: .tuple(entity.deleteParameterIndices.map { .integer($0) }),
               comment: "Property parameter indicies in the ``delete`` SQL")
        ]
      }
    }

    // Struct
    
    var typeAliases : [ ( name: String, type: TypeReference ) ] = [
      ( api.propertyIndicesType, generatePropertyIndicesType(for: entity) ),
      ( api.schemaRecordType, globalTypeRef(of: entity) )
    ]
    if options.generateSwiftFilters {
      // MatchClosureType = ( Person ) -> Bool
      typeAliases.append( ( "MatchClosureType", .closure(
        escaping: false, parameters: [ globalTypeRef(of: entity) ],
        throws: false, returns: .bool
      )))
    }
    
    var typeFunctions = [ generateIndexLookup(for: entity) ]
    
    if options.generateSwiftFilters {
      typeFunctions += [
        generateRegisterSwiftMatcher(for: entity),
        generateUnregisterSwiftMatcher(for: entity)
      ]
    }
    
    var computedProps = [ ComputedPropertyDefinition ]()
    if options.useLighter {
      computedProps.append(ComputedPropertyDefinition(
        public: options.public, name: "_allColumns",
        type: .array(.name("any SQLColumn")),
        statements: [
          .return(.array(entity.properties.map { .variable($0.name) }))
        ],
        minimumSwiftVersion: ( major: 5, minor: 7 )
      ))
    }

    return Struct(
      public: options.public, name: api.recordSchemaName,
      conformances: conformancesForSchemaType(entity).map { .name($0) },
      typeAliases: typeAliases,
      typeVariables: typeVariables,
      variables: !options.useLighter ? [] : entity.properties.map {
        .let($0.name, is: makeMappedColumn(for: $0, in: entity),
             comment:
              "Type information for property ``\(entity.name)/\($0.name)`` (`\($0.externalName)` column)."
            )
      },
      computedProperties: computedProps,
      typeFunctions: typeFunctions,
      functions: [
        .init(
          declaration: .makeInit(public: options.public),
          statements: []
        )
      ],
      comment: .init(
        headline:
          "Static type information for the ``\(entity.name)`` record (`\(entity.externalName)` SQL table).",
        info:
          """
          This structure captures the static SQL information associated with the
          record.
          It is used for static type lookups and more.
          """
      )
    )
  }
  
  /**
   * The type for
   * `typealias PropertyIndices = ( idx_lol: Int32, idx_name: String? )`
   * `typealias PropertyIndices = Int32` (single column)
   */
  private func generatePropertyIndicesType(for entity: EntityInfo) -> TypeReference {
    return entity.properties.count == 1 ? .int32 : .tuple(
      names: entity.properties.map {
        options.propertyIndexPrefix + $0.name
      },
      types: .init(repeating: .int32, count: entity.properties.count)
    )
  }
  
  /*
   public static func lookupColumnIndices(in statement: OpaquePointer!)
                      -> PropertyIndices
   */
  func generateIndexLookup(for entity: EntityInfo) -> FunctionDefinition {
    .init(
      /*
       public static func lookupColumnIndices(in statement: OpaquePointer)
       -> PropertyIndices
       */
      declaration: .call(
        api.lookupColumnIndices,
        returns: .name(api.propertyIndicesType),
        .init(keyword: "in", name: "statement",
              type: .name("OpaquePointer!"))
      ),
      statements: [
        .var("indices", type: .name(api.propertyIndicesType),
             .tuple(Array(repeating: .integer(-1),
                          count: entity.properties.count))),
        .forInRange(
          counter: "i", from: .integer(0),
          to: .call(name: "sqlite3_column_count", .variable("statement")),
          statements: [
            .constantDefinition(
              name: "col",
              value: .call(name: "sqlite3_column_name",
                           .variable("statement"), .variable("i"))
            ),
            // could be made faster by returning early and by only strcmp
            // when the idx is not yet set
            .ifElseSwitch(
              entity.properties.map {
                .init( // ConditionStatementPair
                  // TBD: allow generation w/ strcasecmp?
                  // Note: On Linux we must force-unwrap the column! (i.e.
                  //       `strcmp` doesn't allow NULL).
                  .callIs0("strcmp", .variable("col!"),
                           .string($0.externalName)),
                  [
                    entity.properties.count == 1
                    ? .set("indices", .variable("i")) // not a tuple
                    : .set(instance: "indices",
                           tupleUnsafeIndexName(for: $0.name),
                           .variable("i"))
                  ]
                )
              }
            )
          ]
        ),
        .return(.variable("indices"))
      ],
      comment: .init(
        headline:
          "Lookup property indices by column name in a statement handle.",
        info:
          """
          Properties are ordered in the schema and have a specific index
          assigned.
          E.g. if the record has two properties, `id` and `name`,
          and the query was `SELECT age, \(entity.externalName)_id FROM \(entity.externalName)`,
          this would return `( idx_id: 1, idx_name: -1 )`.
          Because the `\(entity.externalName)_id` is in the second position and `name`
          isn't provided at all.
          """,
        parameters: [
          .init(name: "statement",
                info: "A raw SQLite3 prepared statement handle.")
        ],
        returnInfo:
          "The positions of the properties in the prepared statement."
      ),
      inlinable: true
    )
  }
  
  
  // MARK: - Conformances
  
  func conformancesForSchemaType(_ entity: EntityInfo) -> [ String ] {
    guard options.useLighter else { return [] } // Schema has no conf in raw
    
    var conformances  = [ String ]()
    
    switch entity.type {
      case .table:
        if entity.hasPrimaryKey && !entity.hasCompoundPrimaryKey {
          conformances.append(api.keyedTableSchemaType)
        }
        else {
          conformances.append(api.tableSchemaType)
        }
        
      case .view:
        conformances.append(options.api.viewSchemaType)
        if entity.canUpdate { conformances.append(api.updatableSchema) }
        if entity.canInsert { conformances.append(api.insertableSchema)}
        if entity.canDelete { conformances.append(api.deletableSchema) }
    }
    
    if options.generateSwiftFilters {
      conformances.append(api.swiftMatchableSchemaType)
    }
    
    if !options.readOnly && !(entity.createSQL?.isEmpty ?? true) {
      conformances.append(api.creatableSchema)
    }
    
    return conformances
  }
}
