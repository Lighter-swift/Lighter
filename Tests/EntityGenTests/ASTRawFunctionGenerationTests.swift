//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class ASTRawFunctionGenerationTests: XCTestCase {
  
  func testRawFuncs() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.rawFunctions = .globalFunctions(prefix: "sqlite3_")
    let entity = try XCTUnwrap(dbInfo["Person"])
    let e = gen.generateRawFunctions(for: entity)
    
    let source : String = {
      let builder = CodeGenerator()
      for f in e {
        builder.generateFunctionDefinition(f)
      }
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertFalse(source.contains("static"))
    XCTAssertTrue(source.contains("sqlite3_person_delete(_ db"))
    XCTAssertTrue(source.contains("sqlite3_prepare_v2(db, sql"))
    XCTAssertTrue(source.contains(
      "sqlite3_bind_int64(statement, 1, Int64(record.id"))
    XCTAssertTrue(source.contains("sqlite3_person_update(_ db"))
    XCTAssertTrue(source.contains("sqlite3_person_insert(_ db"))
    XCTAssertTrue(source.contains("_ record: inout Person"))
    XCTAssertTrue(source.contains("public func sqlite3_people_fetch"))
    XCTAssertTrue(source.contains("sql customSQL: String? = nil"))
    XCTAssertTrue(source.contains(
      "filter: @escaping ( Person ) -> Bool"))
    XCTAssertTrue(source.contains(
      "guard Person.Schema.registerSwiftMatcher(in: db, flags: SQLITE_UTF8, m"))
    XCTAssertTrue(source.contains(
      "var sql = customSQL ?? Person.Schema.matchSelect"))
  }
  
  func testRawRecordFuncs() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.rawFunctions = .attachToRecordType
    
    let entity = try XCTUnwrap(dbInfo["Person"])
    let e = gen.generateRawRecordFunctions(for: entity)
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateExtension(e)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("static"))
    XCTAssertTrue(source.contains("public extension Person"))
    XCTAssertTrue(source.contains(
      "  func delete(from db: OpaquePointer!) -> Int32"))
    XCTAssertTrue(source.contains(
      "sqlite3_bind_int64(statement, 1, Int64(id))"))
    XCTAssertTrue(source.contains(
      "func update(`in` db: OpaquePointer!) -> Int32"))
    XCTAssertTrue(source.contains("let sql = Person.Schema.update"))
    XCTAssertTrue(source.contains(
      "return self.bind(to: statement, indices: Person.Schema"))
    XCTAssertTrue(source.contains(
      "mutating func insert(into db: OpaquePointer!) -> Int32"))
    XCTAssertTrue(source.contains("self = record"))
    
    XCTAssertTrue(source.contains("static func fetch"))
    XCTAssertTrue(source.contains("static func find"))
  }
  
  func testTalentFetchFuncs() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.talentSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.rawFunctions = .globalFunctions(prefix: "sqlite3_")
    let entity = try XCTUnwrap(dbInfo["Talent"])
    let e = gen.generateRawFunctions(for: entity)
    
    let source : String = {
      let builder = CodeGenerator()
      for f in e {
        builder.generateFunctionDefinition(f)
      }
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertFalse(source.contains("static"))
    XCTAssertTrue(source.contains("sqlite3_talent_delete(_ db"))
    XCTAssertTrue(source.contains("sqlite3_prepare_v2(db, sql"))
    XCTAssertTrue(source.contains("sqlite3_talent_update(_ db"))
    XCTAssertTrue(source.contains("sqlite3_talent_insert(_ db"))
    XCTAssertTrue(source.contains("_ record: inout Talent"))
    XCTAssertTrue(source.contains("public func sqlite3_talents_fetch"))
    XCTAssertTrue(source.contains("sql customSQL: String? = nil"))
    XCTAssertTrue(source.contains(
      "filter: @escaping ( Talent ) -> Bool"))
    XCTAssertTrue(source.contains(
      "guard Talent.Schema.registerSwiftMatcher(in: db, flags: SQLITE_UTF8, m"))
    XCTAssertTrue(source.contains(
      "var sql = customSQL ?? Talent.Schema.matchSelect"))
    
    XCTAssertFalse(source.contains(
      "sqlite3_bind_int64(statement, 1, Int64(record.id"))
    XCTAssertFalse(source.contains("sqlite3_talent_find"))
  }
  
  
  func testTalentCompleteFuncs() throws {
    let dbInfo = DatabaseInfo(name: "TalentsDB", schema: Fixtures.talentSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.rawFunctions = .globalFunctions(prefix: "sqlite3_")
    let unit = gen.generateCombinedFile(moduleFileName: nil)
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateUnit(unit)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("TalentsDB.withOptUUIDBytes(id)"))
    XCTAssertTrue(source.contains("sqlite3_talent_delete(_ db"))
    XCTAssertTrue(source.contains("sqlite3_prepare_v2(db, sql"))
    XCTAssertTrue(source.contains("sqlite3_talent_update(_ db"))
    XCTAssertTrue(source.contains("sqlite3_talent_insert(_ db"))
    XCTAssertTrue(source.contains("_ record: inout Talent"))
    XCTAssertTrue(source.contains("public func sqlite3_talents_fetch"))
    XCTAssertTrue(source.contains("sql customSQL: String? = nil"))
    XCTAssertTrue(source.contains(
      "filter: @escaping ( Talent ) -> Bool"))
    XCTAssertTrue(source.contains(
      "guard Talent.Schema.registerSwiftMatcher(in: db, flags: SQLITE_UTF8, m"))
    XCTAssertTrue(source.contains(
      "var sql = customSQL ?? Talent.Schema.matchSelect"))

    XCTAssertTrue(source.contains("UUID(uuid:"))
    XCTAssertTrue(source.contains("UUID(uuidString: String(cString"))
    XCTAssertTrue(source.contains(
      "UnsafeRawBufferPointer(start: $0, count: 16)"))

    XCTAssertFalse(source.contains(
      "sqlite3_bind_int64(statement, 1, Int64(record.id"))
    XCTAssertFalse(source.contains("sqlite3_talent_find"))
  }
}
