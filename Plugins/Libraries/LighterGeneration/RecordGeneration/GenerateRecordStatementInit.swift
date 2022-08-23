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

  
  // MARK: - Getting Values
  
  fileprivate func valueGrab(for property: EntityInfo.Property,
                 in entity: EntityInfo) -> Expression
  {
    let generator = SwiftInitPropertyGenerator(
      allowFoundation      : options.allowFoundation,
      dateStorageStyle     : options.dateStorageStyle,
      tupleUnsafeIndexName : self.tupleUnsafeIndexName(for:),
      dateFormatterMap     : self.dateFormatterMap,
      uuidFormatterMap     : self.uuidFormatterMap,
      stringMap            : self.stringMap(initPrefix:initSuffix:),
      
      property : property,
      sole     : entity.properties.count == 1,
      /// RecordType.schema.personId.defaultValue
      defaultValue: options.useLighter
        ? Expression.variablePath([
            "Self", api.recordSchemaVariableName, property.name, "defaultValue"
          ])
        : nonOptionalDefaultValue(for: property)
    )
    return generator.valueGrab()
  }
}

fileprivate struct SwiftInitPropertyGenerator {
  
  let allowFoundation      : Bool
  let dateStorageStyle     : EnlighterASTGenerator.Options.DateStorageStyle
  
  let tupleUnsafeIndexName : ( String ) -> String
  let dateFormatterMap     : () -> Expression
  let uuidFormatterMap     : () -> Expression
  let stringMap            : ( String, String ) -> Expression
  
  let property             : EntityInfo.Property
  var name                 : String { property.name }
  let sole                 : Bool
  let defaultValue         : Expression
  
  
  // MARK: - Support
  
  private func index() -> Expression {
    sole
    ? .variable("indices")
    : .variable("indices", self.tupleUnsafeIndexName(name))
  }
  private func _indexName() -> String {
    sole ? "indices" : "indices." + self.tupleUnsafeIndexName(name)
  }
  
  private func uuidBlobMap() -> Expression {
    let blobMap = // make this nice
    """
    { if sqlite3_column_bytes(statement, \(_indexName())) == 16 {
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

  // MARK: - Performing Statement Range Checks
  
  /// Make sure the property index is within the allowed range:
  /// `indices.idx_personId >= 0 && indices.idx_personId < argc`
  /// E.g. it could be `-1` if it wasn't requested.
  private func makeIndexCheck() -> Expression {
    let idx = index()
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
  private func makeNullIndexCheck() -> Expression {
    let idx = index()
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
  
  
  /// - Int needs a cast
  /// - Double doesn't
  /// - String/BLOB needs a map to `[UInt8]`/`Data`
  /// - URL/Decimal will pass along `nil` when they fail to parse an anotherwise
  ///   non-nil string.
  fileprivate func valueGrab() -> Expression {

    func stringGrab() -> Expression {
      return property.isNotNull
        ? grabColumnValue   (type: "text", map: .raw("String.init(cString:)"))
        : grabOptColumnValue(type: "text", map: .raw("String.init(cString:)"))
    }
    
    switch property.propertyType {
      case .custom(let type):
        return property.isNotNull
          ? grabCustomValue(type: type)
          : grabOptCustomValue(type: type)

      case .integer:
        return property.isNotNull
          ? grabIntColumnValue()
          : grabOptIntColumnValue()
      case .string:
        return stringGrab()
      case .double:
        return property.isNotNull
          ? grabDoubleColumnValue()
          : grabOptDoubleColumnValue()
      case .uint8Array:
        return property.isNotNull
          ? grabColumnValue   (type: "blob", map: blobMap(type: "[ UInt8 ]"))
          : grabOptColumnValue(type: "blob", map: blobMap(type: "[ UInt8 ]"))
      case .data:
        return property.isNotNull
          ? grabColumnValue   (type: "blob", map: blobMap(type: "Data"))
          : grabOptColumnValue(type: "blob", map: blobMap(type: "Data"))

      // derived
      case .bool:
        return property.isNotNull
          ? grabBoolColumnValue()
          : grabOptBoolColumnValue()

      case .date:
        if allowFoundation {
          return property.isNotNull
            ? grabDateColumnValue()
            : grabOptDateColumnValue()
        }
        else {
          switch dateStorageStyle {
            case .formatter:
              return stringGrab()
            case .timeIntervalSince1970:
              return property.isNotNull
                ? grabIntColumnValue()
                : grabOptIntColumnValue()
          }
        }
      case .uuid:
        if allowFoundation {
          return property.isNotNull
            ? grabUUIDColumnValue()
            : grabOptUUIDColumnValue()
        }
        else {
          return stringGrab()
        }

      case .url:
        if allowFoundation {
          return property.isNotNull
            ? grabColumnValue   (type: "text",
                                 map: stringMap("URL(string: ", ")"))
            : grabOptColumnValue(type: "text",
                                 map: stringMap("URL(string: ", ")"))
        }
        else {
          return stringGrab()
        }
      case .decimal: // always use `String`, sole one w/ potential precision
        if allowFoundation {
          return property.isNotNull
            ? grabColumnValue   (type: "text",
                                 map: stringMap("Decimal(string: ", ")"))
            : grabOptColumnValue(type: "text",
                                 map: stringMap("Decimal(string: ", ")"))
        }
        else {
          return stringGrab()
        }
    }
  }

  // init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32)
  //   throws
  private func grabCustomValue(type: String) -> Expression {
    .conditional(
      makeNullIndexCheck(),
      .cast(
        .call(name: type, parameters: [
          ( "unsafeSQLite3StatementHandle", .variable("statement") ),
          ( "column", index() )
        ]),
        to: .int
      ),
      defaultValue
    )
  }
  private func grabOptCustomValue(type: String) -> Expression {
    .conditional(
      makeNullIndexCheck(),
      .cast(
        .call(name: "Optional<\(type)>", parameters: [
          ( "unsafeSQLite3StatementHandle", .variable("statement") ),
          ( "column", index() )
        ]),
        to: .int
      ),
      defaultValue
    )
  }

  // This one needs a cast to `Int` (returns `Int64`)
  private func grabIntColumnValue() -> Expression {
    .conditional(
      makeNullIndexCheck(),
      .cast(
        .call(name: "sqlite3_column_int64",
              .variable("statement"), index()),
        to: .int
      ),
      defaultValue
    )
  }
  private func grabDoubleColumnValue() -> Expression {
    .conditional(
      makeNullIndexCheck(),
     .call(name: "sqlite3_column_double", .variable("statement"), index()),
      defaultValue
    )
  }
  private func grabBoolColumnValue() -> Expression {
    .conditional(
      makeNullIndexCheck(),
      .compare(
        lhs: .call(name: "sqlite3_column_int64",
                   .variable("statement"), index()),
        operator: .notEqual,
        rhs: .integer(0)
      ),
      defaultValue
    )
  }

  private func notNullCondition() -> Expression {
    .cmp(
      .call(name: "sqlite3_column_type", .variable("statement"),
            index()),
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
          .call(name: "sqlite3_column_int64", .variable("statement"),
                index()),
          to: .int
        ),
        .nil
      ),
      // not provided, use default
      defaultValue
    )
  }
  private func grabOptBoolColumnValue() -> Expression {
    .conditional(
      makeIndexCheck(),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(),
        .compare(
          lhs: .call(name: "sqlite3_column_int64",
                     .variable("statement"), index()),
          operator: .notEqual,
          rhs: .integer(0)
        ),
        .nil
      ),
      // not provided, use default
      defaultValue
    )
  }

  private func grabOptDoubleColumnValue() -> Expression {
    let idx = index()
    return .conditional(
      makeIndexCheck(),
      .conditional( // provided, but can still be nil! nil wins over default.
        notNullCondition(),
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
  func grabOptColumnValue(type: String, map: @autoclosure () -> Expression)
       -> Expression
  {
    .conditional(
      makeIndexCheck(), // is it available?
      .flatMap(expression:
                .call(name: "sqlite3_column_\(type)",
                      .variable("statement"), index()),
               map: map()),
      defaultValue
    )
  }
  /// This applies the default value if the index check fails (i.e. the
  /// property is not part of the result)
  /// OR if the value is `NULL` in the result!
  private func grabColumnValue(type: String, map: @autoclosure () -> Expression)
               -> Expression
  {
    .nilCoalesce(
      .conditional(
        makeIndexCheck(), // is it available?
        .flatMap(expression:
                  .call(name: "sqlite3_column_\(type)",
                        .variable("statement"), index()),
                 map: map()),
        .nil
      ),
      defaultValue
    )
  }

  private func blobMap(type: String = "[ UInt8 ]") -> Expression {
    let index = _indexName()

    // $0 is the blob ptr, type is `[ UInt8 ]`
    return .raw("{ \(type)(UnsafeRawBufferPointer(start: $0, "
              + "count: Int(sqlite3_column_bytes(statement, \(index))))) }")
  }
  
  private func grabDateColumnValue() -> Expression {
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
  private func grabOptDateColumnValue() -> Expression {
    .conditional(
      makeIndexCheck(),
      dateValue(), // can also return nil
      defaultValue // it is not in range, use default
    )
  }

  /// This isn't easy :-)
  // this can return nil
  private func dateValue() -> Expression {
    assert(allowFoundation)
    let idx = index()
    // it is not NULL and available. So check either Double or Text
    return .conditional(
      .cmp( // is it a text?
        .call(name: "sqlite3_column_type", .variable("statement"), idx),
        .equal,
        .variable("SQLITE_TEXT")
      ),
      
      // it is a text - this can return nil
      .flatMap(expression:
          .call(name: "sqlite3_column_text", .variable("statement"), idx),
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

  private func grabUUIDColumnValue() -> Expression {
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
  private func grabOptUUIDColumnValue() -> Expression {
    .conditional(
      makeIndexCheck(),
      uuidValue(), // can also return nil
      defaultValue // it is not in range, use default
    )
  }

  private func uuidValue() -> Expression {
    let idx = index()
    return .conditional(
      .cmp( // is it a blob?
        .call(name: "sqlite3_column_type", .variable("statement"), idx),
        .equal,
        .variable("SQLITE_BLOB")
      ),
      .flatMap(expression:
                .call(name: "sqlite3_column_blob",
                      .variable("statement"), idx),
               map: uuidBlobMap()),
      // it is something else, treat as SQLITE_TEXT
      .flatMap(expression:
                .call(name: "sqlite3_column_text",
                      .variable("statement"), idx),
               map: uuidFormatterMap()
      )
    )
  }
}
