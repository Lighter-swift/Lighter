//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import Foundation
import LighterCodeGenAST

/// Generates a `CompilationUnit` with the column `select`, `update` and
/// `insert` functions with various numbers of arguments.
public func generateInternalVariadics(
              filename: String,
              configuration config: LighterConfiguration
            )
            -> CompilationUnit
{
  var fetchOps  = Extension(extendedType: .name("SQLDatabaseFetchOperations"))
  var changeOps = Extension(extendedType: .name("SQLDatabaseChangeOperations"))
  var asyncFetchOps =
        Extension(extendedType: .name("SQLDatabaseAsyncFetchOperations"))
  asyncFetchOps.minimumSwiftVersion = ( 5, 5 )
  asyncFetchOps.requiredImports     = [ "_Concurrency" ]
  
  // MARK: - Selects

  if !config.embeddedLighter.selects.syncYield.isDisabled {
    let sel = config.embeddedLighter.selects.syncYield
    let generator = SelectFunctionGeneration(
      columnCount : sel.columns,
      sortCount   : sel.sorts,
      yield: true, async: false
    )
    generator.predicateParameterName = nil // crashes swiftc
    generator.generate()
    fetchOps.functions += generator.functions
  }
  if !config.embeddedLighter.selects.syncArray.isDisabled {
    let sel = config.embeddedLighter.selects.syncArray
    let generator = SelectFunctionGeneration(
      columnCount : sel.columns,
      sortCount   : sel.sorts,
      yield: false, async: false
    )
    generator.generate()
    generator.predicateParameterName = nil // also need the one w/o the predicate
    generator.generate()
    
    fetchOps.functions += generator.functions
  }
  if !config.embeddedLighter.selects.asyncArray.isDisabled {
    let sel = config.embeddedLighter.selects.asyncArray
    let generator = SelectFunctionGeneration(
      columnCount : sel.columns,
      sortCount   : sel.sorts,
      yield: false, async: true
    )
    generator.generate()
    generator.predicateParameterName = nil // also need the one w/o the predicate
    generator.generate()
    
    asyncFetchOps.functions += generator.functions
  }
  
  
  // MARK: - Updates
  
  if config.embeddedLighter.updates.keyBased > 0 {
    let up = config.embeddedLighter.updates.keyBased
    let generator = UpdateFunctionGeneration(
      columnCount: up, primaryKey: true, async: false
    )
    generator.generate()
    changeOps.functions += generator.functions
  }
  if config.embeddedLighter.updates.predicateBased > 0 {
    let up = config.embeddedLighter.updates.predicateBased
    let generator = UpdateFunctionGeneration(
      columnCount: up, primaryKey: false, async: false
    )
    generator.generate()
    changeOps.functions += generator.functions
  }
  
  
  // MARK: - Inserts
  
  if config.embeddedLighter.inserts > 0 {
    let generator = InsertFunctionGeneration(
      columnCount: config.embeddedLighter.inserts, async: false)
    generator.generate()
    changeOps.functions += generator.functions
  }

  
  // Forge a Unit

  var unit = CompilationUnit(name: filename)
  unit.addIfNotEmpty(fetchOps)
  unit.addIfNotEmpty(asyncFetchOps)
  unit.addIfNotEmpty(changeOps)

  return unit
}
