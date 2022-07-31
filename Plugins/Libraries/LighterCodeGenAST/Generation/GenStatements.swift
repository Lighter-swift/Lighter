//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension CodeGenerator {
  
  func generateStatement(_ value: Statement) {
    switch value {
      
      case .raw(let code):
        writeln(code)
      
      case .group(let statements):
        generateStatements(statements)
      
      case .variableDefinition(let name, let type, let value):
        appendIndent()
        append("var \(tickedWhenReserved(name))")
        if let type = type {
          append(configuration.propertyTypeSeparator) // " : "
          append(string(for: type))
        }
        append(configuration.propertyValueSeparator) // " = "
        appendExpression(value)
        appendEOLIfMissing()
      
      case .variableAssignment(.some(let instance), let name, let value):
        appendIndent()
        append(instance) // "self" can be used here
        append(".")
        append(tickedWhenReserved(name))
        append(configuration.propertyValueSeparator) // " = "
        appendExpression(value)
        appendEOLIfMissing()
      case .variableAssignment(.none, let name, let value):
        appendIndent()
        append(tickedWhenReserved(name))
        append(configuration.propertyValueSeparator) // " = "
        appendExpression(value)
        appendEOLIfMissing()
      
      case .constantDefinition(let name, let value):
        appendIndent()
        append("let \(tickedWhenReserved(name))")
        append(configuration.propertyValueSeparator) // " = "
        appendExpression(value)
        appendEOLIfMissing()
      
      case .call(let call):
        appendIndent()
        appendExpression(call)
        appendEOLIfMissing()
      
      case .`return`(let expression):
        appendIndent()
        append("return ")
        appendExpression(expression)
        appendEOLIfMissing()
      
      case .forInRange(let counter, let from, let to, let stmts):
        appendIndent()
        append("for \(counter) in \(string(for: from))..<\(string(for: to))")
        indentedCodeBlock {
          generateStatements(stmts)
        }
      case .whileTrue(let stmts):
        appendIndent()
        append("while true")
        indentedCodeBlock {
          generateStatements(stmts)
        }
      case .break: writeln("break")

      case .ifElseSwitch(let pairs):
        assert(!pairs.isEmpty)
        var isFirst = true
        for pair in pairs {
          let check = isFirst ? "if" : "else if"
          if isFirst { isFirst = false }
          appendIndent()
          append("\(check) \(string(for: pair.condition))")
          indentedCodeBlock {
            generateStatements(pair.statements)
          }
        }
      case .ifLetElse(let id, let value, let statements, let elseStatements):
        appendIndent()
        append("if let \(tickedWhenReserved(id)) = \(string(for: value))")
        indentedCodeBlock {
          generateStatements(statements)
        }
        if !elseStatements.isEmpty {
          appendIndent()
          append("else")
          indentedCodeBlock {
            generateStatements(elseStatements)
          }
        }

      case .guard(let condition, let statements):
        appendIndent()
        append("guard \(string(for: condition)) else")
        indentedCodeBlock {
          generateStatements(statements)
        }

      case .defer(let statements):
        appendIndent()
        append("defer")
        indentedCodeBlock {
          generateStatements(statements)
        }

      case .nestedFunction(let def):
        generateFunctionDefinition(def, omitPublic: true)
    }
  }
  
  func generateStatements(_ values: [ Statement ],
                          allowSingleReturn: Bool = false)
  {
    // var x : Int { y }
    if allowSingleReturn && values.count == 1,
       let statement = values.first,
       case .return(let expression) = statement
    {
      appendIndent()
      appendExpression(expression)
      appendEOLIfMissing()
    }
    else {
      for statement in values {
        // Later: separate groups by newline (if requested).
        generateStatement(statement)
      }
    }
  }
}
