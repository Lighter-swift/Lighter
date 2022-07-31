//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST
import struct Foundation.URL
import struct Foundation.Date
import struct Foundation.Data
import class  Foundation.ISO8601DateFormatter

public extension CompilationUnit {
  
  func writeCode(to url: URL, configuration config: LighterConfiguration,
                 headerName: String? = nil, now: Date = Date()) throws
  {
    let formatter = ISO8601DateFormatter()

    let codegen = CodeGenerator(configuration: config.codeStyle)
    
    if let toolName = headerName {
      codegen.writeln(
        "// Autocreated by \(toolName) at \(formatter.string(from: now))")
    }

    if !imports.isEmpty && reexports.isEmpty { codegen.writeln() }
    
    codegen.generateUnit(self)
    
    let data = Data(codegen.source.utf8)
    try data.write(to: url, options: [ .atomic ])
  }
}
