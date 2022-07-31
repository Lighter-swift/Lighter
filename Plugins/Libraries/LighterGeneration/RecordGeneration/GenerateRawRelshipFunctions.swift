//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {
  
  /**
   * Generate a `find` function for a toOne relationship.
   *
   * ```swift
   * // let person = sqlite3_people_find(db, for: address)
   * // let owner  = sqlite3_people_find(db, forOwner: address)
   * // Unsupported:
   * // let person = address.findPerson(in: db)
   * // let owner  = address.findOwner (in: db)
   * ```
   *
   * - Parameters:
   *   - entity:       The "source" entity, the one containing the foreign key.
   *   - relationship: The to-one relationship of the find.
   *   - name:         Optional name of the function (defaults to `find`).
   */
  func generateRawFind(for entity: EntityInfo, relationship: EntityInfo.ToOne,
                       name: String = "find") -> FunctionDefinition
  {
    let dest    = relationship.destinationEntity
    let kw      = relationship.isPrimary ? "for" : ("for" + relationship.name)
    
    let isTypeFunc = options.rawFunctions == .attachToRecordType
    let funcName   = isTypeFunc
        ? (name + relationship.name)
        : functionName(for: dest, operation: name)
    
    return .init(
      declaration: .init(
        public: options.public, name: funcName, parameters: isTypeFunc
        ? [ .init(keyword: "in", name: "db", type: .name("OpaquePointer!")) ]
        : [ .init(name: "db", type: .name("OpaquePointer!")),
            .init(keyword: kw, name: "record", type: globalTypeRef(of: entity))
        ],
        returnType: .optional(globalTypeRef(of: dest))
      ),
      statements: findBody(for: entity, relationship: relationship),
      comment: generateRawFindComment(for: entity, relationship: relationship,
                                      name: name),
      inlinable: options.inlinable
    )
  }
  
  private func generateRawFindComment(for entity: EntityInfo,
                                      relationship: EntityInfo.ToOne,
                                      name: String) -> FunctionComment
  {
    let dest    = relationship.destinationEntity
    let selfRef = entity.name == dest.name
    let kw      = relationship.isPrimary ? "for" : ("for" + relationship.name)
    
    let isTypeFunc = options.rawFunctions == .attachToRecordType
    let funcName   = isTypeFunc
    ? name + relationship.name
    : functionName(for: dest, operation: name)
    
    return FunctionComment(
      headline:
        "Fetch the ``\(dest.name)`` record related to "
      + (selfRef
         ? "itself (`\(relationship.sourcePropertyName)`)."
         : "an ``\(entity.name)`` (`\(relationship.sourcePropertyName)`)."),
      info:
        """
        This fetches the related ``\(dest.name)`` record using the
        ``\(entity.name)/\(relationship.sourcePropertyName)`` property.
        """,
      example:
        "let sourceRecord  : \(entity.name) = ...\n"
      + (isTypeFunc
         ? "let relatedRecord = sourceRecord.\(funcName)(in: db)"
         : "let relatedRecord = \(funcName)(db, \(kw): sourceRecord)" ),
      parameters: isTypeFunc
      ? [ .init(name: "db",
                info: "The SQLite database handle (as returned by `sqlite3_open`)" ),
      ]
      : [ .init(name: "db",
                info: "The SQLite database handle (as returned by `sqlite3_open`)" ),
          .init(name: "record", info: "The ``\(entity.name)`` record.")
      ],
      returnInfo:
        "The related ``\(dest.name)`` record, or `nil` if not found/error."
    )
  }

  
  fileprivate func findBody(for entity: EntityInfo,
                            relationship: EntityInfo.ToOne) -> [ Statement ]
  {
    let destTypeName = globalName(of: relationship.destinationEntity)
    
    guard let fkeyProperty = entity[relationship.sourcePropertyName] else {
      return [ .raw("// Code Generation Error, missing " +
                    "\(relationship.sourcePropertyName)") ]
    }
    
    /// let indices = Person.Schema.selectColumnIndices
    let letSelectColumnIndices = Statement.let("indices", is:
        .variablePath([destTypeName, api.recordSchemaName, "selectColumnIndices"])
    )
    
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
      .return(.call(name: destTypeName, parameters: [
        ( nil, .variable("statement") ),
        ( "indices", .variable("indices") )
      ]))
    ]
        
    let fkey = fkeyProperty.foreignKey?.destinationColumn
    ?? relationship.destinationEntity.primaryKeyProperties.first?.externalName
    ?? "<unexpected generation error>"
    
    return [
      // let sql = customSQL ?? Person.Schema.matchSelect
      .var("sql",
           .variablePath([ destTypeName, api.recordSchemaName, "select"])
      ),
      .call(instance: "sql", name: "append", .string(
        " WHERE \(escapeAndQuoteIdentifier(fkey)) = ? LIMIT 1"
      )),
      
      // Prepare Query
      .var("handle", type: .name("OpaquePointer?")),
      .raw("guard sqlite3_prepare_v2(db, sql, -1, &handle, nil) == SQLITE_OK,"),
      .raw("      let statement = handle else { return nil }"),
      .raw("defer { sqlite3_finalize(statement) }"),
    ] + bindPropertyToArgument(fkeyProperty, then: stepAndReturnNil)
  }
  
  /**
   * ```
   * // let addresses      = sqlite3_addresses_fetch(db, for: person)
   * // let ownedAddresses = sqlite3_addresses_fetch(db, forOwner: person)
   * // let addresses      = person.fetchAddresses(in: db)
   * // let ownedAddresses = person.fetchAddressesForOwner(in: db)
   * @inlinable
   * public func sqlite3_addresses_fetch(
   *   _ db: OpaquePointer!, for person: Person,
   *   orderBy orderBySQL: String? = nil, limit: Int? = nil
   * ) -> [ Address ]?
   * ```
   */
  func generateRawFetch(for destinationEntity: EntityInfo,
                        relationship: EntityInfo.ToMany,
                        name: String = "fetch") -> FunctionDefinition
  {
    let src = relationship.sourceEntity
    let kw  = "for" + (relationship.qualifierParameter ?? "")
    
    let isTypeFunc = options.rawFunctions == .attachToRecordType
    let funcName   = isTypeFunc
                   ? (name + relationship.name)
                   : functionName(for: src, operation: name)
    
    return .init(
      declaration: .init(
        public: options.public, name: funcName, parameters: isTypeFunc
        ? [ .init(keyword: "orderBy", name: "orderBySQL",
                  type: .optional(.string), defaultValue: .nil),
            .init(keyword: "limit",   name: "limit",
                  type: .optional(.int), defaultValue: .nil),
            .init(keyword: "in", name: "db", type: .name("OpaquePointer!")) ]
        : [ .init(name: "db", type: .name("OpaquePointer!")),
            .init(keyword: kw, name: "record",
                  type: globalTypeRef(of: destinationEntity)),
            .init(keyword: "orderBy", name: "orderBySQL",
                  type: .optional(.string), defaultValue: .nil),
            .init(keyword: "limit",   name: "limit",
                  type: .optional(.int), defaultValue: .nil)
        ],
        returnType: .optional(.array(globalTypeRef(of: src)))
      ),
      statements: fetchBody(for: destinationEntity, relationship: relationship),
      comment: generateRawFetchComment(
        for: destinationEntity, relationship: relationship, name: name
      ),
      inlinable: options.inlinable
    )
  }
  
  private func generateRawFetchComment(for destinationEntity: EntityInfo,
                                       relationship: EntityInfo.ToMany,
                                       name: String)
  -> FunctionComment
  {
    let src     = relationship.sourceEntity
    let selfRef = destinationEntity.name == src.name
    let kw      = "for" + (relationship.qualifierParameter ?? "")
    
    let isTypeFunc = options.rawFunctions == .attachToRecordType
    let funcName   = isTypeFunc
                   ? (name + relationship.name)
                   : functionName(for: src, operation: name)
    
    let srcDocRef = globalDocRef(of: src)
    let dstDocRef = globalDocRef(of: destinationEntity)
    let keyDocRef = globalDocRef(of: src,
                                 property: relationship.sourcePropertyName)
    
    return FunctionComment(
      headline:
        "Fetches the \(srcDocRef) records related to "
      + (selfRef
         ? "itself (`\(relationship.sourcePropertyName)`)."
         : "a \(dstDocRef) (`\(relationship.sourcePropertyName)`)."),
      info:
        """
        This fetches the related \(srcDocRef) records using the
        \(keyDocRef) property.
        """,
      example:
        "let record         : \(destinationEntity.name) = ...\n"
      + (isTypeFunc
         ? "let relatedRecords = record.\(funcName)(in: db)"
         : "let relatedRecords = \(funcName)(db, \(kw): record)"),
      parameters: isTypeFunc
      ? [ .init(name: "orderBySQL",
                info: "If set, some SQL that is added as an `ORDER BY` clause"
                + " (e.g. `name DESC`)." ),
          .init(name: "limit",
                info: "An optional fetch limit." ),
          .init(name: "db",
                info: "The SQLite database handle (as returned by `sqlite3_open`)" )
      ]
      : [ .init(name: "db",
                info: "The SQLite database handle (as returned by `sqlite3_open`)" ),
          .init(name: "record",
                info: "The \(dstDocRef) record."),
          .init(name: "orderBySQL",
                info: "If set, some SQL that is added as an `ORDER BY` clause"
                + " (e.g. `name DESC`)." ),
          .init(name: "limit",
                info: "An optional fetch limit." )
      ],
      returnInfo: "The related \(srcDocRef) records."
    )
  }
  
  fileprivate func fetchBody(for destinationEntity: EntityInfo,
                             relationship: EntityInfo.ToMany)
                   -> [ Statement ]
  {
    let src = relationship.sourceEntity
    
    guard let fkeyProperty = src[relationship.sourcePropertyName],
          let fkey = fkeyProperty.foreignKey else
    {
      return [ .raw("// Code Generation Error, missing " +
                    "\(relationship.sourcePropertyName)") ]
    }
    guard let sourceProperty =
            destinationEntity[externalName: fkey.destinationColumn] else
    {
      return [ .raw("// Code Generation Error, missing " +
                    "\(fkey.destinationColumn)") ]
    }
    
    let typeName = options.rawFunctions == .attachToRecordType
      ? src.name
      : globalName(of: src)
    
    /// let indices = customSQL != nil
    ///   ? Person.Schema.lookupColumnIndices(in: statement)
    ///   : Person.Schema.selectColumnIndices
    let letSelectColumnIndices = Statement.let("indices", is:
        .variablePath([
            typeName, api.recordSchemaName, "selectColumnIndices"
          ])
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
      .var("sql", .variablePath([
          globalName(of: src), api.recordSchemaName,
          "select"
        ])
      ),
      .call(instance: "sql", name: "append", .string(
        " WHERE \(escapeAndQuoteIdentifier(fkey.sourceColumn)) = ? LIMIT 1"
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
      ]
    + bindPropertyToArgument(sourceProperty, then: [
        // Run fetch loop
        letSelectColumnIndices, // let indices = ....
        // var records = [ Person ]()
        .var("records", .call(name: "[ \(globalName(of: src)) ]")),
        fetchLoop, // while true
        .return(.variable("records"))
      ])
  }
  
  // MARK: - Helpers
  
  fileprivate func bindPropertyToArgument(_ property: EntityInfo.Property,
                                          to parameterIndex: Int = 1,
                                          then: [ Statement ]) -> [ Statement ]
  {
    let source = options.rawFunctions == .attachToRecordType
               ? "self" : "record"
    
    // Optimize single non-null INT primary keys
    if property.propertyType == .integer {
      if property.isNotNull {
        return [
          .call(
            name: "sqlite3_bind_int64",
            .variable("statement"),
            .integer(parameterIndex),
            .cast(expression: .variable(source, property.name),
                  type: .int64)
          )
        ] + then
      }
      else {
        return [
          .ifLetElse(
            "fkey", .variable(source, property.name), [
              .call(
                name: "sqlite3_bind_int64",
                .variable("statement"),
                .integer(parameterIndex),
                .cast(expression: .variable("fkey"), type: .int64)
              )
            ], else: [
              .call(
                name: "sqlite3_bind_null",
                .variable("statement"),
                .integer(parameterIndex)
              )
            ]
          )
        ] + then
      }
    }
    else {
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
    #endif
      // Later: Implement me
      return [ .return(.raw("nil /* UNSUPPORTED PRIMARY KEY */")) ]
    }
  }
}
