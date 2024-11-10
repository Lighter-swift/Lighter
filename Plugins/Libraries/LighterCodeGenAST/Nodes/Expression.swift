//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * An AST node for various Swift expressions.
 */
public indirect enum Expression: Equatable {
  
  /// The operators for ``compare(lhs:operator:rhs:)`` expressions.
  public enum Operator: String, Sendable {
    case equal              = "=="
    case notEqual           = "!="
    case greaterThanOrEqual = ">="
    case lessThan           = "<"
  }
  
  /// Just an arbitrary string to inject
  case raw(String)
  
  /// A literal, like `.nil`
  case literal(Literal)
  
  /// A variable value, like `limit` (as in `doIt(limit: limit)`)
  case variableReference(instance: String?, name: String)
  
  /// `Self.schema.personId.defaultValue`
  case variablePath([ String ])
  
  /// `T.schema[keyPath: column1]`
  case keyPathLookup(rawBase: String, rawPath: String)
  
  /// `\Person.name`
  case keyPath(baseType: TypeReference?, property: String)
  
  /// `builder.addColumn(T.schema[keyPath: column1])`
  case functionCall(FunctionCall)
  
  /// `self.init(...)`
  case selfInit(FunctionCall)
  
  /// `[ ( C1.Value ) ]()`
  case typeInit(TypeReference)
  
  /// `( 10, 20 )`
  case tuple([ Expression ])

  /// `[ 10, 20 ]`
  case array([ Expression ])

  /// `10, 20, 30`
  case varargs([ Expression ])
  
  /// `strcmp("hello", s) == 0`
  case compare(lhs: Expression, operator: Operator, rhs: Expression)
  
  /// `a && b && c`
  case and([ Expression ])
  
  /// `Int64(value)`
  case cast(expression: Expression, type: TypeReference)
  
  /// `a ? b : c`
  case conditional(condition: Expression, true: Expression, false: Expression)
  
  /// `cstr.flatMap(String.init(cString:))`
  case flatMap(expression: Expression, map: Expression)
  
  /// `a ?? b`
  case nilCoalesce(Expression, Expression)
  
  /// `a!`
  case forceUnwrap(Expression)
  
  /// `{ return 46 + 2 }` (w/o calling it)
  case closure([ Statement ])

  /// `{ return 46 + 2 }()` (calling it)
  case inlineClosureCall([ Statement ])
}

/**
 * A Swift function call expression.
 *
 * Used as the value for ``Expression/functionCall(_:)``.
 */
public struct FunctionCall: Equatable, Sendable {
  
  /**
   * A parameter passed as part of the function call.
   */
  public struct Parameter: Equatable, Sendable {
    
    /// The keyword/label of the parameter, can be `nil` if it is a wildcard
    /// (unlabled) parameter.
    public let name  : String? // FIXME:this is `label`
    /// The value passed to the parameter.
    public let value : Expression
    
    /// Initialize a ``FunctionCall`` parameter.
    public init(_ name: String? = nil, _ value: Expression) {
      self.name  = name
      self.value = value
    }
  }
  
  /**
   * A trailing closure attached to a function call.
   */
  public struct TrailingClosure: Equatable, Sendable {
    
    /// The parameter list of the trailing closure (e.g. `( a, b ) in`).
    public let parameters: [ String    ]
    /// The ``Statement``s of the closure.
    public let statements: [ Statement ]
    
    /// Initialize a trailing closure AST node.
    public init?(_ trailing: (parameters: [String], statements: [Statement])?) {
      guard let trailing = trailing else { return nil }
      self.parameters = trailing.parameters
      self.statements = trailing.statements
    }
  }

  /// Whether the function can throw and needs a try.
  public let `try`      : Bool
  /// Whether the function is asynchronous and needs an await.
  public let `await`    : Bool
  /// The optional name of the instance the call is made on, e.g. `sql.append`.
  public let instance   : String?
  /// The name of the function being called.
  public let name       : String
  /// The ``Parameter``s passed to the function. Can be empty.
  public let parameters : [ Parameter ]
  /// An optional trailing closure passed to the function.
  public let trailing   : TrailingClosure?
  
  /// Initialize a function call AST node.
  public init(`try`: Bool, `await`: Bool,
              instance: String?, name: String, parameters: [Parameter],
              trailing: TrailingClosure?)
  {
    self.try        = `try`
    self.await      = `await`
    self.instance   = instance
    self.name       = name
    self.parameters = parameters
    self.trailing   = trailing
  }
}


// MARK: - Literal Convenience

public extension Expression {
  
  /// `nil`
  static let `nil`   = Self.literal(.nil)
  /// Bool `true`
  static let `true`  = Self.literal(.true)
  /// Bool `false`
  static let `false` = Self.literal(.false)

  /// `$0`
  static let closureArg0 = Self.raw("$0")

  /// A literal integer (`42`).
  @inlinable
  static func integer(_ value: Int)    -> Self { .literal(.integer(value)) }
  /// A literal double (`13.37`).
  @inlinable
  static func double (_ value: Double) -> Self { .literal(.double (value)) }
  /// A literal string (`"Them Bones"`).
  @inlinable
  static func string (_ value: String) -> Self { .literal(.string (value)) }

  /// An array of `UInt8` integers (i.e. a data literal).
  @inlinable
  static func integerArray(_ value: [ UInt8 ]) -> Self {
    .literal(.integerArray(value.map { Int($0) }))
  }
}

// MARK: - Variable Convenience

public extension Expression {

  /// A reference to an instance variable, e.g. `builder.sql`.
  static func variable(_ instance: String, _ name: String) -> Self {
    .variableReference(instance: instance, name: name)
  }
  /// A variable reference, e.g. `sql`.
  static func variable(_ name: String) -> Self {
    .variableReference(instance: nil, name: name)
  }

  /// A variable (inout) reference, e.g. `&self.sql`.
  static func variableRef(_ instance: String, _ name: String) -> Self {
    .raw("&\(instance).\(name)") // TODO: add expr
  }
  /// A variable (inout) reference, e.g. `&self.sql`.
  static func variableRef(_ name: String) -> Self {
    .raw("&\(name)") // TODO: add expr
  }

  /// A KeyPath expression.
  static func keyPath(_ baseType: TypeReference? = nil, _ property: String)
              -> Self
  {
    .keyPath(baseType: baseType, property: property)
  }
}

// MARK: - Function Convenience

public extension Expression {
  
  /// Initialize a function call expression.
  static func call(
    `try`: Bool = false, `await`: Bool = false,
    instance   : String? = nil,
    name       : String,
    parameters : [ ( name: String?, value: Expression )],
    trailing   : ( parameters: [ String ], statements: [ Statement ])? = nil
  ) -> Self
  {
    .functionCall(
      FunctionCall(try: `try`, await: `await`,
                   instance: instance, name: name,
                   parameters: parameters.map { .init($0.name, $0.value) },
                   trailing: FunctionCall.TrailingClosure(trailing))
    )
  }
  
  /// Initialize a function call expression.
  /// `sqlite_column_count(stmt)`
  static func call(
    `try`: Bool = false, `await`: Bool = false,
    instance   : String? = nil,
    name       : String,
    _ parameters : Expression...) -> Self
  {
    .functionCall(
      FunctionCall(try: `try`, await: `await`,
                   instance: instance, name: name,
                   parameters: parameters.map { .init(nil, $0) },
                   trailing: nil)
    )
  }
  
  /// Initialize a function call expression.
  /// `strcmp(x, y) == 0`
  static func callIs0(_ name: String, _ parameters: Expression...) -> Self {
    .compare(
      lhs: .functionCall(
        FunctionCall(try: false, await: false,
                     instance: nil, name: name,
                     parameters: parameters.map { .init(nil, $0) },
                     trailing: nil)
      ),
      operator: .equal,
      rhs: .integer(0)
    )
  }
}


// MARK: - Comparison Convenience

public extension Expression {
  /// index >= 0
  static func gtOrEq0(_ expression: Expression) -> Self {
    .compare(lhs: expression, operator: .greaterThanOrEqual, rhs: .integer(0))
  }

  static func cmp(_ lhs: Expression, _ op: Operator, _ rhs: Expression) -> Self {
    .compare(lhs: lhs, operator: op, rhs: rhs)
  }
  static func cmp(_ lhs: Expression, _ op: Operator, _ rhs: Int) -> Self {
    .compare(lhs: lhs, operator: op, rhs: .integer(rhs))
  }
  static func isNil(_ lhs: Expression) -> Self {
    .compare(lhs: lhs, operator: .equal, rhs: .nil)
  }
  static func isNotNil(_ lhs: Expression) -> Self {
    .compare(lhs: lhs, operator: .notEqual, rhs: .nil)
  }

  /// Int64(x)
  static func cast(_ expression: Expression, to type: TypeReference) -> Self {
    .cast(expression: expression, type: type)
  }
  
  /// `a ? b : c`
  static func conditional(_ condition: Expression,
                          _ true: Expression, _ false: Expression) -> Self
  {
    .conditional(condition: condition, true: `true`, false: `false`)
  }
}


// MARK: - Date Formatting Convenience

public extension Expression {
    static func formattedCurrentDate(format: String) -> Self {
        .inlineClosureCall([
            .let("fmt", is: .call(name: "DateFormatter")),
            .set(instance: "fmt", "locale",
                 .call(name: "Locale", parameters: [
                    ("identifier", .string("en_US_POSIX"))
                 ])),
            .set(instance: "fmt", "timeZone",
                 .call(name: "TimeZone", parameters: [
                    ("secondsFromGMT", .integer(0))
                 ])),
            .set(instance: "fmt", "dateFormat", .string(format)),
            .return(.call(instance: "fmt",
                          name: "string",
                          parameters: [
                            ("from", .call(name: "Date"))
                          ]))
        ])
    }
}

#if swift(>=5.5)
extension Expression                   : Sendable {}
extension FunctionCall                 : Sendable {}
extension FunctionCall.Parameter       : Sendable {}
extension FunctionCall.TrailingClosure : Sendable {}
#endif
