//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {

  func generateRecordRelshipExtensions(`async`: Bool = false) -> [ Extension ] {
    assert(options.useLighter)
    
    var entityToExtension = [ String : Extension ]()
    
    for entity in database.entities {
      for relationship in entity.toOneRelationships {
        let key    = relationship.destinationEntity.name
        let finder = generateFind(for: entity, relationship: relationship,
                                  async: `async`)
        if entityToExtension[key] != nil {
          entityToExtension[key]?.functions.append(finder)
        }
        else {
          entityToExtension[key] = generateRecordRelshipExtension(
            for: relationship.destinationEntity, async: `async`,
            functions: [ finder ]
          )
        }
      }
    }
    
    for entity in database.entities {
      for relationship in entity.toManyRelationships {
        let key     = relationship.sourceEntity.name
        let fetcher = generateFetch(for: entity, relationship: relationship,
                                    async: `async`)
        if entityToExtension[key] != nil {
          entityToExtension[key]?.functions.append(fetcher)
        }
        else {
          entityToExtension[key] = generateRecordRelshipExtension(
            for: relationship.sourceEntity, async: `async`,
            functions: [ fetcher ]
          )
        }
      }
    }

    return database.entities.compactMap { // to preserve the order
      entityToExtension[$0.name]
    }
  }

  func generateRecordRelshipExtension(for entity: EntityInfo,
                                      `async`: Bool = false,
                                      functions: [ FunctionDefinition ] = [])
       -> Extension
  {
    assert(options.useLighter)
    
    let ops = `async`
      ? (api.dbFetchOperationsProtocol + " & " + api.dbAyncOperationsProtocol)
      : api.dbFetchOperationsProtocol
    
    let constraints : [ GenericConstraint ] = [
      .equal(name: "T", type: globalTypeRef(of: entity)),
      .conformance(name: "Ops",
                   type: .name(ops)),
      .equal(name: "Ops.\(api.recordTypeLookupTarget)",
             type: .qualifiedType(baseName: database.name,
                                  name: api.recordTypeLookupTarget))
    ]
    
    return Extension(
      extendedType: .name(api.recordFetchOperationsProtocol),
      public: options.public,
      genericConstraints: constraints,
      functions: functions,
      minimumSwiftVersion: `async` ? ( 5, 5 ) : nil,
      requiredImports: `async` ? [ "_Concurrency" ] : []
    )
  }
  
  /**
   * Generate a `find` function for a toOne relationship.
   *
   * ```swift
   * // let person = try db.people.find(for: address)
   * // let owner  = try db.people.find(forOwner: address)
   * @inlinable
   * func find(for address: Address) throws -> Person? {
   *   try operations[dynamicMember: \.addresses]
   *     .findTarget(for: \.personId, in: address)
   * }
   * ```
   *
   * - Parameters:
   *   - entity:       The "source" entity, the one containing the foreign key.
   *   - relationship: The to-one relationship of the find.
   *   - async:        Whether an async func should be generated.
   *   - name:         Optional name of the function (defaults to `find`).
   */
  func generateFind(for entity: EntityInfo, relationship: EntityInfo.ToOne,
                    `async`: Bool = false, name: String = "find")
  -> FunctionDefinition
  {
    let dest    = relationship.destinationEntity
    let kw      = relationship.isPrimary ? "for" : ("for" + relationship.name)
    let isOpt   = !(entity[relationship.sourcePropertyName]?.isNotNull ?? false)
    
    let call = Expression.call(
      try: true, await: async,
      instance: "operations[dynamicMember: \\.\(entity.referenceName)]",
      name: "findTarget", parameters: [
        ( "for" , .keyPath(nil, relationship.sourcePropertyName) ),
        ( "in"  , .variable("record") )
      ]
    )
    let throwError = Statement.raw(
      "throw LighterError(.couldNotFindRelationshipTarget, SQLITE_CONSTRAINT)"
    )
    
    return .init(
      declaration: .init(
        public: options.public, name: name, parameters: [
          .init(keyword: kw, name: "record", type: globalTypeRef(of: entity))
        ],
        async: `async`, throws: true,
        returnType:
          isOpt ? .optional(globalTypeRef(of: dest)): globalTypeRef(of: dest)
      ),
      statements: isOpt ? [ .return(call) ] : [
        .ifLetElse("record", call, [ .return(.variable("record")) ],
                   else:           [ throwError ])
      ],
      comment: generateFindComment(for: entity, relationship: relationship,
                                   async: `async`, name: name),
      inlinable: options.inlinable
    )
  }
  private func generateFindComment(for entity: EntityInfo,
                                   relationship: EntityInfo.ToOne,
                                   `async`: Bool, name: String)
  -> FunctionComment
  {
    let isOpt = !(entity[relationship.sourcePropertyName]?.isNotNull ?? false)
    let kw    = relationship.isPrimary ? "for" : ("for" + relationship.name)
    let dest        = relationship.destinationEntity
    let selfRef     = entity.name == dest.name
    let dstDocName  = globalDocRef(of: dest)
    let srcDocName  = globalDocRef(of: entity)
    let fkeyDocName = globalDocRef(of: entity,
                                   property: relationship.sourcePropertyName)
    
    return FunctionComment(
      headline:
        "Fetch the \(dstDocName) record related to "
      + (selfRef
         ? "itself (`\(relationship.sourcePropertyName)`)."
         : "a \(srcDocName) (`\(relationship.sourcePropertyName)`)."),
      info:
        """
        This fetches the related \(dstDocName) record using the
        \(fkeyDocName) property.
        """,
      example:
        "let sourceRecord  : \(entity.name) = ...\n"
      + "let relatedRecord = "
      + "try \(`async` ? "await " : "")db.\(dest.referenceName).\(name)("
      + "\(kw): sourceRecord)",
      parameters: [
        .init(name: "record", info: "The ``\(entity.name)`` record.")
      ],
      throws: true,
      returnInfo:
        isOpt
      ? "The related \(dstDocName) record, or `nil` if not found."
      : "The related \(dstDocName) record (throws if not found)."
    )
  }
  
  /**
   * ```
   * // let addresses      = try db.addresses.fetch(for: person)
   * // let ownedAddresses = try db.addresses.fetch(forOwner: person)
   * @inlinable
   * func fetch(for person: Person, limit: Int? = nil)
   *        throws -> [ Address ]
   * {
   *   try fetch(for: \.personId, in: person, limit: limit)
   * }
   * ```
   */
  func generateFetch(for destinationEntity: EntityInfo,
                     relationship: EntityInfo.ToMany,
                     `async`: Bool = false, name: String = "fetch")
  -> FunctionDefinition
  {
    let src = relationship.sourceEntity
    let kw  = "for" + (relationship.qualifierParameter ?? "")
    
    return .init(
      declaration: .init(
        public: options.public, name: name, parameters: [
          .init(keyword: kw, name: "record",
                type: globalTypeRef(of: destinationEntity)),
          .init(keywordArg: "limit", .optional(.int), .nil)
        ],
        async: `async`, throws: true,
        returnType: .array(globalTypeRef(of: src))
      ),
      statements: [
        .return(.call(
          try: true, await: `async`, name: "fetch", parameters: [
            ( "for"   , .keyPath(nil, relationship.sourcePropertyName) ),
            ( "in"    , .variable("record") ),
            ( "limit" , .variable("limit")  )
          ]
        ))
      ],
      comment: generateFetchComment(
        for: destinationEntity, relationship: relationship,
        async: `async`, name: name
      ),
      inlinable: options.inlinable
    )
  }
  
  private func generateFetchComment(for destinationEntity: EntityInfo,
                                    relationship: EntityInfo.ToMany,
                                    `async`: Bool = false, name: String = "fetch")
               -> FunctionComment
  {
    
    let src         = relationship.sourceEntity
    let kw          = "for" + (relationship.qualifierParameter ?? "")
    let selfRef     = destinationEntity.name == src.name
    let dstDocName  = globalDocRef(of: destinationEntity)
    let srcDocName  = globalDocRef(of: src)
    let fkeyDocName = globalDocRef(of: src,
                                   property: relationship.sourcePropertyName)
    
    return FunctionComment(
     headline:
       "Fetches the \(srcDocName) records related to "
     + (selfRef
        ? "itself (`\(relationship.sourcePropertyName)`)."
        : "a \(dstDocName) (`\(relationship.sourcePropertyName)`)."),
     info:
       """
       This fetches the related \(dstDocName) records using the
       \(fkeyDocName) property.
       """,
     example:
       "let record         : \(destinationEntity.name) = ...\n"
     + "let relatedRecords = "
     + "try \(`async` ? "await " : "")db.\(src.referenceName).\(name)("
     + "\(kw): record)",
     parameters: [
       .init(name: "record",
             info: "The \(dstDocName) record."),
       .init(name: "limit",
             info: "An optional limit of records to fetch (defaults to `nil`).")
     ],
     throws: true,
     returnInfo: "The related ``\(destinationEntity.name)`` records."
   )
  }
}
