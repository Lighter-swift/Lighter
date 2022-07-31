//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class ASTDatabaseStructGenerationTests: XCTestCase {
  
  func testAddressDBNoEmbeddedRecordStructs() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.nestRecordTypesInDatabase = false
    gen.options.useLighter                = true
    gen.options.optionalHelpersInDatabase = false

    let s = gen.generateDatabaseStructure()
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("SQLDatabase, SQLDatabaseAsyncChangeOperations"))
    XCTAssertTrue(source.contains("public struct TestDB"))
    XCTAssertTrue(source.contains("public struct RecordTypes"))
    XCTAssertTrue(source.contains("public let people = Person.self"))
    XCTAssertTrue(source.contains("public static let recordTypes = RecordTypes()"))
    // has not dates!:
    XCTAssertFalse(source.contains("static var dateFormatter"))
    XCTAssertFalse(source.contains("public static func withOptCString"))
  }
  
  func testAddressDBWithHelpers() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.nestRecordTypesInDatabase = false
    gen.options.useLighter                = true
    gen.options.preferLighterBinds        = false
    gen.options.optionalHelpersInDatabase = true
    gen.options.nestRecordTypesInDatabase = false

    let s = gen.generateDatabaseStructure()
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("SQLDatabase, SQLDatabaseAsyncChangeOperations"))
    XCTAssertTrue(source.contains("public struct TestDB"))
    XCTAssertTrue(source.contains("public struct RecordTypes"))
    XCTAssertTrue(source.contains("public let people = Person.self"))
    XCTAssertTrue(source.contains("public static let recordTypes = RecordTypes()"))
    // has not dates!:
    XCTAssertFalse(source.contains("static var dateFormatter"))
    
    XCTAssertTrue(source.contains("public static func withOptCString"))
  }

  func testAddressDBNoEmbeddedRecordStructsRaw() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.nestRecordTypesInDatabase = false
    gen.options.useLighter = false

    let s = gen.generateDatabaseStructure()
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertFalse(source.contains("SQLDatabase"))
    XCTAssertFalse(source.contains("SQLDatabaseAsyncChangeOperations"))
    XCTAssertTrue(source.contains("public struct TestDB"))
    XCTAssertFalse(source.contains("public struct RecordTypes"))
    XCTAssertFalse(source.contains("public let people = Person.self"))
    XCTAssertFalse(source.contains("public static let recordTypes = RecordTypes()"))
    // has not dates!:
    XCTAssertFalse(source.contains("static var dateFormatter"))
  }
}
