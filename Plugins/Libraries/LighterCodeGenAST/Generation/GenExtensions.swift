//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension CodeGenerator {
  
  /// `extension SQLColumn { ... }`
  func generateExtension(_ value: Extension) {
    if !source.isEmpty { appendEOLIfMissing() }
    
    if let ( major, minor ) = value.minimumSwiftVersion {
      assert(major >= 5)
      writeln("#if swift(>=\(major).\(minor))")
    }
    if !value.requiredImports.isEmpty {
      writeln("#if " + value.requiredImports.map { "canImport(\($0))" }
                            .joined(separator: " && "))
    }
    
    if value.requiredImports.contains("_Concurrency") {
      writeln("@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)")
    }

    appendIndent()
    if value.public { append("public ") }
    append("extension ")
    append(string(for: value.extendedType))
    
    if !value.genericConstraints.isEmpty {
      let constraints = value.genericConstraints.map({ string(for: $0) })
        .joined(separator: configuration.identifierListSeparator)
      appendEOL()
      indent {
        writeln("where \(constraints)")
      }
      writeln("{")
    }
    else {
      append(" {")
      appendEOL()
    }

    indent {
      for structure in value.structures {
        writeln()
        generateStruct(structure, omitPublic: value.public)
      }

      for function in value.typeFunctions {
        writeln()
        generateFunctionDefinition(function, omitPublic: value.public,
                                   static: true)
      }

      for function in value.functions {
        writeln()
        generateFunctionDefinition(function, omitPublic: value.public)
      }
    }
    writeln("}")

    if !value.requiredImports.isEmpty {
      writeln("#endif // required canImports")
    }
    if let ( major, minor ) = value.minimumSwiftVersion {
      writeln("#endif // swift(>=\(major).\(minor))")
    }
  }
}
