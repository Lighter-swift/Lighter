# Dependency-Free API

Using the dependency-free SQLite API.

## Overview

Enlighter and companions can generate code that depends on the `Lighter`
library or dependency-free code that just uses the builtin SQLite API.

This dependency-free API is more low level and follows the conventions of the
[SQLite API](https://www.sqlite.org/cintro.html).
While lower level and less automatic, it is still fully type-safe down to the
schema and quite usable.

The dependency-free code generation has two styles:
- Global functions that work on record structures (default), e.g.:
  ```swift
  func sqlite3_person_insert(_ db: OpaquePointer!, _ record: inout Person)
       -> Int32
  ```
- Record methods:
  ```swift
  extension Person {
    mutating func insert(into db: OpaquePointer!) -> Int32
  }
  ```

Performance is the same and which style is used is just a matter of preference.

Unlike <doc:LighterAPI>, 
this API variant does not itself deal with connection handling or 
async/await.
It also doesn't throw Swift errors, but relies on the same error handling like
the builtin SQLite3 API.


## At a Glimpse

The code generators generate one Swift structure representing the Database
itself (e.g. `Northwind`)
and one Swift structure for each SQL table or view
(e.g. `Product`).

The database is just opened using the regular 
[SQLite3 API](https://www.sqlite.org/c3ref/open.html):
```swift
let db : OpaquePointer!
let rc = sqlite3_open_v2(
  "/tmp/MyDatabase.db", &db, 
  SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, nil
)
assert(rc == SQLITE_OK)
```
If the database needs to be created, a generated function can be used:
```swift
var db : OpaquePointer!
let rc = sqlite3_create_northwind("/tmp/MyDatabase.db", &db) // global-style
let rc = Northwind.create("/tmp/MyDatabase.db", in: &db)     // record-style
assert(rc == SQLITE_OK)
```


The APIs then allow the common
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) on them.
E.g. to insert a new product into the Northwind database:
```swift
var newProduct = Product(name: "Maple Sirup")
sqlite3_products_insert(db, newProduct) // global-style
newProduct.insert(into: db)             // record-style
```
To change it:
```swift
newProduct.name = "Marmelade"
sqlite3_products_update(db, newProduct) // global-style
newProduct.update(in: db)               // record-style
```
To delete it:
```swift
sqlite3_products_delete(db, newProduct) // global-style
newProduct.delete(in: db)               // record-style
```

Fetch functions are generated for database tables and views:
```swift
let allProducts = sqlite3_products_fetch(db) // global-style
let allProducts = Product.fetch(in: db)      // record-style
```
If just a single record needs to be fetched by its identifier, `find` is used:
```swift
let product31 = sqlite3_product_find(db, 31) // global-style
let product31 = Product.find(31, in: db)     // record-style
```
To filter a Swift closure can be used (it runs in the database):
```swift
let products = sqlite3_products_fetch(db) { product in
  product.name.lowercased().contains("e")
}
let products = Product.fetch(in: db) { product in
  product.name.lowercased().contains("e")
}
```


## What is Generated

Unlike the <doc:LighterAPI>, the dependency-free code generated doesn't make
the records conform to any extra protocols. The generated types become 
self-contained.

### Database Structure

The name of the structure is derived from the database file name. E.g. if it
is called "northwind.db", the default name mapping produces a structure with
the name "Northwind".

Depending on the <doc:Configuration>, the database structure can contain some
supporting functions. But it doesn't conform to any extra protocols.

### Table and View Structures

The name of the structure is derived from the table name according to the
<doc:Configuration>.
By default "snake_case" (e.g. `product_assignment`) is converted to Swiftier
camel case (`ProductAssignment`), for both the structure name as well as the
property names.

Depending on the <doc:Configuration>, the structures conforms to e.g.:
- [Identifiable](https://developer.apple.com/documentation/swift/identifiable): 
  If the record has a primary key. 
  This is particularily useful in combination with SwiftUI, as such records can 
  directly be used in SwiftUI Lists and more.
- `Hashable`: Table record structures are always Hashable as the allowed column
  values always are. It can be useful to compare a snapshot to the current edit
  state (e.g. `var hasChanges : Bool { oldRecord != record }`).
- `Codable`: An extra conformance in the default configuration, not needed by
  Lighter itself.

By default Enlighter changes the name of the primary key to `id`,
that can be changed using the <doc:Configuration>.


## Performing Queries

Enlighter generates three things for the dependency-free API:
- fetch functions (e.g. `sqlite3_products_fetch`/`Product.fetch`)
- find functions (e.g. `sqlite3_product_find`/`Product.find`)
- relationship functions (e.g. `sqlite3_category_find(_:for:)`)

### Locating Individual Records

The `find` functions are used to locate individual records by primary key:
```swift
let product31 = sqlite3_product_find(db, 31) // global-style
let product31 = Product.find(31, in: db)     // record-style
```

### Filtering Records using Swift

The generated code can directly filter
in the database using a Swift closure:
```swift
let products = sqlite3_products_fetch { product in
  product.name.lowercased().contains("e")
}
```
The closure receives a fully filled `Product` model which it can
filter w/ arbitrary Swift code.
This can be important if the filtering requirements are more demanding,
e.g. a SQLite `LOWER` function doesn't do the same Unicode normalization the
Swift `lowercased()` function and companions do.

> Note: Careful with reusing the same database within a filter. It is best to
>        keep them simple.

This is the **most convenient way** to filter which offers the broadest 
flexibility.
The **disadvantage** is that it can be a little **slower**.
SQLite can't use database indices and a full record has to be filled for 
filtering.

#### Sorting

The `fetch` functions come with an `orderBy` parameter:
```swift
let products = sqlite3_products_fetch(db, orderBy: "name")
```
The orderBy value is raw SQL and inject as-is into an `ORDER BY` clause.
E.g. to get multiple orderings or change the direction, use actual SQL:
```swift
let products = sqlite3_products_fetch(db, orderBy: "name ASC, age DESC")
```


### Fetching Relationships

When Enlighter detected a relationship, it generates convenience accessors
(can be disabled in the <doc:Configuration>):
```swift
let supplier       : Supplier = ...
let relatedRecords = sqlite3_products_fetch(db, for: supplier)
```
The other way around:
```swift
let product  : Product = ...
let supplier = sqlite3_supplier_find(db, for: product)
```


### Performing raw SQL Queries

As a final escape hatch one can perform raw SQL queries:
```swift
let results = sqlite3_products_fetch(sql: "SELECT * FROM products")
```

A raw fetch against a specific type (e.g. `sqlite3_products_fetch`) will always
return full records (e.g. `Product`). 
This still works for fetching fragments though:
```swift
let results = sqlite3_products_fetch(sql: 
  "SELECT id, name FROM products"
)
```
All other properties of the structure will be set to their default values (as
specified in the SQL schema, or a sensible default if that isn't available).

Fetching fragments like that is still reasonably fast but has a bigger 
associated memory cost vs a custom SQLite3 query.


### Using SQL Views to Define Complex Queries

It is tempting to define queries dynamically in Swift. It is often more
performant to do such in SQL and use the full power of SQL built into
SQLite, e.g. `GROUP BY`, `DISTINCT`, `SUM` and extensive joins.

Lighter can't translate plain queries yet (stay tuned), but there is an easy
workaround: SQL Views. Views in the basic form are just stored queries:
```sql
CREATE VIEW [Customer and Suppliers by City] AS
  SELECT City, CompanyName, ContactName, 'Customers' AS Relationship 
    FROM Customers
  UNION 
  SELECT City, CompanyName, ContactName, 'Suppliers' 
    FROM Suppliers 
ORDER BY City, CompanyName
```

Northwind comes with a set of example views, e.g.
[CustomerAndSuppliersByCity](https://lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/customerandsuppliersbycity).
