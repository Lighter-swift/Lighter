//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {
  
  /**
   * Generates one big `CompilationUnit` containing all the code for the
   * various parts representing the database. Including the struct for the
   * database, for the records and all the various functions, global or not.
   */
  public func generateCombinedFile(moduleFileName: String?) -> CompilationUnit {
    var unit = CompilationUnit(name: filename)
    
    unit.imports = [ "SQLite3" ] // TBD: re-export for raw mode?
    if options.allowFoundation {
      unit.imports.append("Foundation")
    }
    if options.useLighter {
      switch options.importLighter {
        case .none     : break
        case .import   : unit.imports  .append("Lighter")
        case .reexport : unit.reexports.append("Lighter")
      }
    }
    
    // Global raw functions
    
    if case .globalFunctions(let prefix) = options.rawFunctions {
      let lowerName = database.name.lowercased().snake_case()
      if shouldGenerateCreateSQL {
        let name = prefix + "create_" + lowerName
        unit.functions.append(
          generateRawCreateFunction(name: name, moduleFileName: moduleFileName)
        )
      }
      if let filename = moduleFileName {
        let name = prefix + "open_" + lowerName
        unit.functions.append(
          generateRawModuleOpenFunction(name: name, for: filename))
      }
      for entity in database.entities {
        unit.functions += generateRawFunctions(for: entity)
      }
    }
    
    
    // Database Structure

    unit.structures.append(
      generateDatabaseStructure(moduleFileName: moduleFileName))
    
    
    // Entity Structures
    
    if !options.nestRecordTypesInDatabase {
      unit.structures += database.entities.map {
        generateRecordStructure(for: $0)
      }
    }

    // Type-Attached Raw Functions in Extensions (`Person.update(in:)` etc)
    
    if options.rawFunctions == .attachToRecordType {
      unit.extensions += database.entities.map { entity in
        Extension(extendedType: globalTypeRef(of: entity),
                  typeFunctions: generateRawTypeFunctions(for: entity),
                  functions: generateRawFunctions(for: entity))
      }
    }
    
    // Schema Structures, schema inits, binds and matching
    
    unit.extensions += database.entities.map { entity in
      Extension(
        extendedType: globalTypeRef(of: entity),
        structures: [ generateSchemaStructure(for: entity) ],
        functions: [
          generateRecordStatementInit(for: entity),
          generateRecordStatementBind(for: entity)
        ]
      )
    }
    
    // Relationships
    
    if options.useLighter, options.generateLighterRelationships {
      unit.extensions += generateRecordRelshipExtensions()
      if options.asyncAwait {
        unit.extensions += generateRecordRelshipExtensions(async: true)
      }
    }
    
    return unit
  }
}
