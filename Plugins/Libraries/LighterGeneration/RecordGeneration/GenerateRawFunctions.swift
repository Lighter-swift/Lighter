//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {
  // This could use a little refactoring
  
  private func isSupportedKeyProperty(_ property: EntityInfo.Property?) -> Bool
  {
    guard let property = property else { return false }
    return property.propertyType == .integer
  }


  func generateRawTypeFunctions(for entity: EntityInfo)
       -> [ FunctionDefinition ]
  {
    guard options.rawFunctions == .attachToRecordType else { return [] }
    return generateRawFetchFunctions(for: entity)
  }
  
  private func generateRawFetchFunctions(for entity: EntityInfo)
               -> [ FunctionDefinition ]
  {
    var functions = [ FunctionDefinition ]()
    
    if options.generateSwiftFilters {
      functions.append(
        generateRawSwiftMatchFetch(for: entity, defaultFilter: true))
    }
    functions.append(generateRawSQLFetch(for: entity))
  
    // Later: support other primary keys
    if let primaryKey = entity.properties.first(where: \.isPrimaryKey),
       isSupportedKeyProperty(primaryKey), primaryKey.isNotNull,
       !entity.hasCompoundPrimaryKey
    {
      functions.append(generateRawSQLFind(for: entity, primaryKey: primaryKey))
    }
    
    return functions
  }

  func generateRawFunctions(for entity: EntityInfo) -> [ FunctionDefinition ] {
    guard options.rawFunctions != .omit else { return [] }
    
    var functions = [ FunctionDefinition ]()
    
    if !options.readOnly {
      if entity.canInsert { functions.append(generateRawInsert(for: entity)) }
      if entity.canUpdate && entity.updateSQL != nil {
        functions.append(generateRawUpdate(for: entity))
      }
      if entity.canDelete { functions.append(generateRawDelete(for: entity)) }
    }
    
    switch options.rawFunctions {
      case .attachToRecordType, .omit: break
      case .globalFunctions:
        functions += generateRawFetchFunctions(for: entity)
    }
    
    if options.generateRawRelationships {
      for relationship in entity.toOneRelationships {
        guard isSupportedKeyProperty(entity[relationship.sourcePropertyName])
        else {
          // Later: support other foreign keys
          continue
        }
        functions.append(
          generateRawFind(for: entity, relationship: relationship))
      }
      for relationship in entity.toManyRelationships {
        guard isSupportedKeyProperty(
          relationship.sourceEntity[relationship.sourcePropertyName]) else
        {
          // Later: support other foreign keys
          continue
        }
        functions.append(
          generateRawFetch(for: entity, relationship: relationship))
      }
    }
    
    return functions
  }
  
  func generateRawRecordFunctions(for entity: EntityInfo) -> Extension {
    var functions = [ FunctionDefinition ]()

    if !options.readOnly {
      if entity.canInsert { functions.append(generateRawInsert(for: entity)) }
      if entity.canUpdate && entity.updateSQL != nil {
        functions.append(generateRawUpdate(for: entity))
      }
      if entity.canDelete { functions.append(generateRawDelete(for: entity)) }
    }
    
    var typeFunctions = [ FunctionDefinition ]()
    // TBD: is this ambiguous for `fetch(sql: "X")`? Probably not.
    if options.generateSwiftFilters {
      typeFunctions.append(
        generateRawSwiftMatchFetch(for: entity, defaultFilter: true))
    }
    typeFunctions.append(generateRawSQLFetch(for: entity))
    
    // Later: support other primary keys
    if let primaryKey = entity.properties.first(where: \.isPrimaryKey),
       primaryKey.propertyType == .integer, primaryKey.isNotNull,
       !entity.hasCompoundPrimaryKey
    {
      typeFunctions.append(
        generateRawSQLFind(for: entity, primaryKey: primaryKey))
    }
    
    if options.generateRawRelationships {
      for relationship in entity.toOneRelationships {
        guard isSupportedKeyProperty(entity[relationship.sourcePropertyName])
        else {
          // Later: support other foreign keys
          continue
        }
        functions.append(
          generateRawFind(for: entity, relationship: relationship))
      }
      for relationship in entity.toManyRelationships {
        guard isSupportedKeyProperty(
                relationship.sourceEntity[relationship.sourcePropertyName]) else
        {
          // Later: support other foreign keys
          continue
        }
        functions.append(
          generateRawFetch(for: entity, relationship: relationship))
      }
    }

    return Extension(
      extendedType  : globalTypeRef(of: entity),
      typeFunctions : typeFunctions,
      functions     : functions
    )
  }
  
  
  // MARK: - Helpers
  
  fileprivate static var stepAndReturnError : [ Statement ] { [
    .let("rc", is: .call(name: "sqlite3_step", .variable("statement"))),
    .return(
      .conditional(
        .raw("rc != SQLITE_DONE && rc != SQLITE_ROW"), // FIXME
        .call(name: "sqlite3_errcode", .variable("db")),
        .variable("SQLITE_OK")
      )
    )
  ] }

  private func prepareSQL(_ schemaSQLProperty: String, for entity: EntityInfo)
               -> [ Statement ]
  {
    [ .let("sql", is: .variablePath([ entity.name, api.recordSchemaName,
                                      schemaSQLProperty])) ]
    + Self.prepareSQL
  }
  static var prepareSQL : [ Statement ] { [
    // Could use `Self` for record attached funcs
    .var("handle", type: .name("OpaquePointer?")),
    .raw("guard sqlite3_prepare_v2(db, sql, -1, &handle, nil) == SQLITE_OK,"),
    .raw("      let statement = handle else { return sqlite3_errcode(db) }"),
    .raw("defer { sqlite3_finalize(statement) }")
  ] }
  
  func functionName(for entity: EntityInfo, operation: String) -> String {
    switch options.rawFunctions {
      case .omit: return operation
      case .attachToRecordType: return operation
      case .globalFunctions(let prefix):
        return operation == "fetch"
          ? "\(prefix)\(entity.pluralRawName)_\(operation)"
          : "\(prefix)\(entity.singularRawName)_\(operation)"
    }
  }
  
  private func generateRawComment(for entity: EntityInfo,
                                  title: String, name: String,
                                  example: String? = nil)
  -> FunctionComment
  {
    var defaultExample : String? {
      let name = functionName(for: entity, operation: name)
      switch options.rawFunctions {
      case .omit: return nil
      case .attachToRecordType:
        switch name {
        case "find"  :
          return """
                  let record = \(entity.name).\(name)(in: db, pkey)
                  assert(record != nil)
                  """
        case "fetch"  :
          return """
                  let records = \(entity.name).\(name)(from: db)
                  assert(records != nil)
                  """
        case "insert" :
          return """
                  var record = \(entity.name)(...values...)
                  let rc = record.\(name)(into: db)
                  assert(rc == SQLITE_OK)
                  """
        case "delete" :
          return """
                  let rc = record.\(name)(from: db)
                  assert(rc == SQLITE_OK)
                  """
        case "update" :
          return """
                  let rc = record.\(name)(in: db)
                  assert(rc == SQLITE_OK)
                  """
        default       : return nil
        }
      case .globalFunctions:
        if name == "insert" {
          return """
              var record = \(entity.name)(...values...)
              let rc = \(name)(db, &record)
              assert(rc == SQLITE_OK)
              """
        }
        else {
          return """
              let rc = \(name)(db, record)
              assert(rc == SQLITE_OK)
              """
        }
      }
    }
    
    return FunctionComment(
      headline:
        "\(title) a ``\(entity.name)`` record in the SQLite database.",
      info:
        """
        This operates on a raw SQLite database handle (as returned by
        `sqlite3_open`).
        """,
      example: example ?? defaultExample,
      parameters: options.rawFunctions == .attachToRecordType
      ? [ .init(name: "db", info: "SQLite3 database handle.") ]
      : [ .init(name: "db", info: "SQLite3 database handle."),
          .init(name: "record",
                info: "The ``\(entity.name)`` record to \(name).") ],
      returnInfo:
        "The SQLite error code (of `sqlite3_prepare/step`), e.g. `SQLITE_OK`."
    )
  }
  
  
  // MARK: - Functions
  
  /**
   * ```swift
   * @discardableResult
   * func sqlite3_persons_delete(_ db: OpaquePointer!, _ record: Person) -> Int32 {
   *   let sql = Person.Schema.delete
   *   let indices = Person.Schema.deleteParameterIndices
   *
   *   var maybeStmt : OpaquePointer?
   *   guard sqlite3_prepare_v2(db, sql, -1, &maybeStmt, nil) == SQLITE_OK,
   *         let statement = maybeStmt else
   *   {
   *     assertionFailure("Failed to prepare delete SQL \(sql)")
   *     return sqlite3_errcode(db)
   *   }
   *   defer { sqlite3_finalize(statement) }
   *
   *   return record.bind(to: statement, indices: indices) {
   *     let rc = sqlite3_step(statement)
   *     return (rc != SQLITE_DONE && rc != SQLITE_ROW)
   *            ? sqlite3_errcode(db) : SQLITE_OK
   *   }
   *   OR:
   *   sqlite3_bind_int64(statement, 1, Int64(record.personId))
   *
   *   let rc = sqlite3_step(statement)
   *   return (rc != SQLITE_DONE && rc != SQLITE_ROW)
   *          ? sqlite3_errcode(db) : SQLITE_OK
   * }
   * ```
   */
  func generateRawDelete(for entity: EntityInfo) -> FunctionDefinition {
    assert(entity.canDelete)
    
    // Optimize single non-null INT primary keys
    var bindAndReturn : [ Statement ] {
      if let primaryKey = entity.properties.first(where: \.isPrimaryKey),
         primaryKey.propertyType == .integer, primaryKey.isNotNull,
         !entity.hasCompoundPrimaryKey
      {
        return [
          .call(
            name: "sqlite3_bind_int64",
            .variable("statement"),
            .integer(entity.indexOfProperty(primaryKey) + 1),
            .cast(expression: options.rawFunctions == .attachToRecordType
                  ? ivar(primaryKey.name)
                  : .variable("record", primaryKey.name),
                  type: .int64)
          )
        ] + Self.stepAndReturnError
      }
      else {
        return [ .return(.call(
          instance:
            options.rawFunctions == .attachToRecordType ? "self" : "record",
          name: "bind",
          parameters: [ ( "to", .variable("statement") ),
                        ( "indices", .variablePath([
                          options.rawFunctions == .attachToRecordType
                          ? entity.name
                          : globalName(of: entity),
                          api.recordSchemaName,
                          "deleteParameterIndices"]) ) ],
          trailing: ( [], Self.stepAndReturnError )
        ))]
      }
    }
    
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public : options.public,
        name   : functionName(for: entity, operation: "delete"),
        parameters: options.rawFunctions == .attachToRecordType
        ? [ .init(keyword: "from", name: "db", type: .name("OpaquePointer!")) ]
        : [ .init(name: "db",     type: .name("OpaquePointer!")),
            .init(name: "record", type: globalTypeRef(of: entity)) ],
        returnType: .int32
      ),
      statements: prepareSQL("delete", for: entity) + bindAndReturn,
      comment: generateRawComment(for: entity, title: "Delete", name: "delete"),
      inlinable: true, discardableResult: true
    )
  }
  
  /**
   * ```swift
   * func sqlite3_persons_update(_ db: OpaquePointer!, _ record: Person) -> Int32 {
   *   let sql = Person.Schema.update
   *
   *   var maybeStmt : OpaquePointer?
   *   guard sqlite3_prepare_v2(db, sql, -1, &maybeStmt, nil) == SQLITE_OK,
   *         let statement = maybeStmt else
   *   {
   *     assertionFailure("Failed to prepare update SQL \(sql)")
   *     return sqlite3_errcode(db)
   *   }
   *   defer { sqlite3_finalize(statement) }
   *
   *   return record.bind(to: statement,
   *                      indices: Person.Schema.updateParameterIndices)
   *   {
   *     let rc = sqlite3_step(statement)
   *     return (rc != SQLITE_DONE && rc != SQLITE_ROW)
   *          ? sqlite3_errcode(db) : SQLITE_OK
   *   }
   * }
   */
  func generateRawUpdate(for entity: EntityInfo) -> FunctionDefinition {
    assert(entity.canUpdate)
    
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public : options.public,
        name   : functionName(for: entity, operation: "update"),
        parameters: options.rawFunctions == .attachToRecordType
        ? [ .init(keyword: "in", name: "db", type: .name("OpaquePointer!")) ]
        : [
          .init(name: "db",     type: .name("OpaquePointer!")),
          .init(name: "record", type: globalTypeRef(of: entity))
        ],
        returnType: .int32
      ),
      statements: prepareSQL("update", for: entity) + [ .return(.call(
        instance:
          options.rawFunctions == .attachToRecordType ? "self" : "record",
        name: "bind",
        parameters: [ ( "to", .variable("statement") ),
                      ( "indices", .variablePath([
                        globalName(of: entity), api.recordSchemaName,
                        "updateParameterIndices"]) ) ],
        trailing: ( [], Self.stepAndReturnError )
      ))],
      comment: generateRawComment(for: entity, title: "Update", name: "update"),
      inlinable: true, discardableResult: true
    )
  }
  
  /**
   * ```swift
   * @discardableResult
   * func sqlite3_persons_insert(_ db: OpaquePointer!, _ record: inout Person)
   *      -> Int32
   * {
   *   let sql = Person.Schema.insert
   *
   *   var maybeStmt : OpaquePointer?
   *   guard sqlite3_prepare_v2(db, sql, -1, &maybeStmt, nil) == SQLITE_OK,
   *         let statement = maybeStmt else
   *   {
   *     assertionFailure("Failed to prepare insert SQL \(sql)")
   *     return sqlite3_errcode(db)
   *   }
   *   defer { sqlite3_finalize(statement) }
   *
   *   return record.bind(to: statement,
   *                      indices: Person.Schema.insertParameterIndices)
   *   {
   *     let rc = sqlite3_step(statement)
   *     if      rc == SQLITE_DONE { return SQLITE_OK }
   *     else if rc != SQLITE_ROW  { return sqlite3_errcode(db) }
   *     record = Person(statement, indices: Person.Schema.selectColumnIndices)
   *     return SQLITE_OK
   *   }
   * }
   * ```
   */
  func generateRawInsert(for entity: EntityInfo) -> FunctionDefinition {
    assert(entity.canUpdate)
    
    var comment = generateRawComment(
      for: entity, title: "Insert", name: "insert"
    )
    if comment.parameters.count > 1 {
      comment.parameters[1].info =
      "The record to insert. Updated with the actual table values "
      + "(e.g. assigned primary key)."
    }
    
    let entityName = options.rawFunctions == .attachToRecordType
        ? entity.name
        : globalName(of: entity)
    
    // record = Person(statement, indices: Person.Schema.selectColumnIndices)
    let recordInit = Expression.call(name: entityName, parameters: [
      ( nil, .variable("statement") ),
      ( "indices", .variablePath([ entityName, api.recordSchemaName,
                                   "selectColumnIndices" ]) )
    ])
    
    var fetchStepAndReturnError : [ Statement ] = [
      .let("rc", is: .call(name: "sqlite3_step", .variable("statement"))),
      .ifElseSwitch([ // stepAndReturnError w/o fallback
        .init(.cmp(.variable("rc"), .equal, .variable("SQLITE_DONE")),
              [ .return(.variable("SQLITE_OK")) ]),
        .init(.cmp(.variable("rc"), .notEqual, .variable("SQLITE_ROW")),
              [ .return(.call(name: "sqlite3_errcode", .variable("db"))) ] )
      ])
    ]
    if options.rawFunctions == .attachToRecordType {
      fetchStepAndReturnError += [
        // TBD: is this going to fail because of nested access to self?
        .let("record", is: recordInit),
        .raw("self = record") // workaround for escaped `self` when used as prop
      ]
    }
    else {
      fetchStepAndReturnError.append(.set("record", recordInit))
    }
    fetchStepAndReturnError.append(.return(.variable("SQLITE_OK")))
    var insertReturningImp : [ Statement ] {
      // this runs if we didn't get a record! (i.e. straight SQLITE_DONE)
      //let sql = T.Schema.select + " WHERE ROWID = last_insert_rowid();"
      [ .var("sql", .variablePath([ entity.name, api.recordSchemaName,
                                    "select"])),
        .call(instance: "sql", name: "append",
              .string(" WHERE ROWID = last_insert_rowid()"))
      ] + Self.prepareSQL + fetchStepAndReturnError
    }
    
    // options.provideRawInsertReturningFallback
    /* let rc = sqlite3_step(statement)
     * if      rc == SQLITE_DONE { return SQLITE_OK }
     * else if rc != SQLITE_ROW  { return sqlite3_errcode(db) }
     */
    var stepAndReturnError : [ Statement ] = [
      .let("rc", is: .call(name: "sqlite3_step", .variable("statement"))),
      .ifElseSwitch([
        .init(.cmp(.variable("rc"), .equal, .variable("SQLITE_DONE")),
              options.provideRawInsertReturningFallback
              ? insertReturningImp : []
              + [ .return(.variable("SQLITE_OK")) ]),
        .init(.cmp(.variable("rc"), .notEqual, .variable("SQLITE_ROW")),
              [ .return(.call(name: "sqlite3_errcode", .variable("db"))) ] )
      ])
    ]
    
    if options.rawFunctions == .attachToRecordType {
      stepAndReturnError += [
        // TBD: is this going to fail because of nested access to self?
        .let("record", is: recordInit),
        .raw("self = record") // workaround for escaped `self` when used as prop
      ]
    }
    else {
      stepAndReturnError.append(.set("record", recordInit))
    }
    stepAndReturnError.append(.return(.variable("SQLITE_OK")))
    
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public     : options.public,
        mutating   : options.rawFunctions == .attachToRecordType,
        name       : functionName(for: entity, operation: "insert"),
        parameters : options.rawFunctions == .attachToRecordType
        ? [ .init(keyword: "into", name: "db", type: .name("OpaquePointer!")) ]
        : [
          .init(name: "db",     type: .name("OpaquePointer!")),
          .init(name: "record", type: .inout(globalTypeRef(of: entity)))
        ],
        throws: options.generateThrowingFunctions,
        returnType: options.generateThrowingFunctions ? .void : .int32
      ),
      statements:
        //let sql = sqlite3_libversion_number() >= 30_35_000
        // ? Person.Schema.insertReturning : Person.Schema.insert
        [ .let("sql", is:
            .conditional(
              condition:
                .variableReference(instance: database.name,
                                   name: "useInsertReturning"),
              true: .variablePath([ entity.name, api.recordSchemaName,
                                    "insertReturning"]),
              false: .variablePath([ entity.name, api.recordSchemaName,
                                     "insert"])
            )
          )
        ] + Self.prepareSQL + [ .return(.call(
        instance:
          options.rawFunctions == .attachToRecordType ? "self" : "record",
        name: "bind",
        parameters: [ ( "to", .variable("statement") ),
                      ( "indices", .variablePath([
                        globalName(of: entity), api.recordSchemaName,
                        "insertParameterIndices"]) ) ],
        trailing: ( [], stepAndReturnError )
      ))],
      comment: comment,
      inlinable: true, discardableResult: !options.generateThrowingFunctions
    )
  }
  
  /**
   ```swift
   func sqlite3_person_fetch(_               db : OpaquePointer!,
   sql      customSQL : String? = nil,
   orderBy orderBySQL : String? = nil,
   limit              : Int? = nil,
   filter: @escaping ( Person ) -> Bool)
   -> [ Person ]?
   {
   return withUnsafePointer(to: filter) { ptr in
   // Register/Unregister SQLite function
   guard Person.Schema.registerSwiftMatcher(in: db, flags: SQLITE_UTF8,
   matcher: ptr) == SQLITE_OK else {
   return nil
   }
   defer {
   _ = Person.Schema.unregisterSwiftMatcher(in: db, flags: SQLITE_UTF8)
   }
   
   // Prepare Query
   
   var sql = customSQL ?? Person.Schema.matchSelect
   if let s = orderBySQL { sql += " ORDER BY \(s)" }
   if let v = limit      { sql += " LIMIT \(v)"    }
   
   var maybeStmt : OpaquePointer?
   guard sqlite3_prepare_v2(db, sql, -1, &maybeStmt, nil) == SQLITE_OK,
   let statement = maybeStmt else
   {
   assertionFailure("Failed to prepare SQL \(sql)")
   return nil
   }
   defer { sqlite3_finalize(statement) }
   
   // Run fetch loop
   
   let indices = customSQL != nil
   ? Person.Schema.lookupColumnIndices(in: statement)
   : Person.Schema.selectColumnIndices
   var records = [ Person ]()
   
   while true {
   let rc = sqlite3_step(statement)
   if      rc == SQLITE_DONE { break      }
   else if rc != SQLITE_ROW  { return nil }
   records.append(Person(statement, indices: indices))
   }
   
   return records
   }
   ```
   */
  fileprivate func generateRawSwiftMatchFetch(for entity: EntityInfo,
                                              defaultFilter: Bool = true)
  -> FunctionDefinition
  {
    assert(options.generateSwiftFilters)
    let isTypeFunc = options.rawFunctions == .attachToRecordType
    let funcName   = functionName(for: entity, operation: "fetch")
    
    let example = isTypeFunc
    ? """
        let records = \(entity.name).\(funcName)(in: db) { record in
          record.name != "Duck"
        }
        
        let records = \(entity.name).\(funcName)(in: db, orderBy: "name", limit: 5) {
          $0.firstname != nil
        }
        """
    : """
        let records = \(funcName)(db) { record in
          record.name != "Duck"
        }
        
        let records = \(funcName)(db, orderBy: "name", limit: 5) {
          $0.firstname != nil
        }
        """
    
    let callRegisterSwiftMatcher = Expression.call(
      instance: // Later: quoting
      isTypeFunc ? api.recordSchemaName
      : "\(globalName(of: entity)).\(api.recordSchemaName)",
      name: "registerSwiftMatcher",
      parameters: [
        ( "in"      , .variable("db")          ),
        ( "flags"   , .variable("SQLITE_UTF8") ),
        ( "matcher" , .variable("closurePtr")  )
      ]
    )
    let callUnregisterSwiftMatcher = Statement.call(
      instance: // Later: quoting
      "\(globalName(of: entity)).\(api.recordSchemaName)",
      name: "unregisterSwiftMatcher",
      parameters: [
        ( "in"      , .variable("db")          ),
        ( "flags"   , .variable("SQLITE_UTF8") )
      ]
    )
    
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public     : options.public,
        name       : funcName,
        parameters : [
          .init(keyword: isTypeFunc ? "from" : nil,
                name: "db",     type: .name("OpaquePointer!")),
          .init(keyword: "sql", name: "customSQL",
                type: .optional(.string), defaultValue: .nil),
          .init(keyword: "orderBy", name: "orderBySQL",
                type: .optional(.string), defaultValue: .nil),
          .init(keyword: "limit", name: "limit",
                type: .optional(.int), defaultValue: .nil),
          .init(keyword: "filter", name: "filter",
                type: .closure(
                  escaping   : true,
                  parameters : [
                    isTypeFunc ? .name(entity.name) : globalTypeRef(of: entity)
                  ],
                  throws     : false, returns: .bool
                ))
        ],
        returnType: .optional(.array(globalTypeRef(of: entity)))
      ),
      statements: [
        .return(
          .call(name: "withUnsafePointer",
                parameters: [ ( "to", .variable("filter") ) ],
                trailing: (
                  [ "closurePtr" ],
                  [
                    .guard(
                      .cmp(
                        callRegisterSwiftMatcher,
                        .equal,
                        .variable("SQLITE_OK")
                      ),
                      [ .return(.nil) ]
                    ),
                    .defer([
                      callUnregisterSwiftMatcher
                    ])
                  ]
                  + fetchBody(for: entity, select: "matchSelect")
                )
               )
        )
      ],
      comment: .init(
        headline:
          "Fetch ``\(entity.name)`` records, filtering using a Swift closure.",
        info:
          """
          This is fetching full ``\(entity.name)`` records from the passed in SQLite database
          handle. The filtering is done within SQLite, but using a Swift closure
          that can be passed in.
          
          Within that closure other SQL queries can be done on separate connections,
          but *not* within the same database handle that is being passed in (because
          the closure is executed in the context of the query).
          
          Sorting can be done using raw SQL (by passing in a `orderBy` parameter,
          e.g. `orderBy: "name DESC"`),
          or just in Swift (e.g. `fetch(in: db).sorted { $0.name > $1.name }`).
          Since the matching is done in Swift anyways, the primary advantage of
          doing it in SQL is that a `LIMIT` can be applied efficiently (i.e. w/o
          walking and loading all rows).
          
          If the function returns `nil`, the error can be found using the usual
          `sqlite3_errcode` and companions.
          """,
        example: example,
        parameters: [
          .init(name: "db",
                info: "The SQLite database handle (as returned by `sqlite3_open`)" ),
          .init(name: "sql",
                info: "Optional custom SQL yielding ``\(entity.name)`` records."),
          .init(name: "orderBySQL",
                info: "If set, some SQL that is added as an `ORDER BY` clause"
                + " (e.g. `name DESC`)." ),
          .init(name: "limit",
                info: "An optional fetch limit." ),
          .init(name: "filter",
                info: "A Swift closure used for filtering, taking the"
                + "``\(entity.name)`` record to be matched." )
        ],
        returnInfo:
          "The records matching the query, or `nil` if there was an error."
      ),
      inlinable: true
    )
  }
  
  fileprivate func fetchBody(for entity: EntityInfo, select: String)
                   -> [ Statement ]
  {
    let recordSchemaName = options.rawFunctions == .attachToRecordType
      ? api.recordSchemaName
      : "\(globalName(of: entity)).\(api.recordSchemaName)" // Later
    let typeName = options.rawFunctions == .attachToRecordType
      ? globalName(of: entity) // doesn't fly?: "Self"
      : globalName(of: entity)
    
    /// let indices = customSQL != nil
    ///   ? Person.Schema.lookupColumnIndices(in: statement)
    ///   : Person.Schema.selectColumnIndices
    let letSelectColumnIndices = Statement.let("indices", is:
        .conditional(
          .cmp(.variable("customSQL"), .notEqual, .nil),
          .call(
            instance: recordSchemaName,
            name: api.lookupColumnIndices,
            parameters: [ ( "in", .variable("statement") ) ]
          ),
          .variablePath([
            recordSchemaName, "selectColumnIndices"
          ])
        )
    )
    /**
     * ```swift
     * let rc = sqlite3_step(statement)
     * if      rc == SQLITE_DONE { break      }
     * else if rc != SQLITE_ROW  { return nil }
     * records.append(Person(statement, indices: indices))
     * ```
     */
    let fetchLoop = Statement.whileTrue([
      .let("rc", is: .call(name: "sqlite3_step", .variable("statement"))),
      
        .ifSwitch(
          ( .cmp(.variable("rc"), .equal,    .variable("SQLITE_DONE") ),
            .break ),
          ( .cmp(.variable("rc"), .notEqual, .variable("SQLITE_ROW")),
            .return(.nil) )
        ),
      
        .call(instance: "records", name: "append",
              .call(name: typeName, parameters: [
                ( nil,       .variable("statement") ),
                ( "indices", .variable("indices")   )
              ]))
    ])
    
    return [
      // var sql = customSQL ?? Person.Schema.matchSelect
      .var("sql", .nilCoalesce(
        .variable("customSQL"),
        .variablePath([
          globalName(of: entity), api.recordSchemaName,
          select
        ])
      )),
      
      // if let s = orderBySQL { sql += " ORDER BY \(s)" }
      .ifLet(
        "orderBySQL", is: .variable("orderBySQL"),
        then: .call(instance: "sql", name: "append",
                    .raw("\" ORDER BY \\(orderBySQL)\""))
      ),
      // if let v = limit      { sql += " LIMIT \(v)"    }
      .ifLet(
        "limit", is: .variable("limit"),
        then: .call(instance: "sql", name: "append",
                    .raw("\" LIMIT \\(limit)\""))
      ),
      
      // Prepare Query
      .var("handle", type: .name("OpaquePointer?")),
      .raw("guard sqlite3_prepare_v2(db, sql, -1, &handle, nil) == SQLITE_OK,"),
      .raw("      let statement = handle else { return nil }"),
      .raw("defer { sqlite3_finalize(statement) }"),
      
      // Run fetch loop
      
      letSelectColumnIndices, // let indices = ....
      // var records = [ Person ]()
      .var("records", .call(name: "[ \(typeName) ]")),
      fetchLoop, // while true
      .return(.variable("records"))
    ]
  }
  
  /**
   * This requires `sql`, but should it?
   *
   * ```swift
   * func sqlite3_person_fetch(_               db : OpaquePointer!,
   *                           sql                : String,
   *                           orderBy orderBySQL : String? = nil,
   *                           limit              : Int? = nil)
   *      -> [ Person ]?
   * ```
   */
  fileprivate func generateRawSQLFetch(for entity: EntityInfo)
                   -> FunctionDefinition
  {
    let isTypeFunc = options.rawFunctions == .attachToRecordType
    let funcName   = functionName(for: entity, operation: "fetch")
    
    let example = isTypeFunc
        ? """
          let records = \(entity.name).\(funcName)(
            from : db,
            sql  : #"SELECT * FROM \(entity.externalName)"#
          }
          
          let records = \(entity.name).\(funcName)(
            from    : db,
            sql     : #"SELECT * FROM \(entity.externalName)"#,
            orderBy : "name", limit: 5
          )
          """
        : """
          let records = \(funcName)(
            db, sql: #"SELECT * FROM \(entity.externalName)"#
          }
          
          let records = \(funcName)(
            db, sql: #"SELECT * FROM \(entity.externalName)"#,
            orderBy: "name", limit: 5
          )
          """
    
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public     : options.public,
        name       : funcName,
        parameters : [
          .init(keyword: isTypeFunc ? "from" : nil,
                name: "db",     type: .name("OpaquePointer!")),
          .init(keyword: "sql", name: "customSQL",
                type: .optional(.string), defaultValue: .nil),
          .init(keyword: "orderBy", name: "orderBySQL",
                type: .optional(.string), defaultValue: .nil),
          .init(keyword: "limit",   name: "limit",
                type: .optional(.int), defaultValue: .nil)
        ],
        returnType: .optional(.array(globalTypeRef(of: entity)))
      ),
      statements: fetchBody(for: entity, select: "select"),
      comment: .init(
        headline:
          "Fetch ``\(entity.name)`` records using the base SQLite API.",
        info:
          """
          If the function returns `nil`, the error can be found using the usual
          `sqlite3_errcode` and companions.
          """,
        example: example,
        parameters: [
          .init(name: "db",
                info: "The SQLite database handle (as returned by `sqlite3_open`)" ),
          .init(name: "sql",
                info: "Custom SQL yielding ``\(entity.name)`` records."),
          .init(name: "orderBySQL",
                info: "If set, some SQL that is added as an `ORDER BY` clause"
                + " (e.g. `name DESC`)." ),
          .init(name: "limit",
                info: "An optional fetch limit." )
        ],
        returnInfo:
          "The records matching the query, or `nil` if there was an error."
      ),
      inlinable: true
    )
  }
  
  fileprivate func generateRawSQLFind(for entity: EntityInfo,
                                      primaryKey: EntityInfo.Property)
  -> FunctionDefinition
  {
    let isTypeFunc = options.rawFunctions == .attachToRecordType
    let funcName   = functionName(for: entity, operation: "find")
    
    let example = isTypeFunc
        ? """
          if let record = \(entity.name).\(funcName)(10, in: db) {
            print("Found record:", record)
          }
          """
        : """
          let record = \(funcName)(db, 10) {
            print("Found record:", record)
          }
          """
    
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public     : options.public,
        name       : funcName,
        parameters : isTypeFunc
        ? [ .init(name: "primaryKey", type: type(for: primaryKey)),
            .init(keyword: isTypeFunc ? "in" : nil,
                  name: "db",     type: .name("OpaquePointer!")),
            .init(keyword: "sql", name: "customSQL",
                  type: .optional(.string), defaultValue: .nil)
            
        ]
        : [ .init(keyword: isTypeFunc ? "in" : nil,
                  name: "db",     type: .name("OpaquePointer!")),
            .init(keyword: "sql", name: "customSQL",
                  type: .optional(.string), defaultValue: .nil),
            .init(name: "primaryKey", type: type(for: primaryKey))
        ],
        returnType: .optional(globalTypeRef(of: entity))
      ),
      statements: findBody(for: entity, primaryKey: primaryKey),
      comment: .init(
        headline:
          "Fetch a ``\(entity.name)`` record the base SQLite API.",
        info:
          """
          If the function returns `nil`, the error can be found using the usual
          `sqlite3_errcode` and companions.
          """,
        example: example,
        parameters: [
          .init(name: "db",
                info: "The SQLite database handle (as returned by `sqlite3_open`)" ),
          .init(name: "sql",
                info: "Optional custom SQL yielding ``\(entity.name)`` records,"
                    + " has one `?` parameter containing the ID."),
          .init(name: "primaryKey",
                info: "The primary key value to lookup (e.g. `10`)")
        ],
        returnInfo:
          "The record matching the query, "
        + "or `nil` if it wasn't found or there was an error."
      ),
      inlinable: true
    )
  }
  
  
  fileprivate func findBody(for entity: EntityInfo,
                            primaryKey: EntityInfo.Property) -> [ Statement ]
  {
    let recordSchemaName = options.rawFunctions == .attachToRecordType
      ? api.recordSchemaName
      : "\(globalName(of: entity)).\(api.recordSchemaName)" // Later
    
    /// let indices = customSQL != nil
    ///   ? Person.Schema.lookupColumnIndices(in: statement)
    ///   : Person.Schema.selectColumnIndices
    let letSelectColumnIndices = Statement.let("indices", is:
        .conditional(
          .cmp(.variable("customSQL"), .notEqual, .nil),
          .call(
            instance: recordSchemaName,
            name: api.lookupColumnIndices,
            parameters: [ ( "in", .variable("statement") ) ]
          ),
          .variablePath([ recordSchemaName, "selectColumnIndices" ])
        )
    )
    let entityName = globalName(of: entity)
   
    /* let rc = sqlite3_step(statement)
     * if      rc == SQLITE_DONE { return nil }
     * else if rc != SQLITE_ROW  { return nil }
     * let indices ...
     * return Person(statement, indices: indices)
     */
    let stepAndReturnNil : [ Statement ] = [
      .let("rc", is: .call(name: "sqlite3_step", .variable("statement"))),
      .ifSwitch(
        ( .cmp(.variable("rc"), .equal, .variable("SQLITE_DONE")),
          .return(.nil) ), // not found, error will be SQLITE_OK
        ( .cmp(.variable("rc"), .notEqual, .variable("SQLITE_ROW")),
          .return(.nil) )  // error
      ),
      letSelectColumnIndices, // let indices = ....
      .return(.call(name: entityName, parameters: [
        ( nil, .variable("statement") ),
        ( "indices", .variable("indices") )
      ]))
    ]
    
    #if false
    // two remaining issues:
    // - the property _name_ is accessed (need a local variable, "primaryKey")
    // - `try` is not required, the compiler warns
    var bindAndReturn : [ Statement ] {
      let ( statement, didRecurse ) = // will print a warning because `1 >= 0`
        generateBindStatementForProperty(primaryKey, index: .integer(1),
                                         trailer: { stepAndReturnNil })
      return !didRecurse
        ? [ statement ] + stepAndReturnNil
        : [ statement ]
    }
    #else
    // Optimize single non-null INT primary keys
    var bindAndReturn : [ Statement ] {
      if let primaryKey = entity.properties.first(where: \.isPrimaryKey),
         primaryKey.propertyType == .integer, primaryKey.isNotNull,
         !entity.hasCompoundPrimaryKey
      {
        return [
          .call(
            name: "sqlite3_bind_int64",
            .variable("statement"),
            .integer(1),
            .cast(expression: .variable("primaryKey"), type: .int64)
          )
        ] + stepAndReturnNil
      }
      else {
        // Later: Implement me
        return [ .return(.raw("nil /* UNSUPPORTED PRIMARY KEY */")) ]
      }
    }
    #endif
    
    return [
      // let sql = customSQL ?? Person.Schema.matchSelect
      .var("sql", .nilCoalesce(
        .variable("customSQL"),
        .variablePath([ globalName(of: entity), api.recordSchemaName, "select"])
      )),
      .ifSwitch((
        .isNotNil(.variable("customSQL")),
        .call(instance: "sql", name: "append", .string(
          " WHERE \(escapeAndQuoteIdentifier(primaryKey.externalName)) = ? LIMIT 1"
        ))
      )),
      
      // Prepare Query
      .var("handle", type: .name("OpaquePointer?")),
      .raw("guard sqlite3_prepare_v2(db, sql, -1, &handle, nil) == SQLITE_OK,"),
      .raw("      let statement = handle else { return nil }"),
      .raw("defer { sqlite3_finalize(statement) }"),
    ] + bindAndReturn
  }
}

