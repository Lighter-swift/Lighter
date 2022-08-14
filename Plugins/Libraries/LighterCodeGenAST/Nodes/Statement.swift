//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * An AST node for a Swift statement.
 */
public enum Statement: Equatable {
  
  /**
   * A pair for an `if`, `else if` statement, consisting of a condition and the
   * associated ``Statement``s.
   */
  public struct ConditionStatementPair: Equatable {
    
    /// The condition that must be true to have the ``statements`` executed.
    public var condition  : Expression
    /// The ``Statement``s that are executed if the ``condition`` is true.
    public var statements : [ Statement ]
    
    /// Initialize a new condition/statement pair.
    public init(_ condition: Expression, _ statements: [ Statement ]) {
      self.condition  = condition
      self.statements = statements
    }
  }
  
  /// Just a raw string that is emitted into Swift code. Escape hatch for
  /// the incomplete AST.
  case raw(String)
  
  /// Just a group of associated ``Statement``s.
  case group([ Statement ])
  
  /// `var builder = SQLBuilder<T>()`
  case variableDefinition(name: String, type: TypeReference?, value: Expression)
  
  /// `builder = SQLBuilder<T>()`
  case variableAssignment(instance: String?, name: String, value: Expression)
  
  /// `let sql = builder.generateSelect(...)`
  case constantDefinition(name: String, value: Expression)
  
  /// A function call. The expression is going to be an
  /// ``Expression/functionCall(_:)``.
  case call(Expression)
  
  /// A `return xyz` statement.
  case `return`(Expression)
  
  /// A `for` loop going over a range (`for x in 1...10`).
  case forInRange(counter: String, from: Expression, to: Expression,
                  statements: [ Statement ])
  /// A `while true {}` loop. Must contain at least one ``break`` statement.
  case whileTrue([ Statement ])
  /// A `break` statement to leave a loop, e.g. ``whileTrue(_:)``.
  case `break`
  
  /// An `if x else if y else if z` sequence, with associated statement arrays.
  case ifElseSwitch([ ConditionStatementPair ])
  
  /// An `if let x {} else {}` statement.
  case ifLetElse(String, Expression, [ Statement ] , `else`: [ Statement ])
  
  /// A `guard x else {}` statement.
  case `guard`(Expression, [ Statement ])
  
  /// A `defer` statement.
  case `defer`([ Statement ])
  
  /// A nested, inline function.
  case nestedFunction(FunctionDefinition)
}


// MARK: - Convenience

public extension Statement {
  
  /// Initialize a new `ifLetElse` statement.
  static func ifLet(_ id: String, is value: Expression, then: Statement...)
              -> Self
  {
    .ifLetElse(id, value, then, else: [])
  }
  /// Initialize a new `ifLetElse` statement.
  static func ifLet(_ id: String, is value: Expression, then: [Statement],
                    else: [Statement])
              -> Self
  {
    .ifLetElse(id, value, then, else: `else`)
  }

  /// Initialize a new ``ifElseSwitch(_:)`` statement.
  static func ifSwitch(_ pairs: ( Expression, Statement )...) -> Self {
    .ifElseSwitch(pairs.map { ConditionStatementPair($0, [ $1 ]) })
  }
}

public extension Statement {
  
  /// `a = 10`, `x.a = "hello"`
  static func `set`(instance: String? = nil, _ name: String,
                    _ value: Expression) -> Self
  {
    .variableAssignment(instance: instance, name: name, value: value)
  }
  /// `var a : Int = 10`
  static func `var`(_ name: String, type: TypeReference? = nil,
                    _ value: Expression? = nil) -> Self
  {
    .variableDefinition(name: name, type: type, value: value ?? .nil)
  }
  
  /// `let a = 10`
  static func `let`(_ name: String, is value: Expression) -> Self {
    .constantDefinition(name: name, value: value)
  }
}

public extension Statement {

  /// Initialize a `self.init` ``call(_:)`` statement.
  static func selfInit(`try`: Bool = false, `await`: Bool = false,
                       _ parameters: ( name: String?, value: Expression )...)
              -> Self
  {
    .call(.selfInit(FunctionCall(
      try: `try`, await: `await`,
      instance: "self", name: "init",
      parameters: parameters.map { .init($0.name, $0.value) },
      trailing: nil
    )))
  }

  /// Initialize ``call(_:)`` statement.
  static func call(
    `try`: Bool = false, `await`: Bool = false,
    instance: String? = nil, name: String,
    parameters: [ ( name: String?, value: Expression )] = [],
    trailing: ( parameters: [ String ], statements: [ Statement ])? = nil
  ) -> Self
  {
    .call(.functionCall(FunctionCall(
      try: `try`, await: `await`,
      instance: instance, name: name,
      parameters: parameters.map { .init($0.name, $0.value) },
      trailing: FunctionCall.TrailingClosure(trailing)
    )))
  }

  /// `builder.addColumn(column1, column2)`
  static func call(
    `try`: Bool = false, `await`: Bool = false,
    instance: String? = nil, name: String,
    withVariables variableNames: String...,
    trailing: ( parameters: [ String ], statements: [ Statement ])? = nil
  ) -> Self
  {
    .call(try: `try`, await: `await`, instance: instance, name: name,
          parameters: variableNames.map { ( nil, .variable($0) ) })
  }
  
  // sqlite_column_count(stmt)
  static func call(
    `try`: Bool = false, `await`: Bool = false,
    instance   : String? = nil,
    name       : String,
    _ parameters : Expression...) -> Self
  {
    .call(try: `try`, await: `await`, instance: instance, name: name,
          parameters: parameters.map { ( nil, $0 ) })
  }
}
