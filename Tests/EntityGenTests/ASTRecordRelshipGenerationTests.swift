//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class ASTRecordRelshipGenerationTests: XCTestCase {
  
  func testFindPersonForAddress() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    
    let Address         = try XCTUnwrap(dbInfo["Address"])
    let AddressToPerson = try XCTUnwrap(Address[toOne: "Person"])
    let s = gen.generateFind(for: Address, relationship: AddressToPerson)
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    // print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "Fetch the ``Person`` record related to a ``Address``"))
    XCTAssertTrue(source.contains(
      "relatedRecord = try db.people.find(for: sourceRecord"))
    XCTAssertTrue(source.contains(
      "public func find(`for` record: Address) throws -> Person?"))
    XCTAssertTrue(source.contains(
      "try operations[dynamicMember: \\.addresses]"))
    XCTAssertTrue(source.contains(
      "findTarget(for: \\.personId, in: record)"))
  }
  
  
  func testFindAddressesForPerson() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    let gen = EnlighterASTGenerator(
      database: dbInfo, filename: "Contacts.swift"
    )
    
    let Person            = try XCTUnwrap(dbInfo["Person"])
    let PersonToAddresses = try XCTUnwrap(Person[toMany: "Addresses"])
    let s = gen.generateFetch(for: Person, relationship: PersonToAddresses,
                              async: true)
    
    let source : String = {
      let builder = CodeGenerator()
      builder.generateFunctionDefinition(s)
      return builder.source
    }()
    //print("GOT:\n-----\n\(source)\n-----")
    
    XCTAssertTrue(source.contains(
      "Fetches the ``Address`` records related to a ``Person``"))
    XCTAssertTrue(source.contains(
      "let relatedRecords = try await db.addresses.fetch(for: record"))
    XCTAssertTrue(source.contains(
      "public func fetch(`for` record: Person, limit: Int?"))
    XCTAssertTrue(source.contains(
      "async throws -> [ Address ]"))
    XCTAssertTrue(source.contains(
      "try await fetch(for: \\.personId, in: record, limit: limit)"))
  }
}
