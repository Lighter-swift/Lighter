//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class ASTRecordInitGenerationTests: XCTestCase {
  
  func testPersonStatementInit() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    let s = gen.generateRecordStatementInit(for: try XCTUnwrap(dbInfo["Person"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "let indices = indices ?? Self.Schema.lookupColumnIndices"))
    XCTAssertTrue(source.contains("let argc = sqlite3_column_count"))
    XCTAssertTrue(source.contains(
      "indices.idx_id >= 0) && (indices.idx_id < argc) && (sqlite3_column_type"))
    XCTAssertTrue(source.contains("nil) ?? Self.schema.lastname.defaultValue"))
  }
  
  func testAddressStatementInit() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    let s =
    gen.generateRecordStatementInit(for: try XCTUnwrap(dbInfo["Address"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "let indices = indices ?? Self.Schema.lookupColumnIndices"))
    XCTAssertTrue(source.contains("let argc = sqlite3_column_count"))
    XCTAssertTrue(source.contains(
      "indices.idx_id >= 0) && (indices.idx_id < argc) && (sqlite3_column_type"))
    XCTAssertTrue(source.contains("nil) : Self.schema.personId.defaultValue"))
  }
  
  func testRawPersonStatementInit() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.useLighter = false
    let s = gen.generateRecordStatementInit(for: try XCTUnwrap(dbInfo["Person"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "let indices = indices ?? Self.Schema.lookupColumnIndices"))
    XCTAssertTrue(source.contains("let argc = sqlite3_column_count"))
    XCTAssertTrue(source.contains(
      "indices.idx_id >= 0) && (indices.idx_id < argc) && (sqlite3_column_type"))
    
    // no access to mapped column!
    XCTAssertFalse(source.contains("lastname.defaultValue"))
  }
  
  func testTalentInit() throws {
    let dbInfo    = DatabaseInfo(name: "Talents", schema: Fixtures.talentSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Talents.swift"
    )
    let s = gen.generateRecordStatementInit(for: try XCTUnwrap(dbInfo["Talent"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "let indices = indices ?? Self.Schema.lookupColumnIndices"))
    XCTAssertTrue(source.contains("let argc = sqlite3_column_count"))
    XCTAssertTrue(source.contains(
      "indices.idx_id >= 0) && (indices.idx_id < argc) && (sqlite3_column_type"))
    XCTAssertTrue(source.contains(
      "SQLITE_BLOB ? (sqlite3_column_blob(statement, indices.idx_id).flatMap"))
    XCTAssertTrue(source.contains(
      "UnsafeRawBufferPointer(start: $0, count: 16)"))
    XCTAssertTrue(source.contains("UUID(uuid:"))
    XCTAssertTrue(source.contains("rbp[0], rbp[1], rbp[2],  rbp[3],  rbp[4]"))
    XCTAssertTrue(source.contains("rbp[13], rbp[14], rbp[15]"))
    XCTAssertTrue(source.contains("UUID(uuidString: String(cString: $0))"))
  }
}
