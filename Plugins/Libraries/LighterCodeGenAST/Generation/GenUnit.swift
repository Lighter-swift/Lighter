//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
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

    for structure in unit.structures {
      writeln()
      generateStruct(structure)
    }

    for ext in unit.extensions {
      writeln()
      generateExtension(ext)
    }
  }
}
