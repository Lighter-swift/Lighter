//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST

final class BuilderTests: XCTestCase {
  
  func testFunctionDeclaration() {
    let f = Fixtures.makeSelectDeclaration()
    XCTAssertEqual(f.name, "select")
    XCTAssertEqual(f.genericParameterNames.count, 3)
    XCTAssertEqual(f.parameters.count, 5)
    XCTAssertTrue (f.throws)
    XCTAssertEqual(f.genericConstraints.count, 4)
  }
  
  func testFunctionDefinition() {
    let f = Fixtures.makeSelectDefinition()
    XCTAssertTrue(f.declaration.throws)
  }
  
  func testUnitWithExtension() {
    let f    : FunctionDefinition = Fixtures.makeSelectDefinition()
    let ext  = Extension(extendedType: .name("SQLDatabaseFetchOperations"),
                         functions: [ f ])
    let unit =
      CompilationUnit(name: "GeneratedSelectOperations", extensions: [ ext ])
    
    XCTAssertEqual(unit.extensions.count, 1)
    XCTAssertEqual(unit.extensions.first?.functions.count, 1)
    XCTAssertEqual(ext.public, true)
  }
  
  func testExtensionWithNestedStruct() {
    let s    = Struct(name: "RecordTypes")
    let ext  = Extension(extendedType: .name("SQLDatabaseFetchOperations"),
                         structures: [ s ])
    let unit =
      CompilationUnit(name: "GeneratedSelectOperations", extensions: [ ext ])

    XCTAssertEqual(unit.extensions.count, 1)
    XCTAssertEqual(unit.extensions.first?.functions.count, 0)
    XCTAssertEqual(ext.public, true)
    XCTAssertEqual(s.public, true)
  }
}
