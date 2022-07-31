//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension CodeGenerator {
  
  func appendFunctionCall(_ call: FunctionCall, isSelfInit: Bool = false) {
    // Later: make smarter wrt indentation and length

    let preamble : String = {
      var s = ""
      if call.try   { s += "try "   }
      if call.await { s += "await " }
      // Do not escape if we actually want to call `init`.
      // Note that we don't escape the instance in any case (which might become
      // an issue)
      let name = isSelfInit ? call.name : tickedWhenReserved(call.name)
      if let instance = call.instance { s += "\(instance).\(name)" }
      else                            { s += name }
      return s
    }()
    
    let parameters : [ String ] = call.parameters.map {
      if let name = $0.name { return "\(name): \(string(for: $0.value))"}
      else { return string(for: $0.value) }
    }
    let parametersSize = parameters.map(\.count).reduce(0, +)
    
    append(preamble)
    append("(")
    if (parametersSize + preamble.count + 1) < configuration.lineLength {
      append(parameters.joined(separator: configuration.identifierListSeparator))
      append(")")
    }
    else {
      appendEOL()
      indent {
        for ( idx, parameter ) in parameters.enumerated() {
          let isLast = (idx + 1) >= parameters.count
          writeln(parameter + (isLast ? "" : ","))
        }
      }
      appendIndent()
      append(")")
    }
    
    if let t = call.trailing {
      append(" ")
      let suffix = t.parameters.isEmpty ? configuration.eol
        : " ( "
        + t.parameters.joined(separator: configuration.identifierListSeparator)
        + " ) in"
        + configuration.eol
      indentedCodeBlock(startSuffix: suffix) {
        generateStatements(t.statements)
      }
    }
  }
}

public extension CodeGenerator {
  
  func string(for parameter: FunctionDeclaration.Parameter) -> String {
    var s = parameter.keyword.flatMap(tickedWhenReserved) ?? "_"
    if parameter.keyword != parameter.name {
      s += " \(tickedWhenReserved(parameter.name))"
    }
    s += ": "
    s += string(for: parameter.type)
    if let defaultValue = parameter.defaultValue {
      s += " = "
      s += string(for: defaultValue)
    }
    return s
  }
  
  func generateFunctionComment(_ value: FunctionComment) {
    let style = configuration.functionCommentStyle
    guard style != .noComments else { return }
    
    let linePrefix : String
    switch style {
      case .stars, .doubleStars : linePrefix = " * "
      case .dashes              : linePrefix = "// "
      case .tripleDashes        : linePrefix = "/// "
      case .noComments          : linePrefix = ""
    }
    switch style { // start
      case .stars       : writeln("/*")
      case .doubleStars : writeln("/**")
      case .dashes, .tripleDashes, .noComments: break
    }
    
    writeln(linePrefix + value.headline)
    
    if let info = value.info {
      writeln(linePrefix)
      writeLines(in: info, with: linePrefix)
    }
    if let sample = value.example, !sample.isEmpty {
      writeln(linePrefix)
      writeln(linePrefix + "Example:")
      writeTripleTickedSwiftCode(prefix: linePrefix, sample, language: "swift")
    }
    
    if !value.parameters.isEmpty {
      writeln(linePrefix)
      writeln(linePrefix + "- Parameters:")
      for parameter in value.parameters {
        writeln(linePrefix + "  - \(parameter.name): \(parameter.info)")
      }
    }
    // Later: throws
    if let info = value.returnInfo, !info.isEmpty {
      if value.parameters.isEmpty { writeln() }
      writeln(linePrefix + "- Returns: \(info)")
    }
    
    switch style { // end
      case .stars, .doubleStars: writeln(" */")
      case .dashes, .tripleDashes, .noComments: break
    }
  }

  func generateFunctionDeclaration(_    value : FunctionDeclaration,
                                   omitPublic : Bool = false,
                                   `static`   : Bool = false)
  {
    let genericParameterNames : String = {
      if value.genericParameterNames.isEmpty { return "" }
      return "<"
           + (value.genericParameterNames
                 .joined(separator: configuration.identifierListSeparator))
           + ">"
    }()
    var preamble = ""
    if value.public && !omitPublic { preamble.append("public ")   }
    if `static`                    { preamble.append("static ")   }
    if value.mutating              { preamble.append("mutating ") }
    if value.name != "init" && value.name != "deinit" {
      preamble.append("func ")
      preamble.append(tickedWhenReserved(value.name))
    }
    else {
      preamble.append(value.name) // do not tick, we reuse it for `init`
    }
    preamble.append(genericParameterNames)
    let parameters = value.parameters.map { string(for: $0) }
    
    let parametersSize = parameters.map(\.count).reduce(0, +)
    let returnSuffix   : String = {
      var s = ""
      
      if value.async  { s += "async" }
      
      if      value.throws   { if !s.isEmpty { s += " " }; s += "throws"   }
      else if value.rethrows { if !s.isEmpty { s += " " }; s += "rethrows" }
      
      if value.returnType != .void {
        if !s.isEmpty { s += " " }
        s += "-> \(string(for: value.returnType))"
      }
      return s
    }()
    
    appendIndent()
    append(preamble)
    append("(")
    if (preamble.count + parametersSize) < configuration.lineLength {
      append(parameters.joined(separator: configuration.identifierListSeparator))
      append(")")
      if !returnSuffix.isEmpty {
        if (preamble.count + parametersSize + returnSuffix.count)
            < configuration.lineLength
        {
          append(" \(returnSuffix)")
        }
        else {
          appendEOL()
          indent {
            writeln(returnSuffix)
          }
        }
      }
    }
    else {
      appendEOL()
      indent {
        for ( idx, parameter ) in parameters.enumerated() {
          // Later: Would be nice to `:` align the columns properly (if
          //        requested).
          let isLast = idx + 1 >= parameters.count
          writeln(parameter + (isLast ? "" : ","))
        }
      }
      if returnSuffix.isEmpty { writeln(")") }
      else { writeln(") \(returnSuffix)") }
    }
    
    if !value.genericConstraints.isEmpty {
      let constraints     = value.genericConstraints.map { string(for: $0) }
      let constraintsSize = constraints.map(\.count).reduce(0, +)
      
      appendEOLIfMissing()
      indent {
        if (constraintsSize + 6) < configuration.lineLength {
          appendIndent()
          append("where ")
          append(constraints.joined(
            separator: configuration.identifierListSeparator))
        }
        else {
          writeln("where")
          indent {
            for ( idx, constraint ) in constraints.enumerated() {
              let isLast = (idx + 1) >= constraints.count
              writeln(constraint + (isLast ? "" : ","))
            }
          }
        }
      }
    }
  }
  
  func generateFunctionDefinition(_ value: FunctionDefinition,
                                  omitPublic : Bool = false,
                                  `static`   : Bool = false)
  {
    if let comment = value.comment {
      generateFunctionComment(comment)
    }
    if value.inlinable && !configuration.neverInline && value.declaration.public
    {
      writeln("@inlinable")
    }
    if value.discardableResult && value.declaration.returnType != .void {
      writeln("@discardableResult")
    }

    generateFunctionDeclaration(value.declaration, omitPublic: omitPublic,
                                static: `static`)
    appendEOLIfMissing() // could be done smarter, e.g. length based
    appendIndent()
    indentedCodeBlock(addSpaceIfMissing: false) {
      generateStatements(value.statements, allowSingleReturn: true)
    }
  }
  

  func generateComputedPropertyDefinition(_ value: ComputedPropertyDefinition,
                                          omitPublic: Bool = false,
                                          `static`: Bool = false)
  {
    if let ( major, minor ) = value.minimumSwiftVersion {
      assert(major >= 5)
      writeln("#if swift(>=\(major).\(minor))")
    }
    
    writePropertyComment(value.comment)
    if value.inlinable && !configuration.neverInline && value.public {
      writeln("@inlinable")
    }
    
    appendIndent()
    if value.public && !omitPublic { append("public ") }
    if `static` { append("static ") }
    append("var ")
    append(tickedWhenReserved(value.name))
    append(configuration.propertyTypeSeparator) // " : "
    append(string(for: value.type))
        
    let allowSingleReturn = true // make an option?
    if allowSingleReturn && value.statements.count == 1,
       value.setStatements.isEmpty,
       let statement = value.statements.first,
       case .return(let expression) = statement
    {
      append(" { ")
      appendExpression(expression)
      append(" }")
      appendEOL()
    }
    else {
      if value.setStatements.isEmpty {
        indentedCodeBlock {
          generateStatements(value.statements, allowSingleReturn: true)
        }
      }
      else {
        indentedCodeBlock {
          appendIndent()
          append("set")
          indentedCodeBlock {
            generateStatements(value.setStatements, allowSingleReturn: true)
          }
          appendIndent()
          append("get")
          indentedCodeBlock {
            generateStatements(value.statements, allowSingleReturn: true)
          }
        }
      }
    }
    
    if let ( major, minor ) = value.minimumSwiftVersion {
      assert(major >= 5)
      writeln("#endif // swift(>=\(major).\(minor))")
    }
  }
}
