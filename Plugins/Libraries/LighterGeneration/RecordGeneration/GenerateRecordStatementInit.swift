//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {

  /**
   * Generates the statement initializer for the record, e.g.
   *
   * ```swift
   * init(statement: OpaquePointer!, indices: Schema.PropertyIndicies) {
   *   ...
   * }
   * ```
   */
  func generateRecordStatementInit(for entity: EntityInfo) -> FunctionDefinition
  {
    // for the binds the generation needs to recurse backwards
    let lookupFuncName = // Self.Schema.lookupColumnIndices
          "Self.\(api.recordSchemaName).\(api.lookupColumnIndices)"
    
    return FunctionDefinition(
      declaration: FunctionDeclaration(
        public: options.public, name: "init",
        parameters: [
          .init(name: "statement", type: .name("OpaquePointer!")),
          .init(keywordArg: "indices",
                .optional(
                  .qualifiedType(baseName: api.recordSchemaName,
                                 name: api.propertyIndicesType)),
                .nil)
        ]
      ),
      statements: [
        //let indices = indices ?? Self.Schema.lookupColumnIndices(in: statement)
        .let("indices",
             is: .raw("indices ?? \(lookupFuncName)(in: statement)")),
        //let argc    = sqlite3_column_count(statement)
        .let("argc",
             is: .call(name: "sqlite3_column_count", .variable("statement"))),
        .call(.selfInit(FunctionCall(
          try: false, await: false, instance: "self", name: "init",
          parameters: entity.properties.map {
            .init($0.name, valueGrab(for: $0, in: entity))
          },
          trailing: nil
        )))
      ],
      comment: .init(
        headline:
          "Initialize a ``\(entity.name)`` record from a SQLite statement handle.",
        info:
          """
          This initializer allows easy setup of a record structure from an
          otherwise arbitrarily constructed SQLite prepared statement.
          
          If no `indices` are specified, the `\(api.recordSchemaName)/\(api.lookupColumnIndices)`
          function will be used to find the positions of the structure properties
          based on their external name.
          When looping, it is recommended to do the lookup once, and then
          provide the `indices` to the initializer.
          
          Required values that are missing in the statement are replaced with
          their assigned default values, i.e. this can even be used to perform
          partial selects w/ only a minor overhead (the extra space for a
          record).
          """,
        example:
        """
        var statement : OpaquePointer?
        sqlite3_prepare_v2(dbHandle, "SELECT * FROM \(entity.externalName)", -1, &statement, nil)
        while sqlite3_step(statement) == SQLITE_ROW {
          let record = \(entity.name)(statement)
          print("Fetched:", record)
        }
        sqlite3_finalize(statement)
        """,
        parameters: [
          .init(name: "statement",
                info: "Statement handle as returned by `sqlite3_prepare*` functions."),
          .init(name: "indices",
                info: "Property bindings positions, "
                + "defaults to `nil` (automatic lookup).")
          
        ]
      ),
      inlinable: true
    )
  }
  
  fileprivate func index(for propertyName: String) -> Expression {
    .variable("indices", indexName(for: propertyName))
  }
  
  
  // MARK: - Performing Statement Range Checks

  /// Make sure the property index is within the allowed range:
  /// `indices.idx_personId >= 0 && indices.idx_personId < argc`
  /// E.g. it could be `-1` if it wasn't requested.
  func makeIndexCheck(for propertyName: String) -> Expression {
    let idx = index(for: propertyName)
    return Expression.and([
      .cmp(idx, .greaterThanOrEqual, 0),
      .cmp(idx, .lessThan, .variable("argc"))
    ])
  }
  /// Make sure the property index is within the allowed range:
  /// `indices.idx_personId >= 0 && indices.idx_personId < argc`
  /// *and* that it isn't null if available:
  /// `sqlite3_column_type(stmt, indices.idx_personId) != SQLITE_NULL)`.
  /// E.g. it could be `-1` if it wasn't requested.
  fileprivate func makeNullIndexCheck(for propertyName: String) -> Expression {
    let idx = index(for: propertyName)
    return Expression.and([
      .cmp(idx, .greaterThanOrEqual, 0),
      .cmp(idx, .lessThan, .variable("argc")),
      .cmp(
        .call(name: "sqlite3_column_type", .variable("statement"), idx),
        .notEqual,
        .variable("SQLITE_NULL")
      )
    ])
  }
  
  
  // MARK: - Getting Values
  
  /// - Int needs a cast
  /// - Double doesn't
  /// - String/BLOB needs a map to `[UInt8]`/`Data`
  /// - URL/Decimal will pass along `nil` when they fail to parse an anotherwise
  ///   non-nil string.
  fileprivate func valueGrab(for property: EntityInfo.Property,
                 in entity: EntityInfo) -> Expression
  {
    let name = property.name

    /// Self.schema.personId.defaultValue
    let defaultValue = Expression.variablePath([
      "Self", api.recordSchemaVariableName, name, "defaultValue"
    ])

    switch property.propertyType {
      case .custom(let type):
      return property.isNotNull
        ? grabCustomValue   (for: name, type: type, defaultValue: defaultValue)
        : grabOptCustomValue(for: name, type: type, defaultValue: defaultValue)

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
          ? grabDateColumnValue(for: name, defaultValue: defaultValue)
          : grabOptDateColumnValue(for: name, defaultValue: defaultValue)
      case .uuid:
        return property.isNotNull
          ? grabUUIDColumnValue(for: name, defaultValue: defaultValue)
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

  // init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
  //   throws
  fileprivate func grabCustomValue(for propertyName: String, type: String,
                                   defaultValue: Expression)
                   -> Expression
  {
    .conditional(
      makeNullIndexCheck(for: propertyName),
      .cast(
        .call(name: type, parameters: [
          ( "unsafeSQLite3StatementHandle", .variable("statement") ),
          ( "column", index(for: propertyName) )
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
          ( "unsafeSQLite3StatementHandle", .variable("statement") ),
          ( "column", index(for: propertyName) )
        ]),
        to: .int
      ),
      defaultValue
    )
  }

  // This one needs a cast to `Int` (returns `Int64`)
  fileprivate func grabIntColumnValue(for propertyName: String,
                                      defaultValue: Expression) -> Expression {
    .conditional(
      makeNullIndexCheck(for: propertyName),
      .cast(
        .call(name: "sqlite3_column_int64",
              .variable("statement"), index(for: propertyName)),
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
     .call(name: "sqlite3_column_double",
           .variable("statement"), index(for: propertyName)),
      defaultValue
    )
  }
  fileprivate func grabBoolColumnValue(for propertyName: String,
                                       defaultValue: Expression) -> Expression
  {
    .conditional(
      makeNullIndexCheck(for: propertyName),
      .compare(
        lhs: .call(name: "sqlite3_column_int64",
                   .variable("statement"), index(for: propertyName)),
        operator: .notEqual,
        rhs: .integer(0)
      ),
      defaultValue
    )
  }

  fileprivate func notNullCondition(for propertyName: String) -> Expression {
    .cmp(
      .call(name: "sqlite3_column_type", .variable("statement"),
            index(for: propertyName)),
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
          .call(name: "sqlite3_column_int64", .variable("statement"),
                index(for: propertyName)),
          to: .int
        ),
        .nil
      ),
      // not provided, use default
      defaultValue
    )
  }
  fileprivate func grabOptBoolColumnValue(for propertyName: String,
                                          defaultValue: Expression) -> Expression
  {
    .conditional(
      makeIndexCheck(for: propertyName),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(for: propertyName),
        .compare(
          lhs: .call(name: "sqlite3_column_int64",
                     .variable("statement"), index(for: propertyName)),
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
    let idx = index(for: propertyName)
    return .conditional(
      makeIndexCheck(for: propertyName),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(for: propertyName),
        .call(name: "sqlite3_column_double", .variable("statement"), idx),
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
                .call(name: "sqlite3_column_\(type)",
                      .variable("statement"), index(for: propertyName)),
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
                  .call(name: "sqlite3_column_\(type)",
                        .variable("statement"), index(for: propertyName)),
                 map: map()),
        .nil
      ),
      defaultValue
    )
  }

  fileprivate func blobMap(for propertyName: String, type: String = "[ UInt8 ]")
                   -> Expression
  {
    let index = "indices.\(indexName(for: propertyName))"

    // $0 is the blob ptr, type is `[ UInt8 ]`
    return .raw("{ \(type)(UnsafeRawBufferPointer(start: $0, "
              + "count: Int(sqlite3_column_bytes(statement, \(index)))) }")
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

  /// This isn't easy :-)
  // this can return nil
  fileprivate func dateValue(for propertyName: String) -> Expression {
    let idx = index(for: propertyName)
    // it is not NULL and available. So check either Double or Text
    return .conditional(
      .cmp( // is it a text?
        .call(name: "sqlite3_column_type", .variable("statement"), idx),
        .equal,
        .variable("SQLITE_TEXT")
      ),
      
      // it is a text - this can return nil
      .flatMap(expression:
                .call(name: "sqlite3_column_text",
                      .variable("statement"), index(for: propertyName)),
               map: dateFormatterMap()
      ),
      
      // it is something else, treat as Double
      .call(name: "Date", parameters: [(
        "timeIntervalSince1970",
        .call(name: "sqlite3_column_double",
              .variable("statement"), idx)
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
    return .conditional(
      .cmp( // is it a blob?
        .call(name: "sqlite3_column_type", .variable("statement"),
              index(for: propertyName)),
        .equal,
        .variable("SQLITE_BLOB")
      ),
      .flatMap(expression:
                .call(name: "sqlite3_column_blob",
                      .variable("statement"), index(for: propertyName)),
               map: uuidBlobMap(for: propertyName)),
      // it is something else, treat as SQLITE_TEXT
      .flatMap(expression:
                .call(name: "sqlite3_column_text",
                      .variable("statement"), index(for: propertyName)),
               map: uuidFormatterMap()
      )
    )
  }
  
  
  // MARK: - Bind Mappers
  
  func uuidBlobMap(for propertyName: String) -> Expression {
    let idxvar  = index(for: propertyName)
    let blobMap = // make this nice
    """
    { if sqlite3_column_bytes(statement, \(idxvar)) == 16 {
        let rbp = UnsafeRawBufferPointer(start: $0, count: 16)
        return UUID(uuid: (
          rbp[0], rbp[1], rbp[2],  rbp[3],  rbp[4],  rbp[5],  rbp[6],  rbp[7],
          rbp[8], rbp[9], rbp[10], rbp[11], rbp[12], rbp[13], rbp[14], rbp[15]
        ))
      } else { return nil }
    }
    """
    return .raw(blobMap)
  }
  
  // This returns an optional!
  func stringMap(initPrefix: String, initSuffix: String = ")") -> Expression {
    .raw("{ \(initPrefix)String(cString: $0)\(initSuffix) }")
  }
  
  /// This requires the ``dateFormatter`` property in the associated database
  /// structure.
  /// This can still return nil!
  func dateFormatterMap() -> Expression {
    stringMap(initPrefix: "\(database.name).dateFormatter?.date(from: ",
              initSuffix: ")")
  }
  /// This can still return nil!
  func uuidFormatterMap() -> Expression {
    stringMap(initPrefix: "UUID(uuidString: ", initSuffix: ")")
  }
}
