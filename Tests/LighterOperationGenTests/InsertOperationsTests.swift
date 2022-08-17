//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class InsertOperationsTests: XCTestCase {
  
  func testSingleInsert() {
    let functions : [ FunctionDefinition ] = {
      let generator = InsertFunctionGeneration(columnCount: 1)
      generator.generate()
      return generator.functions
    }()
    
    let ext = Extension(extendedType: .name("SQLDatabaseChangeOperations"),
                        functions: functions)
    
    let source : String = {
      let codegen = CodeGenerator()
      codegen.generateExtension(ext)
      return codegen.source
    }()
    
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("func insert<T, C>("))
    XCTAssertTrue(source.contains(
      "into table: KeyPath<Self.RecordTypes, T.Type>"))
    XCTAssertTrue(source.contains("_ column: KeyPath<T.Schema, C>,"))
    XCTAssertTrue(source.contains("values value: C.Value"))
    XCTAssertTrue(source.contains(
      "where T: SQLTableRecord, C: SQLColumn, T == C.T"))
    XCTAssertTrue(source.contains("var builder = SQLBuilder<T>()"))
    XCTAssertTrue(source.contains("builder.addColumn(column)"))
    XCTAssertTrue(source.contains("try execute(builder"))
    XCTAssertTrue(source.contains("readOnly: false"))
  }
  
  func testLargeInsert() {
    let functions : [ FunctionDefinition ] = {
      let generator = InsertFunctionGeneration(columnCount: 8)
      generator.generate()
      return generator.functions
    }()
    
    let ext = Extension(extendedType: .name("SQLDatabaseChangeOperations"),
                        functions: functions)
    
    let source : String = {
      let codegen = CodeGenerator()
      codegen.generateExtension(ext)
      return codegen.source
    }()
    
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("func insert<T, C>("))
    XCTAssertTrue(source.contains(
      "into table: KeyPath<Self.RecordTypes, T.Type>"))
    XCTAssertTrue(source.contains("_ column: KeyPath<T.Schema, C>,"))
    XCTAssertTrue(source.contains("values value: C.Value"))
    XCTAssertTrue(source.contains(
      "where T: SQLTableRecord, C: SQLColumn, T == C.T"))
    XCTAssertTrue(source.contains("var builder = SQLBuilder<T>()"))
    XCTAssertTrue(source.contains("builder.addColumn(column)"))
    XCTAssertTrue(source.contains("try execute(builder"))
    XCTAssertTrue(source.contains("readOnly: false"))
  }
}
