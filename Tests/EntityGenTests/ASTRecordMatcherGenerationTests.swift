//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class ASTRecordMatcherGenerationTests: XCTestCase {
  
  func testPersonMatcher() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    let entity = try XCTUnwrap(dbInfo["Person"])
    let r = gen.generateRegisterSwiftMatcher  (for: entity)
    let u = gen.generateUnregisterSwiftMatcher(for: entity)
    let e = Extension(extendedType: .name(entity.name), functions: [ r, u ])
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateExtension(e)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("func registerSwiftMatcher("))
    XCTAssertTrue(source.contains("func unregisterSwiftMatcher("))
    XCTAssertTrue(source.contains("func dispatch("))
    XCTAssertTrue(source.contains(
      "argv: UnsafeMutablePointer<OpaquePointer?>!"))
    XCTAssertTrue(source.contains(
      "if let closureRawPtr = sqlite3_user_data(context)"))
    XCTAssertTrue(source.contains(
      "sqlite3_value_type(argv[Int(indices.idx_id)]) != SQLITE_NULL"))
    XCTAssertTrue(source.contains(
      "Int(sqlite3_value_int64(argv[Int(indices.idx_id)]))"))
    XCTAssertTrue(source.contains(
      "sqlite3_result_int(context, closurePtr.pointee(record) ? 1 : 0)"))
    XCTAssertTrue(source.contains("sqlite3_result_error(context, "))
  }
  
  func testRawPersonMatcher() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.useLighter = false
    let entity = try XCTUnwrap(dbInfo["Person"])
    let r = gen.generateRegisterSwiftMatcher  (for: entity)
    let e = Extension(extendedType: .name(entity.name), functions: [ r ])
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateExtension(e)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("func registerSwiftMatcher("))
    XCTAssertTrue(source.contains("func dispatch("))
    XCTAssertTrue(source.contains(
      "argv: UnsafeMutablePointer<OpaquePointer?>!"))
    XCTAssertTrue(source.contains(
      "if let closureRawPtr = sqlite3_user_data(context)"))
    XCTAssertTrue(source.contains(
      "sqlite3_value_type(argv[Int(indices.idx_id)]) != SQLITE_NULL"))
    XCTAssertTrue(source.contains(
      "Int(sqlite3_value_int64(argv[Int(indices.idx_id)]))"))
    XCTAssertTrue(source.contains(
      "sqlite3_result_int(context, closurePtr.pointee(record) ? 1 : 0)"))
    XCTAssertTrue(source.contains("sqlite3_result_error(context, "))
    
    // no ref to mappedcolumn!
    XCTAssertFalse(source.contains("lastname.defaultValue"))
  }
  
  func testTalentMatcher() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.talentSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    let entity = try XCTUnwrap(dbInfo["Talent"])
    let r = gen.generateRegisterSwiftMatcher  (for: entity)
    let u = gen.generateUnregisterSwiftMatcher(for: entity)
    let e = Extension(extendedType: .name(entity.name), functions: [ r, u ])
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateExtension(e)
      return builder.source
    }()
    print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("func registerSwiftMatcher("))
    XCTAssertTrue(source.contains("func unregisterSwiftMatcher("))
    XCTAssertTrue(source.contains("func dispatch("))
    XCTAssertTrue(source.contains(
      "argv: UnsafeMutablePointer<OpaquePointer?>!"))
    XCTAssertTrue(source.contains(
      "if let closureRawPtr = sqlite3_user_data(context)"))
    XCTAssertTrue(source.contains(
      "sqlite3_value_type(argv[Int(indices.idx_id)]) != SQLITE_NULL"))
    XCTAssertTrue(source.contains(
      "sqlite3_value_blob(argv[Int(indices.idx_id)]).flatMap"))
    XCTAssertTrue(source.contains(
      "sqlite3_value_bytes(argv[Int(indices.idx_id)]"))
    XCTAssertTrue(source.contains(
      "UnsafeRawBufferPointer(start: $0, count: 16)"))
    XCTAssertTrue(source.contains("rbp[0], rbp[1], rbp[2],  rbp[3]"))
    XCTAssertTrue(source.contains("rbp[13], rbp[14], rbp[15]"))
    XCTAssertTrue(source.contains(
      "lite3_value_text(argv[Int(indices.idx_id)]).flatMap({ UUID(uuidString"))
  }
}
