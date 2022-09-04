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
To filter a Swift closure can be used:
```swift
let products = sqlite3_products_fetch(db) { product in
  product.name.lowercased().contains("e")
}
let products = Product.fetch(in: db) { product in
  product.name.lowercased().contains("e")
}
```
The closure actually runs in the database as part of the query! 
I.e. it is not just a fetch-all and then filter on the Swift side.

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
let results = sqlite3_products_fetch(sql: 
  "SELECT * FROM products WHERE stock_count > 10"
)
```

A raw fetch against a specific type (e.g. `sqlite3_products_fetch`) will always
return full records (e.g. `Product`). 
This still works for fetching fragments though:
```swift
let results = sqlite3_products_fetch(sql: 
  "SELECT id, name FROM products WHERE stock_count > 10"
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


### Advanced SQLite API

In the generated API either Swift closure based filtering can be used
or a raw SQL can be initiated:
```swift
let products = sqlite3_products_fetch { product in
  product.quantityPerUnit.contains("boxes")
}
let results = sqlite3_products_fetch(sql: 
  "SELECT * FROM Products WHERE QuantityPerUnit LIKE '%boxes%'"
)
```
The disadvantage of the closure solution is that a full table scan has to be
performed and indices can't be used. It _does_ run as part of the database
query though (it is not a fetch-all, filter in Swift).
The disadvantage of the SQL one is that the user has to do the value quoting
(careful w/ SQL injection when using `sql`!)

> Unlike the `Lighter` library, the generated dependency-free code doesn't
> contain a "SQL query builder". 
> It isn't supposed to be a library and can only do what the SQLite API itself 
> can do.

#### Parameterized Fetches

If parameterized SQL fetches likes this are needed (Northwind DB):
```sql
SELECT * FROM Products WHERE QuantityPerUnit LIKE ?
```
... the generated code can still be used in combination w/ the builtin 
[SQLite API](https://www.sqlite.org/cintro.html).
First the SQL is "prepared" using
[sqlite3_prepare_v2](https://www.sqlite.org/c3ref/prepare.html):
```swift
var statement : OpaquePointer?
sqlite3_prepare_v2(
  db,
  "SELECT * FROM Products WHERE QuantityPerUnit LIKE ?", -1,
  &statement, nil
)
```
Then the variables (`?` is used here) need to be bound using
[sqlite3_bind_text](https://www.sqlite.org/c3ref/bind_blob.html)
and companions:
```swift
sqlite3_bind_text(
  statement,
  1,               // the parameter index, 1-based
  "%boxes%", -1,   // -1 means `\0` based C string
  SQLITE_TRANSIENT // careful w/ Swift/C API integration here
)
```
And finally the records can be fetched in a fetch-loop using
[`sqlite3_step`](https://www.sqlite.org/c3ref/step.html):
```swift
var products = [ Product ]()
while sqlite3_step(statement) == SQLITE_ROW {
  products.append(Product(statement))
}
```
Note how the generated "`statement`"-initializer for `Product`
can be reused for custom code.

Swift extensions are a good way to build APIs around such code. Puttings
things together:
```swift
extension Product {

  static func fetchWhereQuantityPerUnitContains(
    _ string: String, from db: OpaquePointer!
  ) -> [ Product ]?
  {
    var statement : OpaquePointer?
    guard sqlite3_prepare_v2(
      db,
      "SELECT * FROM Products WHERE QuantityPerUnit LIKE ?", -1,
      &statement, nil
    ) == SQLITE3_OK else { return nil }
    defer { sqlite3_finalize(statement) }
    
    sqlite3_bind_text(statement, 1, "%\(string)%", -1, SQLITE_TRANSIENT)
    var products = [ Product ]()
    while sqlite3_step(statement) == SQLITE_ROW {
      products.append(Product(statement))
    }
    return products
  }
}
```
The function can then be used like:
```swift
let products = 
  Product.fetchWhereQuantityPerUnitContains("boxes", from: db)
```
If more complex code is necessary, the <doc:LighterAPI> might be worth a 
consideration.
But a lot can be done using this style of access w/o any dependencies.

A (not so) small performance improvement can be done. 
Like most other "SQLite Libs" the generated "`statement`"-initializer works by 
looking up the columns by name in the statement. With the above this is done
each time the `Product` value is initialized.
The generated ``SQLEntitySchema/lookupColumnIndices(in:)`` 
can be used to do the lookup just once:
```swift
let indices = Product.Schema.lookupColumnIndices(in: statement)
var records = [ Product ]()
while sqlite3_step(statement) == SQLITE_ROW {
  products.append(Product(statement, indices: indices))
}
```

> [`SQLITE_TRANSIENT`](https://sqlite.org/c3ref/c_static.html) 
> isn't exported by the SQLite module (generated code uses
> SQLITE_STATIC - a reason, why it can be faster on bind-heavy code).
> This can be used:
> ```swift
> let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type?.self)
> ```


#### Handling Errors

The raw API doesn't throw any Swift errors, but expects the user to deal with
SQLite errors as usual.
Described in [Result and Error Codes](https://www.sqlite.org/rescode.html).

However, Lighter comes with a useful ``SQLError`` structure that can grab the
error code from a database handle. 
When just the raw API is generated, it also gets the same ``SQLError`` as part
of the generated database structure.

It can be used like this:
```swift
guard let products = sqlite3_products_fetch(
  db, sql: "SELECT Blub FROM Missing"
) else {
  throw SQLError(db)
}
```

#### Partial Fetches

The generated structures can also be used with partial fetches
which can sometimes be convenient. 
It has a slight overhead over just extracting the values directly 
(because the allocated structures are larger than necessary
and the default values need to be applied).

An example just selecting the 
[`id`](https://lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/product/id-7350h/), 
the
[`name`](https://lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/product/productname/) 
and the
[`quantityPerUnit`](https://lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/product/quantityperunit/):
```swift
sqlite3_prepare_v2(
  db,
  """
  SELECT ProductId, ProductName, QuantityPerUnit FROM Products
   WHERE QuantityPerUnit LIKE ?
  """,
  -1, &statement, nil
)
```
This can still use the generated "`statement`"-initializer for `Product`:
```swift
var records = [ ( id: Int, name: String ) ]()
while sqlite3_step(statement) == SQLITE_ROW {
  let product = Product(statement)
  records.append( ( id: product.id, name: product.productName ) )
}
```
Property values that are not part of the fetch will get their "default value"
if assigned in the SQLite schema, or a reasonable default for the base type
(e.g. `nil` for all optionals, `0` for integers, `""` for strings.)

For example if the `Product` table would be defined as:
```sql
CREATE TABLE Products (
  ProductId       INTEGER NOT NULL PRIMARY KEY,
  ProductName     TEXT    NOT NULL,
  QuantityPerUnit TEXT,
  CategoryId      INTEGER,
  Discontinued    BOOL NOT NULL DEFAULT 0
);
```
The `product` value would contain `nil` for the
[`categoryId`](https://lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/product/categoryid) 
property (because it is optional) and
`0` for the `discontinued` property 
(because that is the specified table default value).

> Important:
> Consider creating an "SQL view" instead of manually doing partial fetches!
> A specific Swift structure and API will be generated for the view by Lighter.
> Explained further up in this document.


#### Reusing a Generated Struct for Multiple Tables

Sometimes very large databases may want to do manual "table partitioning",
i.e. using different tables with the same schema for different datasets.
For example [Shrugs.app](https://shrugs.app), the chat client, creates
[a message table for each channel](https://github.com/ZeeZide/Shrugs/wiki/Querying-the-SQLite-Cache)/conversation.

The raw SQL select can we useful for such scenarios, while still using
features like Swift closure filtering:
```swift
sqlite3_products_fetch(db, sql: "SELECT * FROM Products") {
  $0.name.hasPrefix("Gallions")
}
sqlite3_products_fetch(db, sql: "SELECT * FROM Products2022") {
  $0.name.hasPrefix("Gallions")
}
```

Another "hacky" variant is abusing the schema for a different table,
sometimes also useful to perform migrations:
```
sqlite3_products_fetch(db, sql: 
  """
  SELECT NewProductId    AS ProductId,
         NewProductTitle AS ProductName
    FROM NewProducts
  """
)
```


#### Opening a SQLite Handle from a Lighter Structure

When using the <doc:LighterAPI> there might sometimes still be a need to open a 
SQLite database handle manually. 
To get to the active URL for a Lighter database, 
the ``SQLConnectionHandler/url`` property of the connection handler can be used.

For example:
```swift
let url = database.connectionHandler.url
var db : OpaquePointer?
let rc = sqlite3_open_v2(
  url.absoluteString, &db,
  SQLITE_OPEN_READONLY | SQLITE_OPEN_URI, nil
)
assert(rc == SQLITE_OK)
defer {
  sqlite3_close(db)
}

let allProducts = sqlite3_products_fetch(db)
```
