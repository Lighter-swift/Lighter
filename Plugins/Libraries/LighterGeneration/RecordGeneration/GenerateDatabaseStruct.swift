//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {
  
  public func generateDatabaseStructure(moduleFileName: String? = nil)
              -> Struct
  {
    let typeAliases            = calculateClassTypeAliases()
    var structures             = [ Struct                     ]()
    var typeVariables          = [ Struct.InstanceVariable    ]()
    var variables              = [ Struct.InstanceVariable    ]()
    var computedTypeProperties = [ ComputedPropertyDefinition ]()
    var typeFunctions          = [ FunctionDefinition         ]()
    var functions              = [ FunctionDefinition         ]()

    if options.useLighter, let filename = moduleFileName {
      typeVariables.append(generateModuleSingleton(for: filename))
    }
    
    // Raw Functions

    if options.rawFunctions == .attachToRecordType {
      if shouldGenerateCreateSQL {
        typeFunctions.append(
          generateRawCreateFunction(name: "create",
                                    moduleFileName: moduleFileName)
        )
      }
      
      if let filename = moduleFileName {
        typeFunctions.append(
          generateRawModuleOpenFunction(name: "open", for: filename))
      }
    }

    // Record Struct

    if options.useLighter { // only w/ Lighter, right?
      structures.append(
        generateRecordTypesStruct(
          useAlias: typeAliases.isEmpty ? nil : options.recordTypeAliasSuffix
        )
      )
      typeVariables.append(
        .let(api.recordTypesVariable,
             is: .call(name: api.recordTypeLookupTarget),
             comment:
               "Property based access to the ``RecordTypes-swift.struct``.")
      )
    }
    
    // Schema version
    
    typeVariables.append(.var(
      public: options.public, "userVersion",
      is: .integer(database.userVersion),
      comment: "User version of the database (`PRAGMA user_version`)."
    ))

    // Nested Record Types (if requested)
    
    if options.nestRecordTypesInDatabase {
      structures += database.entities.map {
        generateRecordStructure(for: $0)
      }
    }
    
    // Whether SQLite3 supports returning (the user can override!)
  
    typeVariables.append(.var(
      public: options.public, "useInsertReturning",
      is: .cmp(
        .call(name: "sqlite3_libversion_number"),
        .greaterThanOrEqual,
        .integer(3035000)
      ),
      comment:
        "Whether `INSERT … RETURNING` should be used (requires SQLite 3.35.0+)."
    ))

    
    // DateFormatter
    
    if hasPropertiesOfType(.date) {
      let name    = "dateFormatter"
      let type    = TypeReference.optional(.name("DateFormatter"))
      let comment = "The `DateFormatter` used for parsing string date values."
      if options.useLighter {
        typeVariables.append(
          .var(public: false, "_\(name)", type, comment: comment)
        )
        computedTypeProperties.append(
          .var(public: options.public, inlinable: false,
               name, type,
               set: [ .set("_\(name)", .raw("newValue")) ],
               get: [ .return(.nilCoalesce(
                 .variable("_\(name)"),
                 .variable("Date", "defaultSQLiteDateFormatter")
               ))],
               comment: comment)
        )
      }
      else {
        typeVariables.append(
          .var(public: options.public, name, type: type,
               is: Self.defaultSQLiteDateFormatterExpression,
               comment: comment)
        )
      }
    }
    
    // Helper Functions when not using Lighter Binds
    
    if options.optionalHelpersInDatabase {
      typeFunctions += generateRequiredOptionalHelpers()
    }
    
    // Initializers
    
    if options.useLighter {
      // At least a `let` property with the name is required by Lighter.
      variables.append(
        .var(public: options.public, api.connectionHandler,
             .name(api.connectionHandlerType),
             comment:
              "The `connectionHandler` is used to open SQLite database connections.")
      )
      functions += generateLighterInitializers()
    }
    
    if !options.useLighter {
      structures.append(generateSQLError())
    }

    
    // Creation

    if shouldGenerateCreateSQL {
      computedTypeProperties.append(generateCreationSQL())
    }
    

    
    // Assemble the structure
    
    return Struct(
      dynamicMemberLookup    : options.useLighter,
      public                 : options.public,
      name                   : database.name,
      conformances           : dbTypeConformances,
      typeAliases            : typeAliases,
      structures             : structures,
      typeVariables          : typeVariables,
      variables              : variables,
      computedTypeProperties : computedTypeProperties,
      computedProperties     : [],
      typeFunctions          : typeFunctions,
      functions              : functions,
      comment                : generateDatabaseTypeComment()
    )
  }
  
  fileprivate func generateCreationSQL() -> ComputedPropertyDefinition {
    var statements = [ Statement ]()
    statements.append(.var("sql", .string("")))
    
    func appendToVar(_ entity: EntityInfo, property: String) -> Statement {
      .call(instance: "sql", name: "append",
        .variablePath([ globalName(of: entity), api.recordSchemaName,
                        property ])
      )
    }
    
    // Tables
    statements += database.entities
      .filter { $0.type == .table && $0.createSQL != nil }
      .map { appendToVar($0, property: "create") }
    
    // Indices (contains constraints)
    statements += database.entities
      .filter { $0.type == .table && !$0.indiciesSQL.isEmpty }
      .map { appendToVar($0, property: "createIndex") }

    // Views
    statements += database.entities.filter({ $0.type == .view })
      .filter { $0.type == .view && $0.createSQL != nil }
      .map { appendToVar($0, property: "create") }
    
    // All Triggers, Table and View
    statements += database.entities
      .filter { !$0.triggersSQL.isEmpty }
      .map { appendToVar($0, property: "createTrigger") }
    
    // User version
    if database.userVersion != 0 {
      statements.append(
        .call(instance: "sql", name: "append",
              .string("PRAGMA user_version = \(database.userVersion));"))
      )
    }

    statements.append(.return(.variable("sql")))
    return .var("creationSQL", .string, set: [], get: statements,
                comment:
                  "SQL that can be used to recreate the database structure.")
  }
  
  var shouldGenerateCreateSQL : Bool {
    if options.readOnly || options.omitCreationSQL { return false }
    // TBD: We could synthesize the SQL too?
    return database.entities.contains { $0.createSQL != nil }
  }
  
  fileprivate func generateLighterInitializers() -> [ FunctionDefinition ] {
    var defs = [ FunctionDefinition ]()
    
    if options.readOnly {
      defs.append(
        .init(
          declaration: .makeInit(public: options.public,
            .init(keywordArg: "url", .name("URL"))
          ),
          statements: [
            .raw(
              "self.\(api.connectionHandler) = .simplePool(url: url, readOnly: true)"
            )
          ],
          comment: .init(
            headline: "Initialize ``\(database.name)``, read-only, with a `URL`.",
            info:
              """
              Configures the database with a simple connection pool opening the
              specified `URL` read-only.
              """,
            example:
              """
              let db = \(database.name)(url: ...)
              
              // Write operations will raise an error.
              let readOnly = \(database.name)(
                url: Bundle.module.url(forResource: "samples", withExtension: "db")
              )
              """,
            parameters: [
              .init(name: "url",
                    info: "A `URL` pointing to the database to be used.")
            ]
          ),
          inlinable: options.inlinable
        )
      )
      // This is required for `SQLDatabase` protocol conformance.
      // "Unavailable" conflicts w/ protocol conformance.
      /* Later:
      @available(*, deprecated,
                  message: "Read only database.",
                  renamed: "init(url:)")
       */
      defs.append(
        .init(
          declaration: .makeInit(public: options.public,
            .init(keywordArg: "url", .name("URL")),
            .init(keywordArg: "readOnly", .bool, .true)
          ),
          statements: [
            .raw("self.init(url: url)")
          ],
          comment: .init(
            headline:
              "Initialize ``\(database.name)``, read-only, with a `URL`.",
            info:
              """
              Configures the database with a simple connection pool opening the
              specified `URL` read-only.
              """,
            example:
              """
              let db = \(database.name)(url: ...)
              
              // Write operations will raise an error.
              let readOnly = \(database.name)(
                url: Bundle.module.url(forResource: "samples", withExtension: "db")
              )
              """,
            parameters: [
              .init(name: "url",
                    info: "A `URL` pointing to the database to be used."),
              .init(name: "readOnly",
                    info:
                      "For protocol conformance, only allowed value: `true`.")
            ]
          ),
          inlinable: options.inlinable
        )
      )
    }
    else {
      defs.append(
        .init(
          declaration: .makeInit(public: options.public,
            .init(keywordArg: "url", .name("URL")),
            .init(keywordArg: "readOnly", .bool, .false)
          ),
          statements: [
            .raw(
              "self.\(api.connectionHandler) = .simplePool(url: url, readOnly: readOnly)"
            )
          ],
          comment: .init(
            headline: "Initialize ``\(database.name)`` with a `URL`.",
            info:
              """
              Configures the database with a simple connection pool opening the
              specified `URL`.
              And optional `readOnly` flag can be set (defaults to `false`).
              """,
            example:
              """
              let db = \(database.name)(url: ...)
              
              // Write operations will raise an error.
              let readOnly = \(database.name)(
                url: Bundle.module.url(forResource: "samples", withExtension: "db"),
                readOnly: true
              )
              """,
            parameters: [
              .init(name: "url",
                    info: "A `URL` pointing to the database to be used."),
              .init(name: "readOnly",
                    info: "Whether the database should be opened "
                        + "readonly (default: `false`).")
            ]
          ),
          inlinable: options.inlinable
        )
      )
    }
    defs.append(
      .init(
        declaration: .makeInit(public: options.public,
          .init(keywordArg: api.connectionHandler,
                .name(api.connectionHandlerType))
        ),
        statements: [
          .raw("self.\(api.connectionHandler) = \(api.connectionHandler)")
        ],
        comment: .init(
          headline:
            "Initialize ``\(database.name)`` w/ a `\(api.connectionHandlerType)`.",
          info:
            """
            `\(api.connectionHandlerType)`'s are used to open SQLite database connections when
            queries are run using the `Lighter` APIs.
            `\(api.connectionHandlerType)` is a protocol and custom handlers can
            be provided.
            """,
          example:
            """
            let db = \(database.name)(\(api.connectionHandler): .simplePool(
              url: Bundle.module.url(forResource: "samples", withExtension: "db"),
              readOnly: true,
              maxAge: 10,
              maximumPoolSizePerConfiguration: 4
            ))
            """,
          parameters: [
            .init(name: api.connectionHandler,
                  info: "The `\(api.connectionHandlerType)` to use w/ the "
                      + "database.")
          ]
        ),
        inlinable: options.inlinable
      )
    )
    return defs
  }
  
  fileprivate var dbTypeConformances : [ TypeReference ] {
    guard options.useLighter else { return [] } // Right?
    
    // shouldGenerateCreateSQL
    
    var conformances = [ TypeReference ]()
    conformances.append(.name("SQLDatabase"))

    // Note: The async protocols are even available if async itself is not
    //       available, so we can gen them and still have pre-async compat.
    //       No `#if swift(>=5.5) && canImport(_Concurrency)` necessary here.
    switch ( options.readOnly, options.asyncAwait ) {
      case ( false , false ): // r/w but no async/await
        conformances.append(.name("SQLDatabaseChangeOperations"))
      case ( true  , true  ): // r/o, w/ async/await
        conformances.append(.name("SQLDatabaseAsyncFetchOperations"))
      case ( false  , true  ): // r/w, w/ async/await
        conformances.append(.name("SQLDatabaseAsyncChangeOperations"))
      case ( true  , false  ): // r/o, no async/await
        conformances.append(.name("SQLDatabaseFetchOperations"))
    }
    
    if shouldGenerateCreateSQL {
      conformances.append(.name("SQLCreationStatementsHolder"))
    }
    return conformances
  }
  
  fileprivate func generateDatabaseTypeComment() -> TypeComment {
    var examples = [ TypeComment.Example ]()
    var info = ""
    
    // TBD: to sort or not
    if database.entities.isEmpty {
      info += "*This database has no views or tables?*\n\n"
    }
    else {
      let longestNameLength = database.entities.reduce(0) {
        max($0, $1.name.count)
      }
      
      let hasViews = database.entities.contains(where: { $0.type == .view })
      // TBD: Sort the entities?
      info +=
        """
        ### Database Schema
        
        The schema captures the SQLite table/view catalog as safe Swift types.
        
        """
      if database.entities.contains(where: { $0.type == .table }) {
        info += "\n#### Tables\n\n"
        for entity in database.entities where entity.type == .table {
          let len = entity.name.count
          let pad = String(repeating: " ", count: longestNameLength - len)
          info += "- ``\(entity.name)``\(pad) (SQL: `\(entity.externalName)`)\n"
        }
        if !hasViews && options.showViewHintComment {
          info +=
          """
          
          > Hint: Use [SQL Views](https://www.sqlite.org/lang_createview.html)
          >       to create Swift types that represent common queries.
          >       (E.g. joins between tables or fragments of table data.)
          """
        }
      }
      if hasViews {
        info += "\n#### Views\n\n"
        for entity in database.entities where entity.type == .view {
          let len = entity.name.count
          let pad = String(repeating: " ", count: longestNameLength - len)
          info += "- ``\(entity.name)``\(pad) (SQL: `\(entity.externalName)`)\n"
        }
      }
    }

    // Later: Examples for opening the database and such
    
    if let firstEntity = database.entities.first {
      examples += generateCommentForRecordStruct(firstEntity).examples
    }

    return TypeComment(
      headline : "A structure representing a SQLite database.",
      info     : info,
      examples : examples
    )
  }
  
  fileprivate func generateRequiredOptionalHelpers() -> [ FunctionDefinition ] {
    guard options.optionalHelpersInDatabase, !useLighterBinds else { return [] }

    var functions = [ FunctionDefinition ]()
    
    let hasDecimals = hasPropertiesOfType(.decimal)
    let hasOptionalStringBinds = containsProperties {
      if hasDecimals { return true } // always using withOptCString
      guard $0.propertyType != .uint8Array, $0.propertyType != .data,
            requiresBind($0) else { return false }
      if $0.propertyType == .date { return true } // always w/ withOptCString
      return !$0.isNotNull
    }
    let hasOptionalBlobBinds = containsProperties {
      $0.propertyType == .uint8Array && !$0.isNotNull && requiresBind($0)
    }
    let hasOptionalDataBinds = containsProperties {
      $0.propertyType == .data && !$0.isNotNull && requiresBind($0)
    }
    
    if hasOptionalStringBinds {
      // if we link Lighter, it has `withCString` defined
      functions.append(makeWithOptCString())
    }
    if hasOptionalBlobBinds {
      functions.append(makeWithOptBlob(name: "withOptBlob", type: .uint8Array))
    }
    if hasOptionalDataBinds {
      functions.append(makeWithOptBlob(name: "withOptDataBlob", type: .data))
    }
    if hasDecimals {
      functions.append(makeStringForDecimal())
    }
    
    if options.uuidStorageStyle == .blob && hasPropertiesOfType(.uuid) {
      functions.append(makeWithOptUUIDBytes())
    }
    
    return functions
  }
  
  /// This deals w/ the case when the "referenceName" of an entity is the same
  /// like the typename.
  /// E.g. typename "person", referenceName "person".
  /// If _any_ such happens, we generate an alias map.
  fileprivate func calculateClassTypeAliases()
                   -> [ ( name: String, type: TypeReference ) ]
  {
    guard let suffix = options.recordTypeAliasSuffix else { // xyzRecordType
      return [] // aliases are disabled
    }
    
    let referenceNames = Set(database.entities.map(\.referenceName))
    let typeNames      = Set(database.entities.map(\.name))
    if referenceNames.isDisjoint(with: typeNames) { return [] }
    
    return database.entities.map {
      ( $0.name + suffix, TypeReference.name($0.name) )
    }
  }
  
  /*
   public struct RecordTypes { // associated type
     public let persons   = Person.self
     public let addresses = Address.self
   }
   */
  fileprivate func generateRecordTypesStruct(useAlias suffix: String?) -> Struct
  {
    let firstEntity = database.entities.first ?? .init(name: "NoTypes")
    return Struct(
      public: options.public, name: api.recordTypeLookupTarget,
      variables: database.entities.map {
        let name = "\($0.name)\(suffix ?? "")"
        return .let(
          $0.referenceName, is: .raw("\(name).self"),
          comment:
            "Returns the \(name) type information (SQL: `\($0.externalName)`)."
        )
      },
      comment:
        .init(
          headline:
            "Mappings of table/view Swift types to their \"reference name\".",
          info:
            """
            The `RecordTypes` structure contains a variable for the Swift type
            associated each table/view of the database. It maps the tables
            "reference names" (e.g. ``\(firstEntity.referenceName)``) to the
            "record type" of the table (e.g. ``\(firstEntity.name)``.self).
            """
        )
    )
  }

  fileprivate func hasPropertiesOfType(_ type: EntityInfo.Property.PropertyType)
                   -> Bool
  {
    database.entities.contains { entity in
      entity.properties.contains { property in
        property.propertyType == type
      }
    }
  }
  fileprivate func containsProperties(
                     where condition: ( EntityInfo.Property ) -> Bool
                   )
                   -> Bool
  {
    database.entities.contains { entity in
      entity.properties.contains(where: { condition($0) })
    }
  }

  fileprivate static let defaultSQLiteDateFormatterExpression =
    Expression.inlineClosureCall([
      .let("formatter", is: .call(name: "DateFormatter")),
      .set(instance: "formatter", "dateFormat",
           .string("yyyy-MM-dd HH:mm:ss")),
      .set(instance: "formatter", "locale",
           .call(name: "Locale", parameters:
                  [ ("identifier", .string("en_US_POSIX"))])),
      .return(.variable("formatter"))
     ])
}
