//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class ASTRecordSchemaGenerationTests: XCTestCase {
  
  func testPersonSchema() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    let s = gen.generateSchemaStructure(for: try XCTUnwrap(dbInfo["Person"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "public struct Schema : SQLKeyedTableSchema, SQLSwiftMatchableSchema"))
    XCTAssertTrue(source.contains(
      #"if strcmp(col!, "person_id") == 0"#))
    XCTAssertTrue(source.contains(
      "var indices : PropertyIndices = ( -1, -1, -1 )"))
    XCTAssertTrue(source.contains("return indices"))
    XCTAssertTrue(source.contains("public static func lookupColumnIndices"))
    XCTAssertTrue(source.contains("public let id = MappedColumn<Person, Int>("))
    XCTAssertTrue(source.contains(#"externalName: "person_id","#))
    
    XCTAssertTrue(source.contains("SQLSwiftMatchableSchema"))
    XCTAssertTrue(source.contains("matchSelect"))
    XCTAssertTrue(source.contains(
      "typealias MatchClosureType = ( Person ) -> Bool"))
  }
  
  func testAddressSchema() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    XCTAssertNotNil(dbInfo["Address"]?["personId"])
    XCTAssertNotNil(dbInfo["Address"]?["personId"]?.foreignKey)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    let s = gen.generateSchemaStructure(for: try XCTUnwrap(dbInfo["Address"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "public struct Schema : SQLKeyedTableSchema, SQLSwiftMatchableSchema"))
    XCTAssertTrue(source.contains(
      #"if strcmp(col!, "address_id") == 0"#))
    XCTAssertTrue(source.contains(
      "var indices : PropertyIndices = ( -1, -1, -1, -1, -1, -1 )"))
    XCTAssertTrue(source.contains("return indices"))
    XCTAssertTrue(source.contains("public static func lookupColumnIndices"))
    XCTAssertTrue(source.contains(
      "public let id = MappedColumn<Address, Int>("))
    XCTAssertTrue(source.contains(#"externalName: "address_id","#))
    XCTAssertTrue(source.contains(
      "MappedForeignKey<Address, Int?, MappedColumn<Person, Int>>"))
  }
  
  
  
  func testPersonSchemaNoLighter() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.useLighter = false
    let s = gen.generateSchemaStructure(for: try XCTUnwrap(dbInfo["Person"]))
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "public struct Schema"))
    XCTAssertFalse(source.contains("SQLKeyedTableSchema"))
    XCTAssertFalse(source.contains("SQLSwiftMatchableSchema"))
    XCTAssertTrue(source.contains(
      #"if strcmp(col!, "person_id") == 0"#))
    XCTAssertTrue(source.contains(
      "var indices : PropertyIndices = ( -1, -1, -1 )"))
    XCTAssertTrue(source.contains("return indices"))
    XCTAssertTrue(source.contains("public static func lookupColumnIndices"))

    XCTAssertFalse(source.contains("public let id = MappedColumn<Person, Int>("))
    XCTAssertFalse(source.contains(#"externalName: "person_id","#))

    XCTAssertFalse(source.contains("SQLSwiftMatchableSchema"))
    XCTAssertTrue(source.contains("matchSelect"))
    XCTAssertTrue(source.contains(
      "typealias MatchClosureType = ( Person ) -> Bool"))
  }
}
