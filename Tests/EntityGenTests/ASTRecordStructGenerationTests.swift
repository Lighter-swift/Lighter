//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class ASTRecordStructGenerationTests: XCTestCase {
  
  func testPersonStruct() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    let s = gen.generateRecordStructure(for: try XCTUnwrap(dbInfo["Person"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "public struct Person : Identifiable, SQLKeyedTableRecord, Codable"))
  }
  
  func testPersonStructNoLighter() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.useLighter = false
    let s = gen.generateRecordStructure(for: try XCTUnwrap(dbInfo["Person"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "public struct Person : Identifiable, Hashable, Codable"))
    XCTAssertFalse(source.contains("SQLKeyedTableRecord"))
  }

  
  func testTalentStruct() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.talentSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    let s = gen.generateRecordStructure(for: try XCTUnwrap(dbInfo["Talent"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "public struct Talent : Identifiable, SQLKeyedTableRecord, Codable"))
    XCTAssertTrue(source.contains("var id : UUID"))
    XCTAssertTrue(source.contains("var name : String"))

    XCTAssertTrue(source.contains("init(id: UUID, name: String)"))
    XCTAssertTrue(source.contains("self.id = id"))
    
    XCTAssertFalse(source.contains("has default"))
  }
}
