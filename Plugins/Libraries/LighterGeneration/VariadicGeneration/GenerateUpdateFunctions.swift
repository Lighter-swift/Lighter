//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

/**
 * Generates a variadic set of `update` functions.
 */
public final class UpdateFunctionGeneration: FunctionGenerator {
    
  public init(columnCount: Int, primaryKey: Bool = false, async: Bool = false) {
    super.init()
    self.columnCount    = columnCount
    self.asyncFunctions = async
    self.predicateParameterName = primaryKey ? nil : "predicate"
    self.pkeyParameterName      = primaryKey ? "key" : nil
  }
    
  // MARK: - Configurations for the function signature/style

  public var functionName                     = "update"
  public var asyncFunctions                   = false

  public var recordParameterLabel             : String? = nil // _
  public var recordParameterName              = "table"

  public var columnParameterLabel             : String? = "set"
  public var valueParameterLabel              : String? = "to"
  public var valueParameterName               = "value"

  // Not really specific to a primary key, works for any "single" key
  public var pkeyGenericParameter             = "PK"
  public var pkeyParameterLabel               = "where"
  public var pkeyParameterName                : String? = "keyColumn"
  public var pkeyParameterValueLabel          = "is"
  public var pkeyParameterValueName           = "id"

  public var predicateParameterLabel          : String? = "where"
  /// Note: must be set to generate a predicate builder parameter
  public var predicateParameterName           : String? = "predicate"
  
  public var commentHeadline =
    "Update columns in a SQL table in a typesafe way."
  public var commentRecordParameter =
    "A keypath to the table to update e.g. `\\.person`."
  public var commentQualifierParameter =
    "A closure that returns the predicate to select the records to update. "
  + "The first argument is the schema "
  + "of the associated record. E.g. `{ $0.personId == 10 }`."
  public var commentPrimaryKeyParameter =
    "A keypath to a column used to qualify the update e.g. `\\.personId`."
  public var commentPrimaryKeyValueParameter =
    "The value the key has to have to make the update apply, e.g. `10`."
  public var commentUpdateColumnSuffix = "column to update."
  public var commentUpdateValue = "The value to update the column with."
  
  
  /* Generation */
  
  public func generate() {
    assert(columnCount >= 1 && columnCount < 30)
    guard columnCount >= 1 else { return }
    
    for columnCount in 1...columnCount {
      functions.append(generateUpdate(columnCount: columnCount))
    }
  }
  
  typealias Param = FunctionDeclaration.Parameter

  /// Generate a `FunctionComment` for the given parameters.
  private func makeComment(columnParameterNames : [ String ],
                           valueParameterNames  : [ String ])
               -> FunctionComment
  {
    var comment = FunctionComment(headline: commentHeadline)
    
    if !columnParameterNames.isEmpty &&
       columnParameterNames.count <= commentColumnExamples.count
    {
      var sample = ""
      
      let sampleParameters =
        commentColumnValueExamples[..<columnParameterNames.count]
      
      let prefix = "try \(asyncFunctions ? "await " : "")\(functionName)("
      sample += prefix
      if let l = recordParameterLabel { sample += "\(l): " }
      sample += "\\.\(commentRecordExample)"
      
      for ( columnSample, valueSample ) in sampleParameters {
        sample += ", "
        if let l = columnParameterLabel { sample += "\(l): " }
        sample += "\\.\(columnSample), "
        if let l = valueParameterLabel  { sample += "\(l): " }
        sample += valueSample
      }

      let pkey        = sampleParameters.first?.column ?? "column"
      let otherColumn = commentColumnExamples.dropFirst().first ?? pkey
      if predicateParameterName != nil {
        sample += ") {\n"
        sample += "  \\.\(pkey) == 10 && \\.\(otherColumn).hasPrefix(\"D\")\n"
        sample += "}"
      }
      else {
        sample += ", \(pkeyParameterLabel): \\.\(pkey)"
        sample += ", \(pkeyParameterValueLabel): 10"
        sample += ")"
      }
            
      if !sample.isEmpty { comment.example = sample }
    }
    
    comment.parameters.append(
      .init(name: recordParameterName, info: commentRecordParameter)
    )
    
    for ( idx, n ) in columnParameterNames.enumerated() {
      let v = valueParameterNames[idx]
      var info = "The \(ordinal(idx + 1)) \(commentUpdateColumnSuffix)"
      if idx < commentColumnExamples.count {
        info += " E.g. `\\.\(commentColumnExamples[idx])`."
      }
      comment.parameters.append(.init(name: n, info: info))
      comment.parameters.append(.init(name: v, info: commentUpdateValue))
    }
    
    if let pkeyParameterName = pkeyParameterName {
      comment.parameters.append(
        .init(name: pkeyParameterName, info: commentPrimaryKeyParameter)
      )
      comment.parameters.append(
        .init(name: pkeyParameterValueName,
              info: commentPrimaryKeyValueParameter)
      )
    }

    if let predicateParameterName = predicateParameterName {
      comment.parameters.append(
        .init(name: predicateParameterName, info: commentQualifierParameter)
      )
    }
    return comment
  }
  
  public func generateUpdate(columnCount: Int) -> FunctionDefinition {
    // Yes, this is a little big. But hey, it is a code generator! :-)
    /*
    func update<T, C1, C2, PK>(
      _     table : KeyPath<Self.RecordTypes, T.Type>,
      set column1 : KeyPath<T.Schema, C1>, to value1 : C1.Value,
      set column2 : KeyPath<T.Schema, C2>, to value2 : C2.Value,
      where  pkey : KeyPath<T.Schema, PK>, is     id : PK.Value
    ) throws
    where C1: SQLColumn, C2: SQLColumn, PK: SQLColumn,
          T == C1.T, T == C2.T, T == PK.T, T: SQLTableRecord

    func update<T, C1, C2, P>(
      _     table : KeyPath<Self.RecordTypes, T.Type>,
      set column1 : KeyPath<T.Schema, C1>, to value1: C1.Value,
      set column2 : KeyPath<T.Schema, C2>, to value2: C2.Value,
      where     p : ( T.Schema ) -> P
    ) throws
    where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T, T: SQLTableRecord,
          P: SQLPredicate
    {
      var builder = SQLBuilder<T>()
      builder.addColumn(column1)
      builder.addColumn(column2)
      builder.generateUpdate(
        T.Schema.externalName,
        values    : value1.asSQLiteValue, value2.asSQLiteValue,
        predicate : p(T.schema)
      )
      
      print("SQL:", builder.sql)
      try execute(builder.sql, builder.bindings, readOnly: false)
    }
    */

    let T   = recordGenericParameterPrefix    // T
    let P   = predicateGenericParameterPrefix // P
    let Cs  = oneBasedNames(prefix: columnGenericParameterPrefix,
                            count: columnCount)
    
    let columnParameterNames = oneBasedNames(prefix: columnParameterName,
                                             count: columnCount)
    let valueParameterNames  = oneBasedNames(prefix: valueParameterName,
                                              count: columnCount)

    var parameters = [ Param ]()
    do { // Parameters
      parameters.append(Param(keyword : recordParameterLabel,
                              name    : recordParameterName,
                              keyPath : "Self", api.recordTypeLookupTarget,
                              to: T, "Type"))
      
      for ( idx, C ) in Cs.enumerated() {
        let n = columnParameterNames[idx]
        let v = valueParameterNames [idx]

        parameters += [
          Param(keyword: columnParameterLabel, name: n,
                keyPath: T, api.recordSchemaName, to: C),
          Param(keyword: valueParameterLabel, name: v,
                type: .qualifiedType(baseName: C, name: api.columnValuePAT))
        ]
      }
      
      if let pkeyParameterName = pkeyParameterName {
        // where pkey : KeyPath<T.Schema, PK>, is id : PK.Value
        parameters += [
          Param(keyword: pkeyParameterLabel, name: pkeyParameterName,
                keyPath: T, api.recordSchemaName, to: pkeyGenericParameter),
          Param(keyword: pkeyParameterValueLabel, name: pkeyParameterValueName,
                type: .qualifiedType(baseName: pkeyGenericParameter,
                                     name: api.columnValuePAT))
        ]
      }
      if let predicateParameterName = predicateParameterName {
        // where p : ( T.Schema ) -> some SQLPredicate
        parameters.append(
          Param(keyword: predicateParameterLabel, name: predicateParameterName,
                closureParameters: [ ( T, api.recordSchemaName ) ],
                returns: .name(P))
        )
      }
    }
    
    var genericConstraints = [ GenericConstraint ]()
    do { // Generic Constraints
      genericConstraints.reserveCapacity((Cs.count + 1) * 2 + 1)

      // `T: SQLTableRecord`
      genericConstraints.append(.conformance(T, to: api.tableRecordType))
      if predicateParameterName != nil {
        // `P: SQLPredicate`
        genericConstraints.append(.conformance(P, to: api.predicateType))
      }
      
      // where C1: SQLColumn, T == C1.T ...
      genericConstraints += Cs.map { .conformance($0, to: api.columnType) }
      genericConstraints += Cs.map {
        .parameter(T, sameAs: $0, api.columnTablePAT) // `T`
      }

      if predicateParameterName == nil {
        genericConstraints += [
          .conformance(pkeyGenericParameter, to: api.columnType),
          .parameter(T, sameAs: pkeyGenericParameter, api.columnTablePAT)
        ]
      }
    }
    
    let declaration = FunctionDeclaration(
      name       : functionName,
      genericParameterNames: [ T ] + Cs
        + ((predicateParameterName != nil) ? [ P ] : [ pkeyGenericParameter ]),
      parameters : parameters,
      async      : asyncFunctions,
      throws     : true,
      returnType : .void, // TBD: maybe support RETURNING?
      genericConstraints: genericConstraints
    )
    
    
    // MARK: - Body
    /*
        var builder = SQLBuilder<T>()
        builder.addColumn(column1)
        builder.addColumn(column2)
        builder.generateUpdate(
          T.Schema.externalName,
          values    : value1.asSQLiteValue, value2.asSQLiteValue,
          predicate : p(T.schema)
        )
        try fetch(builder.sql, builder.bindings) { stmt, stop in stop = true }
     */
    
    var statements = [ Statement ]()
    statements.reserveCapacity(Cs.count * 2 + 10)
    
    let values = valueParameterNames.map {
      Expression.variable($0)
    }
    
    let predicate : Expression = {
      assert(!(predicateParameterName != nil && pkeyParameterName != nil),
             "dual mode not supported yet")
      if let predicateParameterName = predicateParameterName {
        return .call(name: predicateParameterName, parameters: [
          ( nil, .variable(T, api.recordSchemaVariableName) )
        ])
      }
      else if let pkeyParameterName = pkeyParameterName {
        return .raw("\(T).\(api.recordSchemaVariableName)"
                  + "[keyPath: \(pkeyParameterName)] == "
                  + "\(pkeyParameterValueName)")
      }
      else {
        return .variable("SQLTruePredicate", "shared")
      }
    }()
    
    // var builder = SQLBuilder<T>()
    statements.append(
      .var(builderVariableName, .raw("\(api.builderType)<T>()"))
    )
    for p in columnParameterNames { // builder.addColumn(column1)
      statements.append(.call(
        instance: builderVariableName, name: "addColumn",
        withVariables: p
      ))
    }
    statements.append(
      .call(
        instance: builderVariableName, name: "generateUpdate", parameters: [
          ( nil, .variable(T + "." + api.recordSchemaName, "externalName") ),
          ( "set"   , .varargs(values)  ),
          ( "where" , predicate         )
        ]
      )
    )
          
    let syncCode = Statement.call(
      try: true, name: "execute", parameters: [
        ( nil, .variable(builderVariableName, "sql")      ),
        ( nil, .variable(builderVariableName, "bindings") ),
        ( "readOnly", .false )
      ]
    )
    
    if asyncFunctions {
      // try await runOnDatabaseQueue { try fetch(from, limit: limit) }
      statements.append(
        .return(
          .call(try: true, await: true, name: "runOnDatabaseQueue",
                parameters: [], trailing: (
            parameters: [],
            statements: [ syncCode ]
          ))
        )
      )
    }
    else {
      statements.append(syncCode)
    }
    
    
    // Compose and return
    
    let definition = FunctionDefinition(
      declaration : declaration,
      statements  : statements,
      comment     : makeComment(columnParameterNames : columnParameterNames,
                                valueParameterNames  : valueParameterNames),
      inlinable   : true
    )
    return definition
  }
}
