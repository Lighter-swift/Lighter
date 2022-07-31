//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import XCTest
import Foundation
@testable import LighterCodeGenAST
@testable import LighterGeneration

final class FancifierTests: XCTestCase {
  
  func testValidIdentifiers() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    
    var options   = Fancifier.Options()
    options.spaceReplacementStringForIDs = nil
    options.capitalizeRecordNames        = false
    options.decapitalizePropertyNames    = false
    options.camelCaseRecordNames         = false
    options.camelCasePropertyNames       = false
    
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    XCTAssertEqual(dbInfo.userVersion, 0)
    XCTAssertEqual(dbInfo.entities.count, 3)
    XCTAssertEqual(dbInfo.entityNames.sorted(),
                   [ "AFancyTestTable", "address", "person" ])
  }
  
  func testSpacesForUnderscoresInIdentifiers() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    
    var options   = Fancifier.Options()
    options.spaceReplacementStringForIDs = "_"
    options.capitalizeRecordNames        = false
    options.decapitalizePropertyNames    = false
    options.camelCaseRecordNames         = false
    options.camelCasePropertyNames       = false
    
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    XCTAssertEqual(dbInfo.userVersion, 0)
    XCTAssertEqual(dbInfo.entities.count, 3)
    XCTAssertEqual(dbInfo.entityNames.sorted(),
                   [ "A_Fancy_Test_Table", "address", "person" ])
  }
  
  func testDefaultFancifierOnContacts() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.addressSchema)
    //print("Original:", dbInfo)
    let opersonPkey = try XCTUnwrap(
      dbInfo[externalName: "person"]?.primaryKeyProperties.first)
    XCTAssertNil  (opersonPkey.foreignKey)
    
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    XCTAssertEqual(dbInfo.userVersion, 0)
    XCTAssertEqual(dbInfo.entities.count, 3)
    XCTAssertEqual(dbInfo.entityNames.sorted(),
                   [ "AFancyTestTable", "Address", "Person" ])
    
    let addressRecord = try XCTUnwrap(dbInfo["Address"])
    XCTAssertEqual(addressRecord.name         , "Address")
    XCTAssertEqual(addressRecord.externalName , "address")
    
    let personRecord = try XCTUnwrap(dbInfo["Person"])
    XCTAssertEqual(personRecord.name         , "Person")
    XCTAssertEqual(personRecord.externalName , "person")
    
    let addressPkey = try XCTUnwrap(addressRecord.primaryKeyProperties.first)
    XCTAssertEqual(addressPkey.name         , "id")
    XCTAssertEqual(addressPkey.externalName , "address_id")
    XCTAssertEqual(addressPkey.columnType   , .integer)
    XCTAssertEqual(addressPkey.propertyType , .integer)
    XCTAssertTrue (addressPkey.isPrimaryKey)
    XCTAssertFalse(addressPkey.isPrimaryKeySynthesized)
    XCTAssertNil  (addressPkey.foreignKey)
    
    let personPkey = try XCTUnwrap(personRecord.primaryKeyProperties.first)
    XCTAssertEqual(personPkey.name         , "id")
    XCTAssertEqual(personPkey.externalName , "person_id")
    XCTAssertEqual(personPkey.columnType   , .integer)
    XCTAssertEqual(personPkey.propertyType , .integer)
    XCTAssertTrue (personPkey.isPrimaryKey)
    XCTAssertFalse(personPkey.isPrimaryKeySynthesized)
    XCTAssertNil  (personPkey.foreignKey)
    
    let personId = try XCTUnwrap(addressRecord["personId"])
    XCTAssertEqual(personId.name         , "personId")
    XCTAssertEqual(personId.externalName , "person_id")
    XCTAssertEqual(personId.columnType   , .integer)
    XCTAssertEqual(personId.propertyType , .integer)
    XCTAssertFalse(personId.isPrimaryKey)
    XCTAssertFalse(personId.isPrimaryKeySynthesized)
    let personIdForeignKey = try XCTUnwrap(personId.foreignKey)
    XCTAssertFalse(personId.isForeignKeySynthesized)
    XCTAssertEqual(personIdForeignKey.sourceColumn,      "person_id")
    XCTAssertEqual(personIdForeignKey.destinationTable,  "person")
    XCTAssertEqual(personIdForeignKey.destinationColumn, "person_id")
  }
  
  func testDefaultFancifierOnNorthwind() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.northWindSchema)
    
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    XCTAssertEqual(dbInfo.userVersion, 0)
    XCTAssertEqual(dbInfo.entities.count, 14)
    XCTAssertEqual(
      dbInfo.entityNames.sorted(),
      ["Category", "Customer", "CustomerCustomerDemo", "CustomerDemographic",
       "Employee", "EmployeeTerritory", "Order", "OrderDetail", "Product",
       "ProductDetailsV", "Region", "Shipper", "Supplier", "Territory" ]
    )
    
    let orderRecord = try XCTUnwrap(dbInfo["Order"])
    XCTAssertEqual(orderRecord.name         , "Order")
    XCTAssertEqual(orderRecord.externalName , "Order")
    
    let customerRecord = try XCTUnwrap(dbInfo["Customer"])
    XCTAssertEqual(customerRecord.name         , "Customer")
    XCTAssertEqual(customerRecord.externalName , "Customer")
    
    let orderPkey = try XCTUnwrap(orderRecord.primaryKeyProperties.first)
    XCTAssertEqual(orderPkey.name         , "id")
    XCTAssertEqual(orderPkey.externalName , "Id")
    XCTAssertEqual(orderPkey.columnType   , .integer)
    XCTAssertEqual(orderPkey.propertyType , .integer)
    XCTAssertTrue (orderPkey.isPrimaryKey)
    XCTAssertFalse(orderPkey.isPrimaryKeySynthesized)
    
    let customerPkey = try XCTUnwrap(customerRecord.primaryKeyProperties.first)
    XCTAssertEqual(customerPkey.name         , "id")
    XCTAssertEqual(customerPkey.externalName , "Id")
    XCTAssertEqual(customerPkey.columnType   , .varchar(width: 8000))
    XCTAssertEqual(customerPkey.propertyType , .string)
    XCTAssertTrue (customerPkey.isPrimaryKey)
    XCTAssertFalse(customerPkey.isPrimaryKeySynthesized)
    
    let customerId = try XCTUnwrap(orderRecord["customerId"])
    XCTAssertEqual(customerId.name         , "customerId")
    XCTAssertEqual(customerId.externalName , "CustomerId")
    XCTAssertEqual(customerId.columnType   , .varchar(width: 8000)) // not kidding
    XCTAssertEqual(customerId.propertyType , .string)
    XCTAssertFalse(customerId.isPrimaryKey)
    XCTAssertFalse(customerId.isPrimaryKeySynthesized)
    let customerIdForeignKey = try XCTUnwrap(customerId.foreignKey)
    XCTAssertTrue (customerId.isForeignKeySynthesized)
    XCTAssertEqual(customerIdForeignKey.sourceColumn,      "CustomerId")
    XCTAssertEqual(customerIdForeignKey.destinationTable,  "Customer")
    XCTAssertEqual(customerIdForeignKey.destinationColumn, "Id")
    
    let employeeId = try XCTUnwrap(orderRecord["employeeId"])
    XCTAssertEqual(employeeId.name         , "employeeId")
    XCTAssertEqual(employeeId.externalName , "EmployeeId")
    XCTAssertEqual(employeeId.columnType   , .integer)
    XCTAssertEqual(employeeId.propertyType , .integer)
    XCTAssertFalse(employeeId.isPrimaryKey)
    XCTAssertFalse(employeeId.isPrimaryKeySynthesized)
    let employeeIdForeignKey = try XCTUnwrap(employeeId.foreignKey)
    XCTAssertTrue (employeeId.isForeignKeySynthesized)
    XCTAssertEqual(employeeIdForeignKey.sourceColumn,      "EmployeeId")
    XCTAssertEqual(employeeIdForeignKey.destinationTable,  "Employee")
    XCTAssertEqual(employeeIdForeignKey.destinationColumn, "Id")
    
    do {
      // In the ER this is called EmployeeTerritories
      let EmployeeTerritory = try XCTUnwrap(dbInfo["EmployeeTerritory"])
      XCTAssertEqual(EmployeeTerritory.name         , "EmployeeTerritory")
      XCTAssertEqual(EmployeeTerritory.externalName , "EmployeeTerritory")
      XCTAssertNotNil(EmployeeTerritory["employeeId"]? .foreignKey)
      XCTAssertNotNil(EmployeeTerritory["territoryId"]?.foreignKey)
    }
  }
  
  func testDefaultFancifierOnOgo() throws {
    let dbInfo    = DatabaseInfo(name: "TestDB", schema: Fixtures.OGoSchema)
    
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)
    
    XCTAssertEqual(dbInfo.userVersion, 0)
    XCTAssertEqual(dbInfo.entities.count, 63)
    
    XCTAssertTrue(dbInfo.entityNames.contains("Address"))
  }
  
  func testNorthwindRelationships() throws {
    let dbInfo = DatabaseInfo(name: "TestDB", schema: Fixtures.northWindSchema)
    
    let options   = Fancifier.Options()
    let fancifier = Fancifier(options: options)
    fancifier.fancifyDatabaseInfo(dbInfo)
    //print("Fancified:", dbInfo)

    XCTAssertEqual(dbInfo.userVersion, 0)
    XCTAssertEqual(dbInfo.entities.count, 14)
    
    let Order = try XCTUnwrap(dbInfo["Order"])
    XCTAssertEqual(Order.name         , "Order")
    XCTAssertEqual(Order.externalName , "Order")

    let Customer = try XCTUnwrap(dbInfo["Customer"])
    XCTAssertEqual(Customer.name         , "Customer")
    XCTAssertEqual(Customer.externalName , "Customer")
    
    #if false
    print("Order:",
          "\n   ", Order.toManyRelationships,
          "\n   ", Order.toOneRelationships)
    print("Customer:",
          "\n   ", Customer.toManyRelationships,
          "\n   ", Customer.toOneRelationships)
    #endif
    
    XCTAssertNil(Order[toOne: "OrderDetails"])
    let orderToDetails = try XCTUnwrap(Order[toMany: "OrderDetails"])
    XCTAssertEqual(orderToDetails.name, "OrderDetails")
    XCTAssertEqual(orderToDetails.sourceEntity.name, "OrderDetail")
    XCTAssertEqual(orderToDetails.sourcePropertyName, "orderId")
    XCTAssertNil  (orderToDetails.qualifierParameter)
    
    XCTAssertNil(Order[toMany: "Customer"])
    let orderToCustomer = try XCTUnwrap(Order[toOne: "Customer"])
    XCTAssertEqual(orderToCustomer.name, "Customer")
    XCTAssertEqual(orderToCustomer.destinationEntity.name, "Customer")
    XCTAssertEqual(orderToCustomer.sourcePropertyName, "customerId")
    XCTAssertTrue (orderToCustomer.isPrimary)
    
    XCTAssertNil(Order[toMany: "Employee"])
    let orderToEmployee = try XCTUnwrap(Order[toOne: "Employee"])
    XCTAssertEqual(orderToEmployee.name, "Employee")
    XCTAssertEqual(orderToEmployee.destinationEntity.name, "Employee")
    XCTAssertEqual(orderToEmployee.sourcePropertyName, "employeeId")
    XCTAssertTrue (orderToEmployee.isPrimary)
    
    XCTAssertNil(Customer[toOne: "OrderDetails"])
    let customerToOrders = try XCTUnwrap(Customer[toMany: "Orders"])
    XCTAssertEqual(customerToOrders.name, "Orders")
    XCTAssertEqual(customerToOrders.sourceEntity.name, "Order")
    XCTAssertEqual(customerToOrders.sourcePropertyName, "customerId")
    XCTAssertNil  (customerToOrders.qualifierParameter)
    
    XCTAssertEqual(Order.toManyRelationships.first?.name,
                   "OrderDetails")
  }
}
