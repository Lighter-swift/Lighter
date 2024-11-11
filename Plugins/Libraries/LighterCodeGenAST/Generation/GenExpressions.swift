//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension CodeGenerator {

  func string(for expression: Expression, wrapIfComplex: Bool) -> String {
    guard wrapIfComplex else { return string(for: expression) }
    
    switch expression {
      case .raw, .tuple, .varargs, .compare, .and, .conditional, .flatMap,
            .arithmetic, .nilCoalesce, .forceUnwrap, .array:
        return "(\(string(for: expression)))"
      
      case .literal, .variableReference, .variablePath,
           .keyPathLookup, .keyPath, .functionCall, .selfInit, .typeInit,
           .cast, .inlineClosureCall, .closure:
        return string(for: expression)
    }
  }

  func string(for expression: Expression) -> String {
    switch expression {
      
      case .raw    (let string)  : return string
      case .literal(let literal) : return string(for: literal)
      
      case .variableReference(.some(let instance), let name):
        return "\(instance).\(tickedWhenReserved(name))" // Allow `self`
      case .variableReference(.none, let name):
        return tickedWhenReserved(name)

      case .variablePath(let path):
        assert(!path.isEmpty)
        guard let first = path.first else { return "/* empty-path */" }
        return first + "." + // first explicitly NOT ticked (for `self.`)
          path.dropFirst().map(tickedWhenReserved).joined(separator: ".")
      
      case .keyPathLookup(let rawBase, let rawPath):
        return "\(rawBase)[keyPath: \(rawPath)]"

      case .keyPath(.some(let type), let name):
        return "\\\(string(for: type)).\(tickedWhenReserved(name))"
      case .keyPath(.none, let name):
        return "\\.\(tickedWhenReserved(name))"

      case .typeInit(let type):
        return "\(string(for: type))()"

      case .tuple(let expressions):
        return "( "
             + expressions.map({ string(for: $0) }).joined(separator: ", ")
             + " )"
      case .array(let expressions):
        if expressions.isEmpty { return "[]" }
        return "[ "
             + expressions.map({ string(for: $0) }).joined(separator: ", ")
             + " ]"
      case .varargs(let expressions):
        return expressions.map({ string(for: $0) }).joined(separator: ", ")

      case .functionCall(let call): // uuuughh
        return expressionStringForFunctionCall(call)
      case .selfInit(let call): // uuuughh
        return expressionStringForFunctionCall(call, isSelfInit: true)

      case .flatMap(let expression, let map):
        return "\(string(for: expression)).flatMap(\(string(for: map)))"

      case .compare(lhs: .literal(.integer(let lhs)),
                    let op,
                    rhs: .literal(.integer(let rhs))):
        // minor optimization to avoid a compiler warning
        // (e.g. "1>0 always true")
        switch op {
          case .equal              : return lhs == rhs ? "true" : "false"
          case .notEqual           : return lhs != rhs ? "true" : "false"
          case .greaterThanOrEqual : return lhs >= rhs ? "true" : "false"
          case .lessThan           : return lhs <  rhs ? "true" : "false"
        }
      
      case .compare(let lhs, let op, let rhs):
        return "\(string(for: lhs)) \(op.rawValue) \(string(for: rhs))"

      case .arithmetic(let lhs, let op, let rhs):
        return "\(string(for: lhs)) \(op.rawValue) \(string(for: rhs))"

      case .and(let expressions):
        return expressions.map({ "(\(string(for: $0)))" })
                          .joined(separator: " && ")

      case .cast(let expression, let type):
        return "\(string(for: type))(\(string(for: expression)))"

      case .conditional(let condition, let `true`, let `false`):
        // Could remove parenthesis for simple cases, but is required for nested
        return "\(string(for: condition)) "
             + "? \(string(for: `true`, wrapIfComplex: true)) "
             + ": \(string(for: `false`, wrapIfComplex: true))"
      
      case .nilCoalesce(let lhs, let rhs):
        return "\(string(for: lhs, wrapIfComplex: true)) "
             + "?? \(string(for: rhs, wrapIfComplex: true))"

      case .forceUnwrap(let expression):
        return "\(string(for: expression, wrapIfComplex: true))!"
      
      case .closure(let statements):
        return nestedGeneration {
          indentedCodeBlock(addSpaceIfMissing: false) {
            generateStatements(statements)
          }
        }
      case .inlineClosureCall(let statements):
        return nestedGeneration {
          indentedCodeBlock(endSuffix: "()", addSpaceIfMissing: false) {
            generateStatements(statements)
          }
        }
    }
  }
  
  /// Renders using the same generator, but first clears the `source` string,
  /// and then reestablishes the old value after it is done.
  private func nestedGeneration(execute: () -> Void) -> String {
    let oldSource = source
    self.source = ""
    execute()
    let generated = self.source
    self.source = oldSource
    return generated
  }

  private func expressionStringForFunctionCall(_ call: FunctionCall,
                                               isSelfInit: Bool = false)
               -> String
  {
    nestedGeneration {
      appendFunctionCall(call, isSelfInit: isSelfInit)
    }
  }

  func appendExpression(_ expression: Expression) {
    switch expression {
      case .raw, .literal, .variableReference, .keyPathLookup, .typeInit,
           .keyPath, .compare, .cast, .and, .conditional, .variablePath,
           .arithmetic, .flatMap, .nilCoalesce, .forceUnwrap:
        append(string(for: expression))
      
      case .tuple, .array: // indent better
        append(string(for: expression))
      case .varargs: // indent better
        append(string(for: expression))
      case .closure: // indent better
        append(string(for: expression))
      case .inlineClosureCall: // indent better
        append(string(for: expression))
      case .functionCall(let call):
        appendFunctionCall(call)
      case .selfInit(let call):
        appendFunctionCall(call, isSelfInit: true)
    }
  }
}
