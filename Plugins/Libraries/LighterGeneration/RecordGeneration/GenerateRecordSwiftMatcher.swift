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
  
  /// - Int needs a cast
  /// - Double doesn't
  /// - String/BLOB needs a map to `[UInt8]`/`Data`
  /// - URL/Decimal will pass along `nil` when they fail to parse an otherwise
  ///   non-nil string.
  fileprivate func valueGrab(for property: EntityInfo.Property,
                             in entity: EntityInfo) -> Expression
  {
    let generator = SwiftMatcherPropertyGenerator(
      tupleUnsafeIndexName : self.tupleUnsafeIndexName(for:),
      dateFormatterMap     : self.dateFormatterMap,
      uuidFormatterMap     : self.uuidFormatterMap,
      uuidBlobMap          : self.uuidBlobMap(for:at:),
      
      property : property,
      sole     : entity.properties.count == 1,
      /// RecordType.schema.personId.defaultValue
      defaultValue: options.useLighter
        ? Expression.variablePath([
            "RecordType", api.recordSchemaVariableName,
            property.name, "defaultValue"
          ])
        : nonOptionalDefaultValue(for: property)
    )
    return generator.valueGrab()
  }
}

fileprivate struct SwiftMatcherPropertyGenerator {
  
  let tupleUnsafeIndexName : ( String ) -> String // a relict
  let dateFormatterMap : () -> Expression
  let uuidFormatterMap : () -> Expression
  let uuidBlobMap      : ( String, String ) -> Expression
  
  let property         : EntityInfo.Property
  var name             : String { property.name }
  let sole             : Bool
  let defaultValue     : Expression
  
  
  // MARK: - Main Dispatcher
  
  /// - Int needs a cast
  /// - Double doesn't
  /// - String/BLOB needs a map to `[UInt8]`/`Data`
  /// - URL/Decimal will pass along `nil` when they fail to parse an otherwise
  ///   non-nil string.
  func valueGrab() -> Expression {
    switch property.propertyType {
      case .custom(let type):
        return property.isNotNull
          ? grabCustomValue   (type: type)
          : grabOptCustomValue(type: type)
      case .integer:
        return property.isNotNull
          ? grabIntColumnValue   ()
          : grabOptIntColumnValue()
      case .string:
        return property.isNotNull
          ? grabColumnValue   (type: "text", map: .raw("String.init(cString:)"))
          : grabOptColumnValue(type: "text", map: .raw("String.init(cString:)"))
      case .double:
        return property.isNotNull
          ? grabDoubleColumnValue   ()
          : grabOptDoubleColumnValue()
      case .uint8Array:
        return property.isNotNull
          ? grabColumnValue   (type: "blob", map: blobMap(type: "[ UInt8 ]"))
          : grabOptColumnValue(type: "blob", map: blobMap( type: "[ UInt8 ]"))
      case .data:
        return property.isNotNull
          ? grabColumnValue   (type: "blob", map: blobMap(type: "Data"))
          : grabOptColumnValue(type: "blob", map: blobMap(type: "Data"))
        
        // derived
      case .bool:
        return property.isNotNull
          ? grabBoolColumnValue   ()
          : grabOptBoolColumnValue()
        
      case .date:
        return property.isNotNull
          ? grabDateColumnValue   ()
          : grabOptDateColumnValue()
      case .uuid:
        return property.isNotNull
          ? grabUUIDColumnValue   ()
          : grabOptUUIDColumnValue()
        
      case .url:
        return property.isNotNull
          ? grabColumnValue   (type: "text",
                               map: stringMap(initPrefix: "URL(string: "))
          : grabOptColumnValue(type: "text",
                               map: stringMap(initPrefix: "URL(string: "))
      case .decimal: // always use `String`, sole one w/ potential precision
        return property.isNotNull
          ? grabColumnValue   (type: "text",
                               map: stringMap(initPrefix: "Decimal(string: "))
          : grabOptColumnValue(type: "text",
                               map: stringMap(initPrefix: "Decimal(string: "))
    }
  }

  // MARK: - Helpers
  
  // Later: Find a way to usefully shared the code w/ the statement init,
  //        currently this is mostly copy&paste due to the different calling
  //        conventions of the retrieval functions.

  // This returns an optional!
  func stringMap(initPrefix: String, initSuffix: String = ")") -> Expression {
    .raw("{ \(initPrefix)String(cString: $0)\(initSuffix) }")
  }

  func index() -> Expression {
    sole
    ? .variable("indices")
    : .variable("indices", self.tupleUnsafeIndexName(name))
  }
  func _indexName() -> String {
    sole ? "indices" : "indices." + self.tupleUnsafeIndexName(name)
  }

  /// argv[Int(indices.idx_personId)]
  func argvItem() -> Expression {
    sole // Later: make nicer (remove raw)
    ? .raw("argv[Int(indices)]")
    : .raw("argv[Int(indices.\(self.tupleUnsafeIndexName(name)))]")
  }
  
  
  /// Make sure the property index is within the allowed range:
  /// `indices.idx_personId >= 0 && indices.idx_personId < argc`
  /// *and* that it isn't null if available:
  /// `sqlite3_value_type(argv[Int(indices.idx_personId)]) != SQLITE_NULL)`.
  /// E.g. it could be `-1` if it wasn't requested.
  func makeNullIndexCheck() -> Expression {
    let idx = index()
    return Expression.and([
      .cmp(idx, .greaterThanOrEqual, 0),
      .cmp(idx, .lessThan, .variable("argc")),
      .cmp(
        // sqlite3_value_type(argv[Int(indices.idx_personId)])
        .call(name: "sqlite3_value_type", argvItem()),
        .notEqual,
        .variable("SQLITE_NULL")
      )
    ])
  }
  /// Make sure the property index is within the allowed range:
  /// `indices.idx_personId >= 0 && indices.idx_personId < argc`
  /// E.g. it could be `-1` if it wasn't requested.
  func makeIndexCheck() -> Expression {
    let idx = index()
    return Expression.and([
      .cmp(idx, .greaterThanOrEqual, 0),
      .cmp(idx, .lessThan, .variable("argc"))
    ])
  }

  // MARK: - Getting Values
  
  // init(unsafeSQLite3ValueHandle value: OpaquePointer?)
  //   throws
  func grabCustomValue(type: String) -> Expression {
    .conditional(
      makeNullIndexCheck(),
      .cast(
        .call(name: type, parameters: [
          ( "unsafeSQLite3ValueHandle", argvItem() )
        ]),
        to: .int
      ),
      defaultValue
    )
  }
  func grabOptCustomValue(type: String) -> Expression {
    .conditional(
      makeNullIndexCheck(),
      .cast(
        .call(name: "Optional<\(type)>", parameters: [
          ( "unsafeSQLite3ValueHandle", argvItem() )
        ]),
        to: .int
      ),
      defaultValue
    )
  }
  
  // This one needs a cast to `Int` (returns `Int64`)
  func grabIntColumnValue() -> Expression {
    .conditional(
      makeNullIndexCheck(),
      .cast(
        .call(name: "sqlite3_value_int64", argvItem()),
        to: .int
      ),
      defaultValue
    )
  }
  func grabDoubleColumnValue() -> Expression {
    .conditional(
      makeNullIndexCheck(),
      .call(name: "sqlite3_value_double", argvItem()),
      defaultValue
    )
  }
  func grabBoolColumnValue() -> Expression {
    .conditional(
      makeNullIndexCheck(),
      .compare(
        lhs: .call(name: "sqlite3_value_int64", argvItem()),
        operator: .notEqual,
        rhs: .integer(0)
      ),
      defaultValue
    )
  }
  
  func notNullCondition() -> Expression {
    .cmp(
      .call(name: "sqlite3_value_type", argvItem()),
      .notEqual,
      .variable("SQLITE_NULL")
    )
  }
  
  func grabOptIntColumnValue() -> Expression {
    .conditional(
      makeIndexCheck(),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(),
        .cast(
          .call(name: "sqlite3_value_int64", argvItem()),
          to: .int
        ),
        .nil
      ),
      // not provided, use default
      defaultValue
    )
  }
  func grabOptBoolColumnValue() -> Expression {
    .conditional(
      makeIndexCheck(),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(),
        .compare(
          lhs: .call(name: "sqlite3_value_int64", argvItem()),
          operator: .notEqual,
          rhs: .integer(0)
        ),
        .nil
      ),
      // not provided, use default
      defaultValue
    )
  }
  
  func grabOptDoubleColumnValue() -> Expression {
    return .conditional(
      makeIndexCheck(),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(),
        .call(name: "sqlite3_value_double", argvItem()),
        .nil
      ),
      // not provided, use default
      defaultValue
    )
  }
  
  /// This ONLY applies the default value, if the index check fails (i.e. the
  /// property is NOT part of the result). If the property IS part of the result
  /// and `NULL`, that is passed along to the optional property as `nil`.
  func grabOptColumnValue(type: String, map: @autoclosure () -> Expression)
       -> Expression
  {
    return .conditional(
      makeIndexCheck(), // is it available?
      .flatMap(expression:
          .call(name: "sqlite3_value_\(type)", argvItem()), map: map()),
      defaultValue
    )
  }
  /// This applies the default value if the index check fails (i.e. the
  /// property is not part of the result)
  /// OR if the value is `NULL` in the result!
  func grabColumnValue(type: String, map: @autoclosure () -> Expression)
       -> Expression
  {
    .nilCoalesce(
      .conditional(
        makeIndexCheck(), // is it available?
        .flatMap(expression: .call(name: "sqlite3_value_\(type)", argvItem()),
                 map: map()),
        .nil
      ),
      defaultValue
    )
  }
  
  func blobMap(type: String = "[ UInt8 ]") -> Expression {
    let argvItem = sole ? "argv[Int(indices)]"
                        : "argv[Int(indices.\(tupleUnsafeIndexName(name)))]"
    
    // $0 is the blob ptr, type is `[ UInt8 ]`
    return .raw("{ \(type)(UnsafeRawBufferPointer(start: $0, "
                + "count: Int(sqlite3_value_bytes(\(argvItem))))) }")
  }
  
  func grabDateColumnValue() -> Expression {
    .nilCoalesce(
      .conditional(
        makeNullIndexCheck(),
        dateValue(), // the date parser can return nil
        .nil // this is going to be coalesced below:
      ),
      
      // it is not in range or NULL, or parsed as nil, use default
      defaultValue
    )
  }
  fileprivate func grabOptDateColumnValue() -> Expression {
    .conditional(
      makeIndexCheck(),
      dateValue(), // can also return nil
      defaultValue // it is not in range, use default
    )
  }
  
  // this can return nil
  func dateValue() -> Expression {
    let argvItem = argvItem()
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
  
  func grabUUIDColumnValue() -> Expression {
    .nilCoalesce(
      .conditional(
        makeNullIndexCheck(),
        uuidValue(), // the parser can return nil
        .nil // this is going to be coalesced below:
      ),
      // it is not in range or NULL, or parsed as nil, use default
      defaultValue
    )
  }
  func grabOptUUIDColumnValue() -> Expression {
    .conditional(
      makeIndexCheck(),
      uuidValue(), // can also return nil
      defaultValue // it is not in range, use default
    )
  }
  
  func uuidValue() -> Expression {
    let argvItem = argvItem()
    return .conditional(
      .cmp( // is it a blob?
        .call(name: "sqlite3_value_type", argvItem),
        .equal,
        .variable("SQLITE_BLOB")
      ),
      .flatMap(expression: .call(name: "sqlite3_column_blob", argvItem),
               map: uuidBlobMap(name, _indexName())),
      // it is something else, treat as SQLITE_TEXT
      .flatMap(expression: .call(name: "sqlite3_column_text", argvItem),
               map: uuidFormatterMap())
    )
  }
}
