//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class FetchOperationsTests: XCTestCase {
  
  func testYieldOpsNoSort() {
    let generator = SelectFunctionGeneration(
      columnCount: 3,
      sortCount: 0
    )
    generator.yieldCallbackName      = "yield"
    generator.predicateParameterName = nil
    
    generator.generate()
    
    let ext = Extension(extendedType: .name("SQLDatabaseFetchOperations"),
                        functions: generator.functions)
    
    let codegen = CodeGenerator()
    codegen.generateExtension(ext)
    
    //print("GOT:\n-----\n\(codegen.source)\n-----")
    
    XCTAssertTrue(codegen.source.contains("builder.addColumn(column3)"))
    XCTAssertTrue(codegen.source.contains("try fetch"))
    XCTAssertTrue(codegen.source.contains("try yield("))
    XCTAssertTrue(codegen.source.contains(
      "C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2)"))
  }
  
  func testYieldOpsOneSortWithPredicateBuilder() {
    let generator = SelectFunctionGeneration(
      columnCount : 3,
      sortCount   : 1
    )
    generator.yieldCallbackName      = "yield"
    generator.predicateParameterName = "predicate"
    
    generator.generate()
    
    let ext = Extension(extendedType: .name("SQLDatabaseFetchOperations"),
                        functions: generator.functions)
    
    let codegen = CodeGenerator()
    codegen.generateExtension(ext)
    
    //print("GOT:\n-----\n\(codegen.source)\n-----")
    
    XCTAssertTrue(codegen.source.contains("builder.addColumn(column3)"))
    XCTAssertTrue(codegen.source.contains("try fetch"))
    XCTAssertTrue(codegen.source.contains("try yield("))
    XCTAssertTrue(codegen.source.contains(
      "C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2)"))
    
    XCTAssertTrue(codegen.source.contains(
      "orderBy sortColumn: KeyPath<T.Schema, CS>"))
    XCTAssertTrue(codegen.source.contains(
      "orderBy sortColumn: KeyPath<T.Schema, CS>,"))
    XCTAssertTrue(codegen.source.contains(
      "_ direction: SQLSortOrder = .ascending"))
  }
  
  func testArrayOpsOneSortWithPredicateBuilder() {
    let generator = SelectFunctionGeneration(
      columnCount : 3,
      sortCount   : 1
    )
    generator.yieldCallbackName      = nil
    generator.predicateParameterName = "predicate"
    
    generator.generate()
    
    let ext = Extension(extendedType: .name("SQLDatabaseFetchOperations"),
                        functions: generator.functions)
    
    let codegen = CodeGenerator()
    codegen.generateExtension(ext)
    
    //print("GOT:\n-----\n\(codegen.source)\n-----")
    
    XCTAssertTrue(codegen.source.contains("builder.addColumn(column3)"))
    XCTAssertTrue(codegen.source.contains("try fetch"))
    XCTAssertFalse(codegen.source.contains("try yield("))
    XCTAssertTrue(codegen.source.contains(
      "C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2)"))
    
    XCTAssertTrue(codegen.source.contains(
      "orderBy sortColumn: KeyPath<T.Schema, CS>"))
    XCTAssertTrue(codegen.source.contains(
      "orderBy sortColumn: KeyPath<T.Schema, CS>,"))
    XCTAssertTrue(codegen.source.contains(
      "_ direction: SQLSortOrder = .ascending"))
    
    XCTAssertTrue(codegen.source.contains("var records = [ "))
    XCTAssertTrue(codegen.source.contains("records.append("))
  }
  
  
  func testAsyncArrayOpsNoSortWithPredicateBuilder() {
    let generator = SelectFunctionGeneration(
      columnCount : 2,
      sortCount   : 0
    )
    generator.yieldCallbackName      = nil
    generator.predicateParameterName = "predicate"
    generator.asyncFunctions         = true
    
    generator.generate()
    
    let ext = Extension(extendedType: .name("SQLDatabaseAsyncFetchOperations"),
                        functions: generator.functions)
    
    let source : String = {
      let codegen = CodeGenerator()
      codegen.generateExtension(ext)
      return codegen.source
    }()
    
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue (source.contains("builder.addColumn(column2)"))
    XCTAssertTrue (source.contains("try await runOnDatabaseQueue"))
    XCTAssertFalse(source.contains("try yield("))
    XCTAssertTrue (source.contains(
      "C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1)"))
    
    XCTAssertFalse(source.contains("orderBy "))
    
    XCTAssertTrue(source.contains("var records = [ "))
    XCTAssertTrue(source.contains("records.append("))
    
    XCTAssertTrue(source.contains("async throws"))
  }
  
  func testLargeAsyncArrayOpsWithSortAndPredicateBuilder() {
    let generator = SelectFunctionGeneration(
      columnCount : 8,
      sortCount   : 2
    )
    generator.yieldCallbackName      = nil
    generator.predicateParameterName = "predicate"
    generator.asyncFunctions         = true
    
    generator.generate()
    
    let ext = Extension(extendedType: .name("SQLDatabaseAsyncFetchOperations"),
                        functions: generator.functions)
    
    let codegen = CodeGenerator()
    codegen.generateExtension(ext)
    
    //print("GOT:\n-----\n\(codegen.source)\n-----")

    XCTAssertTrue (codegen.source.contains("builder.addColumn(column2)"))
    XCTAssertTrue (codegen.source.contains("try await runOnDatabaseQueue"))
    XCTAssertFalse(codegen.source.contains("try yield("))
    XCTAssertTrue (codegen.source.contains(
      "C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1)"))

    XCTAssertTrue (codegen.source.contains("orderBy "))

    XCTAssertTrue (codegen.source.contains("var records = [ "))
    XCTAssertTrue (codegen.source.contains("records.append("))

    XCTAssertTrue (codegen.source.contains("async throws"))
  }
}
