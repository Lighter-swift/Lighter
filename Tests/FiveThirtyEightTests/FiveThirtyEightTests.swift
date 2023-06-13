//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class FiveThirtyEightTests: XCTestCase {
  
  let fm  = FileManager.default
  let url = URL(fileURLWithPath: "/Users/helge/Dropbox/OpenData/FiveThirtyEight.db")
  
  func testLoadSchema() throws {
    try XCTSkipUnless(fm.isReadableFile(atPath: url.path),"helge specific test")
    let schema = try SchemaLoader.buildSchemaFromURLs([ url ])
    XCTAssertTrue (schema.views.isEmpty)
    XCTAssertFalse(schema.indices.isEmpty)
    XCTAssertTrue (schema.triggers.isEmpty)
    XCTAssertEqual(schema.tables.count, 388)
    //print("SCHEMA:", schema.tables.map(\.name))
    XCTAssertTrue(schema.tables.contains(where: {
      $0.name == "world-cup-predictions/wc-20140701-184332"
    }))
  }
  
  func testDatabaseMapping() throws {
    try XCTSkipUnless(fm.isReadableFile(atPath: url.path),"helge specific test")
    let schema = try SchemaLoader.buildSchemaFromURLs([ url ])
    let dbInfo = DatabaseInfo(name: "FiveThirtyEight", schema: schema)
    XCTAssertEqual(schema.tables.count, dbInfo.entities.count)
    XCTAssertTrue(dbInfo.entities.contains(where: {
      $0.name == "world-cup-predictions/wc-20140701-184332"
    }))
  }
  
  func testFancifier() throws {
    try XCTSkipUnless(fm.isReadableFile(atPath: url.path),"helge specific test")
    let schema = try SchemaLoader.buildSchemaFromURLs([ url ])
    let dbInfo = DatabaseInfo(name: "FiveThirtyEight", schema: schema)
    
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    XCTAssertEqual(schema.tables.count, dbInfo.entities.count)
    
    //print("Entities:", dbInfo.entities.map(\.name))
    XCTAssertTrue(dbInfo.entities.contains(where: {
      $0.name == "WorldCupPredictions_Wc20140701184332"
    }))
  }
  
  func testASTGeneration() throws {
    try XCTSkipUnless(fm.isReadableFile(atPath: url.path),"helge specific test")
    let schema = try SchemaLoader.buildSchemaFromURLs([ url ])
    
    var config = LighterConfiguration.default
    config.codeGeneration.rawFunctions = .omit
    
    let dbInfo = DatabaseInfo(name: "FiveThirtyEight", schema: schema)
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    let gen = EnlighterASTGenerator(
      database : dbInfo,
      filename : dbInfo.name.appending(".swift"),
      options  : .init()
    )
    let unit = gen.generateCombinedFile(moduleFileName: nil)
    #if false
      print("UNIT:")
      print("  Structures: #\(unit.structures.count)")
      print("  Functions:  #\(unit.functions.count)")
      print("  Extensions: #\(unit.extensions.count)")
    #endif
    
    XCTAssertEqual(schema.tables.count + 1, unit.structures.count)
  }
}
