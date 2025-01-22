//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

public extension CodeGenerator {
  
  func generateUnit(_ unit: CompilationUnit) {
    for imp in unit.reexports {
      writeln("@_exported import \(imp)")
    }
    for imp in unit.imports {
      writeln("import \(imp)")
    }

    for function in unit.functions {
      writeln()
      generateFunctionDefinition(function)
    }

    for typeDefinition in unit.typeDefinitions {
      writeln()
      generateTypeDefinition(typeDefinition)
    }

    for ext in unit.extensions {
      writeln()
      generateExtension(ext)
    }
  }
}
