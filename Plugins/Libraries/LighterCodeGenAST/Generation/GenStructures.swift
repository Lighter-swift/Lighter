//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

public extension CodeGenerator {
  
  /// public static let schema = Schema()
  /// public var personId  : Int
  func generateInstanceVariable(_    value : TypeDefinition.InstanceVariable,
                                `static`   : Bool = false,
                                omitPublic : Bool = false)
  {
    assert(value.type != nil || value.value != nil)
    
    func writeBody() {
      if value.public && !omitPublic { append("public ") }
      if `static` { append("static ") }
      append(value.let ? "let " : "var ")
      append(tickedWhenReserved(value.name))
      if let type = value.type {
        append(configuration.propertyTypeSeparator) // " : "
        append(string(for: type))
      }
      if let value = value.value {
        append(configuration.propertyValueSeparator) // " = "
        append(string(for: value))
      }
      appendEOL()
    }
    
    func writePlain() {
      if let ( major, minor ) = value.minimumSwiftVersion {
        assert(major >= 5)
        writeln("#if swift(>=\(major).\(minor))")
      }
      
      writePropertyComment(value.comment)
      appendIndent()
      writeBody()

      if let ( major, minor ) = value.minimumSwiftVersion {
        assert(major >= 5)
        writeln("#endif // swift(>=\(major).\(minor))")
      }
    }
    
    if value.nonIsolatedUnsafe {
      if let ( major, minor ) = value.minimumSwiftVersion,
         (major > 5) || (major >= 5 && minor >= 10)
      {
        writePlain()
      }
      else {
        writeln("#if swift(>=5.10)")

        writePropertyComment(value.comment)
        appendIndent()
        append("nonisolated(unsafe) ")
        writeBody()

        if let ( major, minor ) = value.minimumSwiftVersion {
          assert(major >= 5)
          writeln("#elseif swift(>=\(major).\(minor))")
        }
        else {
          writeln("#else")
        }
        
        writePropertyComment(value.comment)
        appendIndent()
        writeBody()
        writeln("#endif")
      }
    }
    else {
      writePlain()
    }
  }

  /**
   * ```swift
   * public struct Person: SQLKeyedTableRecord, Identifiable {
   *
   *   public static let schema = Schema()
   *
   *   @inlinable
   *   public var id : Int { personId }
   *
   *   public var personId  : Int
   *   public var lastname  : String
   *   public var firstname : String?
   *
   *   @inlinable
   *   public init(personId: Int = 0, lastname: String, firstname: String? = nil) {
   *     self.personId  = personId
   *     self.lastname  = lastname
   *     self.firstname = firstname
   *   }
   * }
   * ```
   */
  func generateStruct(_ value: TypeDefinition, omitPublic: Bool = false) {
    assert(value.kind == .struct)
    generateTypeDefinition(value, omitPublic: omitPublic)
  }

  /**
   * ```swift
   * public struct Person: SQLKeyedTableRecord, Identifiable {
   *
   *   public static let schema = Schema()
   *
   *   @inlinable
   *   public var id : Int { personId }
   *
   *   public var personId  : Int
   *   public var lastname  : String
   *   public var firstname : String?
   *
   *   @inlinable
   *   public init(personId: Int = 0, lastname: String, firstname: String? = nil) {
   *     self.personId  = personId
   *     self.lastname  = lastname
   *     self.firstname = firstname
   *   }
   * }
   * ```
   */
  func generateTypeDefinition(_ value: TypeDefinition, omitPublic: Bool = false)
  {
    if !source.isEmpty { appendEOLIfMissing() }
    
    if let comment = value.comment {
      generateTypeComment(comment)
    }
    
    if value.dynamicMemberLookup {
      writeln("@dynamicMemberLookup")
    }
    
    do { // header
      appendIndent()
      if value.public && !omitPublic { append("public ") }
      switch value.kind {
        case .struct : append("struct ")
        case .class  : append("class ")
        case .enum   : append("enum ")
      }
      append(tickedWhenReserved(value.name))
      
      if !value.conformances.isEmpty {
        append(configuration.typeConformanceSeparator) // " : "
        append(value.conformances.map(string(for:))
          .joined(separator: configuration.identifierListSeparator))
      }
    }
    
    indentedCodeBlock {
      let pubPrefix = value.public ? "public " : ""
      
      if !value.typeAliases.isEmpty { writeln() }
      for ( name, ref ) in value.typeAliases {
        writeln("\(pubPrefix)typealias \(tickedWhenReserved(name))"
              + "\(configuration.propertyValueSeparator)\(string(for: ref))")
      }
      
      for nestedType in value.nestedTypes {
        writeln()
        generateStruct(nestedType)
      }
      
      // Later: I'd really like to vertically align the colors and equals.
      
      var lastHadComment = false
      if !value.typeVariables.isEmpty { writeln() }
      for variable in value.typeVariables {
        if lastHadComment { writeln() }
        generateInstanceVariable(variable, static: true)
        lastHadComment = variable.comment != nil
      }
      
      lastHadComment = false
      if !value.computedTypeProperties.isEmpty { writeln() }
      for property in value.computedTypeProperties {
        if lastHadComment { writeln() }
        generateComputedPropertyDefinition(property, static: true)
        lastHadComment = property.comment != nil
      }

      for function in value.typeFunctions {
        writeln()
        generateFunctionDefinition(function, static: true)
      }

      lastHadComment = false
      if !value.variables.isEmpty { writeln() }
      for variable in value.variables {
        if lastHadComment { writeln() }
        generateInstanceVariable(variable, static: false)
        lastHadComment = variable.comment != nil
      }
      
      lastHadComment = false
      if !value.computedProperties.isEmpty { writeln() }
      for property in value.computedProperties {
        if lastHadComment { writeln() }
        generateComputedPropertyDefinition(property)
        lastHadComment = property.comment != nil
      }
      
      for function in value.functions {
        writeln()
        generateFunctionDefinition(function)
      }
    }
  }
  
  func writeTripleTickedSwiftCode(prefix: String? = nil, _ code: String?,
                                  language: String?) {
    guard let code = code?.trimmingCharacters(in: .newlines),
          !code.isEmpty else { return }
    let linePrefix = prefix ?? ""
    let lines = code.split(separator: "\n", omittingEmptySubsequences: false)
    writeln(linePrefix + "```\(language ?? "")")
    for line in lines {
      writeln(linePrefix + line)
    }
    writeln(linePrefix + "```")
  }
  
  func generateTypeComment(_ value: TypeComment) {
    let style = configuration.typeCommentStyle
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
    
    // Examples
    
    if value.examples.count == 1, let example = value.examples.first {
      writeln(linePrefix)
      writeln(linePrefix + example.headline)
      writeTripleTickedSwiftCode(prefix: linePrefix, example.code,
                                 language: example.language)
    }
    else if value.examples.count > 1 {
      writeLines(in: configuration.multiExampleSectionHeader, with: linePrefix)
      
      for example in value.examples {
        writeln(linePrefix)
        writeln(linePrefix + example.headline)
        writeTripleTickedSwiftCode(prefix: linePrefix, example.code,
                                   language: example.language)
      }
    }
    
    // SQL
    
    if !value.sql.isEmpty {
      writeLines(in: configuration.multiSQLSectionHeader, with: linePrefix)
      
      for example in value.sql {
        writeln(linePrefix)
        writeln(linePrefix + example.headline)
        writeTripleTickedSwiftCode(prefix: linePrefix, example.code,
                                   language: example.language)
      }
    }

    // Close up
    
    switch style { // end
      case .stars, .doubleStars: writeln(" */")
      case .dashes, .tripleDashes, .noComments: break
    }
  }
}
