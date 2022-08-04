//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {
  
  func matcherFunction(for entity: EntityInfo) -> String {
    return "\(entity.referenceName)_swift_match"
  }
  
  /**
   * Generate the `registerSwiftMatcher` function for a Record type.
   *
   * Example:
   * ```swift
   * static func registerSwiftMatcher(in   db : OpaquePointer!,
   *                                  flags   : Int32 = SQLITE_UTF8,
   *                                  matcher : UnsafeRawPointer) -> Int32
   * {
   *   func dispatch(_ context : OpaquePointer?,
   *                 argc      : Int32,
   *                 argv      : UnsafeMutablePointer<OpaquePointer?>!)
   *   { .. }
   * }
   * ```
   */
  func generateRegisterSwiftMatcher(for entity: EntityInfo)
  -> FunctionDefinition
  {
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public: options.public, name: api.registerSwiftMatcher,
        parameters: [
          .init(keyword: "in", name: "unsafeDatabaseHandle",
                type: .name("OpaquePointer!")),
          .init(keyword: "flags", name: "flags", type: .int32,
                defaultValue: .variable("SQLITE_UTF8")),
          .init(keywordArg: "matcher", .name("UnsafeRawPointer"))
        ],
        returnType: .int32
      ),
      statements: [
        .nestedFunction(generateDispatchFunction(for: entity)),
        .return(
          .call(name: "sqlite3_create_function", parameters: [
            ( nil, .variable("unsafeDatabaseHandle") ),
            ( nil, .string(matcherFunction(for: entity)) ),
            ( nil, .variablePath([
              globalName(of: entity), api.recordSchemaName, api.columnCount ])),
            ( nil, .variable("flags") ),
            ( nil, .call(name: "UnsafeMutableRawPointer",
                         parameters: [ ( "mutating" , .variable("matcher")) ])),
            ( nil, .variable("dispatch") ),( nil, .nil ),( nil, .nil )
          ])
        )
      ],
      comment: .init(
        headline:
          "Register the Swift matcher function for the ``\(entity.name)`` record.",
        info:
          """
          SQLite Swift matcher functions are used to process `filter` queries
          and low-level matching w/o the Lighter library.
          """,
        example: nil,
        parameters: [
          .init(name: "unsafeDatabaseHandle",
                info: "SQLite3 database handle."),
          .init(
            name: "flags",
            info:
              "SQLite3 function registration flags, default: `SQLITE_UTF8`"
          ),
          .init(
            name: "matcher",
            info: "A pointer to the Swift closure used to filter the records."
          )
        ],
        returnInfo:
          "The result code of `sqlite3_create_function`, e.g. `SQLITE_OK`."
      ),
      inlinable: true, discardableResult: true
    )
  }
  
  /**
   * Generate the `unregisterSwiftMatcher` function for a Record type.
   *
   * Example:
   * ```swift
   * @discardableResult
   * static func unregisterSwiftMatcher(in db: OpaquePointer!,
   *                                    flags: Int32 = SQLITE_UTF8) -> Int32
   * {
   *   return sqlite3_create_function(db, "person_swift_match",
   *     Person.Schema.columnCount, flags, nil, nil, nil, nil
   *   )
   * }
   * ```
   */
  func generateUnregisterSwiftMatcher(for entity: EntityInfo)
  -> FunctionDefinition
  {
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public: options.public, name: api.unregisterSwiftMatcher,
        parameters: [
          .init(keyword: "in", name: "unsafeDatabaseHandle",
                type: .name("OpaquePointer!")),
          .init(keyword: "flags", name: "flags", type: .int32,
                defaultValue: .variable("SQLITE_UTF8"))
        ],
        returnType: .int32
      ),
      statements: [ // yes, delete is covered by create ;-)
        .return(
          .call(name: "sqlite3_create_function", parameters: [
            ( nil, .variable("unsafeDatabaseHandle") ),
            ( nil, .string(matcherFunction(for: entity)) ),
            ( nil, .variablePath([
              globalName(of: entity), api.recordSchemaName, api.columnCount
            ]) ),
            ( nil, .variable("flags") ),
            ( nil, .nil ), ( nil, .nil ),( nil, .nil ),( nil, .nil )
          ])
        )
      ],
      comment: .init(
        headline:
          "Unregister the Swift matcher function for the ``\(entity.name)`` record.",
        info:
          """
          SQLite Swift matcher functions are used to process `filter` queries
          and low-level matching w/o the Lighter library.
          """,
        example: nil,
        parameters: [
          .init(name: "unsafeDatabaseHandle",
                info: "SQLite3 database handle."),
          .init(name: "flags",
                info:
                  "SQLite3 function registration flags, default: `SQLITE_UTF8`")
          
        ],
        returnInfo:
          "The result code of `sqlite3_create_function`, e.g. `SQLITE_OK`."
      ),
      inlinable: true, discardableResult: true
    )
  }
  
  
  // MARK: - Inner Dispatch
  
  /**
   * Generate the `dispatch` function for a Record type Swift closure matcher.
   *
   * Example:
   * ```swift
   * func dispatch(_ context : OpaquePointer?,
   *               argc      : Int32,
   *               argv      : UnsafeMutablePointer<OpaquePointer?>!)
   * { .. }
   * ```
   */
  private func generateDispatchFunction(for entity: EntityInfo)
  -> FunctionDefinition
  {
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public: false, name: "dispatch",
        parameters: [
          .init(name       : "context", type: .name("OpaquePointer?")),
          .init(keywordArg : "argc",    .int32),
          .init(keywordArg : "argv",
                .name("UnsafeMutablePointer<OpaquePointer?>!")),
        ],
        returnType: .void
      ),
      statements: [
        .ifLetElse(
          "closureRawPtr",
          .call(name: "sqlite3_user_data", .variable("context")),
          [
            // let closurePtr =
            // closureRawPtr.bindMemory(to: MatchClosureType.self, capacity: 1)
            .constantDefinition(
              name: "closurePtr",
              value: .call(instance: "closureRawPtr", name: "bindMemory",
                           parameters: [ ( "to", .raw("MatchClosureType.self") ),
                                         ( "capacity", .integer(1) ) ])
            ),
            // let indices = Person.Schema.selectColumnIndices
            .constantDefinition(
              name: "indices",
              value: .variablePath([ globalName(of: entity),
                                     api.recordSchemaName,
                                     "selectColumnIndices" ])
            ),
            
            // let reocrd = Person(
            //    id: ...,
            // )
              .constantDefinition(
                name: "record",
                value: .functionCall(FunctionCall(
                  try: false, await: false, instance: nil,
                  name: globalName(of: entity),
                  parameters: entity.properties.map {
                    .init($0.name, valueGrab(for: $0, in: entity))
                  },
                  trailing: nil
                ))
              ),
            .call(name: "sqlite3_result_int",
                  .variable("context"),
                  .conditional(
                    // Call the closure with the record: `closurePtr.pointee(record)`
                    condition: .call(instance: "closurePtr", name: "pointee",
                                     .variable("record")),
                    true: .integer(1), false: .integer(0)
                  )
            )
          ],
          else: [
            .call(name: "sqlite3_result_error", .variable("context"),
                  .string("Missing Swift matcher closure"), .integer(-1))
          ]
        )
      ]
    )
  }
  
  
  // MARK: - Getting Values
  // Later: Find a way to usefully shared the code w/ the statement init,
  //        currently this is mostly copy&paste due to the different calling
  //        conventions of the retrieval functions.
  
  fileprivate func index(for propertyName: String) -> Expression {
    .variable("indices", indexName(for: propertyName))
  }
  
  /// argv[Int(indices.idx_personId)]
  fileprivate func argvItem(for propertyName: String) -> Expression {
    // Later: make nicer
    .raw("argv[Int(indices.\(indexName(for: propertyName)))]")
  }
  
  /// Make sure the property index is within the allowed range:
  /// `indices.idx_personId >= 0 && indices.idx_personId < argc`
  /// *and* that it isn't null if available:
  /// `sqlite3_value_type(argv[Int(indices.idx_personId)]) != SQLITE_NULL)`.
  /// E.g. it could be `-1` if it wasn't requested.
  fileprivate func makeNullIndexCheck(for propertyName: String) -> Expression {
    let idx = index(for: propertyName)
    return Expression.and([
      .cmp(idx, .greaterThanOrEqual, 0),
      .cmp(idx, .lessThan, .variable("argc")),
      .cmp(
        // sqlite3_value_type(argv[Int(indices.idx_personId)])
        .call(name: "sqlite3_value_type", argvItem(for: propertyName)),
        .notEqual,
        .variable("SQLITE_NULL")
      )
    ])
  }
  
  /// - Int needs a cast
  /// - Double doesn't
  /// - String/BLOB needs a map to `[UInt8]`/`Data`
  /// - URL/Decimal will pass along `nil` when they fail to parse an anotherwise
  ///   non-nil string.
  fileprivate func valueGrab(for property: EntityInfo.Property,
                             in entity: EntityInfo) -> Expression
  {
    let name = property.name
    
    /// RecordType.schema.personId.defaultValue
    let defaultValue = options.useLighter
      ? Expression.variablePath([
          "RecordType", api.recordSchemaVariableName, name, "defaultValue"
        ])
      : nonOptionalDefaultValue(for: property)

    switch property.propertyType {
      case .custom(let type):
        return property.isNotNull
          ? grabCustomValue   (for: name, type: type,
                               defaultValue: defaultValue)
          : grabOptCustomValue(for: name, type: type,
                               defaultValue: defaultValue)
      case .integer:
        return property.isNotNull
          ? grabIntColumnValue   (for: name, defaultValue: defaultValue)
          : grabOptIntColumnValue(for: name, defaultValue: defaultValue)
      case .string:
        return property.isNotNull
          ? grabColumnValue   (for: name, type: "text",
                               map: .raw("String.init(cString:)"),
                               defaultValue: defaultValue)
          : grabOptColumnValue(for: name, type: "text",
                               map: .raw("String.init(cString:)"),
                               defaultValue: defaultValue)
      case .double:
        return property.isNotNull
          ? grabDoubleColumnValue   (for: property.name, defaultValue: defaultValue)
          : grabOptDoubleColumnValue(for: property.name, defaultValue: defaultValue)
      case .uint8Array:
        return property.isNotNull
          ? grabColumnValue   (for: name, type: "blob",
                               map: blobMap(for: name, type: "[ UInt8 ]"),
                               defaultValue: defaultValue)
          : grabOptColumnValue(for: name, type: "blob",
                               map: blobMap(for: name, type: "[ UInt8 ]"),
                               defaultValue: defaultValue)
      case .data:
        return property.isNotNull
          ? grabColumnValue   (for: name, type: "blob",
                               map: blobMap(for: name, type: "Data"),
                               defaultValue: defaultValue)
          : grabOptColumnValue(for: name, type: "blob",
                               map: blobMap(for: name, type: "Data"),
                               defaultValue: defaultValue)
        
        // derived
      case .bool:
        return property.isNotNull
          ? grabBoolColumnValue   (for: name, defaultValue: defaultValue)
          : grabOptBoolColumnValue(for: name, defaultValue: defaultValue)
        
      case .date:
        return property.isNotNull
          ? grabDateColumnValue   (for: name, defaultValue: defaultValue)
          : grabOptDateColumnValue(for: name, defaultValue: defaultValue)
      case .uuid:
        return property.isNotNull
          ? grabUUIDColumnValue   (for: name, defaultValue: defaultValue)
          : grabOptUUIDColumnValue(for: name, defaultValue: defaultValue)
        
      case .url:
        return property.isNotNull
          ? grabColumnValue   (for: name, type: "text",
                               map: stringMap(initPrefix: "URL(string: "),
                               defaultValue: defaultValue)
          : grabOptColumnValue(for: name, type: "text",
                               map: stringMap(initPrefix: "URL(string: "),
                               defaultValue: defaultValue)
      case .decimal: // always use `String`, sole one w/ potential precision
        return property.isNotNull
          ? grabColumnValue   (for: name, type: "text",
                               map: stringMap(initPrefix: "Decimal(string: "),
                               defaultValue: defaultValue)
          : grabOptColumnValue(for: name, type: "text",
                               map: stringMap(initPrefix: "Decimal(string: "),
                               defaultValue: defaultValue)
    }
  }
  
  // init(unsafeSQLite3ValueHandle value: OpaquePointer?)
  //   throws
  fileprivate func grabCustomValue(for propertyName: String, type: String,
                                   defaultValue: Expression)
                   -> Expression
  {
    .conditional(
      makeNullIndexCheck(for: propertyName),
      .cast(
        .call(name: type, parameters: [
          ( "unsafeSQLite3ValueHandle", argvItem(for: propertyName) )
        ]),
        to: .int
      ),
      defaultValue
    )
  }
  fileprivate func grabOptCustomValue(for propertyName: String, type: String,
                                      defaultValue: Expression)
                   -> Expression
  {
    .conditional(
      makeNullIndexCheck(for: propertyName),
      .cast(
        .call(name: "Optional<\(type)>", parameters: [
          ( "unsafeSQLite3ValueHandle", argvItem(for: propertyName) )
        ]),
        to: .int
      ),
      defaultValue
    )
  }
  
  // This one needs a cast to `Int` (returns `Int64`)
  fileprivate func grabIntColumnValue(for propertyName: String,
                                      defaultValue: Expression) -> Expression
  {
    .conditional(
      makeNullIndexCheck(for: propertyName),
      .cast(
        .call(name: "sqlite3_value_int64", argvItem(for: propertyName)),
        to: .int
      ),
      defaultValue
    )
  }
  fileprivate func grabDoubleColumnValue(for propertyName: String,
                                         defaultValue: Expression) -> Expression
  {
    .conditional(
      makeNullIndexCheck(for: propertyName),
      .call(name: "sqlite3_value_double", argvItem(for: propertyName)),
      defaultValue
    )
  }
  fileprivate func grabBoolColumnValue(for propertyName: String,
                                       defaultValue: Expression) -> Expression
  {
    .conditional(
      makeNullIndexCheck(for: propertyName),
      .compare(
        lhs: .call(name: "sqlite3_value_int64", argvItem(for: propertyName)),
        operator: .notEqual,
        rhs: .integer(0)
      ),
      defaultValue
    )
  }
  
  fileprivate func notNullCondition(for propertyName: String) -> Expression {
    .cmp(
      .call(name: "sqlite3_value_type", argvItem(for: propertyName)),
      .notEqual,
      .variable("SQLITE_NULL")
    )
  }
  
  fileprivate func grabOptIntColumnValue(for propertyName: String,
                                         defaultValue: Expression) -> Expression
  {
    .conditional(
      makeIndexCheck(for: propertyName),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(for: propertyName),
        .cast(
          .call(name: "sqlite3_value_int64", argvItem(for: propertyName)),
          to: .int
        ),
        .nil
      ),
      // not provided, use default
      defaultValue
    )
  }
  fileprivate func grabOptBoolColumnValue(for propertyName: String,
                                          defaultValue: Expression)
                   -> Expression
  {
    .conditional(
      makeIndexCheck(for: propertyName),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(for: propertyName),
        .compare(
          lhs: .call(name: "sqlite3_value_int64", argvItem(for: propertyName)),
          operator: .notEqual,
          rhs: .integer(0)
        ),
        .nil
      ),
      // not provided, use default
      defaultValue
    )
  }
  
  fileprivate func grabOptDoubleColumnValue(for propertyName: String,
                                            defaultValue: Expression)
                   -> Expression
  {
    return .conditional(
      makeIndexCheck(for: propertyName),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(for: propertyName),
        .call(name: "sqlite3_value_double", argvItem(for: propertyName)),
        .nil
      ),
      // not provided, use default
      defaultValue
    )
  }
  
  /// This ONLY applies the default value, if the index check fails (i.e. the
  /// property is NOT part of the result). If the property IS part of the result
  /// and `NULL`, that is passed along to the optional property as `nil`.
  fileprivate func grabOptColumnValue(for propertyName: String,
                                      type: String,
                                      map: @autoclosure () -> Expression,
                                      defaultValue: Expression)
                   -> Expression
  {
    return .conditional(
      makeIndexCheck(for: propertyName), // is it available?
      .flatMap(expression:
          .call(name: "sqlite3_value_\(type)",
                argvItem(for: propertyName)),
                map: map()),
      defaultValue
    )
  }
  /// This applies the default value if the index check fails (i.e. the
  /// property is not part of the result)
  /// OR if the value is `NULL` in the result!
  fileprivate func grabColumnValue(for propertyName: String,
                                   type: String,
                                   map: @autoclosure () -> Expression,
                                   defaultValue: Expression)
                   -> Expression
  {
    .nilCoalesce(
      .conditional(
        makeIndexCheck(for: propertyName), // is it available?
        .flatMap(expression:
            .call(name: "sqlite3_value_\(type)",
                  argvItem(for: propertyName)),
                 map: map()),
        .nil
      ),
      defaultValue
    )
  }
  
  fileprivate func blobMap(for propertyName: String, type: String = "[ UInt8 ]")
                   -> Expression
  {
    let argvItem = "argv[Int(indices.\(indexName(for: propertyName)))]"
    
    // $0 is the blob ptr, type is `[ UInt8 ]`
    return .raw("{ \(type)(UnsafeRawBufferPointer(start: $0, "
                + "count: Int(sqlite3_value_bytes(\(argvItem))))) }")
  }
  
  fileprivate func grabDateColumnValue(for propertyName: String,
                                       defaultValue: Expression) -> Expression {
    .nilCoalesce(
      .conditional(
        makeNullIndexCheck(for: propertyName),
        dateValue(for: propertyName), // the date parser can return nil
        .nil // this is going to be coalesced below:
      ),
      
      // it is not in range or NULL, or parsed as nil, use default
      defaultValue
    )
  }
  fileprivate func grabOptDateColumnValue(for propertyName: String,
                                          defaultValue: Expression)
                   -> Expression
  {
    .conditional(
      makeIndexCheck(for: propertyName),
      dateValue(for: propertyName), // can also return nil
      defaultValue                  // it is not in range, use default
    )
  }
  
  // this can return nil
  fileprivate func dateValue(for propertyName: String) -> Expression {
    let argvItem = argvItem(for: propertyName)
    // it is not NULL and available. So check either Double or Text
    return .conditional(
      .cmp( // is it a text?
        .call(name: "sqlite3_value_type", argvItem),
        .equal,
        .variable("SQLITE_TEXT")
      ),
      
      // it is a text - this can return nil
      .flatMap(expression: .call(name: "sqlite3_value_text", argvItem),
               map: dateFormatterMap()
              ),
      
      // it is something else, treat as Double
      .call(name: "Date", parameters: [(
        "timeIntervalSince1970", .call(name: "sqlite3_value_double", argvItem)
      )])
    )
  }
  
  fileprivate func grabUUIDColumnValue(for propertyName: String,
                                       defaultValue: Expression) -> Expression {
    .nilCoalesce(
      .conditional(
        makeNullIndexCheck(for: propertyName),
        uuidValue(for: propertyName), // the parser can return nil
        .nil // this is going to be coalesced below:
      ),
      // it is not in range or NULL, or parsed as nil, use default
      defaultValue
    )
  }
  fileprivate func grabOptUUIDColumnValue(for propertyName: String,
                                          defaultValue: Expression)
                   -> Expression
  {
    .conditional(
      makeIndexCheck(for: propertyName),
      uuidValue(for: propertyName), // can also return nil
      defaultValue                  // it is not in range, use default
    )
  }
  
  fileprivate func uuidValue(for propertyName: String) -> Expression {
    let argvItem = argvItem(for: propertyName)
    return .conditional(
      .cmp( // is it a blob?
        .call(name: "sqlite3_value_type", argvItem),
        .equal,
        .variable("SQLITE_BLOB")
      ),
      .flatMap(expression: .call(name: "sqlite3_column_blob", argvItem),
               map: uuidBlobMap(for: propertyName)),
      // it is something else, treat as SQLITE_TEXT
      .flatMap(expression: .call(name: "sqlite3_column_text", argvItem),
               map: uuidFormatterMap())
    )
  }
}
