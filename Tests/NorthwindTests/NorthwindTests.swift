//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class NorthwindTests: XCTestCase {
  
  let fm  = FileManager.default
  let url = URL(fileURLWithPath:
    "/Users/helge/dev/Swift/Lighter/NorthwindSQLite.swift/src/create.sql"
  )
  
  func testLoadSchema() throws {
    try XCTSkipUnless(fm.isReadableFile(atPath: url.path),"helge specific test")
    let schema = try SchemaLoader.buildSchemaFromURLs([ url ])
    XCTAssertFalse(schema.views.isEmpty)
    XCTAssertTrue (schema.indices.isEmpty)
    XCTAssertTrue (schema.triggers.isEmpty)
    XCTAssertEqual(schema.tables.count, 13)
    XCTAssertEqual(schema.tables.map(\.name), [
      "Categories", "CustomerCustomerDemo", "CustomerDemographics", "Customers",
      "Employees", "EmployeeTerritories", "Order Details", "Orders", "Products",
      "Regions", "Shippers", "Suppliers", "Territories"
    ])
  }
  
  func testDatabaseMapping() throws {
    try XCTSkipUnless(fm.isReadableFile(atPath: url.path),"helge specific test")
    let schema = try SchemaLoader.buildSchemaFromURLs([ url ])
    let dbInfo = DatabaseInfo(name: "Northwind", schema: schema)
    XCTAssertEqual(schema.tables.count + schema.views.count,
                   dbInfo.entities.count)
    XCTAssertEqual(dbInfo.entities.map(\.name), [
      "Categories", "CustomerCustomerDemo", "CustomerDemographics", "Customers",
      "Employees", "EmployeeTerritories", "Order Details", "Orders", "Products",
      "Regions", "Shippers", "Suppliers", "Territories",
      "Alphabetical list of products", "Current Product List",
      "Customer and Suppliers by City", "Invoices", "Orders Qry",
      "Order Subtotals", "Product Sales for 1997",
      "Products Above Average Price", "Products by Category",
      "Quarterly Orders", "Sales Totals by Amount",
      "Summary of Sales by Quarter", "Summary of Sales by Year",
      "Category Sales for 1997", "Order Details Extended", "Sales by Category"
    ])
  }
  
  func testFancifier() throws {
    try XCTSkipUnless(fm.isReadableFile(atPath: url.path),"helge specific test")
    let schema = try SchemaLoader.buildSchemaFromURLs([ url ])
    let dbInfo = DatabaseInfo(name: "Northwind", schema: schema)
    
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    
    XCTAssertEqual(schema.tables.count + schema.views.count,
                   dbInfo.entities.count)
    
    print("Entities:", dbInfo.entities.map(\.name))
    XCTAssertEqual(dbInfo.entities.map(\.name), [
      "Categories", "CustomerCustomerDemo", "CustomerDemographics", "Customers",
      "Employees", "EmployeeTerritories", "OrderDetails", "Orders", "Products",
      "Regions", "Shippers", "Suppliers", "Territories",
      "AlphabeticalListOfProducts", "CurrentProductList",
      "CustomerAndSuppliersByCity", "Invoices", "OrdersQry",
      "OrderSubtotals", "ProductSalesFor1997",
      "ProductsAboveAveragePrice", "ProductsByCategory",
      "QuarterlyOrders", "SalesTotalsByAmount",
      "SummaryOfSalesByQuarter", "SummaryOfSalesByYear",
      "CategorySalesFor1997", "OrderDetailsExtended", "SalesByCategory"
    ])
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
    #if true
      print("UNIT:")
      print("  Structures: #\(unit.structures.count)")
      print("  Functions:  #\(unit.functions.count)")
      print("  Extensions: #\(unit.extensions.count)")
    #endif
    
    XCTAssertEqual(schema.tables.count + schema.views.count + 1,
                   unit.structures.count)
  }
}
