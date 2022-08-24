//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3Schema

enum Fixtures {
  
  static let addressSchema = Schema(
    version: 1, userVersion: 0,
    tables: [
      Schema.Table(
        info: .init(type: .table, name: "person"),
        columns: [
          .init(id: 0, name: "person_id", type: .integer, isNotNull: true,
                defaultValue: nil, isPrimaryKey: true),
          .init(id: 1, name: "firstname", type: .varchar(width: nil)),
          .init(id: 2, name: "lastname", type: .varchar(width: nil),
                isNotNull: true)
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "address"),
        columns: [
          .init(id: 0, name: "address_id", type: .integer, isNotNull: true,
                isPrimaryKey: true),
          .init(id: 1, name: "street",  type: .varchar(width: nil)),
          .init(id: 2, name: "city",    type: .varchar(width: nil)),
          .init(id: 3, name: "state",   type: .varchar(width: nil)),
          .init(id: 4, name: "country", type: .varchar(width: nil)),
          .init(id: 5, name: "person_id", type: .integer)
        ],
        foreignKeys: [
          .init(id: 0, sourceColumn: "person_id", destinationTable: "person",
                deleteAction: .cascade, match: .none)
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "A Fancy Test Table"),
        columns: [
          .init(id: 1, name: "id", type: .integer, isNotNull: false,
                isPrimaryKey: true),
          .init(id: 2, name: "text", type: .text, isNotNull: true)
        ],
        foreignKeys: [
          .init(id: 0, sourceColumn: "person_id", destinationTable: "person")
        ]
      )
    ]
  )

  static let talentSchema = Schema(
    version: 1, userVersion: 0,
    tables: [
      Schema.Table(
        info: .init(type: .table, name: "talent"),
        columns: [
          .init(id: 0, name: "talent_id", type: .custom("UUID"),
                isNotNull: true, defaultValue: nil, isPrimaryKey: true),
          .init(id: 1, name: "name", type: .text, isNotNull: true)
        ]
      )
    ]
  )

  static let northWindSchema = Schema(
    version: 17, userVersion: 0,
    tables: [
      Schema.Table(
        info: .init(type: .table, name: "Employee", sql: "CREATE TABLE \"Employee\" \n(\n  \"Id\" INTEGER PRIMARY KEY, \n  \"LastName\" VARCHAR(8000) NULL, \n  \"FirstName\" VARCHAR(8000) NULL, \n  \"Title\" VARCHAR(8000) NULL, \n  \"TitleOfCourtesy\" VARCHAR(8000) NULL, \n  \"BirthDate\" VARCHAR(8000) NULL, \n  \"HireDate\" VARCHAR(8000) NULL, \n  \"Address\" VARCHAR(8000) NULL, \n  \"City\" VARCHAR(8000) NULL, \n  \"Region\" VARCHAR(8000) NULL, \n  \"PostalCode\" VARCHAR(8000) NULL, \n  \"Country\" VARCHAR(8000) NULL, \n  \"HomePhone\" VARCHAR(8000) NULL, \n  \"Extension\" VARCHAR(8000) NULL, \n  \"Photo\" BLOB NULL, \n  \"Notes\" VARCHAR(8000) NULL, \n  \"ReportsTo\" INTEGER NULL, \n  \"PhotoPath\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "LastName", type: .varchar(width: 8000)),
          .init(id: 2, name: "FirstName", type: .varchar(width: 8000)),
          .init(id: 3, name: "Title", type: .varchar(width: 8000)),
          .init(id: 4, name: "TitleOfCourtesy", type: .varchar(width: 8000)),
          .init(id: 5, name: "BirthDate", type: .varchar(width: 8000)),
          .init(id: 6, name: "HireDate", type: .varchar(width: 8000)),
          .init(id: 7, name: "Address", type: .varchar(width: 8000)),
          .init(id: 8, name: "City", type: .varchar(width: 8000)),
          .init(id: 9, name: "Region", type: .varchar(width: 8000)),
          .init(id: 10, name: "PostalCode", type: .varchar(width: 8000)),
          .init(id: 11, name: "Country", type: .varchar(width: 8000)),
          .init(id: 12, name: "HomePhone", type: .varchar(width: 8000)),
          .init(id: 13, name: "Extension", type: .varchar(width: 8000)),
          .init(id: 14, name: "Photo", type: .blob),
          .init(id: 15, name: "Notes", type: .varchar(width: 8000)),
          .init(id: 16, name: "ReportsTo", type: .integer),
          .init(id: 17, name: "PhotoPath", type: .varchar(width: 8000)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "Category", sql: "CREATE TABLE \"Category\" \n(\n  \"Id\" INTEGER PRIMARY KEY, \n  \"CategoryName\" VARCHAR(8000) NULL, \n  \"Description\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "CategoryName", type: .varchar(width: 8000)),
          .init(id: 2, name: "Description", type: .varchar(width: 8000)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "Customer", sql: "CREATE TABLE \"Customer\" \n(\n  \"Id\" VARCHAR(8000) PRIMARY KEY, \n  \"CompanyName\" VARCHAR(8000) NULL, \n  \"ContactName\" VARCHAR(8000) NULL, \n  \"ContactTitle\" VARCHAR(8000) NULL, \n  \"Address\" VARCHAR(8000) NULL, \n  \"City\" VARCHAR(8000) NULL, \n  \"Region\" VARCHAR(8000) NULL, \n  \"PostalCode\" VARCHAR(8000) NULL, \n  \"Country\" VARCHAR(8000) NULL, \n  \"Phone\" VARCHAR(8000) NULL, \n  \"Fax\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .varchar(width: 8000), isPrimaryKey: true),
          .init(id: 1, name: "CompanyName", type: .varchar(width: 8000)),
          .init(id: 2, name: "ContactName", type: .varchar(width: 8000)),
          .init(id: 3, name: "ContactTitle", type: .varchar(width: 8000)),
          .init(id: 4, name: "Address", type: .varchar(width: 8000)),
          .init(id: 5, name: "City", type: .varchar(width: 8000)),
          .init(id: 6, name: "Region", type: .varchar(width: 8000)),
          .init(id: 7, name: "PostalCode", type: .varchar(width: 8000)),
          .init(id: 8, name: "Country", type: .varchar(width: 8000)),
          .init(id: 9, name: "Phone", type: .varchar(width: 8000)),
          .init(id: 10, name: "Fax", type: .varchar(width: 8000)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "Shipper", sql: "CREATE TABLE \"Shipper\" \n(\n  \"Id\" INTEGER PRIMARY KEY, \n  \"CompanyName\" VARCHAR(8000) NULL, \n  \"Phone\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "CompanyName", type: .varchar(width: 8000)),
          .init(id: 2, name: "Phone", type: .varchar(width: 8000)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "Supplier", sql: "CREATE TABLE \"Supplier\" \n(\n  \"Id\" INTEGER PRIMARY KEY, \n  \"CompanyName\" VARCHAR(8000) NULL, \n  \"ContactName\" VARCHAR(8000) NULL, \n  \"ContactTitle\" VARCHAR(8000) NULL, \n  \"Address\" VARCHAR(8000) NULL, \n  \"City\" VARCHAR(8000) NULL, \n  \"Region\" VARCHAR(8000) NULL, \n  \"PostalCode\" VARCHAR(8000) NULL, \n  \"Country\" VARCHAR(8000) NULL, \n  \"Phone\" VARCHAR(8000) NULL, \n  \"Fax\" VARCHAR(8000) NULL, \n  \"HomePage\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "CompanyName", type: .varchar(width: 8000)),
          .init(id: 2, name: "ContactName", type: .varchar(width: 8000)),
          .init(id: 3, name: "ContactTitle", type: .varchar(width: 8000)),
          .init(id: 4, name: "Address", type: .varchar(width: 8000)),
          .init(id: 5, name: "City", type: .varchar(width: 8000)),
          .init(id: 6, name: "Region", type: .varchar(width: 8000)),
          .init(id: 7, name: "PostalCode", type: .varchar(width: 8000)),
          .init(id: 8, name: "Country", type: .varchar(width: 8000)),
          .init(id: 9, name: "Phone", type: .varchar(width: 8000)),
          .init(id: 10, name: "Fax", type: .varchar(width: 8000)),
          .init(id: 11, name: "HomePage", type: .varchar(width: 8000)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "Order", sql: "CREATE TABLE \"Order\" \n(\n  \"Id\" INTEGER PRIMARY KEY, \n  \"CustomerId\" VARCHAR(8000) NULL, \n  \"EmployeeId\" INTEGER NOT NULL, \n  \"OrderDate\" VARCHAR(8000) NULL, \n  \"RequiredDate\" VARCHAR(8000) NULL, \n  \"ShippedDate\" VARCHAR(8000) NULL, \n  \"ShipVia\" INTEGER NULL, \n  \"Freight\" DECIMAL NOT NULL, \n  \"ShipName\" VARCHAR(8000) NULL, \n  \"ShipAddress\" VARCHAR(8000) NULL, \n  \"ShipCity\" VARCHAR(8000) NULL, \n  \"ShipRegion\" VARCHAR(8000) NULL, \n  \"ShipPostalCode\" VARCHAR(8000) NULL, \n  \"ShipCountry\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "CustomerId", type: .varchar(width: 8000)),
          .init(id: 2, name: "EmployeeId", type: .integer, isNotNull: true),
          .init(id: 3, name: "OrderDate", type: .varchar(width: 8000)),
          .init(id: 4, name: "RequiredDate", type: .varchar(width: 8000)),
          .init(id: 5, name: "ShippedDate", type: .varchar(width: 8000)),
          .init(id: 6, name: "ShipVia", type: .integer),
          .init(id: 7, name: "Freight", type: .decimal, isNotNull: true),
          .init(id: 8, name: "ShipName", type: .varchar(width: 8000)),
          .init(id: 9, name: "ShipAddress", type: .varchar(width: 8000)),
          .init(id: 10, name: "ShipCity", type: .varchar(width: 8000)),
          .init(id: 11, name: "ShipRegion", type: .varchar(width: 8000)),
          .init(id: 12, name: "ShipPostalCode", type: .varchar(width: 8000)),
          .init(id: 13, name: "ShipCountry", type: .varchar(width: 8000)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "Product", sql: "CREATE TABLE \"Product\" \n(\n  \"Id\" INTEGER PRIMARY KEY, \n  \"ProductName\" VARCHAR(8000) NULL, \n  \"SupplierId\" INTEGER NOT NULL, \n  \"CategoryId\" INTEGER NOT NULL, \n  \"QuantityPerUnit\" VARCHAR(8000) NULL, \n  \"UnitPrice\" DECIMAL NOT NULL, \n  \"UnitsInStock\" INTEGER NOT NULL, \n  \"UnitsOnOrder\" INTEGER NOT NULL, \n  \"ReorderLevel\" INTEGER NOT NULL, \n  \"Discontinued\" INTEGER NOT NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "ProductName", type: .varchar(width: 8000)),
          .init(id: 2, name: "SupplierId", type: .integer, isNotNull: true),
          .init(id: 3, name: "CategoryId", type: .integer, isNotNull: true),
          .init(id: 4, name: "QuantityPerUnit", type: .varchar(width: 8000)),
          .init(id: 5, name: "UnitPrice", type: .decimal, isNotNull: true),
          .init(id: 6, name: "UnitsInStock", type: .integer, isNotNull: true),
          .init(id: 7, name: "UnitsOnOrder", type: .integer, isNotNull: true),
          .init(id: 8, name: "ReorderLevel", type: .integer, isNotNull: true),
          .init(id: 9, name: "Discontinued", type: .integer, isNotNull: true),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "OrderDetail", sql: "CREATE TABLE \"OrderDetail\" \n(\n  \"Id\" VARCHAR(8000) PRIMARY KEY, \n  \"OrderId\" INTEGER NOT NULL, \n  \"ProductId\" INTEGER NOT NULL, \n  \"UnitPrice\" DECIMAL NOT NULL, \n  \"Quantity\" INTEGER NOT NULL, \n  \"Discount\" DOUBLE NOT NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .varchar(width: 8000), isPrimaryKey: true),
          .init(id: 1, name: "OrderId", type: .integer, isNotNull: true),
          .init(id: 2, name: "ProductId", type: .integer, isNotNull: true),
          .init(id: 3, name: "UnitPrice", type: .decimal, isNotNull: true),
          .init(id: 4, name: "Quantity", type: .integer, isNotNull: true),
          .init(id: 5, name: "Discount", type: .custom("DOUBLE"), isNotNull: true),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "CustomerCustomerDemo", sql: "CREATE TABLE \"CustomerCustomerDemo\" \n(\n  \"Id\" VARCHAR(8000) PRIMARY KEY, \n  \"CustomerTypeId\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .varchar(width: 8000), isPrimaryKey: true),
          .init(id: 1, name: "CustomerTypeId", type: .varchar(width: 8000)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "CustomerDemographic", sql: "CREATE TABLE \"CustomerDemographic\" \n(\n  \"Id\" VARCHAR(8000) PRIMARY KEY, \n  \"CustomerDesc\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .varchar(width: 8000), isPrimaryKey: true),
          .init(id: 1, name: "CustomerDesc", type: .varchar(width: 8000)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "Region", sql: "CREATE TABLE \"Region\" \n(\n  \"Id\" INTEGER PRIMARY KEY, \n  \"RegionDescription\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "RegionDescription", type: .varchar(width: 8000)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "Territory", sql: "CREATE TABLE \"Territory\" \n(\n  \"Id\" VARCHAR(8000) PRIMARY KEY, \n  \"TerritoryDescription\" VARCHAR(8000) NULL, \n  \"RegionId\" INTEGER NOT NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .varchar(width: 8000), isPrimaryKey: true),
          .init(id: 1, name: "TerritoryDescription", type: .varchar(width: 8000)),
          .init(id: 2, name: "RegionId", type: .integer, isNotNull: true),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "EmployeeTerritory", sql: "CREATE TABLE \"EmployeeTerritory\" \n(\n  \"Id\" VARCHAR(8000) PRIMARY KEY, \n  \"EmployeeId\" INTEGER NOT NULL, \n  \"TerritoryId\" VARCHAR(8000) NULL \n)"),
        columns: [
          .init(id: 0, name: "Id", type: .varchar(width: 8000), isPrimaryKey: true),
          .init(id: 1, name: "EmployeeId", type: .integer, isNotNull: true),
          .init(id: 2, name: "TerritoryId", type: .varchar(width: 8000)),
        ]
      ),
    ],
    views: [
      Schema.View(
        info: .init(type: .view, name: "ProductDetails_V", sql: "CREATE VIEW [ProductDetails_V] as\nselect \np.*, \nc.CategoryName, c.Description as [CategoryDescription],\ns.CompanyName as [SupplierName], s.Region as [SupplierRegion]\nfrom [Product] p\njoin [Category] c on p.CategoryId = c.id\njoin [Supplier] s on s.id = p.SupplierId"),
        columns: [
          .init(id: 0, name: "Id", type: .integer),
          .init(id: 1, name: "ProductName", type: .varchar(width: 8000)),
          .init(id: 2, name: "SupplierId", type: .integer),
          .init(id: 3, name: "CategoryId", type: .integer),
          .init(id: 4, name: "QuantityPerUnit", type: .varchar(width: 8000)),
          .init(id: 5, name: "UnitPrice", type: .decimal),
          .init(id: 6, name: "UnitsInStock", type: .integer),
          .init(id: 7, name: "UnitsOnOrder", type: .integer),
          .init(id: 8, name: "ReorderLevel", type: .integer),
          .init(id: 9, name: "Discontinued", type: .integer),
          .init(id: 10, name: "CategoryName", type: .varchar(width: 8000)),
          .init(id: 11, name: "CategoryDescription", type: .varchar(width: 8000)),
          .init(id: 12, name: "SupplierName", type: .varchar(width: 8000)),
          .init(id: 13, name: "SupplierRegion", type: .varchar(width: 8000)),
        ]
      )
    ],
    indices: [
      "CustomerCustomerDemo": [
        .init(type: .index, name: "sqlite_autoindex_CustomerCustomerDemo_1", tableName: "CustomerCustomerDemo", rootPage: 17),
      ],
      "OrderDetail": [
        .init(type: .index, name: "sqlite_autoindex_OrderDetail_1", tableName: "OrderDetail", rootPage: 15),
      ],
      "CustomerDemographic": [
        .init(type: .index, name: "sqlite_autoindex_CustomerDemographic_1", tableName: "CustomerDemographic", rootPage: 19),
      ],
      "Territory": [
        .init(type: .index, name: "sqlite_autoindex_Territory_1", tableName: "Territory", rootPage: 23),
      ],
      "EmployeeTerritory": [
        .init(type: .index, name: "sqlite_autoindex_EmployeeTerritory_1", tableName: "EmployeeTerritory", rootPage: 25),
      ],
      "Customer": [
        .init(type: .index, name: "sqlite_autoindex_Customer_1", tableName: "Customer", rootPage: 5),
      ],
    ]
  )
  
  static let OGoSchema = Schema(
    version: 218, userVersion: 0,
    tables: [
      Schema.Table(
        info: .init(type: .table, name: "object_model", sql: "CREATE TABLE object_model (\n  db_version INTEGER /* t_int */,\n  model_name VARCHAR(255) /* t_string */\n  ,\n  CHECK(db_version IS NOT NULL),\n  CHECK(model_name IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "db_version", type: .integer),
          .init(id: 1, name: "model_name", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "log", sql: "CREATE TABLE log (\n  log_id        INTEGER     /* t_id */,\n  creation_date TIMESTAMP   /* t_datetime */,\n  object_id     INTEGER     /* t_id */,      \n  log_text      VARCHAR(2000000000) /* t_text */,\n  action        VARCHAR(50) /* t_smallstring */,\n  account_id    INTEGER     /* t_id */\n  ,\n  PRIMARY KEY(log_id),\n  CHECK(log_id        IS NOT NULL),\n  CHECK(creation_date IS NOT NULL),\n  CHECK(object_id     IS NOT NULL),\n  CHECK(log_text      IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "log_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "creation_date", type: .timestamp),
          .init(id: 2, name: "object_id", type: .integer),
          .init(id: 3, name: "log_text", type: .varchar(width: 2000000000)),
          .init(id: 4, name: "action", type: .varchar(width: 50)),
          .init(id: 5, name: "account_id", type: .integer),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "session_log", sql: "CREATE TABLE session_log (\n  session_log_id          INTEGER /* t_id */,\n  account_id              INTEGER /* t_id */,\n  log_date                TIMESTAMP /* t_datetime */,\n  action                  VARCHAR(255) /* t_string */\n  ,\n  PRIMARY KEY(session_log_id),\n  CHECK(session_log_id IS NOT NULL),\n  CHECK(account_id     IS NOT NULL),\n  CHECK(log_date       IS NOT NULL),\n  CHECK(action         IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "session_log_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "account_id", type: .integer),
          .init(id: 2, name: "log_date", type: .timestamp),
          .init(id: 3, name: "action", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "table_version", sql: "CREATE TABLE table_version (\n  table_version INTEGER      /* t_int */,\n  name         VARCHAR(255) /* t_string */\n  ,\n  PRIMARY KEY(name),\n  CHECK(name          IS NOT NULL),\n  CHECK(table_version IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "table_version", type: .integer),
          .init(id: 1, name: "name", type: .varchar(width: 255), isPrimaryKey: true),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "staff", sql: "CREATE TABLE staff (\n  staff_id      INTEGER /* t_id */,\n  company_id    INTEGER /* t_id */,\n  description   VARCHAR(255) /* t_string */,\n  login         VARCHAR(255) /* t_string */,\n  is_team       BOOLEAN /* t_bool */,\n  is_account    BOOLEAN /* t_bool */,\n  db_status     VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(staff_id),\n  CHECK(staff_id   IS NOT NULL),\n  CHECK(company_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "staff_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "description", type: .varchar(width: 255)),
          .init(id: 3, name: "login", type: .varchar(width: 255)),
          .init(id: 4, name: "is_team", type: .boolean),
          .init(id: 5, name: "is_account", type: .boolean),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "company", sql: "CREATE TABLE company (\n  company_id        INTEGER /* t_id */,\n\n/* all companies */\n\n  owner_id          INTEGER /* t_id */,\n  object_version    INTEGER /* t_int */,\n  contact_id        INTEGER /* t_id */,   \n  template_user_id  INTEGER /* t_id */,   \n  is_private        BOOLEAN /* t_bool */,\n  is_person         BOOLEAN /* t_bool */,\n  is_readonly       BOOLEAN /* t_bool */,      \n  is_enterprise     BOOLEAN /* t_bool */,\n  is_account        BOOLEAN /* t_bool */,\n  is_intra_account  BOOLEAN /* t_bool */,\n  is_extra_account  BOOLEAN /* t_bool */,\n  is_trust          BOOLEAN /* t_bool */,\n  is_team           BOOLEAN /* t_bool */,\n  is_location_team  BOOLEAN /* t_bool */,\n  is_customer       BOOLEAN /* t_bool */,\n  \n  number            VARCHAR(50)  /* t_tinystring */, /* Sybase:number */\n  description       VARCHAR(255) /* t_string */,\n  priority          VARCHAR(50)  /* t_tinystring */,\n  keywords          VARCHAR(255) /* t_string */,\n\n/* person, enterprise, customer, team or trust */\n\n  url               VARCHAR(255) /* t_string */,\n  email             VARCHAR(50)  /* t_tinystring */, \n  type              VARCHAR(50)  /* t_tinystring */, /* Sybase:type */\n  bank              VARCHAR(50)  /* t_tinystring */,\n  bank_code         VARCHAR(50)  /* t_tinystring */,\n  account           VARCHAR(50)  /* t_tinystring */,\n  payment           VARCHAR(50)  /* t_tinystring */,\n\n/* account */\n\n  is_locked           BOOLEAN     /* t_bool */,\n  is_template_user    BOOLEAN     /* t_bool */,\n  can_change_password BOOLEAN     /* t_bool */,\n  login               VARCHAR(50) /* t_tinystring */,\n  password            VARCHAR(50) /* t_tinystring */,\n  pop3_account        VARCHAR(50) /* t_tinystring */,\n\n/* person */\n\n  name              VARCHAR(50) /* t_tinystring */, /* Sybase:name */\n  middlename        VARCHAR(50) /* t_tinystring */, \n  firstname         VARCHAR(50) /* t_tinystring */,\n  salutation        VARCHAR(50) /* t_tinystring */,\n  degree            VARCHAR(50) /* t_tinystring */,\n  birthday          TIMESTAMP   /* t_datetime */,\n  sex               VARCHAR(10) /* t_tinieststring */,\n\n  source_url        varchar(255),\n\n  db_status         VARCHAR(50) /* t_tinystring */,\n\n/* ZideStore additions */\n\n  sensitivity       INTEGER      /* smallint */, /* sensitivity      */\n  boss_name         VARCHAR(255) /* t_string */, /* boss' name       */\n  partner_name      VARCHAR(255) /* t_string */, /* partners' name   */\n  assistant_name    VARCHAR(255) /* t_string */, /* assistants' name */\n  department        VARCHAR(255) /* t_string */, /* department       */\n  office            VARCHAR(255) /* t_string */, /* office (office number) */\n  occupation        VARCHAR(255) /* t_string */, /* occupation       */\n  anniversary       TIMESTAMP    /* t_datetime */, /* anniversary */\n  dir_server        VARCHAR(255) /* t_string */,   /* dirserver (NetMeeting) */\n  email_alias       VARCHAR(255) /* t_string */,   /* emailalias (NetMeeting)*/\n  freebusy_url      VARCHAR(255) /* t_string */,   /* free/busy URL */\n\n  fileas              VARCHAR(255) /* t_string */, /* file as/save as */\n  name_title          VARCHAR(255) /* t_string */, /* name title (Prof.) */\n  name_affix          VARCHAR(255) /* t_string */, /* name affix (jun.) */\n  im_address          VARCHAR(255) /* t_string */, /* IM address */\n  associated_contacts VARCHAR(255)   /* t_string */, /* assoc. contacts */\n  associated_categories VARCHAR(255) /* t_string */, /* assoc. categories */\n  associated_company  VARCHAR(255) /* t_string */,   /* assoc. company */\n  show_email_as       VARCHAR(255) /* t_string */,   /* email show as attr */\n  show_email2_as      VARCHAR(255) /* t_string */,   /* email 2 show as attr */\n  show_email3_as      VARCHAR(255) /* t_string */    /* email 3 show as attr */\n  ,\n  birthplace          VARCHAR(255),\n  birthname           VARCHAR(255),\n  family_status       VARCHAR(255),\n  citizenship         VARCHAR(255),\n  dayofdeath          timestamp with time zone\n  ,\n  PRIMARY KEY(company_id),\n  CHECK (company_id IS NOT NULL),\n  CHECK (NOT(is_person IS NULL AND is_enterprise IS NULL AND \n             is_trust IS NULL AND is_team IS NULL))\n)"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "owner_id", type: .integer),
          .init(id: 2, name: "object_version", type: .integer),
          .init(id: 3, name: "contact_id", type: .integer),
          .init(id: 4, name: "template_user_id", type: .integer),
          .init(id: 5, name: "is_private", type: .boolean),
          .init(id: 6, name: "is_person", type: .boolean),
          .init(id: 7, name: "is_readonly", type: .boolean),
          .init(id: 8, name: "is_enterprise", type: .boolean),
          .init(id: 9, name: "is_account", type: .boolean),
          .init(id: 10, name: "is_intra_account", type: .boolean),
          .init(id: 11, name: "is_extra_account", type: .boolean),
          .init(id: 12, name: "is_trust", type: .boolean),
          .init(id: 13, name: "is_team", type: .boolean),
          .init(id: 14, name: "is_location_team", type: .boolean),
          .init(id: 15, name: "is_customer", type: .boolean),
          .init(id: 16, name: "number", type: .varchar(width: 50)),
          .init(id: 17, name: "description", type: .varchar(width: 255)),
          .init(id: 18, name: "priority", type: .varchar(width: 50)),
          .init(id: 19, name: "keywords", type: .varchar(width: 255)),
          .init(id: 20, name: "url", type: .varchar(width: 255)),
          .init(id: 21, name: "email", type: .varchar(width: 50)),
          .init(id: 22, name: "type", type: .varchar(width: 50)),
          .init(id: 23, name: "bank", type: .varchar(width: 50)),
          .init(id: 24, name: "bank_code", type: .varchar(width: 50)),
          .init(id: 25, name: "account", type: .varchar(width: 50)),
          .init(id: 26, name: "payment", type: .varchar(width: 50)),
          .init(id: 27, name: "is_locked", type: .boolean),
          .init(id: 28, name: "is_template_user", type: .boolean),
          .init(id: 29, name: "can_change_password", type: .boolean),
          .init(id: 30, name: "login", type: .varchar(width: 50)),
          .init(id: 31, name: "password", type: .varchar(width: 50)),
          .init(id: 32, name: "pop3_account", type: .varchar(width: 50)),
          .init(id: 33, name: "name", type: .varchar(width: 50)),
          .init(id: 34, name: "middlename", type: .varchar(width: 50)),
          .init(id: 35, name: "firstname", type: .varchar(width: 50)),
          .init(id: 36, name: "salutation", type: .varchar(width: 50)),
          .init(id: 37, name: "degree", type: .varchar(width: 50)),
          .init(id: 38, name: "birthday", type: .timestamp),
          .init(id: 39, name: "sex", type: .varchar(width: 10)),
          .init(id: 40, name: "source_url", type: .custom("varchar(255)")),
          .init(id: 41, name: "db_status", type: .varchar(width: 50)),
          .init(id: 42, name: "sensitivity", type: .integer),
          .init(id: 43, name: "boss_name", type: .varchar(width: 255)),
          .init(id: 44, name: "partner_name", type: .varchar(width: 255)),
          .init(id: 45, name: "assistant_name", type: .varchar(width: 255)),
          .init(id: 46, name: "department", type: .varchar(width: 255)),
          .init(id: 47, name: "office", type: .varchar(width: 255)),
          .init(id: 48, name: "occupation", type: .varchar(width: 255)),
          .init(id: 49, name: "anniversary", type: .timestamp),
          .init(id: 50, name: "dir_server", type: .varchar(width: 255)),
          .init(id: 51, name: "email_alias", type: .varchar(width: 255)),
          .init(id: 52, name: "freebusy_url", type: .varchar(width: 255)),
          .init(id: 53, name: "fileas", type: .varchar(width: 255)),
          .init(id: 54, name: "name_title", type: .varchar(width: 255)),
          .init(id: 55, name: "name_affix", type: .varchar(width: 255)),
          .init(id: 56, name: "im_address", type: .varchar(width: 255)),
          .init(id: 57, name: "associated_contacts", type: .varchar(width: 255)),
          .init(id: 58, name: "associated_categories", type: .varchar(width: 255)),
          .init(id: 59, name: "associated_company", type: .varchar(width: 255)),
          .init(id: 60, name: "show_email_as", type: .varchar(width: 255)),
          .init(id: 61, name: "show_email2_as", type: .varchar(width: 255)),
          .init(id: 62, name: "show_email3_as", type: .varchar(width: 255)),
          .init(id: 63, name: "birthplace", type: .varchar(width: 255)),
          .init(id: 64, name: "birthname", type: .varchar(width: 255)),
          .init(id: 65, name: "family_status", type: .varchar(width: 255)),
          .init(id: 66, name: "citizenship", type: .varchar(width: 255)),
          .init(id: 67, name: "dayofdeath", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "company_info", sql: "CREATE TABLE company_info (\n  company_info_id INTEGER /* t_id */,\n  company_id      INTEGER /* t_id */, \n  comment         VARCHAR(2000000000) /* t_text */,\n  db_status       VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(company_info_id),\n  CHECK(company_id      IS NOT NULL),\n  CHECK(company_info_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "company_info_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "comment", type: .varchar(width: 2000000000)),
          .init(id: 3, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "company_value", sql: "CREATE TABLE company_value (\n  company_value_id   INTEGER       /* t_id */,\n  company_id         INTEGER       /* t_id */,\n  attribute          VARCHAR(255)  /* t_string */,\n  attribute_type     VARCHAR(50)   /* t_tinystring */,\n  value_string       VARCHAR(255)  /* t_string */,\n  value_date         TIMESTAMP     /* t_datetime */,\n  value_int          INTEGER       /* t_int */,\n  is_enum            BOOLEAN       /* t_bool */,\n  category           VARCHAR(255)  /* t_string */,\n  uid                INTEGER       /* t_id */, \n  label              VARCHAR(255)  /* t_string */,\n  type               INTEGER       /* t_int */,\n  is_label_localized BOOLEAN       /* t_bool */,\n  db_status          VARCHAR(50)   /* t_tinystring */\n  ,\n  start_date         timestamp with time zone,\n  end_date           timestamp with time zone\n  ,\n  PRIMARY KEY(company_value_id),\n  CHECK(company_value_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "company_value_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "attribute", type: .varchar(width: 255)),
          .init(id: 3, name: "attribute_type", type: .varchar(width: 50)),
          .init(id: 4, name: "value_string", type: .varchar(width: 255)),
          .init(id: 5, name: "value_date", type: .timestamp),
          .init(id: 6, name: "value_int", type: .integer),
          .init(id: 7, name: "is_enum", type: .boolean),
          .init(id: 8, name: "category", type: .varchar(width: 255)),
          .init(id: 9, name: "uid", type: .integer),
          .init(id: 10, name: "label", type: .varchar(width: 255)),
          .init(id: 11, name: "type", type: .integer),
          .init(id: 12, name: "is_label_localized", type: .boolean),
          .init(id: 13, name: "db_status", type: .varchar(width: 50)),
          .init(id: 14, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 15, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "company_category", sql: "CREATE TABLE company_category (\n  company_category_id INTEGER /* t_id */,\n  object_version      INTEGER /* t_int */,\n  category            VARCHAR(255) /* t_string */,\n  db_status           VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(company_category_id),\n  CHECK(company_category_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "company_category_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "category", type: .varchar(width: 255)),
          .init(id: 3, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "appointment_resource", sql: "CREATE TABLE appointment_resource (\n  appointment_resource_id INTEGER /* t_id */,\n  object_version          INTEGER /* t_int */,\n  name                    VARCHAR(255) /* t_string */, /* Sybase: name */\n  email                   VARCHAR(255) /* t_string */,\n  email_subject           VARCHAR(255) /* t_string */,\n  category                VARCHAR(255) /* t_string */,\n  notification_time       INTEGER /* t_int */,\n  db_status               VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(appointment_resource_id),\n  CHECK(appointment_resource_id IS NOT NULL),\n  CHECK(name IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "appointment_resource_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "name", type: .varchar(width: 255)),
          .init(id: 3, name: "email", type: .varchar(width: 255)),
          .init(id: 4, name: "email_subject", type: .varchar(width: 255)),
          .init(id: 5, name: "category", type: .varchar(width: 255)),
          .init(id: 6, name: "notification_time", type: .integer),
          .init(id: 7, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "appointment", sql: "CREATE TABLE appointment ( /* Sybase: date */\n  date_id                INTEGER /* t_id */, /* primary key */\n  object_version         INTEGER /* t_int */,\n  owner_id               INTEGER /* t_id */, /* owner - staff entry */\n  access_team_id         INTEGER /* t_id */,    \n  parent_date_id         INTEGER /* t_id */, /* foreign key to parent date in cyclic dates */\n  start_date             TIMESTAMP /* t_datetime */,\n  end_date               TIMESTAMP /* t_datetime */,\n  cycle_end_date         TIMESTAMP /* t_datetime */,\n  type                   VARCHAR(255) /* t_tinystring */, /* Sybase: type:weekday daily weekly monthly yearly */\n  title                  VARCHAR(255) /* t_string */,\n  location               VARCHAR(255) /* t_string */,\n  absence                VARCHAR(255) /* t_string */,\n  resource_names         VARCHAR(255) /* t_string */,\n  write_access_list      VARCHAR(255) /* t_string */,\n  is_absence             BOOLEAN /* t_bool */,\n  is_attendance          BOOLEAN /* t_bool */,\n  is_conflict_disabled   BOOLEAN /* t_bool */,\n  travel_duration_before INTEGER /* t_int */,\n  travel_duration_after  INTEGER /* t_int */,\n  notification_time      INTEGER /* t_int */,\n  db_status              VARCHAR(50) /* t_tinystring */,\n  apt_type               VARCHAR(50) /* t_smallstring */,\n  calendar_name          VARCHAR(255) /* t_string */,\n  source_url             VARCHAR(255) /* t_string */,\n  fbtype                 VARCHAR(50) /* t_tinystring */,\n\n  sensitivity            INTEGER /* smallint */,        /* sensitivity */\n  busy_type              INTEGER /* smallint */,        /* busy type */\n  importance             INTEGER /* smallint */,        /* importance */\n  last_modified          INTEGER /* t_int */,           /* timestamp of last modification */\n\n  evo_reminder           VARCHAR(255) /* t_string */,   /* Evolution reminder settings */\n  ol_reminder            VARCHAR(255) /* t_string */,   /* Outlook reminder settings */\n  online_meeting         VARCHAR(255) /* t_string */,   /* CSV for online meeting values */\n  associated_contacts    VARCHAR(255) /* t_string */,   /* Outlook associated contacts */\n  keywords               VARCHAR(255) /* t_string */    /* Outlook keywords */\n  ,\n  PRIMARY KEY(date_id),\n  CHECK(date_id    IS NOT NULL),\n  CHECK(start_date IS NOT NULL),\n  CHECK(end_date   IS NOT NULL),\n  CHECK(title      IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "date_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "owner_id", type: .integer),
          .init(id: 3, name: "access_team_id", type: .integer),
          .init(id: 4, name: "parent_date_id", type: .integer),
          .init(id: 5, name: "start_date", type: .timestamp),
          .init(id: 6, name: "end_date", type: .timestamp),
          .init(id: 7, name: "cycle_end_date", type: .timestamp),
          .init(id: 8, name: "type", type: .varchar(width: 255)),
          .init(id: 9, name: "title", type: .varchar(width: 255)),
          .init(id: 10, name: "location", type: .varchar(width: 255)),
          .init(id: 11, name: "absence", type: .varchar(width: 255)),
          .init(id: 12, name: "resource_names", type: .varchar(width: 255)),
          .init(id: 13, name: "write_access_list", type: .varchar(width: 255)),
          .init(id: 14, name: "is_absence", type: .boolean),
          .init(id: 15, name: "is_attendance", type: .boolean),
          .init(id: 16, name: "is_conflict_disabled", type: .boolean),
          .init(id: 17, name: "travel_duration_before", type: .integer),
          .init(id: 18, name: "travel_duration_after", type: .integer),
          .init(id: 19, name: "notification_time", type: .integer),
          .init(id: 20, name: "db_status", type: .varchar(width: 50)),
          .init(id: 21, name: "apt_type", type: .varchar(width: 50)),
          .init(id: 22, name: "calendar_name", type: .varchar(width: 255)),
          .init(id: 23, name: "source_url", type: .varchar(width: 255)),
          .init(id: 24, name: "fbtype", type: .varchar(width: 50)),
          .init(id: 25, name: "sensitivity", type: .integer),
          .init(id: 26, name: "busy_type", type: .integer),
          .init(id: 27, name: "importance", type: .integer),
          .init(id: 28, name: "last_modified", type: .integer),
          .init(id: 29, name: "evo_reminder", type: .varchar(width: 255)),
          .init(id: 30, name: "ol_reminder", type: .varchar(width: 255)),
          .init(id: 31, name: "online_meeting", type: .varchar(width: 255)),
          .init(id: 32, name: "associated_contacts", type: .varchar(width: 255)),
          .init(id: 33, name: "keywords", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "date_info", sql: "CREATE TABLE date_info (\n  date_info_id INTEGER /* t_id */,\n  date_id      INTEGER /* t_id */,\n  comment      VARCHAR(100000), /* Sybase: TEXT */\n  db_status    VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(date_info_id),\n  CHECK(date_id      IS NOT NULL),\n  CHECK(date_info_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "date_info_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "date_id", type: .integer),
          .init(id: 2, name: "comment", type: .varchar(width: 100000)),
          .init(id: 3, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "date_company_assignment", sql: "CREATE TABLE date_company_assignment (\n  date_company_assignment_id INTEGER      /* t_id */,\n  company_id                 INTEGER      /* t_id */,\n  date_id                    INTEGER      /* t_id */,\n  is_staff                   BOOLEAN      /* t_bool */,\n  is_new                     BOOLEAN      /* t_bool */,\n  partstatus                 VARCHAR(50)  /* t_tinystring */,\n  role                       VARCHAR(50)  /* t_tinystring */,\n  comment                    VARCHAR(255) /* t_string */,\n  rsvp                       BOOLEAN      /* t_bool */,\n  db_status                  VARCHAR(50)  /* t_tinystring */,\n  outlook_key                VARCHAR(255) /* t_string */\n  ,\n  PRIMARY KEY(date_company_assignment_id),\n  CHECK(date_company_assignment_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "date_company_assignment_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "date_id", type: .integer),
          .init(id: 3, name: "is_staff", type: .boolean),
          .init(id: 4, name: "is_new", type: .boolean),
          .init(id: 5, name: "partstatus", type: .varchar(width: 50)),
          .init(id: 6, name: "role", type: .varchar(width: 50)),
          .init(id: 7, name: "comment", type: .varchar(width: 255)),
          .init(id: 8, name: "rsvp", type: .boolean),
          .init(id: 9, name: "db_status", type: .varchar(width: 50)),
          .init(id: 10, name: "outlook_key", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "project", sql: "CREATE TABLE project (\n  project_id        INTEGER /* t_id */,\n  object_version    INTEGER /* t_int */,\n  owner_id          INTEGER /* t_id */,\n  team_id           INTEGER /* t_id */,\n  number            VARCHAR(50) /* t_tinystring */,  /*Sybase: number */\n  name              VARCHAR(255) /* t_string */,  /*Sybase: name */\n  start_date        TIMESTAMP /* t_datetime */,\n  end_date          TIMESTAMP /* t_datetime */,\n  status            VARCHAR(255) /* t_string */,\n  is_fake           BOOLEAN /* t_bool */,\n  db_status         VARCHAR(50) /* t_tinystring */,\n  kind              VARCHAR(50) /* t_tinystring */,\n  url               VARCHAR(50) /* t_smallstring */,\n  parent_project_id INTEGER\n  ,\n  PRIMARY KEY(project_id),\n  CHECK(project_id IS NOT NULL),\n  CHECK(owner_id   IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "project_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "owner_id", type: .integer),
          .init(id: 3, name: "team_id", type: .integer),
          .init(id: 4, name: "number", type: .varchar(width: 50)),
          .init(id: 5, name: "name", type: .varchar(width: 255)),
          .init(id: 6, name: "start_date", type: .timestamp),
          .init(id: 7, name: "end_date", type: .timestamp),
          .init(id: 8, name: "status", type: .varchar(width: 255)),
          .init(id: 9, name: "is_fake", type: .boolean),
          .init(id: 10, name: "db_status", type: .varchar(width: 50)),
          .init(id: 11, name: "kind", type: .varchar(width: 50)),
          .init(id: 12, name: "url", type: .varchar(width: 50)),
          .init(id: 13, name: "parent_project_id", type: .integer),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "project_company_assignment", sql: "CREATE TABLE project_company_assignment (\n  project_company_assignment_id INTEGER /* t_id */,\n  company_id                    INTEGER /* t_id */,\n  project_id                    INTEGER /* t_id */,\n  info                          VARCHAR(255) /* t_string */,\n  has_access                    BOOLEAN /* t_bool */,\n  access_right                  VARCHAR(50) /* t_tinystring */,\n  db_status                     VARCHAR(50) /* t_tinystring */\n  ,\n  start_date         timestamp with time zone,\n  end_date           timestamp with time zone\n  ,\n  PRIMARY KEY(project_company_assignment_id),\n  CHECK(project_company_assignment_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "project_company_assignment_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "project_id", type: .integer),
          .init(id: 3, name: "info", type: .varchar(width: 255)),
          .init(id: 4, name: "has_access", type: .boolean),
          .init(id: 5, name: "access_right", type: .varchar(width: 50)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "document", sql: "CREATE TABLE document (\n  document_id        INTEGER /* t_id */,\n  object_version     INTEGER /* t_int */,\n  parent_document_id INTEGER /* t_id */,\n  project_id         INTEGER /* t_id */,\n  date_id            INTEGER /* t_id */,\n  first_owner_id     INTEGER /* t_id */,\n  current_owner_id   INTEGER /* t_id */,\n  version_count      INTEGER /* t_int */,\n  file_size          INTEGER /* t_int */,\n  is_note            BOOLEAN /* t_bool */,\n  is_folder          BOOLEAN /* t_bool */,\n  is_object_link     BOOLEAN /* t_bool */,\n  is_index_doc       BOOLEAN /* t_bool */,\n  title              VARCHAR(255) /* t_string */,\n  abstract           VARCHAR(255) /* t_string */,\n  file_type          VARCHAR(255) /* t_string */,\n  object_link        VARCHAR(255) /* t_string */,\n  creation_date      TIMESTAMP    /* t_datetime */,\n  lastmodified_date  TIMESTAMP    /* t_datetime */,\n  status             VARCHAR(50)  /* t_tinystring */,\n  db_status          VARCHAR(50)  /* t_tinystring */,\n  contact            VARCHAR(255) /* t_string */,\n  company_id         INTEGER\n  ,\n  PRIMARY KEY(document_id),\n  CHECK(document_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "document_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "parent_document_id", type: .integer),
          .init(id: 3, name: "project_id", type: .integer),
          .init(id: 4, name: "date_id", type: .integer),
          .init(id: 5, name: "first_owner_id", type: .integer),
          .init(id: 6, name: "current_owner_id", type: .integer),
          .init(id: 7, name: "version_count", type: .integer),
          .init(id: 8, name: "file_size", type: .integer),
          .init(id: 9, name: "is_note", type: .boolean),
          .init(id: 10, name: "is_folder", type: .boolean),
          .init(id: 11, name: "is_object_link", type: .boolean),
          .init(id: 12, name: "is_index_doc", type: .boolean),
          .init(id: 13, name: "title", type: .varchar(width: 255)),
          .init(id: 14, name: "abstract", type: .varchar(width: 255)),
          .init(id: 15, name: "file_type", type: .varchar(width: 255)),
          .init(id: 16, name: "object_link", type: .varchar(width: 255)),
          .init(id: 17, name: "creation_date", type: .timestamp),
          .init(id: 18, name: "lastmodified_date", type: .timestamp),
          .init(id: 19, name: "status", type: .varchar(width: 50)),
          .init(id: 20, name: "db_status", type: .varchar(width: 50)),
          .init(id: 21, name: "contact", type: .varchar(width: 255)),
          .init(id: 22, name: "company_id", type: .integer),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "document_version", sql: "CREATE TABLE document_version (\n  document_version_id INTEGER      /* t_id */,\n  object_version      INTEGER      /* t_int */,\n  document_id         INTEGER      /* t_id */,\n  last_owner_id       INTEGER      /* t_id */,\n  title               VARCHAR(255) /* t_string */,\n  abstract            VARCHAR(255) /* t_string */,\n  file_type           VARCHAR(255) /* t_string */,\n  version             INTEGER      /* t_int */,\n  file_size           INTEGER      /* t_int */,\n  creation_date       TIMESTAMP    /* t_datetime */,\n  archive_date        TIMESTAMP    /* t_datetime */,\n  is_packed           BOOLEAN      /* t_bool */,\n  change_text         VARCHAR(2000000000) /* t_text */,\n  db_status           VARCHAR(50)  /* t_tinystring */,\n  contact             VARCHAR(255) /* t_string */\n  ,\n  PRIMARY KEY(document_version_id),\n  CHECK(document_version_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "document_version_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "document_id", type: .integer),
          .init(id: 3, name: "last_owner_id", type: .integer),
          .init(id: 4, name: "title", type: .varchar(width: 255)),
          .init(id: 5, name: "abstract", type: .varchar(width: 255)),
          .init(id: 6, name: "file_type", type: .varchar(width: 255)),
          .init(id: 7, name: "version", type: .integer),
          .init(id: 8, name: "file_size", type: .integer),
          .init(id: 9, name: "creation_date", type: .timestamp),
          .init(id: 10, name: "archive_date", type: .timestamp),
          .init(id: 11, name: "is_packed", type: .boolean),
          .init(id: 12, name: "change_text", type: .varchar(width: 2000000000)),
          .init(id: 13, name: "db_status", type: .varchar(width: 50)),
          .init(id: 14, name: "contact", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "document_editing", sql: "CREATE TABLE document_editing (\n  document_editing_id INTEGER      /* t_id */,\n  object_version      INTEGER      /* t_int */,\n  document_id         INTEGER      /* t_id */,\n  current_owner_id    INTEGER      /* t_id */,\n  title               VARCHAR(255) /* t_string */,\n  abstract            VARCHAR(255) /* t_string */,\n  file_type           VARCHAR(255) /* t_string */,\n  file_size           INTEGER      /* t_int */,\n  version             INTEGER      /* t_int */,\n  is_attach_changed   BOOLEAN      /* t_bool */,\n  checkout_date       TIMESTAMP    /* t_datetime */,\n  status              VARCHAR(50)  /* t_tinystring */,\n  db_status           VARCHAR(50)  /* t_tinystring */,\n  contact             VARCHAR(255) /* t_string */\n  ,\n  PRIMARY KEY(document_editing_id),\n  CHECK(document_editing_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "document_editing_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "document_id", type: .integer),
          .init(id: 3, name: "current_owner_id", type: .integer),
          .init(id: 4, name: "title", type: .varchar(width: 255)),
          .init(id: 5, name: "abstract", type: .varchar(width: 255)),
          .init(id: 6, name: "file_type", type: .varchar(width: 255)),
          .init(id: 7, name: "file_size", type: .integer),
          .init(id: 8, name: "version", type: .integer),
          .init(id: 9, name: "is_attach_changed", type: .boolean),
          .init(id: 10, name: "checkout_date", type: .timestamp),
          .init(id: 11, name: "status", type: .varchar(width: 50)),
          .init(id: 12, name: "db_status", type: .varchar(width: 50)),
          .init(id: 13, name: "contact", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "address", sql: "CREATE TABLE address (\n  address_id        INTEGER /* t_id */,\n  object_version    INTEGER /* t_int */,\n  company_id        INTEGER /* t_id */,\n  name1             VARCHAR(255) /* t_string */,\n  name2             VARCHAR(255) /* t_string */,\n  name3             VARCHAR(255) /* t_string */,\n  street            VARCHAR(255) /* t_string */,\n  zip               VARCHAR(50) /* t_tinystring */,\n  zipcity           VARCHAR(255) /* t_string */,\n  country           VARCHAR(50) /* t_tinystring */,\n  state             VARCHAR(50) /* t_tinystring */,\n  type              VARCHAR(50) /* t_tinystring */, /*Sybase: type */\n  db_status         VARCHAR(50) /* t_tinystring */,\n  source_url        VARCHAR(255) /* t_string */,\n  district          VARCHAR(255)\n  ,\n  PRIMARY KEY(address_id),\n  CHECK(address_id IS NOT NULL),\n  CHECK(type       IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "address_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "company_id", type: .integer),
          .init(id: 3, name: "name1", type: .varchar(width: 255)),
          .init(id: 4, name: "name2", type: .varchar(width: 255)),
          .init(id: 5, name: "name3", type: .varchar(width: 255)),
          .init(id: 6, name: "street", type: .varchar(width: 255)),
          .init(id: 7, name: "zip", type: .varchar(width: 50)),
          .init(id: 8, name: "zipcity", type: .varchar(width: 255)),
          .init(id: 9, name: "country", type: .varchar(width: 50)),
          .init(id: 10, name: "state", type: .varchar(width: 50)),
          .init(id: 11, name: "type", type: .varchar(width: 50)),
          .init(id: 12, name: "db_status", type: .varchar(width: 50)),
          .init(id: 13, name: "source_url", type: .varchar(width: 255)),
          .init(id: 14, name: "district", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "telephone", sql: "CREATE TABLE telephone (\n  telephone_id      INTEGER /* t_id */,\n  object_version    INTEGER /* t_int */,\n  company_id        INTEGER /* t_id */,\n  number            VARCHAR(255) /* t_string */, /*Sybase: number */\n  real_number       VARCHAR(255) /* t_string */,\n  type              VARCHAR(50)  /* t_tinystring */, /*Sybase: type */\n  info              VARCHAR(255) /* t_string */,\n  url               VARCHAR(255) /* t_string */,\n  db_status         VARCHAR(50)  /* t_tinystring */\n  ,\n  PRIMARY KEY(telephone_id),\n  CHECK(telephone_id IS NOT NULL)\n  CHECK(type IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "telephone_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "company_id", type: .integer),
          .init(id: 3, name: "number", type: .varchar(width: 255)),
          .init(id: 4, name: "real_number", type: .varchar(width: 255)),
          .init(id: 5, name: "type", type: .varchar(width: 50)),
          .init(id: 6, name: "info", type: .varchar(width: 255)),
          .init(id: 7, name: "url", type: .varchar(width: 255)),
          .init(id: 8, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "job", sql: "CREATE TABLE job (\n  job_id               INTEGER /* t_id */,\n  object_version       INTEGER /* t_int */,\n  parent_job_id        INTEGER /* t_id */,\n  project_id           INTEGER /* t_id */,\n  creator_id           INTEGER /* t_id */,\n  executant_id         INTEGER /* t_id */,\n  name                 VARCHAR(255) /* t_string */,    /* Sybase: name */\n  start_date           TIMESTAMP /* t_datetime */,\n  end_date             TIMESTAMP /* t_datetime */,\n  notify               INTEGER /* t_int */,\n  is_control_job       BOOLEAN /* t_bool */,\n  is_team_job          BOOLEAN /* t_bool */,\n  is_new               BOOLEAN /* t_bool */,\n  job_status           VARCHAR(255) /* t_string */,\n  category             VARCHAR(255) /* t_string */,\n  priority             INTEGER /* t_int */,\n  db_status            VARCHAR(50) /* t_tinystring */,\n  kind                 VARCHAR(50) /* t_tinystring */,\n  keywords             VARCHAR(255) /* t_string */,\n  source_url           VARCHAR(255) /* t_string */,\n  sensitivity          INTEGER /* smallint */,\n  job_comment          VARCHAR(2000000000) /* t_text */,\n  completion_date      TIMESTAMP /* t_datetime */,\n  percent_complete     INTEGER /* smallint */,\n  actual_work          INTEGER /* smallint */,\n  total_work           INTEGER /* smallint */,\n  last_modified        INTEGER /* t_int */,\n  accounting_info      VARCHAR(255) /* t_string */,\n  kilometers           VARCHAR(255) /* t_string */,\n  associated_companies VARCHAR(255) /* t_string */,\n  associated_contacts  VARCHAR(255) /* t_string */,\n  timer_date           TIMESTAMP /* t_datetime */\n  ,\n  PRIMARY KEY(job_id),\n  CHECK(job_id     IS NOT NULL),\n  CHECK(name       IS NOT NULL),\n  CHECK(start_date IS NOT NULL),\n  CHECK(end_date   IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "job_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "parent_job_id", type: .integer),
          .init(id: 3, name: "project_id", type: .integer),
          .init(id: 4, name: "creator_id", type: .integer),
          .init(id: 5, name: "executant_id", type: .integer),
          .init(id: 6, name: "name", type: .varchar(width: 255)),
          .init(id: 7, name: "start_date", type: .timestamp),
          .init(id: 8, name: "end_date", type: .timestamp),
          .init(id: 9, name: "notify", type: .integer),
          .init(id: 10, name: "is_control_job", type: .boolean),
          .init(id: 11, name: "is_team_job", type: .boolean),
          .init(id: 12, name: "is_new", type: .boolean),
          .init(id: 13, name: "job_status", type: .varchar(width: 255)),
          .init(id: 14, name: "category", type: .varchar(width: 255)),
          .init(id: 15, name: "priority", type: .integer),
          .init(id: 16, name: "db_status", type: .varchar(width: 50)),
          .init(id: 17, name: "kind", type: .varchar(width: 50)),
          .init(id: 18, name: "keywords", type: .varchar(width: 255)),
          .init(id: 19, name: "source_url", type: .varchar(width: 255)),
          .init(id: 20, name: "sensitivity", type: .integer),
          .init(id: 21, name: "job_comment", type: .varchar(width: 2000000000)),
          .init(id: 22, name: "completion_date", type: .timestamp),
          .init(id: 23, name: "percent_complete", type: .integer),
          .init(id: 24, name: "actual_work", type: .integer),
          .init(id: 25, name: "total_work", type: .integer),
          .init(id: 26, name: "last_modified", type: .integer),
          .init(id: 27, name: "accounting_info", type: .varchar(width: 255)),
          .init(id: 28, name: "kilometers", type: .varchar(width: 255)),
          .init(id: 29, name: "associated_companies", type: .varchar(width: 255)),
          .init(id: 30, name: "associated_contacts", type: .varchar(width: 255)),
          .init(id: 31, name: "timer_date", type: .timestamp),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "job_history", sql: "CREATE TABLE job_history (\n  job_history_id INTEGER /* t_id */,\n  object_version INTEGER /* t_int */,\n  job_id         INTEGER /* t_id */,\n  actor_id       INTEGER /* t_id */,\n  action         VARCHAR(50) /* t_tinystring */, /* Sybase : action */\n  action_date    TIMESTAMP   /* t_datetime */,\n  job_status     VARCHAR(50) /* t_tinystring */,\n  db_status      VARCHAR(50) /* t_tinystring */ \n  ,\n  PRIMARY KEY(job_history_id),\n  CHECK(job_history_id IS NOT NULL),\n  CHECK(job_id         IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "job_history_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "job_id", type: .integer),
          .init(id: 3, name: "actor_id", type: .integer),
          .init(id: 4, name: "action", type: .varchar(width: 50)),
          .init(id: 5, name: "action_date", type: .timestamp),
          .init(id: 6, name: "job_status", type: .varchar(width: 50)),
          .init(id: 7, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "job_history_info", sql: "CREATE TABLE job_history_info (\n  job_history_info_id INTEGER /* t_id */,\n  job_history_id      INTEGER /* t_id */,\n  comment             VARCHAR(1000000), /* Sybase: TEXT */\n  db_status           VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(job_history_info_id),\n  CHECK(job_history_info_id IS NOT NULL),\n  CHECK(job_history_id      IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "job_history_info_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "job_history_id", type: .integer),
          .init(id: 2, name: "comment", type: .varchar(width: 1000000)),
          .init(id: 3, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "job_resource_assignment", sql: "CREATE TABLE job_resource_assignment (\n  job_resource_assignment_id INTEGER /* t_id */,\n  resource_id                INTEGER /* t_id */,\n  job_id                     INTEGER /* t_id */,\n  operative_part             INTEGER /* t_int */,\n  db_status                  VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(job_resource_assignment_id),\n  CHECK(job_resource_assignment_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "job_resource_assignment_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "resource_id", type: .integer),
          .init(id: 2, name: "job_id", type: .integer),
          .init(id: 3, name: "operative_part", type: .integer),
          .init(id: 4, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "news_article", sql: "CREATE TABLE news_article (\n  news_article_id       INTEGER /* t_id */,\n  object_version        INTEGER /* t_int */,\n  name                  VARCHAR(255) /* t_string */, /* Sybase: name */\n  caption               VARCHAR(255) /* t_string */,\n  is_index_article      BOOLEAN /* t_bool */,\n  db_status             VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(news_article_id),\n  CHECK(news_article_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "news_article_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "name", type: .varchar(width: 255)),
          .init(id: 3, name: "caption", type: .varchar(width: 255)),
          .init(id: 4, name: "is_index_article", type: .boolean),
          .init(id: 5, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "news_article_link", sql: "CREATE TABLE news_article_link (\n  news_article_link_id  INTEGER /* t_id */,\n  object_version        INTEGER /* t_int */,\n  news_article_id       INTEGER /* t_id */,\n  sub_news_article_id   INTEGER /* t_id */\n  ,\n  PRIMARY KEY(news_article_link_id),\n  CHECK(news_article_link_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "news_article_link_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "news_article_id", type: .integer),
          .init(id: 3, name: "sub_news_article_id", type: .integer),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "invoice", sql: "CREATE TABLE invoice (\n  invoice_id         INTEGER /* t_id */,\n  debitor_id         INTEGER /* t_id */,\n  object_version     INTEGER /* t_int */,\n  parent_invoice_id  INTEGER /* t_id */,\n  invoice_nr         VARCHAR(255) /* t_string */,\n  invoice_date       TIMESTAMP /* t_datetime */,\n  kind               VARCHAR(50) /* t_smallstring */,\n  status             VARCHAR(50) /* t_smallstring */,\n  net_amount         NUMERIC(19,2) /* t_float */,\n  gross_amount       NUMERIC(19,2) /* t_float */,\n  paid               NUMERIC(19,2) /* t_float */,\n  comment            VARCHAR(2000000000) /* t_text */,\n  db_status          VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(invoice_id),\n  CHECK(invoice_id IS NOT NULL),\n  CHECK(debitor_id IS NOT NULL),\n  CHECK(invoice_nr IS NOT NULL),\n  CHECK(status     IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "invoice_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "debitor_id", type: .integer),
          .init(id: 2, name: "object_version", type: .integer),
          .init(id: 3, name: "parent_invoice_id", type: .integer),
          .init(id: 4, name: "invoice_nr", type: .varchar(width: 255)),
          .init(id: 5, name: "invoice_date", type: .timestamp),
          .init(id: 6, name: "kind", type: .varchar(width: 50)),
          .init(id: 7, name: "status", type: .varchar(width: 50)),
          .init(id: 8, name: "net_amount", type: .custom("NUMERIC(19,2)")),
          .init(id: 9, name: "gross_amount", type: .custom("NUMERIC(19,2)")),
          .init(id: 10, name: "paid", type: .custom("NUMERIC(19,2)")),
          .init(id: 11, name: "comment", type: .varchar(width: 2000000000)),
          .init(id: 12, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "invoice_account", sql: "CREATE TABLE invoice_account (\n  invoice_account_id    INTEGER       /* t_id */,\n  enterprise_id         INTEGER       /* t_id */,\n  account_nr            VARCHAR(50)   /* t_tinystring */,\n  balance               NUMERIC(19,2) /* t_money */,\n  object_version        INTEGER       /* t_int */,\n  db_status             VARCHAR(50)   /* t_tinystring */\n  ,\n  PRIMARY KEY(invoice_account_id),\n  CHECK(invoice_account_id IS NOT NULL),\n  CHECK(enterprise_id IS NOT NULL),\n  CHECK(account_nr IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "invoice_account_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "enterprise_id", type: .integer),
          .init(id: 2, name: "account_nr", type: .varchar(width: 50)),
          .init(id: 3, name: "balance", type: .custom("NUMERIC(19,2)")),
          .init(id: 4, name: "object_version", type: .integer),
          .init(id: 5, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "invoice_action", sql: "CREATE TABLE invoice_action (\n  invoice_action_id     INTEGER /* t_id */,\n  account_id            INTEGER /* t_id */,\n  invoice_id            INTEGER /* t_id */,\n  document_id           INTEGER /* t_id */,\n  action_date           TIMESTAMP /* t_datetime */,\n  action_kind           VARCHAR(50) /* t_smallstring */,\n  log_text              VARCHAR(2000000000) /* t_text */,\n  object_version        INTEGER /* t_int */,\n  db_status             VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY (invoice_action_id),\n  CHECK(invoice_action_id IS NOT NULL),\n  CHECK(account_id IS NOT NULL),\n  CHECK(action_kind IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "invoice_action_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "account_id", type: .integer),
          .init(id: 2, name: "invoice_id", type: .integer),
          .init(id: 3, name: "document_id", type: .integer),
          .init(id: 4, name: "action_date", type: .timestamp),
          .init(id: 5, name: "action_kind", type: .varchar(width: 50)),
          .init(id: 6, name: "log_text", type: .varchar(width: 2000000000)),
          .init(id: 7, name: "object_version", type: .integer),
          .init(id: 8, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "invoice_accounting", sql: "CREATE TABLE invoice_accounting (\n  invoice_accounting_id         INTEGER /* t_id */,\n  action_id                     INTEGER /* t_id */,\n  debit                         NUMERIC(19,2) /* t_money */,\n  balance                       NUMERIC(19,2) /* t_money */,\n  object_version                INTEGER /* t_int */,\n  db_status                     VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(invoice_accounting_id),\n  CHECK(invoice_accounting_id IS NOT NULL),\n  CHECK(action_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "invoice_accounting_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "action_id", type: .integer),
          .init(id: 2, name: "debit", type: .custom("NUMERIC(19,2)")),
          .init(id: 3, name: "balance", type: .custom("NUMERIC(19,2)")),
          .init(id: 4, name: "object_version", type: .integer),
          .init(id: 5, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "article_category", sql: "CREATE TABLE article_category (\n  article_category_id INTEGER      /* t_id */,\n  category_name       VARCHAR(255) /* t_string */,\n  category_abbrev     VARCHAR(255) /* t_string */\n  ,\n  PRIMARY KEY(article_category_id),\n  CHECK(article_category_id IS NOT NULL),\n  CHECK(category_name       IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "article_category_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "category_name", type: .varchar(width: 255)),
          .init(id: 2, name: "category_abbrev", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "article_unit", sql: "CREATE TABLE article_unit (\n  article_unit_id    INTEGER /* t_id */,        \n  format             VARCHAR(50) /* t_tinystring */,\n  singular_unit      VARCHAR(255) /* t_string */,\n  plural_unit        VARCHAR(255) /* t_string */\n  ,\n  PRIMARY KEY(article_unit_id),\n  CHECK(article_unit_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "article_unit_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "format", type: .varchar(width: 50)),
          .init(id: 2, name: "singular_unit", type: .varchar(width: 255)),
          .init(id: 3, name: "plural_unit", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "article", sql: "CREATE TABLE article (\n  article_id          INTEGER /* t_id */,\n  article_unit_id     INTEGER /* t_id */,\n  article_category_id INTEGER /* t_id */,\n  object_version      INTEGER /* t_int */,\n  article_name        VARCHAR(255) /* t_string */,\n  article_nr          VARCHAR(255) /* t_string */,\n  article_text        VARCHAR(2000000000) /* t_text */,      \n  status              VARCHAR(50) /* t_tinystring */,\n  price               NUMERIC(19,2) /* t_float */,\n  vat                 NUMERIC(19,2) /* t_float */,\n  vat_group           VARCHAR(50) /* t_tinystring */,\n  db_status           VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(article_id),\n  CHECK(article_id   IS NOT NULL),\n  CHECK(article_name IS NOT NULL),\n  CHECK(article_nr   IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "article_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "article_unit_id", type: .integer),
          .init(id: 2, name: "article_category_id", type: .integer),
          .init(id: 3, name: "object_version", type: .integer),
          .init(id: 4, name: "article_name", type: .varchar(width: 255)),
          .init(id: 5, name: "article_nr", type: .varchar(width: 255)),
          .init(id: 6, name: "article_text", type: .varchar(width: 2000000000)),
          .init(id: 7, name: "status", type: .varchar(width: 50)),
          .init(id: 8, name: "price", type: .custom("NUMERIC(19,2)")),
          .init(id: 9, name: "vat", type: .custom("NUMERIC(19,2)")),
          .init(id: 10, name: "vat_group", type: .varchar(width: 50)),
          .init(id: 11, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "invoice_article_assignment", sql: "CREATE TABLE invoice_article_assignment (\n  invoice_article_assignment_id INTEGER /* t_id */,\n  invoice_id                    INTEGER /* t_id */,\n  article_id                    INTEGER /* t_id */,\n  article_count                 INTEGER /* t_id */,\n  object_version                INTEGER /* t_int */,  \n  net_amount                    NUMERIC(19,2) /* t_float */,\n  vat                           NUMERIC(19,2) /* t_float */,\n  comment                       VARCHAR(2000000000) /* t_text */,\n  db_status                     VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY(invoice_article_assignment_id),\n  CHECK(invoice_article_assignment_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "invoice_article_assignment_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "invoice_id", type: .integer),
          .init(id: 2, name: "article_id", type: .integer),
          .init(id: 3, name: "article_count", type: .integer),
          .init(id: 4, name: "object_version", type: .integer),
          .init(id: 5, name: "net_amount", type: .custom("NUMERIC(19,2)")),
          .init(id: 6, name: "vat", type: .custom("NUMERIC(19,2)")),
          .init(id: 7, name: "comment", type: .varchar(width: 2000000000)),
          .init(id: 8, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "resource", sql: "CREATE TABLE resource (\n  resource_id         INTEGER /* t_id */,\n  resource_name       VARCHAR(255) /* t_string */,\n  token               VARCHAR(255) /* t_string */,\n  object_id           INTEGER /* t_id */,\n  quantity            INTEGER /* t_int */,\n  comment             VARCHAR(2000000000) /* t_text */, /*(oracle: ocomment)*/\n  standard_costs      NUMERIC(19,2) /* t_price */,\n  type                INTEGER /* t_int */,\n  db_status           VARCHAR(50) /* t_tinystring */,\n  object_version      INTEGER /* t_int */\n  ,\n  PRIMARY KEY(resource_id),\n  CHECK(resource_id   IS NOT NULL),\n  CHECK(resource_name IS NOT NULL),\n  CHECK(type          IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "resource_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "resource_name", type: .varchar(width: 255)),
          .init(id: 2, name: "token", type: .varchar(width: 255)),
          .init(id: 3, name: "object_id", type: .integer),
          .init(id: 4, name: "quantity", type: .integer),
          .init(id: 5, name: "comment", type: .varchar(width: 2000000000)),
          .init(id: 6, name: "standard_costs", type: .custom("NUMERIC(19,2)")),
          .init(id: 7, name: "type", type: .integer),
          .init(id: 8, name: "db_status", type: .varchar(width: 50)),
          .init(id: 9, name: "object_version", type: .integer),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "resource_assignment", sql: "CREATE TABLE resource_assignment (\n  resource_assignment_id INTEGER     /* t_id */,\n  super_resource_id      INTEGER     /* t_id */,\n  sub_resource_id        INTEGER     /* t_id */,\n  db_status              VARCHAR(50) /* t_tinystring */\n  ,\n  PRIMARY KEY (resource_assignment_id),\n  CHECK(resource_assignment_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "resource_assignment_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "super_resource_id", type: .integer),
          .init(id: 2, name: "sub_resource_id", type: .integer),
          .init(id: 3, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "job_assignment", sql: "CREATE TABLE job_assignment (\n  job_assignment_id     INTEGER /* t_id */,\n  parent_job_id         INTEGER     /* t_id */,\n  child_job_id          INTEGER     /* t_id */,\n  db_status             VARCHAR(50) /* t_tinystring */,\n  assignment_kind       VARCHAR(50) /* t_tinystring */,\n  fposition             INTEGER     /* t_int */\n  ,\n  PRIMARY KEY(job_assignment_id),\n  CHECK(job_assignment_id IS NOT NULL),\n  CHECK(parent_job_id     IS NOT NULL),\n  CHECK(child_job_id      IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "job_assignment_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "parent_job_id", type: .integer),
          .init(id: 2, name: "child_job_id", type: .integer),
          .init(id: 3, name: "db_status", type: .varchar(width: 50)),
          .init(id: 4, name: "assignment_kind", type: .varchar(width: 50)),
          .init(id: 5, name: "fposition", type: .integer),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "project_info", sql: "CREATE TABLE project_info (\n  project_info_id INTEGER             /* t_id */,\n  project_id      INTEGER             /* t_id */, \n  comment         VARCHAR(2000000000) /* t_text */,\n  db_status       VARCHAR(50)         /* t_tinystring */\n  ,\n  PRIMARY KEY(project_info_id),\n  CHECK(project_id IS NOT NULL),\n  CHECK(project_info_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "project_info_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "project_id", type: .integer),
          .init(id: 2, name: "comment", type: .varchar(width: 2000000000)),
          .init(id: 3, name: "db_status", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "obj_property", sql: "CREATE TABLE obj_property (\n  obj_property_id    INTEGER      /* t_id */,\n  obj_id             INTEGER      /* t_id */,\n  obj_type           VARCHAR(255) /* t_string */,\n  access_key         INTEGER      /* t_id */,\n  value_key          VARCHAR(255) /* t_string */,\n  namespace_prefix   VARCHAR(255) /* t_string */,\n  preferred_type     VARCHAR(255) /* t_string */,\n  value_string       VARCHAR(2000000),\n  value_int          INTEGER       /* t_int */,\n  value_float        NUMERIC(19,2) /* t_float */,\n  value_date         TIMESTAMP     /* t_datetime */,\n  value_oid          VARCHAR(255)  /* t_string */,\n  blob_size          INTEGER       /* t_int */,\n  value_blob         BLOB          /* t_image */\n  ,\n  PRIMARY KEY (obj_property_id),\n  CHECK(obj_property_id IS NOT NULL),\n  CHECK(obj_id          IS NOT NULL),\n  CHECK(value_key       IS NOT NULL),\n  CHECK(preferred_type  IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "obj_property_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "obj_id", type: .integer),
          .init(id: 2, name: "obj_type", type: .varchar(width: 255)),
          .init(id: 3, name: "access_key", type: .integer),
          .init(id: 4, name: "value_key", type: .varchar(width: 255)),
          .init(id: 5, name: "namespace_prefix", type: .varchar(width: 255)),
          .init(id: 6, name: "preferred_type", type: .varchar(width: 255)),
          .init(id: 7, name: "value_string", type: .varchar(width: 2000000)),
          .init(id: 8, name: "value_int", type: .integer),
          .init(id: 9, name: "value_float", type: .custom("NUMERIC(19,2)")),
          .init(id: 10, name: "value_date", type: .timestamp),
          .init(id: 11, name: "value_oid", type: .varchar(width: 255)),
          .init(id: 12, name: "blob_size", type: .integer),
          .init(id: 13, name: "value_blob", type: .blob),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "obj_info", sql: "CREATE TABLE obj_info (\n  obj_id             INTEGER      /* t_id */,\n  obj_type           VARCHAR(255) /* t_string */\n  ,\n  PRIMARY KEY (obj_id),\n  CHECK(obj_id   IS NOT NULL),\n  CHECK(obj_type IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "obj_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "obj_type", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "object_acl", sql: "CREATE TABLE object_acl (\n  object_acl_id INTEGER NOT NULL  /* t_id */,\n  sort_key      INTEGER NOT NULL  /* t_int */,\n  action        VARCHAR(10) NOT NULL  /* t_tinieststring */,\n  object_id     INTEGER NOT NULL,\n  auth_id       INTEGER NOT NULL,\n  permissions   VARCHAR(50)  /* t_tinystring */\n  ,\n  PRIMARY KEY (object_acl_id),\n  CHECK(sort_key  IS NOT NULL),\n  CHECK(action    IS NOT NULL),\n  CHECK(object_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "object_acl_id", type: .integer, isNotNull: true, isPrimaryKey: true),
          .init(id: 1, name: "sort_key", type: .integer, isNotNull: true),
          .init(id: 2, name: "action", type: .varchar(width: 10), isNotNull: true),
          .init(id: 3, name: "object_id", type: .integer, isNotNull: true),
          .init(id: 4, name: "auth_id", type: .integer, isNotNull: true),
          .init(id: 5, name: "permissions", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "palm_address", sql: "CREATE TABLE palm_address (\n  company_id                    INTEGER /* t_id */,\n  device_id                     VARCHAR(50) /* t_smallstring */,\n  palm_address_id               INTEGER /* t_id */,\n  palm_id                       INTEGER /* t_id */,\n  category_index                INTEGER /* t_int */,\n  is_deleted                    BOOLEAN /* t_bool */,\n  is_modified                   BOOLEAN /* t_bool */,\n  is_archived                   BOOLEAN /* t_bool */,\n  is_new                        BOOLEAN /* t_bool */,\n  is_private                    BOOLEAN /* t_bool */,\n  md5hash                       VARCHAR(50) /* t_tinystring */,\n  address                       VARCHAR(255) /* t_string */,\n  city                          VARCHAR(255) /* t_string */,\n  company                       VARCHAR(255) /* t_string */,\n  country                       VARCHAR(255) /* t_string */,\n  display_phone                 INTEGER      /* t_int */,\n  firstname                     VARCHAR(255) /* t_string */,\n  lastname                      VARCHAR(255) /* t_string */,\n  note                          VARCHAR(2000000000) /* t_text */,\n  phone0                        VARCHAR(255) /* t_string */,\n  phone1                        VARCHAR(255) /* t_string */,\n  phone2                        VARCHAR(255) /* t_string */,\n  phone3                        VARCHAR(255) /* t_string */,\n  phone4                        VARCHAR(255) /* t_string */,\n  phone_label_id0               INTEGER      /* t_int */,\n  phone_label_id1               INTEGER      /* t_int */,\n  phone_label_id2               INTEGER      /* t_int */,\n  phone_label_id3               INTEGER      /* t_int */,\n  phone_label_id4               INTEGER      /* t_int */,\n  state                         VARCHAR(255) /* t_string */,\n  title                         VARCHAR(255) /* t_string */,\n  zipcode                       VARCHAR(255) /* t_string */,\n  custom1                       VARCHAR(255) /* t_string */,\n  custom2                       VARCHAR(255) /* t_string */,\n  custom3                       VARCHAR(255) /* t_string */,\n  custom4                       VARCHAR(255) /* t_string */,\n  skyrix_id                     INTEGER      /* t_id */,\n  skyrix_sync                   INTEGER      /* t_int */,\n  skyrix_version                INTEGER      /* t_int */,\n  skyrix_type                   VARCHAR(50)  /* t_tinystring */\n  ,\n  PRIMARY KEY (palm_address_id),\n  CHECK(company_id           IS NOT NULL),\n  CHECK(device_id            IS NOT NULL),\n  CHECK(palm_address_id      IS NOT NULL),\n  CHECK(is_deleted           IS NOT NULL),\n  CHECK(is_modified          IS NOT NULL),\n  CHECK(is_archived          IS NOT NULL),\n  CHECK(is_new               IS NOT NULL),\n  CHECK(is_private           IS NOT NULL),\n  CHECK(md5hash              IS NOT NULL),\n  CHECK(display_phone        IS NOT NULL),\n  CHECK(phone_label_id0      IS NOT NULL),\n  CHECK(phone_label_id1      IS NOT NULL),\n  CHECK(phone_label_id2      IS NOT NULL),\n  CHECK(phone_label_id3      IS NOT NULL),\n  CHECK(phone_label_id4      IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer),
          .init(id: 1, name: "device_id", type: .varchar(width: 50)),
          .init(id: 2, name: "palm_address_id", type: .integer, isPrimaryKey: true),
          .init(id: 3, name: "palm_id", type: .integer),
          .init(id: 4, name: "category_index", type: .integer),
          .init(id: 5, name: "is_deleted", type: .boolean),
          .init(id: 6, name: "is_modified", type: .boolean),
          .init(id: 7, name: "is_archived", type: .boolean),
          .init(id: 8, name: "is_new", type: .boolean),
          .init(id: 9, name: "is_private", type: .boolean),
          .init(id: 10, name: "md5hash", type: .varchar(width: 50)),
          .init(id: 11, name: "address", type: .varchar(width: 255)),
          .init(id: 12, name: "city", type: .varchar(width: 255)),
          .init(id: 13, name: "company", type: .varchar(width: 255)),
          .init(id: 14, name: "country", type: .varchar(width: 255)),
          .init(id: 15, name: "display_phone", type: .integer),
          .init(id: 16, name: "firstname", type: .varchar(width: 255)),
          .init(id: 17, name: "lastname", type: .varchar(width: 255)),
          .init(id: 18, name: "note", type: .varchar(width: 2000000000)),
          .init(id: 19, name: "phone0", type: .varchar(width: 255)),
          .init(id: 20, name: "phone1", type: .varchar(width: 255)),
          .init(id: 21, name: "phone2", type: .varchar(width: 255)),
          .init(id: 22, name: "phone3", type: .varchar(width: 255)),
          .init(id: 23, name: "phone4", type: .varchar(width: 255)),
          .init(id: 24, name: "phone_label_id0", type: .integer),
          .init(id: 25, name: "phone_label_id1", type: .integer),
          .init(id: 26, name: "phone_label_id2", type: .integer),
          .init(id: 27, name: "phone_label_id3", type: .integer),
          .init(id: 28, name: "phone_label_id4", type: .integer),
          .init(id: 29, name: "state", type: .varchar(width: 255)),
          .init(id: 30, name: "title", type: .varchar(width: 255)),
          .init(id: 31, name: "zipcode", type: .varchar(width: 255)),
          .init(id: 32, name: "custom1", type: .varchar(width: 255)),
          .init(id: 33, name: "custom2", type: .varchar(width: 255)),
          .init(id: 34, name: "custom3", type: .varchar(width: 255)),
          .init(id: 35, name: "custom4", type: .varchar(width: 255)),
          .init(id: 36, name: "skyrix_id", type: .integer),
          .init(id: 37, name: "skyrix_sync", type: .integer),
          .init(id: 38, name: "skyrix_version", type: .integer),
          .init(id: 39, name: "skyrix_type", type: .varchar(width: 50)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "palm_date", sql: "CREATE TABLE palm_date (\n  company_id                    INTEGER /* t_id */,\n  device_id                     VARCHAR(50) /* t_smallstring */,\n  palm_date_id                  INTEGER /* t_id */,\n  palm_id                       INTEGER /* t_id */,\n  category_index                INTEGER /* t_int */,\n  is_deleted                    BOOLEAN /* t_bool */,\n  is_modified                   BOOLEAN /* t_bool */,\n  is_archived                   BOOLEAN /* t_bool */,\n  is_new                        BOOLEAN /* t_bool */,\n  is_private                    BOOLEAN /* t_bool */,\n  md5hash                       VARCHAR(50) /* t_tinystring */,\n  alarm_advance_time            INTEGER /* t_int */,\n  alarm_advance_unit            INTEGER /* t_int */,\n  description                   VARCHAR(255) /* t_string */,\n  enddate                       TIMESTAMP /* t_datetime */,\n  is_alarmed                    BOOLEAN /* t_bool */,\n  is_untimed                    BOOLEAN /* t_bool */,\n  note                          VARCHAR(2000000000) /* t_text */,\n  repeat_enddate                TIMESTAMP /* t_datetime */,\n  repeat_frequency              INTEGER /* t_int */,\n  repeat_on                     INTEGER /* t_int */,\n  repeat_start_week             INTEGER /* t_int */,\n  repeat_type                   INTEGER /* t_int */,\n  startdate                     TIMESTAMP /* t_datetime */,\n  exceptions                    VARCHAR(2000000000) /* t_text */,\n  skyrix_id                     INTEGER /* t_id */,\n  skyrix_sync                   INTEGER /* t_int */,\n  skyrix_version                INTEGER /* t_int */\n  ,\n  PRIMARY KEY(palm_date_id),\n  CHECK(company_id              IS NOT NULL),\n  CHECK(device_id               IS NOT NULL),\n  CHECK(palm_date_id            IS NOT NULL),\n  CHECK(is_deleted              IS NOT NULL),\n  CHECK(is_modified             IS NOT NULL),\n  CHECK(is_archived             IS NOT NULL),\n  CHECK(is_new                  IS NOT NULL),\n  CHECK(is_private              IS NOT NULL),\n  CHECK(md5hash                 IS NOT NULL),\n  CHECK(alarm_advance_time      IS NOT NULL),\n  CHECK(alarm_advance_unit      IS NOT NULL),\n  CHECK(description             IS NOT NULL),\n  CHECK(is_alarmed              IS NOT NULL),\n  CHECK(is_untimed              IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer),
          .init(id: 1, name: "device_id", type: .varchar(width: 50)),
          .init(id: 2, name: "palm_date_id", type: .integer, isPrimaryKey: true),
          .init(id: 3, name: "palm_id", type: .integer),
          .init(id: 4, name: "category_index", type: .integer),
          .init(id: 5, name: "is_deleted", type: .boolean),
          .init(id: 6, name: "is_modified", type: .boolean),
          .init(id: 7, name: "is_archived", type: .boolean),
          .init(id: 8, name: "is_new", type: .boolean),
          .init(id: 9, name: "is_private", type: .boolean),
          .init(id: 10, name: "md5hash", type: .varchar(width: 50)),
          .init(id: 11, name: "alarm_advance_time", type: .integer),
          .init(id: 12, name: "alarm_advance_unit", type: .integer),
          .init(id: 13, name: "description", type: .varchar(width: 255)),
          .init(id: 14, name: "enddate", type: .timestamp),
          .init(id: 15, name: "is_alarmed", type: .boolean),
          .init(id: 16, name: "is_untimed", type: .boolean),
          .init(id: 17, name: "note", type: .varchar(width: 2000000000)),
          .init(id: 18, name: "repeat_enddate", type: .timestamp),
          .init(id: 19, name: "repeat_frequency", type: .integer),
          .init(id: 20, name: "repeat_on", type: .integer),
          .init(id: 21, name: "repeat_start_week", type: .integer),
          .init(id: 22, name: "repeat_type", type: .integer),
          .init(id: 23, name: "startdate", type: .timestamp),
          .init(id: 24, name: "exceptions", type: .varchar(width: 2000000000)),
          .init(id: 25, name: "skyrix_id", type: .integer),
          .init(id: 26, name: "skyrix_sync", type: .integer),
          .init(id: 27, name: "skyrix_version", type: .integer),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "palm_memo", sql: "CREATE TABLE palm_memo (\n  company_id                    INTEGER /* t_id */,\n  device_id                     VARCHAR(50) /* t_smallstring */,\n  palm_memo_id                  INTEGER /* t_id */,\n  palm_id                       INTEGER /* t_id */,\n  category_index                INTEGER /* t_int */,\n  is_deleted                    BOOLEAN /* t_bool */,\n  is_modified                   BOOLEAN /* t_bool */,\n  is_archived                   BOOLEAN /* t_bool */,\n  is_new                        BOOLEAN /* t_bool */,\n  is_private                    BOOLEAN /* t_bool */,\n  md5hash                       VARCHAR(50) /* t_tinystring */,\n  memo                          VARCHAR(2000000000) /* t_text */,\n  skyrix_id                     INTEGER /* t_id */,\n  skyrix_sync                   INTEGER /* t_int */,\n  skyrix_version                INTEGER /* t_int */\n  ,\n  PRIMARY KEY(palm_memo_id),\n  CHECK(company_id              IS NOT NULL),\n  CHECK(device_id               IS NOT NULL),\n  CHECK(palm_memo_id            IS NOT NULL),\n  CHECK(is_deleted              IS NOT NULL),\n  CHECK(is_modified             IS NOT NULL),\n  CHECK(is_archived             IS NOT NULL),\n  CHECK(is_new                  IS NOT NULL),\n  CHECK(is_private              IS NOT NULL),\n  CHECK(md5hash                 IS NOT NULL),\n  CHECK(memo                    IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer),
          .init(id: 1, name: "device_id", type: .varchar(width: 50)),
          .init(id: 2, name: "palm_memo_id", type: .integer, isPrimaryKey: true),
          .init(id: 3, name: "palm_id", type: .integer),
          .init(id: 4, name: "category_index", type: .integer),
          .init(id: 5, name: "is_deleted", type: .boolean),
          .init(id: 6, name: "is_modified", type: .boolean),
          .init(id: 7, name: "is_archived", type: .boolean),
          .init(id: 8, name: "is_new", type: .boolean),
          .init(id: 9, name: "is_private", type: .boolean),
          .init(id: 10, name: "md5hash", type: .varchar(width: 50)),
          .init(id: 11, name: "memo", type: .varchar(width: 2000000000)),
          .init(id: 12, name: "skyrix_id", type: .integer),
          .init(id: 13, name: "skyrix_sync", type: .integer),
          .init(id: 14, name: "skyrix_version", type: .integer),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "palm_todo", sql: "CREATE TABLE palm_todo (\n  company_id                    INTEGER /* t_id */,\n  device_id                     VARCHAR(50) /* t_smallstring */,\n  palm_todo_id                  INTEGER /* t_id */,\n  palm_id                       INTEGER /* t_id */,\n  category_index                INTEGER /* t_int */,\n  is_deleted                    BOOLEAN /* t_bool */,\n  is_modified                   BOOLEAN /* t_bool */,\n  is_archived                   BOOLEAN /* t_bool */,\n  is_new                        BOOLEAN /* t_bool */,\n  is_private                    BOOLEAN /* t_bool */,\n  md5hash                       VARCHAR(50) /* t_tinystring */,\n  description                   VARCHAR(255) /* t_string */,\n  duedate                       TIMESTAMP /* t_datetime */,\n  note                          VARCHAR(2000000000) /* t_text */,\n  priority                      INTEGER /* t_int */,\n  is_completed                  BOOLEAN /* t_bool */,\n  skyrix_id                     INTEGER /* t_id */,\n  skyrix_sync                   INTEGER /* t_int */,\n  skyrix_version                INTEGER /* t_int */\n  ,\n  PRIMARY KEY(palm_todo_id),\n  CHECK(company_id              IS NOT NULL),\n  CHECK(device_id               IS NOT NULL),\n  CHECK(palm_todo_id            IS NOT NULL),\n  CHECK(is_deleted              IS NOT NULL),\n  CHECK(is_modified             IS NOT NULL),\n  CHECK(is_archived             IS NOT NULL),\n  CHECK(is_new                  IS NOT NULL),\n  CHECK(is_private              IS NOT NULL),\n  CHECK(md5hash                 IS NOT NULL),\n  CHECK(description             IS NOT NULL),\n  CHECK(priority                IS NOT NULL),\n  CHECK(is_completed            IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer),
          .init(id: 1, name: "device_id", type: .varchar(width: 50)),
          .init(id: 2, name: "palm_todo_id", type: .integer, isPrimaryKey: true),
          .init(id: 3, name: "palm_id", type: .integer),
          .init(id: 4, name: "category_index", type: .integer),
          .init(id: 5, name: "is_deleted", type: .boolean),
          .init(id: 6, name: "is_modified", type: .boolean),
          .init(id: 7, name: "is_archived", type: .boolean),
          .init(id: 8, name: "is_new", type: .boolean),
          .init(id: 9, name: "is_private", type: .boolean),
          .init(id: 10, name: "md5hash", type: .varchar(width: 50)),
          .init(id: 11, name: "description", type: .varchar(width: 255)),
          .init(id: 12, name: "duedate", type: .timestamp),
          .init(id: 13, name: "note", type: .varchar(width: 2000000000)),
          .init(id: 14, name: "priority", type: .integer),
          .init(id: 15, name: "is_completed", type: .boolean),
          .init(id: 16, name: "skyrix_id", type: .integer),
          .init(id: 17, name: "skyrix_sync", type: .integer),
          .init(id: 18, name: "skyrix_version", type: .integer),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "palm_category", sql: "CREATE TABLE palm_category (\n  company_id                    INTEGER      /* t_id */,\n  device_id                     VARCHAR(50)  /* t_smallstring */,\n  palm_category_id              INTEGER      /* t_id */,\n  palm_id                       INTEGER      /* t_id */,\n  palm_table                    VARCHAR(50)  /* t_tinystring */,\n  is_modified                   BOOLEAN      /* t_bool */,\n  md5hash                       VARCHAR(50)  /* t_tinystring */,\n  category_index                INTEGER      /* t_int */,\n  category_name                 VARCHAR(255) /* t_string */\n  ,\n  PRIMARY KEY(palm_category_id),\n  CHECK(company_id          IS NOT NULL),\n  CHECK(palm_category_id    IS NOT NULL),\n  CHECK(palm_table          IS NOT NULL),\n  CHECK(is_modified         IS NOT NULL),\n  CHECK(md5hash             IS NOT NULL),\n  CHECK(category_index      IS NOT NULL),\n  CHECK(category_name       IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer),
          .init(id: 1, name: "device_id", type: .varchar(width: 50)),
          .init(id: 2, name: "palm_category_id", type: .integer, isPrimaryKey: true),
          .init(id: 3, name: "palm_id", type: .integer),
          .init(id: 4, name: "palm_table", type: .varchar(width: 50)),
          .init(id: 5, name: "is_modified", type: .boolean),
          .init(id: 6, name: "md5hash", type: .varchar(width: 50)),
          .init(id: 7, name: "category_index", type: .integer),
          .init(id: 8, name: "category_name", type: .varchar(width: 255)),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "ctags", sql: "CREATE TABLE ctags (\n  entity VARCHAR NOT NULL,\n  ctag  INTEGER NOT NULL DEFAULT 0\n)"),
        columns: [
          .init(id: 0, name: "entity", type: .varchar(width: nil), isNotNull: true),
          .init(id: 1, name: "ctag", type: .integer, isNotNull: true, defaultValue: .text("0")),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "login_token", sql: "CREATE TABLE login_token (\n  token           VARCHAR(4096) PRIMARY KEY,\n  account_id      INT   NOT NULL,\n  environment     TEXT  NULL,\n  info            TEXT  NULL,\n\n  creation_date   TIMESTAMP WITH TIME ZONE /*DEFAULT NOW()*/ NOT NULL,\n  touch_date      TIMESTAMP WITH TIME ZONE /*DEFAULT NOW()*/ NOT NULL,\n\n  timeout         INT DEFAULT 3600 NOT NULL,\n  expiration_date TIMESTAMP WITH TIME ZONE NULL\n)"),
        columns: [
          .init(id: 0, name: "token", type: .varchar(width: 4096), isPrimaryKey: true),
          .init(id: 1, name: "account_id", type: .integer, isNotNull: true),
          .init(id: 2, name: "environment"),
          .init(id: 3, name: "info"),
          .init(id: 4, name: "creation_date", type: .custom("TIMESTAMP WITH TIME ZONE"), isNotNull: true),
          .init(id: 5, name: "touch_date", type: .custom("TIMESTAMP WITH TIME ZONE"), isNotNull: true),
          .init(id: 6, name: "timeout", type: .integer, isNotNull: true, defaultValue: .text("3600")),
          .init(id: 7, name: "expiration_date", type: .custom("TIMESTAMP WITH TIME ZONE")),
        ]
      ),
      Schema.Table(
        info: .init(type: .table, name: "company_assignment", sql: "CREATE TABLE company_assignment (\n  company_assignment_id INTEGER      /* t_id */,\n  company_id            INTEGER      /* t_id */,\n  sub_company_id        INTEGER      /* t_id */,\n  is_headquarter        BOOLEAN      /* t_bool */,\n  is_chief              BOOLEAN      /* t_bool */,\n  function              VARCHAR(255) /* t_string */, /* sybase: function */\n  db_status             VARCHAR(50)  /* t_tinystring */\n  ,\n  start_date         timestamp with time zone,\n  end_date           timestamp with time zone\n  ,\n  PRIMARY KEY(company_assignment_id),\n  CHECK(company_assignment_id IS NOT NULL)\n)"),
        columns: [
          .init(id: 0, name: "company_assignment_id", type: .integer, isPrimaryKey: true),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "sub_company_id", type: .integer),
          .init(id: 3, name: "is_headquarter", type: .boolean),
          .init(id: 4, name: "is_chief", type: .boolean),
          .init(id: 5, name: "function", type: .varchar(width: 255)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
    ],
    views: [
      Schema.View(
        info: .init(type: .view, name: "person", sql: "CREATE VIEW person AS \n  SELECT company_id, owner_id, contact_id, template_user_id, \n         number, description, priority, keywords, name,\n         middlename, firstname, salutation, degree, is_private, is_readonly,\n         birthday, url, sex, is_person, login, password, is_locked, \n         pop3_account, is_account, is_intra_account, is_extra_account, \n         is_customer, db_status, object_version, is_template_user, \n         can_change_password, source_url, sensitivity, boss_name, partner_name,\n         assistant_name, department, office, occupation, anniversary,\n         dir_server, email_alias, freebusy_url, fileas, name_title,\n         name_affix, im_address, associated_contacts, associated_categories,\n         associated_company, show_email_as, show_email2_as, show_email3_as\n  FROM company\n  WHERE is_person     =  1    AND \n        is_enterprise IS NULL AND \n        is_trust      IS NULL AND \n        is_team       IS NULL"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer),
          .init(id: 1, name: "owner_id", type: .integer),
          .init(id: 2, name: "contact_id", type: .integer),
          .init(id: 3, name: "template_user_id", type: .integer),
          .init(id: 4, name: "number", type: .varchar(width: 50)),
          .init(id: 5, name: "description", type: .varchar(width: 255)),
          .init(id: 6, name: "priority", type: .varchar(width: 50)),
          .init(id: 7, name: "keywords", type: .varchar(width: 255)),
          .init(id: 8, name: "name", type: .varchar(width: 50)),
          .init(id: 9, name: "middlename", type: .varchar(width: 50)),
          .init(id: 10, name: "firstname", type: .varchar(width: 50)),
          .init(id: 11, name: "salutation", type: .varchar(width: 50)),
          .init(id: 12, name: "degree", type: .varchar(width: 50)),
          .init(id: 13, name: "is_private", type: .boolean),
          .init(id: 14, name: "is_readonly", type: .boolean),
          .init(id: 15, name: "birthday", type: .timestamp),
          .init(id: 16, name: "url", type: .varchar(width: 255)),
          .init(id: 17, name: "sex", type: .varchar(width: 10)),
          .init(id: 18, name: "is_person", type: .boolean),
          .init(id: 19, name: "login", type: .varchar(width: 50)),
          .init(id: 20, name: "password", type: .varchar(width: 50)),
          .init(id: 21, name: "is_locked", type: .boolean),
          .init(id: 22, name: "pop3_account", type: .varchar(width: 50)),
          .init(id: 23, name: "is_account", type: .boolean),
          .init(id: 24, name: "is_intra_account", type: .boolean),
          .init(id: 25, name: "is_extra_account", type: .boolean),
          .init(id: 26, name: "is_customer", type: .boolean),
          .init(id: 27, name: "db_status", type: .varchar(width: 50)),
          .init(id: 28, name: "object_version", type: .integer),
          .init(id: 29, name: "is_template_user", type: .boolean),
          .init(id: 30, name: "can_change_password", type: .boolean),
          .init(id: 31, name: "source_url", type: .custom("varchar(255)")),
          .init(id: 32, name: "sensitivity", type: .integer),
          .init(id: 33, name: "boss_name", type: .varchar(width: 255)),
          .init(id: 34, name: "partner_name", type: .varchar(width: 255)),
          .init(id: 35, name: "assistant_name", type: .varchar(width: 255)),
          .init(id: 36, name: "department", type: .varchar(width: 255)),
          .init(id: 37, name: "office", type: .varchar(width: 255)),
          .init(id: 38, name: "occupation", type: .varchar(width: 255)),
          .init(id: 39, name: "anniversary", type: .timestamp),
          .init(id: 40, name: "dir_server", type: .varchar(width: 255)),
          .init(id: 41, name: "email_alias", type: .varchar(width: 255)),
          .init(id: 42, name: "freebusy_url", type: .varchar(width: 255)),
          .init(id: 43, name: "fileas", type: .varchar(width: 255)),
          .init(id: 44, name: "name_title", type: .varchar(width: 255)),
          .init(id: 45, name: "name_affix", type: .varchar(width: 255)),
          .init(id: 46, name: "im_address", type: .varchar(width: 255)),
          .init(id: 47, name: "associated_contacts", type: .varchar(width: 255)),
          .init(id: 48, name: "associated_categories", type: .varchar(width: 255)),
          .init(id: 49, name: "associated_company", type: .varchar(width: 255)),
          .init(id: 50, name: "show_email_as", type: .varchar(width: 255)),
          .init(id: 51, name: "show_email2_as", type: .varchar(width: 255)),
          .init(id: 52, name: "show_email3_as", type: .varchar(width: 255)),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "enterprise", sql: "CREATE VIEW enterprise AS \n  SELECT company_id, owner_id, contact_id, number, description, priority, \n         keywords, url, email, login, bank, bank_code, account,\n         is_enterprise, db_status, is_customer, is_private, is_readonly,\n         object_version, source_url, sensitivity, boss_name, partner_name,\n         assistant_name, department, office, occupation, anniversary,\n         dir_server, email_alias, freebusy_url, fileas, name_title,\n         name_affix, im_address, associated_contacts, associated_categories,\n         associated_company, show_email_as, show_email2_as, show_email3_as,\n         birthday, firstname\n  FROM company \n  WHERE is_person     IS NULL AND \n        is_enterprise =  1    AND\n        is_trust      IS NULL AND\n        is_team       IS NULL"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer),
          .init(id: 1, name: "owner_id", type: .integer),
          .init(id: 2, name: "contact_id", type: .integer),
          .init(id: 3, name: "number", type: .varchar(width: 50)),
          .init(id: 4, name: "description", type: .varchar(width: 255)),
          .init(id: 5, name: "priority", type: .varchar(width: 50)),
          .init(id: 6, name: "keywords", type: .varchar(width: 255)),
          .init(id: 7, name: "url", type: .varchar(width: 255)),
          .init(id: 8, name: "email", type: .varchar(width: 50)),
          .init(id: 9, name: "login", type: .varchar(width: 50)),
          .init(id: 10, name: "bank", type: .varchar(width: 50)),
          .init(id: 11, name: "bank_code", type: .varchar(width: 50)),
          .init(id: 12, name: "account", type: .varchar(width: 50)),
          .init(id: 13, name: "is_enterprise", type: .boolean),
          .init(id: 14, name: "db_status", type: .varchar(width: 50)),
          .init(id: 15, name: "is_customer", type: .boolean),
          .init(id: 16, name: "is_private", type: .boolean),
          .init(id: 17, name: "is_readonly", type: .boolean),
          .init(id: 18, name: "object_version", type: .integer),
          .init(id: 19, name: "source_url", type: .custom("varchar(255)")),
          .init(id: 20, name: "sensitivity", type: .integer),
          .init(id: 21, name: "boss_name", type: .varchar(width: 255)),
          .init(id: 22, name: "partner_name", type: .varchar(width: 255)),
          .init(id: 23, name: "assistant_name", type: .varchar(width: 255)),
          .init(id: 24, name: "department", type: .varchar(width: 255)),
          .init(id: 25, name: "office", type: .varchar(width: 255)),
          .init(id: 26, name: "occupation", type: .varchar(width: 255)),
          .init(id: 27, name: "anniversary", type: .timestamp),
          .init(id: 28, name: "dir_server", type: .varchar(width: 255)),
          .init(id: 29, name: "email_alias", type: .varchar(width: 255)),
          .init(id: 30, name: "freebusy_url", type: .varchar(width: 255)),
          .init(id: 31, name: "fileas", type: .varchar(width: 255)),
          .init(id: 32, name: "name_title", type: .varchar(width: 255)),
          .init(id: 33, name: "name_affix", type: .varchar(width: 255)),
          .init(id: 34, name: "im_address", type: .varchar(width: 255)),
          .init(id: 35, name: "associated_contacts", type: .varchar(width: 255)),
          .init(id: 36, name: "associated_categories", type: .varchar(width: 255)),
          .init(id: 37, name: "associated_company", type: .varchar(width: 255)),
          .init(id: 38, name: "show_email_as", type: .varchar(width: 255)),
          .init(id: 39, name: "show_email2_as", type: .varchar(width: 255)),
          .init(id: 40, name: "show_email3_as", type: .varchar(width: 255)),
          .init(id: 41, name: "birthday", type: .timestamp),
          .init(id: 42, name: "firstname", type: .varchar(width: 50)),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "trust", sql: "CREATE VIEW trust AS \n  SELECT company_id, owner_id, contact_id, number, is_private, is_readonly,\n         description, priority, keywords, url, email, is_trust, db_status,\n         object_version\n  FROM company \n  WHERE is_person     IS NULL AND \n        is_enterprise IS NULL AND\n        is_trust      =  1    AND\n        is_team       IS NULL"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer),
          .init(id: 1, name: "owner_id", type: .integer),
          .init(id: 2, name: "contact_id", type: .integer),
          .init(id: 3, name: "number", type: .varchar(width: 50)),
          .init(id: 4, name: "is_private", type: .boolean),
          .init(id: 5, name: "is_readonly", type: .boolean),
          .init(id: 6, name: "description", type: .varchar(width: 255)),
          .init(id: 7, name: "priority", type: .varchar(width: 50)),
          .init(id: 8, name: "keywords", type: .varchar(width: 255)),
          .init(id: 9, name: "url", type: .varchar(width: 255)),
          .init(id: 10, name: "email", type: .varchar(width: 50)),
          .init(id: 11, name: "is_trust", type: .boolean),
          .init(id: 12, name: "db_status", type: .varchar(width: 50)),
          .init(id: 13, name: "object_version", type: .integer),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "team", sql: "CREATE VIEW team AS \n  SELECT company_id, owner_id, contact_id, number, login, email,\n         description, is_team, is_location_team, db_status, object_version,\n         sensitivity, boss_name, partner_name, assistant_name, department, \n         office, occupation, anniversary, dir_server, email_alias, \n         freebusy_url, fileas, name_title,\n         name_affix, im_address, associated_contacts, associated_categories,\n         associated_company\n\n  FROM company \n  WHERE is_person     IS NULL AND\n        is_enterprise IS NULL AND\n        is_trust      IS NULL AND\n        is_team       =  1"),
        columns: [
          .init(id: 0, name: "company_id", type: .integer),
          .init(id: 1, name: "owner_id", type: .integer),
          .init(id: 2, name: "contact_id", type: .integer),
          .init(id: 3, name: "number", type: .varchar(width: 50)),
          .init(id: 4, name: "login", type: .varchar(width: 50)),
          .init(id: 5, name: "email", type: .varchar(width: 50)),
          .init(id: 6, name: "description", type: .varchar(width: 255)),
          .init(id: 7, name: "is_team", type: .boolean),
          .init(id: 8, name: "is_location_team", type: .boolean),
          .init(id: 9, name: "db_status", type: .varchar(width: 50)),
          .init(id: 10, name: "object_version", type: .integer),
          .init(id: 11, name: "sensitivity", type: .integer),
          .init(id: 12, name: "boss_name", type: .varchar(width: 255)),
          .init(id: 13, name: "partner_name", type: .varchar(width: 255)),
          .init(id: 14, name: "assistant_name", type: .varchar(width: 255)),
          .init(id: 15, name: "department", type: .varchar(width: 255)),
          .init(id: 16, name: "office", type: .varchar(width: 255)),
          .init(id: 17, name: "occupation", type: .varchar(width: 255)),
          .init(id: 18, name: "anniversary", type: .timestamp),
          .init(id: 19, name: "dir_server", type: .varchar(width: 255)),
          .init(id: 20, name: "email_alias", type: .varchar(width: 255)),
          .init(id: 21, name: "freebusy_url", type: .varchar(width: 255)),
          .init(id: 22, name: "fileas", type: .varchar(width: 255)),
          .init(id: 23, name: "name_title", type: .varchar(width: 255)),
          .init(id: 24, name: "name_affix", type: .varchar(width: 255)),
          .init(id: 25, name: "im_address", type: .varchar(width: 255)),
          .init(id: 26, name: "associated_contacts", type: .varchar(width: 255)),
          .init(id: 27, name: "associated_categories", type: .varchar(width: 255)),
          .init(id: 28, name: "associated_company", type: .varchar(width: 255)),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "note", sql: "CREATE VIEW note AS SELECT * FROM document WHERE is_note = 1"),
        columns: [
          .init(id: 0, name: "document_id", type: .integer),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "parent_document_id", type: .integer),
          .init(id: 3, name: "project_id", type: .integer),
          .init(id: 4, name: "date_id", type: .integer),
          .init(id: 5, name: "first_owner_id", type: .integer),
          .init(id: 6, name: "current_owner_id", type: .integer),
          .init(id: 7, name: "version_count", type: .integer),
          .init(id: 8, name: "file_size", type: .integer),
          .init(id: 9, name: "is_note", type: .boolean),
          .init(id: 10, name: "is_folder", type: .boolean),
          .init(id: 11, name: "is_object_link", type: .boolean),
          .init(id: 12, name: "is_index_doc", type: .boolean),
          .init(id: 13, name: "title", type: .varchar(width: 255)),
          .init(id: 14, name: "abstract", type: .varchar(width: 255)),
          .init(id: 15, name: "file_type", type: .varchar(width: 255)),
          .init(id: 16, name: "object_link", type: .varchar(width: 255)),
          .init(id: 17, name: "creation_date", type: .timestamp),
          .init(id: 18, name: "lastmodified_date", type: .timestamp),
          .init(id: 19, name: "status", type: .varchar(width: 50)),
          .init(id: 20, name: "db_status", type: .varchar(width: 50)),
          .init(id: 21, name: "contact", type: .varchar(width: 255)),
          .init(id: 22, name: "company_id", type: .integer),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "doc", sql: "CREATE VIEW doc  AS SELECT * FROM document WHERE is_note = 0"),
        columns: [
          .init(id: 0, name: "document_id", type: .integer),
          .init(id: 1, name: "object_version", type: .integer),
          .init(id: 2, name: "parent_document_id", type: .integer),
          .init(id: 3, name: "project_id", type: .integer),
          .init(id: 4, name: "date_id", type: .integer),
          .init(id: 5, name: "first_owner_id", type: .integer),
          .init(id: 6, name: "current_owner_id", type: .integer),
          .init(id: 7, name: "version_count", type: .integer),
          .init(id: 8, name: "file_size", type: .integer),
          .init(id: 9, name: "is_note", type: .boolean),
          .init(id: 10, name: "is_folder", type: .boolean),
          .init(id: 11, name: "is_object_link", type: .boolean),
          .init(id: 12, name: "is_index_doc", type: .boolean),
          .init(id: 13, name: "title", type: .varchar(width: 255)),
          .init(id: 14, name: "abstract", type: .varchar(width: 255)),
          .init(id: 15, name: "file_type", type: .varchar(width: 255)),
          .init(id: 16, name: "object_link", type: .varchar(width: 255)),
          .init(id: 17, name: "creation_date", type: .timestamp),
          .init(id: 18, name: "lastmodified_date", type: .timestamp),
          .init(id: 19, name: "status", type: .varchar(width: 50)),
          .init(id: 20, name: "db_status", type: .varchar(width: 50)),
          .init(id: 21, name: "contact", type: .varchar(width: 255)),
          .init(id: 22, name: "company_id", type: .integer),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "employment", sql: "CREATE VIEW employment AS\n  SELECT\n    ca.company_assignment_id,\n    ca.company_id     AS enterprise_id,\n    ca.sub_company_id AS person_id,\n    ca.is_headquarter, ca.is_chief, ca.\"function\",\n    ca.db_status,\n    ca.start_date, ca.end_date\n  FROM company_assignment ca\n  INNER JOIN enterprise e USING (company_id)\n  INNER JOIN person     p ON (p.company_id = ca.sub_company_id)"),
        columns: [
          .init(id: 0, name: "company_assignment_id", type: .integer),
          .init(id: 1, name: "enterprise_id", type: .integer),
          .init(id: 2, name: "person_id", type: .integer),
          .init(id: 3, name: "is_headquarter", type: .boolean),
          .init(id: 4, name: "is_chief", type: .boolean),
          .init(id: 5, name: "function", type: .varchar(width: 255)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "company_hierarchy", sql: "CREATE VIEW company_hierarchy AS\n  SELECT\n    ca.company_assignment_id,\n    ca.company_id     AS parent_id,\n    ca.sub_company_id AS company_id,\n    ca.is_headquarter, ca.is_chief, ca.\"function\",\n    ca.db_status,\n    ca.start_date AS start_date, ca.end_date AS end_date\n  FROM company_assignment ca\n  INNER JOIN enterprise e1 USING (company_id)\n  INNER JOIN enterprise e2 ON (e2.company_id = ca.sub_company_id)"),
        columns: [
          .init(id: 0, name: "company_assignment_id", type: .integer),
          .init(id: 1, name: "parent_id", type: .integer),
          .init(id: 2, name: "company_id", type: .integer),
          .init(id: 3, name: "is_headquarter", type: .boolean),
          .init(id: 4, name: "is_chief", type: .boolean),
          .init(id: 5, name: "function", type: .varchar(width: 255)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "team_membership", sql: "CREATE VIEW team_membership AS\n  SELECT\n    ca.company_assignment_id,\n    ca.company_id     AS team_id,\n    ca.sub_company_id AS person_id,\n    ca.is_headquarter, ca.is_chief, ca.\"function\",\n    ca.db_status,\n    ca.start_date AS start_date, ca.end_date AS end_date\n  FROM company_assignment ca\n  INNER JOIN team   t USING (company_id)\n  INNER JOIN person p ON (p.company_id = ca.sub_company_id)"),
        columns: [
          .init(id: 0, name: "company_assignment_id", type: .integer),
          .init(id: 1, name: "team_id", type: .integer),
          .init(id: 2, name: "person_id", type: .integer),
          .init(id: 3, name: "is_headquarter", type: .boolean),
          .init(id: 4, name: "is_chief", type: .boolean),
          .init(id: 5, name: "function", type: .varchar(width: 255)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "team_hierarchy", sql: "CREATE VIEW team_hierarchy AS\n  SELECT\n    ca.company_assignment_id,\n    ca.company_id     AS parent_id,\n    ca.sub_company_id AS team_id,\n    ca.is_headquarter, ca.is_chief, ca.\"function\",\n    ca.db_status,\n    start_date, end_date\n  FROM company_assignment ca\n  INNER JOIN team t1 USING (company_id)\n  INNER JOIN team t2 ON (t2.company_id = ca.sub_company_id)"),
        columns: [
          .init(id: 0, name: "company_assignment_id", type: .integer),
          .init(id: 1, name: "parent_id", type: .integer),
          .init(id: 2, name: "team_id", type: .integer),
          .init(id: 3, name: "is_headquarter", type: .boolean),
          .init(id: 4, name: "is_chief", type: .boolean),
          .init(id: 5, name: "function", type: .varchar(width: 255)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "project_teams", sql: "CREATE VIEW project_teams AS\n  SELECT pca.*\n  FROM project_company_assignment pca\n  JOIN team e USING (company_id)"),
        columns: [
          .init(id: 0, name: "project_company_assignment_id", type: .integer),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "project_id", type: .integer),
          .init(id: 3, name: "info", type: .varchar(width: 255)),
          .init(id: 4, name: "has_access", type: .boolean),
          .init(id: 5, name: "access_right", type: .varchar(width: 50)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "project_persons", sql: "CREATE VIEW project_persons AS\n  SELECT pca.*\n  FROM project_company_assignment pca\n  JOIN person p USING (company_id)"),
        columns: [
          .init(id: 0, name: "project_company_assignment_id", type: .integer),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "project_id", type: .integer),
          .init(id: 3, name: "info", type: .varchar(width: 255)),
          .init(id: 4, name: "has_access", type: .boolean),
          .init(id: 5, name: "access_right", type: .varchar(width: 50)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "project_companies", sql: "CREATE VIEW project_companies AS\n  SELECT pca.*\n  FROM project_company_assignment pca\n  JOIN enterprise e USING (company_id)"),
        columns: [
          .init(id: 0, name: "project_company_assignment_id", type: .integer),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "project_id", type: .integer),
          .init(id: 3, name: "info", type: .varchar(width: 255)),
          .init(id: 4, name: "has_access", type: .boolean),
          .init(id: 5, name: "access_right", type: .varchar(width: 50)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      ),
      Schema.View(
        info: .init(type: .view, name: "project_acl", sql: "CREATE VIEW project_acl AS\n  SELECT pca.*\n  FROM project_company_assignment pca\n  WHERE has_access = 1"),
        columns: [
          .init(id: 0, name: "project_company_assignment_id", type: .integer),
          .init(id: 1, name: "company_id", type: .integer),
          .init(id: 2, name: "project_id", type: .integer),
          .init(id: 3, name: "info", type: .varchar(width: 255)),
          .init(id: 4, name: "has_access", type: .boolean),
          .init(id: 5, name: "access_right", type: .varchar(width: 50)),
          .init(id: 6, name: "db_status", type: .varchar(width: 50)),
          .init(id: 7, name: "start_date", type: .custom("timestamp with time zone")),
          .init(id: 8, name: "end_date", type: .custom("timestamp with time zone")),
        ]
      )
    ],
    indices: [
      "article": [
        .init(type: .index, name: "article_status_idx", tableName: "article", rootPage: 122, sql: "CREATE INDEX article_status_idx ON article(status)"),
      ],
      "project_company_assignment": [
        .init(type: .index, name: "has_access_idx", tableName: "project_company_assignment", rootPage: 65, sql: "CREATE INDEX has_access_idx   ON project_company_assignment(has_access)"),
        .init(type: .index, name: "access_right_idx", tableName: "project_company_assignment", rootPage: 66, sql: "CREATE INDEX access_right_idx ON project_company_assignment(access_right)"),
      ],
      "address": [
        .init(type: .index, name: "address__name1", tableName: "address", rootPage: 82, sql: "CREATE INDEX address__name1      ON address(name1)"),
        .init(type: .index, name: "address__name2", tableName: "address", rootPage: 83, sql: "CREATE INDEX address__name2      ON address(name2)"),
        .init(type: .index, name: "address__name3", tableName: "address", rootPage: 84, sql: "CREATE INDEX address__name3      ON address(name3)"),
        .init(type: .index, name: "address__street", tableName: "address", rootPage: 85, sql: "CREATE INDEX address__street     ON address(street)"),
        .init(type: .index, name: "address__zip", tableName: "address", rootPage: 86, sql: "CREATE INDEX address__zip        ON address(zip)"),
        .init(type: .index, name: "address__zipcity", tableName: "address", rootPage: 87, sql: "CREATE INDEX address__zipcity    ON address(zipcity)"),
        .init(type: .index, name: "address_type_idx", tableName: "address", rootPage: 88, sql: "CREATE INDEX address_type_idx    ON address(type)"),
      ],
      "palm_memo": [
        .init(type: .index, name: "palmmemo_company_idx", tableName: "palm_memo", rootPage: 167, sql: "CREATE INDEX palmmemo_company_idx ON palm_memo (company_id)"),
        .init(type: .index, name: "palmmemo_device_idx", tableName: "palm_memo", rootPage: 168, sql: "CREATE INDEX palmmemo_device_idx  ON palm_memo (device_id)"),
        .init(type: .index, name: "palmmemo_palm_idx", tableName: "palm_memo", rootPage: 169, sql: "CREATE INDEX palmmemo_palm_idx    ON palm_memo (palm_id)"),
        .init(type: .index, name: "palmmemo_md5hash_idx", tableName: "palm_memo", rootPage: 170, sql: "CREATE INDEX palmmemo_md5hash_idx ON palm_memo (md5hash)"),
        .init(type: .index, name: "palmmemo_skyrix_idx", tableName: "palm_memo", rootPage: 171, sql: "CREATE INDEX palmmemo_skyrix_idx  ON palm_memo (skyrix_id)"),
      ],
      "project": [
        .init(type: .index, name: "unique_project_number", tableName: "project", rootPage: 59, sql: "CREATE UNIQUE INDEX unique_project_number ON project(number)"),
        .init(type: .index, name: "is_fake_idx", tableName: "project", rootPage: 60, sql: "CREATE INDEX is_fake_idx           ON project(is_fake)"),
        .init(type: .index, name: "project_kind_idx", tableName: "project", rootPage: 61, sql: "CREATE INDEX project_kind_idx      ON project(kind)"),
        .init(type: .index, name: "project_status_idx", tableName: "project", rootPage: 62, sql: "CREATE INDEX project_status_idx    ON project(status)"),
        .init(type: .index, name: "project_db_status_idx", tableName: "project", rootPage: 63, sql: "CREATE INDEX project_db_status_idx ON project(db_status)"),
      ],
      "palm_address": [
        .init(type: .index, name: "palmaddr_company_idx", tableName: "palm_address", rootPage: 152, sql: "CREATE INDEX palmaddr_company_idx ON palm_address (company_id)"),
        .init(type: .index, name: "palmaddr_device_idx", tableName: "palm_address", rootPage: 153, sql: "CREATE INDEX palmaddr_device_idx  ON palm_address (device_id)"),
        .init(type: .index, name: "palmaddr_palm_idx", tableName: "palm_address", rootPage: 154, sql: "CREATE INDEX palmaddr_palm_idx    ON palm_address (palm_id)"),
        .init(type: .index, name: "palmaddr_md5hash_idx", tableName: "palm_address", rootPage: 155, sql: "CREATE INDEX palmaddr_md5hash_idx ON palm_address (md5hash)"),
        .init(type: .index, name: "palmaddr_skyrix_idx", tableName: "palm_address", rootPage: 156, sql: "CREATE INDEX palmaddr_skyrix_idx  ON palm_address (skyrix_id)"),
        .init(type: .index, name: "palmaddr_cat_idxx", tableName: "palm_address", rootPage: 157, sql: "CREATE INDEX palmaddr_cat_idxx    ON palm_address(category_index)"),
        .init(type: .index, name: "palmaddr_is_del_idx", tableName: "palm_address", rootPage: 158, sql: "CREATE INDEX palmaddr_is_del_idx  ON palm_address(is_deleted)"),
        .init(type: .index, name: "palmaddr_is_mod_idx", tableName: "palm_address", rootPage: 159, sql: "CREATE INDEX palmaddr_is_mod_idx  ON palm_address(is_modified)"),
        .init(type: .index, name: "palmaddr_is_arch_idx", tableName: "palm_address", rootPage: 160, sql: "CREATE INDEX palmaddr_is_arch_idx ON palm_address(is_archived)"),
        .init(type: .index, name: "palmaddr_is_new_idx", tableName: "palm_address", rootPage: 161, sql: "CREATE INDEX palmaddr_is_new_idx  ON palm_address(is_new)"),
        .init(type: .index, name: "palmaddr_is_priv_idx", tableName: "palm_address", rootPage: 162, sql: "CREATE INDEX palmaddr_is_priv_idx ON palm_address(is_private)"),
        .init(type: .index, name: "palmaddr_sky_sync_idx", tableName: "palm_address", rootPage: 163, sql: "CREATE INDEX palmaddr_sky_sync_idx ON palm_address(skyrix_sync)"),
        .init(type: .index, name: "palmaddr_sky_vers_idx", tableName: "palm_address", rootPage: 164, sql: "CREATE INDEX palmaddr_sky_vers_idx ON palm_address(skyrix_version)"),
        .init(type: .index, name: "palmaddr_sky_type_idx", tableName: "palm_address", rootPage: 166, sql: "CREATE INDEX palmaddr_sky_type_idx ON palm_address(skyrix_type)"),
      ],
      "ctags": [
        .init(type: .index, name: "ctag_unique_entity", tableName: "ctags", rootPage: 191, sql: "CREATE UNIQUE INDEX ctag_unique_entity ON ctags(entity)"),
      ],
      "invoice": [
        .init(type: .index, name: "invoice_kind_idx", tableName: "invoice", rootPage: 111, sql: "CREATE INDEX invoice_kind_idx   ON invoice(kind)"),
        .init(type: .index, name: "invoice_status_idx", tableName: "invoice", rootPage: 112, sql: "CREATE INDEX invoice_status_idx ON invoice(status)"),
        .init(type: .index, name: "invoice_date_idx", tableName: "invoice", rootPage: 113, sql: "CREATE INDEX invoice_date_idx   ON invoice(invoice_date)"),
      ],
      "document": [
        .init(type: .index, name: "is_note_idx", tableName: "document", rootPage: 69, sql: "CREATE INDEX is_note_idx        ON document(is_note)"),
        .init(type: .index, name: "is_folder_idx", tableName: "document", rootPage: 70, sql: "CREATE INDEX is_folder_idx      ON document(is_folder)"),
        .init(type: .index, name: "is_object_link_idx", tableName: "document", rootPage: 71, sql: "CREATE INDEX is_object_link_idx ON document(is_object_link)"),
        .init(type: .index, name: "is_index_doc_idx", tableName: "document", rootPage: 72, sql: "CREATE INDEX is_index_doc_idx   ON document(is_index_doc)"),
        .init(type: .index, name: "object_link_idx", tableName: "document", rootPage: 73, sql: "CREATE INDEX object_link_idx    ON document(object_link)"),
        .init(type: .index, name: "document_status_idx", tableName: "document", rootPage: 74, sql: "CREATE INDEX document_status_idx ON document(status)"),
        .init(type: .index, name: "doc_title_id_idx", tableName: "document", rootPage: 75, sql: "CREATE INDEX doc_title_id_idx    ON document(title)"),
      ],
      "log": [
        .init(type: .index, name: "action_idx", tableName: "log", rootPage: 4, sql: "CREATE INDEX action_idx ON log(action)"),
        .init(type: .index, name: "log_object_idx", tableName: "log", rootPage: 5, sql: "CREATE INDEX log_object_idx        ON log(object_id)"),
        .init(type: .index, name: "log_creation_date_idx", tableName: "log", rootPage: 6, sql: "CREATE INDEX log_creation_date_idx ON log(creation_date)"),
        .init(type: .index, name: "log_account_id_idx", tableName: "log", rootPage: 7, sql: "CREATE INDEX log_account_id_idx    ON log(account_id)"),
      ],
      "palm_category": [
        .init(type: .index, name: "palmcat_company_idx", tableName: "palm_category", rootPage: 172, sql: "CREATE INDEX palmcat_company_idx ON palm_category (company_id)"),
        .init(type: .index, name: "palmcat_device_idx", tableName: "palm_category", rootPage: 173, sql: "CREATE INDEX palmcat_device_idx  ON palm_category (device_id)"),
        .init(type: .index, name: "palmcat_palm_idx", tableName: "palm_category", rootPage: 174, sql: "CREATE INDEX palmcat_palm_idx    ON palm_category (palm_id)"),
        .init(type: .index, name: "palmcat_md5hash_idx", tableName: "palm_category", rootPage: 175, sql: "CREATE INDEX palmcat_md5hash_idx ON palm_category (md5hash)"),
        .init(type: .index, name: "palmcat_table_idx", tableName: "palm_category", rootPage: 176, sql: "CREATE INDEX palmcat_table_idx   ON palm_category (palm_table)"),
      ],
      "document_editing": [
        .init(type: .index, name: "document_editing_status_idx", tableName: "document_editing", rootPage: 79, sql: "CREATE INDEX document_editing_status_idx ON document_editing(status)"),
      ],
      "table_version": [
        .init(type: .index, name: "sqlite_autoindex_table_version_1", tableName: "table_version", rootPage: 13),
      ],
      "appointment_resource": [
        .init(type: .index, name: "unique_aptresname_idx", tableName: "appointment_resource", rootPage: 47, sql: "CREATE UNIQUE INDEX unique_aptresname_idx ON appointment_resource(name)"),
      ],
      "session_log": [
        .init(type: .index, name: "account_id_idx", tableName: "session_log", rootPage: 9, sql: "CREATE INDEX account_id_idx ON session_log(account_id)"),
        .init(type: .index, name: "log_date_idx", tableName: "session_log", rootPage: 10, sql: "CREATE INDEX log_date_idx ON session_log(log_date)"),
        .init(type: .index, name: "session_log_action_idx", tableName: "session_log", rootPage: 11, sql: "CREATE INDEX session_log_action_idx ON session_log(action)"),
      ],
      "company": [
        .init(type: .index, name: "unique_company_number", tableName: "company", rootPage: 20, sql: "CREATE UNIQUE INDEX unique_company_number ON company(number)"),
        .init(type: .index, name: "unique_company_login", tableName: "company", rootPage: 21, sql: "CREATE UNIQUE INDEX unique_company_login  ON company(login)"),
        .init(type: .index, name: "company__is_team", tableName: "company", rootPage: 22, sql: "CREATE INDEX company__is_team       ON company(is_team)"),
        .init(type: .index, name: "company__is_enterprise", tableName: "company", rootPage: 23, sql: "CREATE INDEX company__is_enterprise ON company(is_enterprise)"),
        .init(type: .index, name: "company__is_trust", tableName: "company", rootPage: 24, sql: "CREATE INDEX company__is_trust      ON company(is_trust)"),
        .init(type: .index, name: "company__is_person", tableName: "company", rootPage: 25, sql: "CREATE INDEX company__is_person     ON company(is_person)"),
        .init(type: .index, name: "company__email", tableName: "company", rootPage: 26, sql: "CREATE INDEX company__email         ON company(email)"),
        .init(type: .index, name: "company__name", tableName: "company", rootPage: 27, sql: "CREATE INDEX company__name          ON company(name)"),
        .init(type: .index, name: "company__firstname", tableName: "company", rootPage: 29, sql: "CREATE INDEX company__firstname     ON company(firstname)"),
        .init(type: .index, name: "company__keywords", tableName: "company", rootPage: 31, sql: "CREATE INDEX company__keywords      ON company(keywords)"),
        .init(type: .index, name: "is_private_idx", tableName: "company", rootPage: 32, sql: "CREATE INDEX is_private_idx         ON company(is_private)"),
        .init(type: .index, name: "is_account_idx", tableName: "company", rootPage: 33, sql: "CREATE INDEX is_account_idx         ON company(is_account)"),
        .init(type: .index, name: "is_intra_account_idx", tableName: "company", rootPage: 34, sql: "CREATE INDEX is_intra_account_idx   ON company(is_intra_account)"),
        .init(type: .index, name: "is_extra_account_idx", tableName: "company", rootPage: 35, sql: "CREATE INDEX is_extra_account_idx   ON company(is_extra_account)"),
        .init(type: .index, name: "is_location_team_idx", tableName: "company", rootPage: 36, sql: "CREATE INDEX is_location_team_idx   ON company(is_location_team)"),
        .init(type: .index, name: "is_template_user_idx", tableName: "company", rootPage: 37, sql: "CREATE INDEX is_template_user_idx   ON company(is_template_user)"),
        .init(type: .index, name: "company_db_status_idx", tableName: "company", rootPage: 38, sql: "CREATE INDEX company_db_status_idx  ON company(db_status)"),
      ],
      "obj_property": [
        .init(type: .index, name: "obj_p_obj_id_idx", tableName: "obj_property", rootPage: 131, sql: "CREATE INDEX obj_p_obj_id_idx           ON obj_property(obj_id)"),
        .init(type: .index, name: "obj_p_value_key_idx", tableName: "obj_property", rootPage: 132, sql: "CREATE INDEX obj_p_value_key_idx        ON obj_property(value_key)"),
        .init(type: .index, name: "obj_p_value_string_idx", tableName: "obj_property", rootPage: 133, sql: "CREATE INDEX obj_p_value_string_idx     ON obj_property(value_string)"),
        .init(type: .index, name: "obj_p_namespace_prefix_idx", tableName: "obj_property", rootPage: 134, sql: "CREATE INDEX obj_p_namespace_prefix_idx ON obj_property(namespace_prefix)"),
        .init(type: .index, name: "obj_p_access_key_idx", tableName: "obj_property", rootPage: 135, sql: "CREATE INDEX obj_p_access_key_idx       ON obj_property(access_key)"),
        .init(type: .index, name: "obj_p_obj_type_idx", tableName: "obj_property", rootPage: 136, sql: "CREATE INDEX obj_p_obj_type_idx         ON obj_property(obj_type)"),
      ],
      "job_assignment": [
        .init(type: .index, name: "assignment_kind_idx", tableName: "job_assignment", rootPage: 127, sql: "CREATE INDEX assignment_kind_idx ON job_assignment(assignment_kind)"),
      ],
      "palm_todo": [
        .init(type: .index, name: "palmtodo_company_idx", tableName: "palm_todo", rootPage: 184, sql: "CREATE INDEX palmtodo_company_idx ON palm_todo (company_id)"),
        .init(type: .index, name: "palmtodo_device_idx", tableName: "palm_todo", rootPage: 185, sql: "CREATE INDEX palmtodo_device_idx  ON palm_todo (device_id)"),
        .init(type: .index, name: "palmtodo_palm_idx", tableName: "palm_todo", rootPage: 186, sql: "CREATE INDEX palmtodo_palm_idx    ON palm_todo (palm_id)"),
        .init(type: .index, name: "palmtodo_md5hash_idx", tableName: "palm_todo", rootPage: 187, sql: "CREATE INDEX palmtodo_md5hash_idx ON palm_todo (md5hash)"),
        .init(type: .index, name: "palmtodo_skyrix_idx", tableName: "palm_todo", rootPage: 188, sql: "CREATE INDEX palmtodo_skyrix_idx  ON palm_todo (skyrix_id)"),
      ],
      "news_article": [
        .init(type: .index, name: "is_index_article_idx", tableName: "news_article", rootPage: 108, sql: "CREATE INDEX is_index_article_idx ON news_article(is_index_article)"),
      ],
      "appointment": [
        .init(type: .index, name: "is_absence_idx", tableName: "appointment", rootPage: 49, sql: "CREATE INDEX is_absence_idx           ON appointment(is_absence)"),
        .init(type: .index, name: "is_attendance_idx", tableName: "appointment", rootPage: 50, sql: "CREATE INDEX is_attendance_idx        ON appointment(is_attendance)"),
        .init(type: .index, name: "is_conflict_disabled_idx", tableName: "appointment", rootPage: 51, sql: "CREATE INDEX is_conflict_disabled_idx ON appointment(is_conflict_disabled)"),
        .init(type: .index, name: "start_date_ind", tableName: "appointment", rootPage: 52, sql: "CREATE INDEX start_date_ind           ON appointment(start_date)"),
        .init(type: .index, name: "end_date_ind", tableName: "appointment", rootPage: 53, sql: "CREATE INDEX end_date_ind             ON appointment(end_date)"),
        .init(type: .index, name: "resource_names_ind", tableName: "appointment", rootPage: 54, sql: "CREATE INDEX resource_names_ind       ON appointment(resource_names)"),
      ],
      "staff": [
        .init(type: .index, name: "unique_company_id", tableName: "staff", rootPage: 15, sql: "CREATE UNIQUE INDEX unique_company_id ON staff(company_id)"),
        .init(type: .index, name: "staff__is_team", tableName: "staff", rootPage: 16, sql: "CREATE INDEX staff__is_team    ON staff(is_team)"),
        .init(type: .index, name: "staff__is_account", tableName: "staff", rootPage: 17, sql: "CREATE INDEX staff__is_account ON staff(is_account)"),
      ],
      "object_acl": [
        .init(type: .index, name: "obj_acl_sort_key_idx", tableName: "object_acl", rootPage: 139, sql: "CREATE INDEX obj_acl_sort_key_idx    ON object_acl(sort_key)"),
        .init(type: .index, name: "obj_acl_object_id_idx", tableName: "object_acl", rootPage: 140, sql: "CREATE INDEX obj_acl_object_id_idx   ON object_acl(object_id)"),
        .init(type: .index, name: "obj_acl_action_idx", tableName: "object_acl", rootPage: 141, sql: "CREATE INDEX obj_acl_action_idx      ON object_acl(action)"),
        .init(type: .index, name: "obj_acl_auth_id_idx", tableName: "object_acl", rootPage: 142, sql: "CREATE INDEX obj_acl_auth_id_idx     ON object_acl(auth_id)"),
        .init(type: .index, name: "obj_acl_permissions_idx", tableName: "object_acl", rootPage: 143, sql: "CREATE INDEX obj_acl_permissions_idx ON object_acl(permissions)"),
      ],
      "invoice_action": [
        .init(type: .index, name: "action_kind_idx", tableName: "invoice_action", rootPage: 116, sql: "CREATE INDEX action_kind_idx on invoice_action(action_kind)"),
      ],
      "palm_date": [
        .init(type: .index, name: "palmdate_company_idx", tableName: "palm_date", rootPage: 177, sql: "CREATE INDEX palmdate_company_idx   ON palm_date (company_id)"),
        .init(type: .index, name: "palmdate_device_idx", tableName: "palm_date", rootPage: 178, sql: "CREATE INDEX palmdate_device_idx    ON palm_date (device_id)"),
        .init(type: .index, name: "palmdate_palm_idx", tableName: "palm_date", rootPage: 179, sql: "CREATE INDEX palmdate_palm_idx      ON palm_date (palm_id)"),
        .init(type: .index, name: "palmdate_md5hash_idx", tableName: "palm_date", rootPage: 180, sql: "CREATE INDEX palmdate_md5hash_idx   ON palm_date (md5hash)"),
        .init(type: .index, name: "palmdate_skyrix_idx", tableName: "palm_date", rootPage: 181, sql: "CREATE INDEX palmdate_skyrix_idx    ON palm_date (skyrix_id)"),
        .init(type: .index, name: "palmdate_startdate_idx", tableName: "palm_date", rootPage: 182, sql: "CREATE INDEX palmdate_startdate_idx ON palm_date (startdate)"),
        .init(type: .index, name: "palmdate_enddate_idx", tableName: "palm_date", rootPage: 183, sql: "CREATE INDEX palmdate_enddate_idx   ON palm_date (enddate)"),
      ],
      "login_token": [
        .init(type: .index, name: "sqlite_autoindex_login_token_1", tableName: "login_token", rootPage: 193),
      ],
      "telephone": [
        .init(type: .index, name: "telephone__number", tableName: "telephone", rootPage: 90, sql: "CREATE INDEX telephone__number      ON telephone(number)"),
        .init(type: .index, name: "telephone__type", tableName: "telephone", rootPage: 91, sql: "CREATE INDEX telephone__type        ON telephone(type)"),
        .init(type: .index, name: "telephone__real_number", tableName: "telephone", rootPage: 92, sql: "CREATE INDEX telephone__real_number ON telephone(real_number)"),
      ],
      "job": [
        .init(type: .index, name: "job__keywords", tableName: "job", rootPage: 95, sql: "CREATE INDEX job__keywords      ON job(keywords)"),
        .init(type: .index, name: "is_control_job_idx", tableName: "job", rootPage: 96, sql: "CREATE INDEX is_control_job_idx ON job(is_control_job)"),
        .init(type: .index, name: "is_team_job_idx", tableName: "job", rootPage: 97, sql: "CREATE INDEX is_team_job_idx    ON job(is_team_job)"),
        .init(type: .index, name: "is_new_idx", tableName: "job", rootPage: 98, sql: "CREATE INDEX is_new_idx         ON job(is_new)"),
        .init(type: .index, name: "priority_idx", tableName: "job", rootPage: 99, sql: "CREATE INDEX priority_idx       ON job(priority)"),
        .init(type: .index, name: "job_kind_idx", tableName: "job", rootPage: 100, sql: "CREATE INDEX job_kind_idx       ON job(kind)"),
        .init(type: .index, name: "job_status_idx", tableName: "job", rootPage: 101, sql: "CREATE INDEX job_status_idx     ON job(job_status)"),
        .init(type: .index, name: "job_db_status_idx", tableName: "job", rootPage: 102, sql: "CREATE INDEX job_db_status_idx  ON job(db_status)"),
      ],
      "document_version": [
        .init(type: .index, name: "doc_v_obj_version_idx", tableName: "document_version", rootPage: 77, sql: "CREATE INDEX doc_v_obj_version_idx    ON document_version(object_version)"),
      ],
      "company_value": [
        .init(type: .index, name: "attribute_idx", tableName: "company_value", rootPage: 41, sql: "CREATE INDEX attribute_idx ON company_value(attribute)"),
        .init(type: .index, name: "company_value_type_idx", tableName: "company_value", rootPage: 42, sql: "CREATE INDEX company_value_type_idx      ON company_value(type)"),
      ],
    ]
  )

}
