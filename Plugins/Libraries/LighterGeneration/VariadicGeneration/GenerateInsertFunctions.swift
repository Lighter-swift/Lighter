//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

/**
 * Generates a variadic set of `insert` functions.
 */
public final class InsertFunctionGeneration: FunctionGenerator {
    
  public init(columnCount: Int, async: Bool = false) {
    super.init()
    self.columnCount    = columnCount
    self.asyncFunctions = async
  }
    
  // MARK: - Configurations for the function signature/style

  public var functionName                     = "insert"
  public var asyncFunctions                   = false

  public var recordParameterLabel             : String? = "into"
  public var recordParameterName              = "table"

  public var valuesParameterLabel             : String? = "values"
  public var valueParameterName               = "value"

  public var commentHeadline =
    "Insert a record into a SQL table in a typesafe way."
  public var commentRecordParameter =
    "A keypath to the table to fill e.g. `\\.person`."
  public var commentInsertColumnSuffix = "column of the new record."
  public var commentInsertValueSuffix = "value of the new record."
  
  
  /* Generation */
  
  public func generate() {
    assert(columnCount >= 1 && columnCount < 30)
    guard columnCount >= 1 else { return }
    
    for columnCount in 1...columnCount {
      functions.append(generateInsert(columnCount: columnCount))
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

      sample += ", "
      sample += sampleParameters.map({ "\\.\($0.column)" })
                                .joined(separator: ", ")

      if let l = valuesParameterLabel  { sample += ", \(l): " }
      else { sample += ", " }

      sample += sampleParameters.map(\.value).joined(separator: ", ")      
      sample += ")"
            
      if !sample.isEmpty { comment.example = sample }
    }
    
    comment.parameters.append(
      .init(name: recordParameterName, info: commentRecordParameter)
    )
    
    for ( idx, n ) in columnParameterNames.enumerated() {
      var info = "The \(ordinal(idx + 1)) \(commentInsertColumnSuffix)"
      if idx < commentColumnExamples.count {
        info += " E.g. `\\.\(commentColumnExamples[idx])`."
      }
      comment.parameters.append(.init(name: n, info: info))
    }
    for ( idx, v ) in valueParameterNames.enumerated() {
      var info = "The \(ordinal(idx + 1)) \(commentInsertValueSuffix)"
      if idx < commentColumnValueExamples.count {
        info += " E.g. `\(commentColumnValueExamples[idx].value)`."
      }
      comment.parameters.append(.init(name: v, info: info))
    }
    
    return comment
  }
  
  public func generateInsert(columnCount: Int) -> FunctionDefinition {
    // Yes, this is a little big. But hey, it is a code generator! :-)
    _ = """
    func insert<T, C1, C2>(
      into    table : KeyPath<Self.RecordTypes, T.Type>,
      _     column1 : KeyPath<T.Schema, C1>,
      _     column2 : KeyPath<T.Schema, C2>,
      values value1 : C1.Value,
      _      value2 : C2.Value
    ) throws
    where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T, T: SQLTableRecord
    {
      var builder = SQLBuilder<T>()
      builder.addColumn(column1)
      builder.addColumn(column2)
      builder.generateInsert(
        into      : T.Schema.externalName,
        values    : value1.asSQLiteValue, value2.asSQLiteValue
      )
      
      print("SQL:", builder.sql)
      try fetch(builder.sql, builder.bindings) { stmt, stop in stop = true }
    }
    """

    let T   = recordGenericParameterPrefix // T
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
      
      parameters += zip(Cs, columnParameterNames).map { C, n in
        Param(name: n, keyPath: T, api.recordSchemaName, to: C)
      }

      var isFirst = true
      parameters += zip(Cs, valueParameterNames).map { C, v in
        let p = Param(keyword: isFirst ? valuesParameterLabel : nil, name: v,
                      type: .qualifiedType(baseName: C, name: api.columnValuePAT))
        isFirst = false
        return p
      }
    }
    
    var genericConstraints = [ GenericConstraint ]()
    do { // Generic Constraints
      genericConstraints.reserveCapacity((Cs.count + 1) * 2 + 1)

      // `T: SQLTableRecord`
      genericConstraints.append(.conformance(T, to: api.tableRecordType))

      // where C1: SQLColumn, T == C1.T ...
      genericConstraints += Cs.map { .conformance($0, to: api.columnType) }
      genericConstraints += Cs.map {
        .parameter(T, sameAs: $0, api.columnTablePAT) // `T`
      }
    }
    
    let declaration = FunctionDeclaration(
      name       : functionName,
      genericParameterNames: [ T ] + Cs,
      parameters : parameters,
      async      : asyncFunctions,
      throws     : true,
      returnType : .void, // TBD: maybe support RETURNING?
      genericConstraints: genericConstraints
    )
    
    
    // MARK: - Body
    _ = """
        var builder = SQLBuilder<T>()
        builder.addColumn(column1)
        builder.addColumn(column2)
        builder.generateInsert(
          into   : T.Schema.externalName,
          values : value1.asSQLiteValue, value2.asSQLiteValue
        )
        try fetch(builder.sql, builder.bindings) { stmt, stop in stop = true }
        """
    
    var statements = [ Statement ]()
    statements.reserveCapacity(Cs.count * 2 + 10)
    
    let values = valueParameterNames.map {
      Expression.variable($0)
    }
        
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
    statements.append( // builder.generateInsert
      .call(
        instance: builderVariableName, name: "generateInsert", parameters: [
          ( "into", .variable(T + "." + api.recordSchemaName, "externalName") ),
          ( "values", .varargs(values)  )
        ]
      )
    )
          
    let syncCode = Statement.call(
      try: true, name: "fetch", parameters: [
        ( nil, .variable(builderVariableName, "sql")      ),
        ( nil, .variable(builderVariableName, "bindings") )
      ],
      trailing: ( parameters: [ "_", "stop" ], statements: [
        .set("stop", .literal(.true))
      ])
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
