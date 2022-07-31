//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {
  
  func requiresBind(_ property: EntityInfo.Property) -> Bool {
    switch property.propertyType {
      case .integer, .double, .bool: return false
      case .string, .uint8Array, .data, .url, .decimal: return true
      case .uuid: return true
      case .date: return true // edgy, tie to `DB.dateFormatter != nil`?
        // and/or Date.sqlDateStorageStyle for Lighter
      case .custom: return true
    }
  }
  fileprivate func index(for propertyName: String) -> Expression {
    .variable("indices", indexName(for: propertyName))
  }
  
  /// Whether to use the `SQLiteValueType` `bind` methods (needs
  /// ``Options-swift.struct/useLighter` enabled).
  var useLighterBinds : Bool {
    return options.useLighter && options.preferLighterBinds
  }
  fileprivate var isInlineHelperGenerationEnabled : Bool {
    guard !options.optionalHelpersInDatabase else { return false }
    return !useLighterBinds
  }
  
  func generateRecordStatementBind(for entity: EntityInfo) -> FunctionDefinition
  {
    var statements = [ Statement ]()
    
    if isInlineHelperGenerationEnabled {
      let hasDecimals = entity.properties.contains {
        $0.propertyType == .decimal
      }
      let hasOptionalStringBinds = entity.properties.contains {
        if hasDecimals { return true } // always using withOptCString
        guard $0.propertyType != .uint8Array, $0.propertyType != .data,
              requiresBind($0) else { return false }
        if $0.propertyType == .date { return true } // always w/ withOptCString
        return !$0.isNotNull
      }
      let hasOptionalBlobBinds = entity.properties.contains {
        $0.propertyType == .uint8Array && !$0.isNotNull && requiresBind($0)
      }
      let hasOptionalDataBinds = entity.properties.contains {
        $0.propertyType == .data && !$0.isNotNull && requiresBind($0)
      }
      
      if hasOptionalStringBinds {
        // if we link Lighter, it has `withCString` defined
        statements.append(.nestedFunction(makeWithOptCString()))
      }
      if hasOptionalBlobBinds {
        statements.append(.nestedFunction(
          makeWithOptBlob(name: "withOptBlob", type: .uint8Array)))
      }
      if hasOptionalDataBinds {
        statements.append(.nestedFunction(
          makeWithOptBlob(name: "withOptDataBlob", type: .data)))
      }
      if hasDecimals {
        statements.append(.nestedFunction(makeStringForDecimal()))
      }
      
      if options.uuidStorageStyle == .blob &&
         entity.properties.contains(where: { $0.propertyType == .uuid })
      {
        statements.append(.nestedFunction(
          makeWithOptUUIDBytes()
        ))
      }
    }
    
    statements.append(
      .group(generateBindStatementsForProperties(entity.properties))
    )
    
    // for the binds the generation needs to recurse backwards
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public: options.public, name: "bind", genericParameterNames: [ "R" ],
        parameters: [
          .init(keyword: "to", name: "statement",
                type: .name("OpaquePointer!")), // to match SQLite API
          .init(keywordArg: "indices",
                .qualifiedType(baseName: api.recordSchemaName,
                               name: api.propertyIndicesType)),
          .init(keyword: "then", name: "execute",
                type: .closure(escaping: false, parameters: [], throws: true,
                               returns: .name("R")))
        ],
        async: false, throws: false, rethrows: true,
        returnType: .name("R"),
        genericConstraints: []
      ),
      statements: statements,
      comment: .init(
        headline:
          "Bind all ``\(entity.name)`` properties to a prepared statement and call a closure.",
        info:
          """
          *Important*: The bindings are only valid within the closure being executed!
          """,
        example: generateBindSample(for: entity),
        parameters: [
          .init(name: "statement",
                info: "A SQLite3 statement handle as returned by the `sqlite3_prepare*` functions."),
          .init(name: "indices",
                info: "The parameter positions for the bindings."),
          .init(name: "execute",
                info: "Closure executed with bindings applied, "
                + "bindings _only_ valid within the call!")
        ],
        throws: true,
        returnInfo: "Returns the result of the closure that is passed in."
      ),
      inlinable: true, discardableResult: true
    )
  }
  
  fileprivate func generateBindSample(for entity: EntityInfo) -> String {
    let updateSQL = entity.updateSQL ??
    "UPDATE \(entity.externalName) SET lastname = ?, firstname = ? WHERE person_id = ?"
    let indices = entity.updateParameterIndices
      .map { String($0) }.joined(separator: ", ")
    
    let stringSamples = [ "Hello", "World", "Duck", "Donald", "Mickey" ]
    var intValue      = 0
    var stringValue   = 0
    var nilCount      = 0
    let parameters : String = entity.properties.compactMap { property in
      if !property.isNotNull && nilCount > 3 { return nil }
      if !property.isNotNull { nilCount += 1 }
      let name = property.name
      switch property.propertyType {
      case .integer, .double:
        intValue += 1
        return "\(name): \(intValue)"
      case .string:
        if stringValue >= stringSamples.count {
          return property.isNotNull ? "\(name): \"string\"" : nil
        }
        defer { stringValue += 1 }
        return "\(name): \"\(stringSamples[stringValue])\""
      default:
        return property.isNotNull ? "\(name): ..." : "\(name): nil"
      }
    }.joined(separator: ", ")
    
    return """
    var statement : OpaquePointer?
    sqlite3_prepare_v2(
      dbHandle,
      #"\(updateSQL)"#,
      -1, &statement, nil
    )
    
    let record = \(entity.name)(\(parameters))
    let ok = record.bind(to: statement, indices: ( \(indices) )) {
      sqlite3_step(statement) == SQLITE_DONE
    }
    sqlite3_finalize(statement)
    """
  }
  
  
  // MARK: - Binds

  func generateBindStatementForProperty(
         _ property : EntityInfo.Property,
         index      : Expression,
         trailer    : () -> [ Statement ] = { [] }
       ) -> ( Statement, didRecurse: Bool )
  {
    var helperPrefix : String { options.optionalHelpersInDatabase
                                ? "\(database.name)." : "" }

    var didRecurse = false
    let statement  : Statement

    switch property.propertyType {
      
      // Note: We don't use Lighter binds for base types to avoid
      //       unncessary recursion.
      
      case .custom:
        statement = bindLighter(property.name,
                                index: index, trailer: trailer())

      case .integer:
        statement = bindBaseProperty(
          property.name, optional: !property.isNotNull, type: "int64",
          value: .cast(ivar(property.name), to: .name("Int64")),
          index: index
        )
        
      case .double:
        statement = bindBaseProperty(
          property.name, optional: !property.isNotNull, type: "double",
          value: ivar(property.name),
          index: index
        )
        
      case .bool: // bind as int 1/0
        statement = bindBaseProperty(
          property.name, optional: !property.isNotNull, type: "int64",
          value: .conditional(ivar(property.name), .integer(1), .integer(0)),
          index: index
        )
        
      case .string:
        didRecurse = true
        // TBD: Maybe put the `ifSwitch` here and only bind on demand? (i.e.
        //      if the index is -1 and the value is not nil).
        //      Well, no, we would actually have to replicate the branch.
        //      Or we do some extra to fit things into an expression.
        if useLighterBinds {
          statement = bindLighter(property.name,
                                  index: index, trailer: trailer())
        }
        else {
          statement = bindString(property.name, optional: !property.isNotNull,
                                 index: index, trailer: trailer())
        }
      case .url:
        didRecurse = true
        if useLighterBinds {
          statement = bindLighter(property.name,
                                  index: index, trailer: trailer())
        }
        else {
          statement = bindString(
            property.name, converter: "absoluteString",
            optional: !property.isNotNull, index: index, trailer: trailer()
          )
        }
        
      case .decimal:
        didRecurse = true
        if useLighterBinds {
          statement = bindLighter(property.name,
                                  index: index, trailer: trailer())
        }
        else {
          statement = bindDecimal(
            property.name, optional: !property.isNotNull,
            index: index, trailer: trailer()
          )
        }
        
      case .uint8Array:
        didRecurse = true
        if useLighterBinds {
          statement = bindLighter(property.name,
                                  index: index, trailer: trailer())
        }
        else {
          statement = bindBlob(
            property.name,
            optHelper:
              property.isNotNull ? nil : "\(helperPrefix)withOptBlob",
            index: index, trailer: trailer()
          )
        }
      case .data:
        didRecurse = true
        if useLighterBinds {
          statement = bindLighter(property.name,
                                  index: index, trailer: trailer())
        }
        else {
          statement = bindBlob(
            property.name,
            optHelper: property.isNotNull
              ? nil : "\(helperPrefix)withOptDataBlob",
            index: index, trailer: trailer()
          )
        }
      case .date:
        if useLighterBinds {
          didRecurse = true
          statement  = bindLighter(property.name,
                                   index: index, trailer: trailer())
        }
        else if options.dateStorageStyle == .timeIntervalSince1970 {
          statement = bindBaseProperty(
            property.name,
            optional: !property.isNotNull, type: "double",
            value: .variablePath(
              options.qualifiedSelf
              ? [ "self", property.name, "timeIntervalSince1970" ]
              : [ property.name, "timeIntervalSince1970" ]
            ),
            index: index
          )
        }
        else {
          didRecurse = true
          statement = bindDateString(
            property.name, optional: !property.isNotNull,
            index: index, trailer: trailer()
          )
        }
      case .uuid:
        didRecurse = true
        if useLighterBinds {
          statement = bindLighter(property.name,
                                  index: index, trailer: trailer())
        }
        else {
          switch options.uuidStorageStyle {
            case .text:
              statement = bindString(
                property.name, converter: "uuidString",
                optional: !property.isNotNull, index: index, trailer: trailer()
              )
            case .blob:
              statement = bindUUIDBlob(property.name,
                                       index: index, trailer: trailer())
          }
        }
    }
    
    return ( statement, didRecurse )
  }

  private func generateBindStatementsForProperties<C>(_ properties: C)
               -> [ Statement ]
    where C: Collection, C.Element == EntityInfo.Property,
          C.Index == Array.Index
  {
    guard !properties.isEmpty else {
      return [ .return(.call(try: true, name: "execute")) ]
    }
    
    var didRecurse = false
    var statements = [ Statement ]()
    for ( idx, property ) in zip(properties.indices, properties) {
#if DEBUG && false
      print("WARNING: DEBUG HACK IS ON \(#function)", idx)
      var property = property
      //property.propertyType = .date
      //property.propertyType = .uint8Array
      property.propertyType = .date
#endif
      if didRecurse { break }

      let ( statement, didNewRecurse ) = generateBindStatementForProperty(
        property,
        index: index(for: property.name),
        trailer: {
          generateBindStatementsForProperties(
            properties[properties.index(after: idx)...]
          )
        }
      )
      if didNewRecurse { didRecurse = true }
      
      statements.append(statement)
    }
    
    if !didRecurse {
      statements.append(.return(.call(try: true, name: "execute")))
    }
    return statements
  }
  
  
  fileprivate func bindBaseProperty(_ propertyName: String,
                                    optional : Bool,
                                    type     : String,
                                    value    : Expression,
                                    index    : Expression) -> Statement
  {
    var bindFunc  : String { "sqlite3_bind_\(type)" }
    let statement = Expression.variable("statement")
    return !optional
    // if indices.idx_id >= 0 {
    //   sqlite3_bind_int64(statement, indices.idx_id, Int64(id))
    // }
    ? .ifSwitch(( .gtOrEq0(index),
                  .call( name: bindFunc, statement, index, value )
      ))
    : .ifSwitch(( .gtOrEq0(index), .ifLet(
       propertyName, is: ivar(propertyName),
       then: [ .call(name: bindFunc, statement, index, value )],
       else: [ .call(name: "sqlite3_bind_null", statement, index) ]
    )))
  }

  /**
   * Bind using the `SQLiteValueType` `bind` function:
   * ```swift
   * func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
   *           index: Int32, then execute: () -> Void)
   * ```
   */
  fileprivate func bindLighter(_ propertyName: String,
                               index: Expression, trailer: [ Statement ])
                   -> Statement
  {
    return .return(
      .call(
        try: true, instance: propertyName, name: "bind",
        parameters : [
          ( "unsafeSQLite3StatementHandle", .variable("statement") ),
          ( "index", index )
        ],
        trailing: ( [], trailer )
      )
    )
  }

  fileprivate func bindString(_ propertyName : String,
                              converter      : String? = nil, // .absoluteString
                              optional       : Bool,
                              index          : Expression,
                              trailer        : [ Statement ])
  -> Statement
  {
    let helperPrefix = options.optionalHelpersInDatabase
                     ? "\(database.name)." : ""
    return .return(
      .call(
        try: true,
        instance   : !optional ? propertyName : nil,
        name       : !optional
        ? (converter.flatMap({ "\($0).withCString" }) ?? "withCString")
        : "\(helperPrefix)withOptCString",
        parameters : !optional ? [] : [
          // optional
          ( nil, converter.flatMap({
            // Note: This breaks ticking of special words
            .variable(propertyName + (optional ? "?" : ""), $0)
          })
            ?? .variable(propertyName) )
        ],
        trailing: ( [ "s" ], [
          .ifSwitch( (
            .gtOrEq0(index), // works for `nil` as well!
            Statement.call(name: "sqlite3_bind_text",
                           .variable("statement"), index,
                           .variable("s"), .integer(-1), .nil)
          ) ) ] + trailer
        )
      )
    )
  }
  
  fileprivate func bindBlob(_ propertyName: String, optHelper: String?,
                            index   : Expression,
                            trailer : [ Statement ]) -> Statement
  {
    let optional = optHelper != nil
    return .return(
      .call(
        try: true,
        instance: !optional ? propertyName : nil,
        name: optHelper ?? "withUnsafeBytes",
        parameters: !optional ? [] : [ ( nil, ivar(propertyName) ) ],
        trailing: ( [ "rbp" ], [
          .ifSwitch( (
            .gtOrEq0(index), // works for `nil` as well!
            .call(name: "sqlite3_bind_blob", .variable("statement"), index,
                  .variable("rbp.baseAddress"), .variable("Int32(rbp.count)"),
                  .nil) // this says: do not copy (`SQLITE_STATIC`)
          ) ) ] +
          trailer
        )
      )
    )
  }
  fileprivate func bindUUIDBlob(_ propertyName : String,
                                index          : Expression,
                                trailer        : [ Statement ]) -> Statement
  {
    return .return(
      .call(
        try: true, name: "withOptUUIDBytes",
        parameters: [ ( nil, ivar(propertyName) ) ],
        trailing: ( [ "rbp" ], [
          .ifSwitch( (
            .gtOrEq0(index), // works for `nil` as well!
            .call(name: "sqlite3_bind_blob", .variable("statement"), index,
                  .variable("rbp.baseAddress"), .variable("Int32(rbp.count)"),
                  .nil) // this says: do not copy (`SQLITE_STATIC`)
          ) ) ] +
          trailer
        )
      )
    )
  }

  fileprivate func bindDecimal(_ propertyName : String, optional: Bool,
                               index          : Expression,
                               trailer        : [ Statement ]) -> Statement
  {
    let helperPrefix = options.optionalHelpersInDatabase
    ? "\(database.name)." : ""
    return .return(
      .call(
        try: true,
        name       : "\(helperPrefix)withOptCString", // always use this
        parameters : [ (
          nil,
          .call(name: "\(helperPrefix)stringForDecimal",
                .variable(propertyName))
        ) ],
        trailing: ( [ "s" ], [
          .ifSwitch( (
            .gtOrEq0(index), // works for `nil` as well!
            Statement.call(name: "sqlite3_bind_text",
                           .variable("statement"), index,
                           .variable("s"), .integer(-1), .nil)
          ) ) ] +
                    trailer
        )
      )
    )
  }
  
  fileprivate func bindDateString(_ propertyName : String, optional: Bool,
                                  index          : Expression,
                                  trailer        : [ Statement ]) -> Statement
  {
    let helperPrefix = options.optionalHelpersInDatabase
                     ? "\(database.name)." : ""
    return .return(
      .call(
        try: true,
        name       : "\(helperPrefix)withOptCString", // always use this
        parameters : [ (
          nil,
          !optional // but still yields an optional if dateformatter is nil
          ? .call(name: "\(database.name).dateFormatter?.string",
                  parameters: [ ( "from", ivar(propertyName) ) ])
          : .flatMap(expression: ivar(propertyName), map: .call(
                  name: "\(database.name).dateFormatter?.string",
                  parameters: [ ( "from", .raw("$0") ) ]
            ))
        ) ],
        trailing: ( [ "s" ], [
          .ifSwitch( (
              .gtOrEq0(index), // works for `nil` as well!
              Statement.call(name: "sqlite3_bind_text",
                             .variable("statement"), index,
                             .variable("s"), .integer(-1), .nil)
          ) ) ] +
          trailer
        )
      )
    )
  }
}
