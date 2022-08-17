//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class UpdateOperationsTests: XCTestCase {
  
  func testSinglePrimaryKeyUpdate() {
    let functions : [ FunctionDefinition ] = {
      let generator = UpdateFunctionGeneration(
        columnCount: 1,
        primaryKey: true
      )
      generator.generate()
      return generator.functions
    }()
    
    let ext = Extension(extendedType: .name("SQLDatabaseChangeOperations"),
                        functions: functions)
    
    let result : String = {
      let codegen = CodeGenerator()
      codegen.generateExtension(ext)
      return codegen.source
    }()
    
    //print("GOT:\n-----\n\(result)\n-----")
    
    XCTAssertTrue(result.contains("`set` column: KeyPath<T.Schema, C>,"))
    XCTAssertTrue(result.contains(
      "try execute(builder.sql, builder.bindings, readOnly: false)"))
    XCTAssertTrue(result.contains("`is` id: PK.Value"))
  }
  
  func testMultiPrimaryKeyUpdate() {
    let functions : [ FunctionDefinition ] = {
      let generator = UpdateFunctionGeneration(
        columnCount: 6,
        primaryKey: true
      )
      generator.generate()
      return generator.functions
    }()
    
    let ext = Extension(extendedType: .name("SQLDatabaseChangeOperations"),
                        functions: functions)

    let result : String = {
      let codegen = CodeGenerator()
      codegen.generateExtension(ext)
      return codegen.source
    }()
    
    //print("GOT:\n-----\n\(result)\n-----")
    
    XCTAssertTrue(result.contains("`set` column5: KeyPath<T.Schema, C5>,"))
    XCTAssertTrue(result.contains(
      "try execute(builder.sql, builder.bindings, readOnly: false)"))
    XCTAssertTrue(result.contains("`is` id: PK.Value"))
  }
  
  func testQualifierUpdate() {
    let functions : [ FunctionDefinition ] = {
      let generator = UpdateFunctionGeneration(
        columnCount: 3,
        primaryKey: false
      )
      generator.generate()
      return generator.functions
    }()
    
    let ext = Extension(extendedType: .name("SQLDatabaseChangeOperations"),
                        functions: functions)

    let result : String = {
      let codegen = CodeGenerator()
      codegen.generateExtension(ext)
      return codegen.source
    }()
    
    //print("GOT:\n-----\n\(result)\n-----")
    
    XCTAssertTrue(result.contains("`set` column2: KeyPath<T.Schema, C2>,"))
    XCTAssertTrue(result.contains(
      "try execute(builder.sql, builder.bindings, readOnly: false)"))
    XCTAssertTrue(result.contains(
      "predicate: ( T.Schema ) -> P"))
    XCTAssertTrue(result.contains("where: predicate(T.schema)"))
  }
}
