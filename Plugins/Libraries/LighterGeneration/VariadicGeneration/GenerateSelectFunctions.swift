//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import LighterCodeGenAST

/**
 * Generates a variadic set of `select` functions.
 */
public final class SelectFunctionGeneration: FunctionGenerator {
  // TBD: Maybe we should also build an `any SQLColumn` based variant?
  //      But how would autocompletion work? Doesn't fly.
  
  public init(columnCount: Int, sortCount: Int,
              yield: Bool = false, async: Bool = false)
  {
    super.init()
    
    self.columnCount    = columnCount
    self.sortCount      = sortCount
    self.asyncFunctions = !yield && async
    
    self.limitParameterName     = "limit"
    self.yieldCallbackName      = yield ? "yield" : nil
    self.predicateParameterName = "predicate"
  }
  
  /* Parameters */
  
  public var sortCount   : Int = 2 {
    didSet { assert(sortCount >= 0 && sortCount <= 8) }
  }
    
  // MARK: - Configurations for the function signature/style

  public var functionName                     = "select"
  /// Note: must be set to generate a limit parameter
  public var limitParameterName               : String? = "limit"
  /// Note: if set, this returns a callback variant of fetch
  public var yieldCallbackName                : String? = "yield"
  public var asyncFunctions                   = false

  public var recordParameterLabel             = "from"
  public var recordParameterName              = "tableOrView"

  public var sortColumnGenericParameterPrefix = "CS"
  public var sortColumnsLabel                 = "orderBy"
  public var sortColumnParameterName          = "sortColumn"
  public var sortDirParameterName             = "direction"
  
  public var predicateParameterLabel          : String? = "where"
  /// Note: must be set to generate a predicate builder parameter
  public var predicateParameterName           : String? = "predicate"
  
  public var commentHeadline =
    "Select columns from a SQL table or view in a typesafe way."
  public var commentArrayReturn =
    "Returns an array of tuples for each requested row."
  public var commentRecordParameter =
    "A keypath to the table/view to fetch from e.g. `\\.person`."
  public var commentLimitParameter =
    "An optional limit on the number of records returned."
  public var commentYieldParameter =
    "An closure that is called for each result row. It has one argument for "
  + "each selected column."
  public var commentQualifierParameter =
    "A closure that returns the predicate used for filtering. The first argument is the schema "
  + "of the associated record. E.g. `{ $0.personId == 10 }`."
  public var commentSelectColumnSuffix = "selected column."
  public var commentSortColumnSuffix   = "column the result is sorted by."
  public var commentSortDirection      =
    "The sort direction for the column (`.ascending`/`.descending`)."

  
  
  /* Generation */
  
  public func generate() {
    assert(sortCount   >= 0)
    assert(columnCount >= 1)
    
    if sortCount == 0 { // Xcode 14beta2 ARC crash w/o this
      for columnCount in 1...columnCount {
        functions.append(
          generateSelect(columnCount: columnCount, sortColumnCount: 0))
      }
    }
    else {
      for sortCount in 0...sortCount {
        for columnCount in 1...columnCount {
          functions.append(
            generateSelect(columnCount: columnCount, sortColumnCount: sortCount)
          )
        }
      }
    }
  }
  
  typealias Param = FunctionDeclaration.Parameter

  /// Generate a `FunctionComment` for the given parameters.
  private func makeComment(columnParameterNames  : [ String ],
                           sortParameterNames    : [ String ],
                           sortDirParameterNames : [ String ])
               -> FunctionComment
  {
    var comment = FunctionComment(headline: commentHeadline)
    
    if !columnParameterNames.isEmpty &&
       columnParameterNames.count <= commentColumnExamples.count
    {
      var sample = ""
      
      if yieldCallbackName == nil { sample += "let records = "}
      
      let sampleParameters =
            commentColumnExamples[..<columnParameterNames.count]
      
      let prefix = "try \(asyncFunctions ? "await " : "")\(self.functionName)("
      sample += "\(prefix)\(recordParameterLabel): \\.\(commentRecordExample)"
      for columnSample in sampleParameters {
        sample += ", \\.\(columnSample)"
      }
      
      // skipping limit
      
      if !sortParameterNames.isEmpty {
        sample += ",\n" + String(repeating: " ", count: prefix.count)
        
        let sampleSortParameters =
              commentColumnExamples[..<sortParameterNames.count]
        sample += "\(sortColumnsLabel): "
        var isFirst = true
        for ( idx, columnSample) in sampleSortParameters.enumerated() {
          if isFirst { isFirst = false }
          else { sample += ", " }
          sample += "\\.\(columnSample)"
          if sortParameterNames.count > 1 {
            sample += ((idx % 2) != 0) ? ", .ascending" : ".descending"
          }
        }
      }

      let pkey        = sampleParameters.first ?? "column"
      let otherColumn = commentColumnExamples.dropFirst().first ?? pkey
      if yieldCallbackName != nil {
        if predicateParameterName != nil {
          sample += ",\n" + String(repeating: " ", count: prefix.count)
          if let label = predicateParameterLabel { sample += "\(label): " }
          sample += "{ \\.\(pkey) == 10 && \\.\(otherColumn).hasPrefix(\"So\") }"
          sample += ")\n"
        }
        else {
          sample += ") "
        }
        sample += "{\n  "
        sample += sampleParameters.joined(separator: ", ")
        sample += " in\n\n"
        sample += "  print(\"First column:\", \(sampleParameters[0]))\n"
        sample += "}"
      }
      else { // array return based version
        sample += ") {\n"
        sample += "  \\.\(pkey) == 10 && \\.\(otherColumn).hasPrefix(\"D\")\n"
        sample += "}"
      }
      
      if !sample.isEmpty { comment.example = sample }
    }
    
    comment.parameters.append(
      .init(name: recordParameterName, info: commentRecordParameter)
    )
    
    comment.parameters += columnParameterNames.enumerated().map { idx, name in
      var info = "The \(ordinal(idx + 1)) \(commentSelectColumnSuffix)"
      if idx < commentColumnExamples.count {
        info += " E.g. `\\.\(commentColumnExamples[idx])`."
      }
      return FunctionComment.Parameter(name: name, info: info)
    }
    
    if let limitParameterName = limitParameterName {
      comment.parameters.append(
        .init(name: limitParameterName, info: commentLimitParameter)
      )
    }
    
    for ( idx, params ) in zip(sortParameterNames, sortDirParameterNames)
      .enumerated()
    {
      var info = "The \(ordinal(idx + 1)) \(commentSortColumnSuffix)"
      if idx < commentColumnExamples.count {
        info += " E.g. `\\.\(commentColumnExamples[idx])`."
      }
      comment.parameters.append(
        FunctionComment.Parameter(name: params.0, info: info))
      comment.parameters.append(
        FunctionComment.Parameter(name: params.1, info: commentSortDirection))
    }

    if let predicateParameterName = predicateParameterName {
      comment.parameters.append(
        .init(name: predicateParameterName, info: commentQualifierParameter)
      )
    }

    if let yieldCallbackName = yieldCallbackName {
      comment.parameters.append(
        .init(name: yieldCallbackName, info: commentYieldParameter)
      )
    }
    else {
      comment.returnInfo = commentArrayReturn
    }
    
    return comment
  }
  
  private func sortParameters(_ SCs                   : [ String ],
                              _ sortParameterNames    : [ String ],
                              _ sortDirParameterNames : [ String ])
               -> [ Param ]
  {
    var parameters = [ Param ]()
    parameters.reserveCapacity(sortParameterNames.count * 2)
    
    let T = recordGenericParameterPrefix
    
    for idx in 0..<sortParameterNames.count {
      // orderBy  column : KeyPath<T.Schema, C1>,
      // _     direction : SQLSortOrder = .ascending)
      parameters.append(Param(keyword: idx == 0 ? sortColumnsLabel : nil,
                              name: sortParameterNames[idx],
                              keyPath: T, api.recordSchemaName, to: SCs[idx]))
      parameters.append(Param(name: sortDirParameterNames[idx],
                              type: .name(api.sortOrderType),
                              defaultValue: .variable(".ascending")))
    }
    return parameters
  }
  
  public func generateSelect(columnCount: Int, sortColumnCount: Int)
              -> FunctionDefinition
  {
    // Yes, this is a little big. But hey, it is a code generator! :-)
    _ = """
    func select<T, C1, C2, SC1>(
      from: KeyPath<Self.RecordTypes, T.Type>,
      _ column1: KeyPath<T.Schema, C1>,
      _ column2: KeyPath<T.Schema, C2>,
      orderBy sortColumn1: KeyPath<T.Schema, SC1>, direction: SQLSortOrder,
      limit: Int? = nil,
      yield: ( C1.Value, C2.Value ) -> Void
    ) throws
    where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T, SC1: SQLColumn,
          T = SC1.T
    {
      var builder = SQLBuilder<T>()
      builder.addColumn(column1)
      builder.addColumn(column2)
      builder.addSort(sortColumn1, direction1)

      let sql = builder.generateSelect(limit: limit,
                                       predicate: SQLTruePredicate.shared)
      
      try fetch(sql, builder.bindings) { stmt, _ in
        yield(try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0),
              try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1))
      }
    }
    """
    _ = """
    func select<T, C1, C2, SC1>(
      from: KeyPath<Self.RecordTypes, T.Type>,
      _ column1: KeyPath<T.Schema, C1>,
      _ column2: KeyPath<T.Schema, C2>,
      orderBy sortColumn1: KeyPath<T.Schema, SC1>, direction: SQLSortOrder,
      limit: Int? = nil
    ) throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T, SC1: SQLColumn,
          T = SC1.T
    {
      var builder = SQLBuilder<T>()
      builder.addColumn(column1)
      builder.addColumn(column2)
      builder.addSort(sortColumn1, direction1)

      let sql = builder.generateSelect(limit: limit,
                                       predicate: SQLTruePredicate.shared)
      
      var records = [ ( C1.Value, C2.Value ) ]()
      try fetch(sql, builder.bindings) { stmt, _ in
        records.append((
          first  : try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0),
          second : try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1)
        ))
      }
      return records
    }
    """

    let T   = recordGenericParameterPrefix    // T
    let P   = predicateGenericParameterPrefix // P
    let Cs  = oneBasedNames(prefix: columnGenericParameterPrefix,
                            count: columnCount)
    let SCs = oneBasedNames(prefix: sortColumnGenericParameterPrefix,
                            count: sortColumnCount)
    
    let columnParameterNames = oneBasedNames(prefix: columnParameterName,
                                             count: columnCount)
    let sortParameterNames =
      oneBasedNames(prefix: sortColumnParameterName, count: SCs.count)
    let sortDirParameterNames =
      oneBasedNames(prefix: sortDirParameterName, count: SCs.count)

    var parameters = [ Param ]()
    do { // Parameters
      parameters.append(Param(keyword : recordParameterLabel,
                              name    : recordParameterName,
                              keyPath : "Self", api.recordTypeLookupTarget,
                              to: T, "Type"))
      
      for ( n, C ) in zip(columnParameterNames, Cs) {
        parameters.append(Param(name: n, keyPath: T, api.recordSchemaName, to: C))
      }

      parameters += sortParameters(
        SCs, sortParameterNames, sortDirParameterNames
      )
      
      if let limitParameterName = limitParameterName {
        parameters.append(Param(name: limitParameterName, type: .optional(.int),
                                defaultValue: .literal(.nil)))
      }
      
      if let predicateParameterName = predicateParameterName {
        // where p : ( T.Schema ) -> some SQLPredicate
        parameters.append(
          Param(keyword: predicateParameterLabel, name: predicateParameterName,
                closureParameters: [ ( T, api.recordSchemaName ) ],
                returns: .name(P))
        )
      }
      
      if let yieldCallbackName = yieldCallbackName {
        parameters.append(Param(
          name: yieldCallbackName,
          closureParameters: Cs.map { ( $0, api.columnValuePAT ) },
          throws: true, returns: .void
        ))
      }
    }

    let returnType : TypeReference = (yieldCallbackName != nil) ? .void : {
      // [ ( first: C1.Value, second: C2.Value ) ]
      if columnParameterNames.count > 1 {
        return .array(.tuple(
          names: columnParameterNames,
          types: Cs.map {
            .qualifiedType(baseName: $0, name: api.columnValuePAT)
          }
        ))
      }
      else {
        return .array(.qualifiedType(baseName: Cs[0],
                                     name: api.columnValuePAT))
      }
    }()
    
    var genericConstraints = [ GenericConstraint ]()
    do { // Generic Constraints
      genericConstraints.reserveCapacity((Cs.count + SCs.count) * 2)

      let ACs = Cs + SCs
      if ACs.isEmpty { // where T: SQLRecord
        genericConstraints.append(.conformance(T, to: api.recordType))
      }
      else {
        // where C1: SQLColumn, T == C1.T ...
        genericConstraints += ACs.map { .conformance($0, to: api.columnType) }
        genericConstraints += ACs.map {
          .parameter(T, sameAs: $0, api.columnTablePAT) // `T`
        }
      }
      
      if predicateParameterName != nil {
        genericConstraints.append(.conformance(P, to: api.predicateType))
      }
    }
    
    let declaration = FunctionDeclaration(
      name       : functionName,
      genericParameterNames:
        [ T ] + Cs + SCs + (predicateParameterName != nil ? [ P ] : []),
      parameters : parameters,
      async      : asyncFunctions,
      throws     : true,
      returnType : returnType,
      genericConstraints: genericConstraints
    )
    
    var statements = [ Statement ]()
    statements.reserveCapacity(Cs.count * 2 + 10)
    
    // var builder = SQLBuilder<T>()
    // builder.addColumn(column1)
    // builder.addColumn(column2)
    statements.append(.group({
      var statements = [ Statement ]()
      statements.append(
        .var(builderVariableName, .raw("\(api.builderType)<T>()"))
      )
      // TBD: We could also just set the builder `columns` array?
      //      Well, it does the alias processing, so maybe not? Hm, but not in
      //      here, the T's are fixed to the C's.
      for p in columnParameterNames {
        statements.append(.call(
          instance: builderVariableName, name: "addColumn",
          withVariables: p
        ))
      }
      
      for ( sc, sd ) in zip(sortParameterNames, sortDirParameterNames) {
        statements.append(.call(
          instance: builderVariableName, name: "addSort",
          withVariables: sc, sd
        ))
      }
      
      return statements
    }()))
    
    // `builder.generateSelect(limit: limit, predicate: predicate(T.schema))`
    statements.append(.let("sql",
      is: .call(
        instance: "builder", name: "generateSelect",
        parameters: [
          ( "limit",     .variable("limit") ),
          ( "predicate",
            predicateParameterName.flatMap({
              .call(name: $0, parameters: [
                ( nil, .variable(T, api.recordSchemaVariableName) )
              ])
            })
            ?? .variable("SQLTruePredicate", "shared") )
        ]
      )
    ))
    
    // `[ try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0) ]`
    let initCalls : [ Expression ] = Cs.enumerated().map { idx, C in
      .call(try: true, name: "\(C).\(api.columnValuePAT).init",
            parameters: [
              ( "unsafeSQLite3StatementHandle" , .variable("stmt") ),
              ( "column"                       , .integer(idx)     )
            ])
    }
    
    if let yieldCallbackName = yieldCallbackName {
      /*
       try fetch(sql, builder.bindings) { stmt, _ in
         yield(try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0),
               try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1))
       }
       */
      statements.append(
        .call(try: true, name: "fetch", parameters: [
          ( nil, .variable("sql") ),
          ( nil, .variable(builderVariableName, "bindings" ) )
        ], trailing: ( parameters: [ "stmt", "_" ], statements: [
          .call(try: true, name: yieldCallbackName,
                parameters: initCalls.map { ( nil, $0 ) })
        ]))
      )
    }
    else {
      /*
      var records = [ ResultSet ]() // <= the returnType!
      try fetch(sql, builder.bindings) { stmt, _ in
        records.append((
          first  : try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0),
          second : try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1)
        ))
      }
      */
            
      let syncCode : [ Statement ] = [
        .var("records", .typeInit(returnType)),
      
        .call(try: true, name: "fetch", parameters: [
          ( nil, .variable("sql") ),
          ( nil, .variable("bindings" ) )
        ], trailing: ( parameters: [ "stmt", "_" ], statements: [
          .call(instance: "records", name: "append",
                parameters: [ ( nil, // could generate the labels
                  // one tuple as the parameter
                  initCalls.count == 1 ? initCalls[0] : .tuple(initCalls)
                )])
        ])),
        
        .return(.variable("records"))
      ]

      statements.append(.let("bindings",
                             is: .variable(builderVariableName, "bindings")))
      if asyncFunctions {
        // try await runOnDatabaseQueue { try fetch(from, limit: limit) }
        statements.append(
          .return(
            .call(try: true, await: true, name: "runOnDatabaseQueue",
                  parameters: [], trailing: (
              parameters: [],
              statements: syncCode
            ))
          )
        )
      }
      else {
        statements += syncCode
      }
    }
    
    let definition = FunctionDefinition(
      declaration : declaration,
      statements  : statements,
      comment     : makeComment(columnParameterNames  : columnParameterNames,
                                sortParameterNames    : sortParameterNames,
                                sortDirParameterNames : sortDirParameterNames),
      inlinable: true
    )
    
    return definition
  }
}
