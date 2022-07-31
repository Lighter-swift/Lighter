//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class ASTRecordBindGenerationTests: XCTestCase {
  
  func testPersonStatementBindWithLocalHelpers() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.optionalHelpersInDatabase = false
    let s = gen.generateRecordStatementBind(for: try XCTUnwrap(dbInfo["Person"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "sqlite3_bind_int64(statement, indices.idx_id"))
    XCTAssertTrue(source.contains("return try withOptCString(firstname)"))
    XCTAssertTrue(source.contains(
      "func withOptCString<R>(_ s: String?, _ body"))
    XCTAssertTrue(source.contains("return try execute()"))
  }
  
  func testPersonStatementBindWithDBHelpers() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.optionalHelpersInDatabase = true
    let s = gen.generateRecordStatementBind(for: try XCTUnwrap(dbInfo["Person"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "sqlite3_bind_int64(statement, indices.idx_id"))
    XCTAssertFalse(source.contains("return try withOptCString(firstname)"))
    XCTAssertFalse(source.contains(
      "func withOptCString(_ s: String?, _ body"))
    XCTAssertTrue(source.contains("return try execute()"))
    XCTAssertTrue(source.contains("try TestDB.withOptCString"))
  }
}
