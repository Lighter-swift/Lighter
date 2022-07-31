//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class ASTRawRelshipGenerationTests: XCTestCase {
  
  // sqlite3_person_find(_ db: OpaquePointer!, for: Address) -> Person?
  func testFindPersonForAddress() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.rawFunctions = .globalFunctions(prefix: "sqlite3_")

    let Address         = try XCTUnwrap(dbInfo["Address"])
    let AddressToPerson = try XCTUnwrap(Address[toOne: "Person"])
    let s = gen.generateRawFind(for: Address, relationship: AddressToPerson)
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "public func sqlite3_person_find(_ db: OpaquePointer!, `for` record: Address"))
    XCTAssertTrue(source.contains("var sql = Person.Schema.select"))
    XCTAssertTrue(source.contains(
      "sql.append(#\" WHERE \"person_id\" = ? LIMIT"))
    XCTAssertTrue(source.contains("sqlite3_prepare_v2(db, sql"))
    XCTAssertTrue(source.contains("if let fkey = record.personId"))
    XCTAssertTrue(source.contains("Person(statement, indices: indices"))
  }
  
  // address.findPerson(in db: OpaquePointer!) -> Person?
  func testRecordFindPersonForAddress() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.rawFunctions = .attachToRecordType

    let Address         = try XCTUnwrap(dbInfo["Address"])
    let AddressToPerson = try XCTUnwrap(Address[toOne: "Person"])
    let s = gen.generateRawFind(for: Address, relationship: AddressToPerson)
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "public func findPerson(`in` db: OpaquePointer!) -> Person"))
    XCTAssertTrue(source.contains("var sql = Person.Schema.select"))
    XCTAssertTrue(source.contains(
      "sql.append(#\" WHERE \"person_id\" = ? LIMIT"))
    XCTAssertTrue(source.contains("sqlite3_prepare_v2(db, sql"))
    XCTAssertTrue(source.contains("if let fkey = self.personId"))
    XCTAssertTrue(source.contains("Person(statement, indices: indices"))
  }

  
  // sqlite3_addresses_fetch(db, for: person)
  func testFetchAddressesForPerson() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.rawFunctions = .globalFunctions(prefix: "sqlite3_")

    let Person            = try XCTUnwrap(dbInfo["Person"])
    let PersonToAddresses = try XCTUnwrap(Person[toMany: "Addresses"])
    let s = gen.generateRawFetch(for: Person, relationship: PersonToAddresses)
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("public func sqlite3_addresses_fetch"))
    XCTAssertTrue(source.contains("var sql = Address.Schema.select"))
    XCTAssertTrue(source.contains(
      "sql.append(#\" WHERE \"person_id\" = ? LIMIT"))
    XCTAssertTrue(source.contains(
      "sqlite3_bind_int64(statement, 1, Int64(record.id"))
    XCTAssertTrue(source.contains(") -> [ Address ]?"))
  }

  
  // person.fetchAddresses(in: db)
  func testRecordFetchAddressesForPerson() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    gen.options.rawFunctions = .attachToRecordType

    let Person            = try XCTUnwrap(dbInfo["Person"])
    let PersonToAddresses = try XCTUnwrap(Person[toMany: "Addresses"])
    let s = gen.generateRawFetch(for: Person, relationship: PersonToAddresses)
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains("public func fetchAddresses"))
    XCTAssertTrue(source.contains("var sql = Address.Schema.select"))
    XCTAssertTrue(source.contains(
      "sql.append(#\" WHERE \"person_id\" = ? LIMIT"))
    XCTAssertTrue(source.contains(
      "sqlite3_bind_int64(statement, 1, Int64(self.id"))
    XCTAssertTrue(source.contains(") -> [ Address ]?"))
  }
}
