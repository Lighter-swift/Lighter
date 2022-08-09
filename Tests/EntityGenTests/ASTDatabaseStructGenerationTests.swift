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
  
  
  func testRawDateFormatter() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.nestRecordTypesInDatabase = false
    gen.options.useLighter = false
    gen.options.public = true
    
    
    let Person = try XCTUnwrap(dbInfo["Person"])
    Person.properties.append(.init(
      name: "birthDate", externalName: "birth_date",
      propertyType: .date, columnType: .timestamp,
      defaultValue: nil, isPrimaryKey: false, isNotNull: true
    ))
    
    let s = gen.generateDatabaseStructure()
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertFalse(source.contains("_dateFormatter"))
    XCTAssertTrue(source.contains(
      "public static var dateFormatter : DateFormatter? = {"))
    XCTAssertTrue(source.contains(
      #"formatter.dateFormat = "yyyy-MM-dd HH:mm:ss""#))
  }
  
  func testLighterDateFormatter() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.nestRecordTypesInDatabase = false
    gen.options.useLighter = true
    gen.options.rawFunctions = .omit
    gen.options.public = true
    
    
    let Person = try XCTUnwrap(dbInfo["Person"])
    Person.properties.append(.init(
      name: "birthDate", externalName: "birth_date",
      propertyType: .date, columnType: .timestamp,
      defaultValue: nil, isPrimaryKey: false, isNotNull: true
    ))
    
    let s = gen.generateDatabaseStructure()
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("static var _dateFormatter : DateFormatter?"))
    XCTAssertTrue(source.contains(
      "public static var dateFormatter : DateFormatter? {"))
    XCTAssertTrue(source.contains(
      "_dateFormatter ?? Date.defaultSQLiteDateFormatter"))
  }
  
  func testLighterAllRecordTypes() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.nestRecordTypesInDatabase = false
    gen.options.useLighter = true
    gen.options.rawFunctions = .omit
    gen.options.public = true
    
    
    let Person = try XCTUnwrap(dbInfo["Person"])
    Person.properties.append(.init(
      name: "birthDate", externalName: "birth_date",
      propertyType: .date, columnType: .timestamp,
      defaultValue: nil, isPrimaryKey: false, isNotNull: true
    ))

    let s = gen.generateDatabaseStructure()
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateStruct(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("#if swift(>=5.7)"))
    XCTAssertTrue(source.contains(
      "public static let _allRecordTypes : [ any SQLRecord.Type ] = ["))
    XCTAssertTrue(source.contains(
      "[ Person.self, Address.self, AFancyTestTable.self ]"))
  }
}
