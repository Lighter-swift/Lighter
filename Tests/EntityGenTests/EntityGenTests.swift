//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class EntityGenTests: XCTestCase {
  
  func testSimpleEntityInfo() throws {
    let dbInfo = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    //print("GOT DB:", dbInfo)
    
    XCTAssertEqual(dbInfo.userVersion, 0)
    XCTAssertEqual(dbInfo.entities.count, 3)
    XCTAssertEqual(dbInfo.entityNames.sorted(),
                   [ "A Fancy Test Table", "address", "person" ])
  }
  
  func testNorthWindEntityInfo() throws {
    let dbInfo = DatabaseInfo(name: "TestDB", schema: Fixtures.northWindSchema)
    //print("GOT DB:", dbInfo)
    
    XCTAssertEqual(dbInfo.userVersion, 0)
    XCTAssertEqual(dbInfo.entities.count, 14)
    XCTAssertEqual(
      dbInfo.entityNames.sorted(),
      ["Category", "Customer", "CustomerCustomerDemo", "CustomerDemographic",
       "Employee", "EmployeeTerritory", "Order", "OrderDetail", "Product",
       "ProductDetails_V", "Region", "Shipper", "Supplier", "Territory" ]
    )
  }
  
  func testOGoEntityInfo() throws {
    let dbInfo = DatabaseInfo(name: "TestDB", schema: Fixtures.OGoSchema)
    
    XCTAssertEqual(dbInfo.userVersion, 0)
    XCTAssertEqual(dbInfo.entities.count, 63)
    XCTAssertEqual(
      dbInfo.entityNames.sorted(),
      ["address", "appointment", "appointment_resource",
       "article", "article_category", "article_unit",
       "company", "company_assignment", "company_category", "company_hierarchy",
       "company_info", "company_value", "ctags",
       "date_company_assignment", "date_info",
       "doc", "document", "document_editing", "document_version",
       "employment", "enterprise",
       "invoice", "invoice_account", "invoice_accounting", "invoice_action",
       "invoice_article_assignment",
       "job", "job_assignment", "job_history", "job_history_info",
       "job_resource_assignment",
       "log", "login_token",
       "news_article", "news_article_link",
       "note",
       "obj_info", "obj_property", "object_acl", "object_model",
       "palm_address", "palm_category", "palm_date", "palm_memo", "palm_todo",
       "person",
       "project", "project_acl", "project_companies",
       "project_company_assignment", "project_info", "project_persons",
       "project_teams",
       "resource", "resource_assignment",
       "session_log",
       "staff",
       "table_version",
       "team", "team_hierarchy", "team_membership",
       "telephone",
       "trust"]
    )
  }
}
