# Lighter API Overview

Using the Lighter API.

## Overview

Lighter itself is a small support library that enhances the capabilities of the
generated code. It is still a pretty small library but can do tasks like:

- connection management
- async/await query execution
- dynamic building of SQL predicates

Lighter is not supposed to be used on its own. It is a set of Swift
protocols and mixins that annotate the sources generated by the code generators.

If an additional dependency is not desired, Enlighter can also generate
dependency free code for a database: <doc:SQLiteAPI>.


## At a Glimpse

The code generators generate one Swift structure representing the Database
itself (e.g. 
[Northwind](https://Northwind-swift.github.io/NorthwindSQLite.swift/documentation/northwind/northwind))
and one Swift structure for each SQL table or view
(e.g.
[Product](https://Northwind-swift.github.io/NorthwindSQLite.swift/documentation/northwind/product)).

If the database is embedded into the app or library (as a resource file), it
can be directly used like this:
```swift
let database = Northwind.module!
```
If the database is a cache or document storage, it needs to be created:
```swift
let database = Northwind.bootstrap()
```
Many variants of bootstrap exist, e.g. it can also copy a prefilled resource
database.
During development, when the SQL files are still changed,
`bootstrap(overwrite: true)` can be useful, e.g. to get a new cache database on
each start.


The Lighter APIs then allow the common
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) on them.
E.g. to insert a new product into the Northwind database:
```swift
var newProduct = Product(name: "Maple Sirup")
try database.insert(newProduct)
```
To change it:
```swift
newProduct.name = "Marmelade"
try database.update(newProduct)
```
To delete it:
```swift
try database.delete(newProduct)
```

Database tables and views are exposed as "record references",
which enable us to fetch them with a nice syntax:
```swift
let allProducts = try database.products.fetch()
```
If just a single record needs to be fetched by its identifier, `find` is used:
```swift
let product31 = try database.products.find(31)
```
To filter a Swift closure can be used (it runs in the database):
```swift
let products = try database.products.filter { product in
  product.name.lowercased().contains("e")
}
```

Things can be put into transactions for isolation and performance:
```swift
try database.transaction { tx in
  tx.insert([ one, two, three, four, five ])
}
```

And if Swift concurrency is available, async/await versions of everything are
available:
```swift
async let supplier = database.suppliers.find(for: product)
async let category = database.categories.find(for: product)
( self.supplier, self.category ) = try await ( supplier, category )
```


## What is Generated

The code generators generate one Swift structure representing the Database
itself (e.g. 
[Northwind](https://Northwind-swift.github.io/NorthwindSQLite.swift/documentation/northwind/northwind))
and one Swift structure for each SQL table or view
(e.g.
[Product](https://Northwind-swift.github.io/NorthwindSQLite.swift/documentation/northwind/product)).

### Database Structure

The name of the structure is derived from the database file name. E.g. if it
is called "northwind.db", the default name mapping produces a structure with
the name 
"[Northwind](https://Northwind-swift.github.io/NorthwindSQLite.swift/documentation/northwind/northwind)".

Depending on the <doc:Configuration>, the database structure conforms to e.g.:
- ``SQLDatabase``: This handles opening the database etc.
- ``SQLDatabaseAsyncChangeOperations``: This mixin provides support for all the
  CRUD operations and more.
- ``SQLCreationStatementsHolder``: Using this the database can bootstrap a new
  database from the contained SQL.

### Table and View Structures

The name of the structure is derived from the table name according to the
<doc:Configuration>.
By default "snake_case" (e.g. `product_assignment`) is converted to Swiftier
camel case (`ProductAssignment`), for both the structure name as well as the
property names.

Depending on the <doc:Configuration>, the structures conforms to e.g.:
- ``SQLKeyedTableRecord``: If the record represents a table that has a single
  primary key.
- [Identifiable](https://developer.apple.com/documentation/swift/identifiable): 
  If the record has a primary key. 
  This is particularily useful in combination with SwiftUI, as such records can 
  directly be used in SwiftUI Lists and more.
- `Codable`: An extra conformance in the default configuration, not needed by
  Lighter itself.

By default Enlighter changes the name of the primary key to `id`,
that can be changed using the <doc:Configuration>.


## Performing Queries

Lighter has a rich set of query functions for many needs.

### Locating Individual Records

The ``SQLRecordFetchOperations/find(_:)-7k750`` functions are used to locate
individual records. One variant works for records with primary keys:
```swift
let person = try database.people.find(10)
let earth  = try db.solarBodies.find("Earth")
```
The other one allows the specification of a column:
```swift
let earth = try db.solarBodies.find(by: \.name, "Earth")
```

### Filtering Records

Lighter provides two ways to filter tables that look similar but work
differently.

#### Filtering using Swift

Lighter can directly filter
in the database using a Swift closure (``SQLRecordFetchOperations/filter(limit:filter:)``):
```swift
let products = try database.products.filter { product in
  product.name.lowercased().contains("e")
}
```
The closure receives a fully filled `Product` model which it can
filter w/ arbitrary Swift code.
This can be important if the filtering requirements are more demanding,
e.g. a SQLite `LOWER` function doesn't do the same Unicode normalization the
Swift `lowercased()` function and companions do.

> Note: Careful with reusing the same database within a filter. It is possible,
>       but each call will get an own database connection. It is best to keep
>       them simple.

This is the **most convenient way** to filter which offers the broadest 
flexibility.
The **disadvantage** is that it can be a little **slower**.
SQLite can't use database indices and a full record has to be filled for 
filtering.

#### Filtering using Predicates

``SQLPredicate``'s work a lot like CoreData `NSPredicate`s, but directly bind
to the column types and due to that are completely typesafe.

Straight forward operators (like `!`, `&&`, `||`, `<`) are provided,
as well as matchers (``SQLColumn/hasPrefix(_:caseInsensitive:)``,
``SQLColumn/hasSuffix(_:caseInsensitive:)`` and ``SQLColumn/contains(_:caseInsensitive:)``),
and range queries (``SQLColumn/in(_:)-4ds12``, ``SQLColumn/in(_:)-6rq6g``).

Example:
```swift
let products = try database.products.fetch { product in
  product.name.contains("e") && product.age < 10
}
```
It looks very much like the Swift-closure based filter, but it isn't.
The `product` is a standin for the record, which knows about the column types,
but is just used for ``SQLPredicate`` generation.

Due to the type-safety one can't accidentially compare a number with a string,
e.g. the compiler would forbid this:
```swift
let products = try database.products.fetch {
  $0.age == "FourSomething"
}
```

This is a **fast and flexible** way to filter records as real SQL is produced
that can be used by SQLite as it sees fit (e.g. use indices).

#### Sorting

The `fetch` functions come with an `orderBy` variant:
``SQLRecordFetchOperations/fetch(limit:orderBy:_:)-4ly8m``.

Examples:
```swift
let bodies = try db.solarBodies.fetch(orderBy: \.englishName)
let bodies = try db.solarBodies.fetch(orderBy: \.bodyType, .descending)
```


### Fetching Relationships

When Enlighter detected a relationship, it generates convenience accessors
(can be disabled in the <doc:Configuration>):

```swift
let category = try db.categories.find(5)
let productsForCategory = try db.products.fetch(for: category)
```
The other way around:
```swift
let product = try db.products.find(42)
let categoryOfProduct = try.db.categories.find(for: product)
```

Those are just convenience wrappers for the builtin fetcher functions that
work on the foreign keys:
```swift
let products = try await db.products.fetch(for: \.categoryID, in: category)
let category = try await db.products.findTarget(for: \.categoryID, in: product)
```


### Selecting Individual Columns

One of the advantages of SQL is that individual columns can be selected
and updated for maximum efficiency. Only things that are
required need to be fetched (vs. full records):
```swift
// Fetch just the `id` and `name` columns:
let people = try await db.select(from: \.people, \.id, \.name) {
  $0.id > 2 && $0.title == nil
}
```
Or updated:
```swift
// Bulk update a specific column:
try db.update(\.people, set: \.title, to: nil, where: { record in
  record.name.hasPrefix("Duck")
})
```

The references are fully typesafe down to the schema, only columns
contained in the `person` table can be specified (and are directly available
in Xcode autocompletion).


### Performing raw SQL Queries

As a final escape hatch one can perform raw SQL queries:
```swift
let results = try db.solarBodies.fetch(sql: "SELECT * FROM solar_bodies")
```
This does proper escaping using interpolations, e.g. this is possible:
```swift
let results = try db.persons.fetch(sql:
  "SELECT * FROM person WHERE \($0.personId) LIKE UPPER(\(name))"
)
```

A raw fetch against a specific type (e.g. `solarBodies`) will always return
full records (e.g. `SolarBody`). This still works for fetching fragments though:
```swift
let results = try db.solarBodies.fetch(sql: 
  "SELECT id, name FROM solar_bodies"
)
```
All other properties of the structure will be set to their default values (as
specified in the SQL schema, or a sensible default if that isn't available).

Fetching fragments like that is still reasonably fast, it has a bigger 
associated memory cost vs the targetted ``SQLDatabaseFetchOperations/select(from:_:_:)``.


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
[CustomerAndSuppliersByCity](https://Northwind-swift.github.io/NorthwindSQLite.swift/documentation/northwind/customerandsuppliersbycity).


## Topics

### Important Types

- ``SQLDatabase``
- ``SQLTableRecord``
- ``SQLPredicate``
