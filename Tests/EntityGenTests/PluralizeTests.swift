import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class PluralizeTests: XCTestCase {
  
  func testPluralize() {
    XCTAssertEqual("Order"     .pluralized,   "Orders")
    XCTAssertEqual("Category"  .pluralized,   "Categories")
    XCTAssertEqual("Person"    .pluralized,   "Persons") // wrong
  }
  
  func testSingularize() {
    XCTAssertEqual("Orders"    .singularized, "Order")
    XCTAssertEqual("Categories".singularized, "Category")
    XCTAssertEqual("Persons"   .singularized, "Person") // wrong
  }
}
