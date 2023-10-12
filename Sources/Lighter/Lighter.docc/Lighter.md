# ``Lighter``

Type-safe down to the schema. Very, **very**, fast. Dependency free.

@Metadata {
  @DisplayName("Lighter.swift for SQLite3")
}

## Overview

**Lighter** is a Swift toolset to work with [SQLite3](https://www.sqlite.org) 
databases  in a way that is **typesafe** not just on the Swift side, 
but **down to the SQL schema**.
Like [SwiftGen](https://github.com/SwiftGen/SwiftGen) but for SQLite.
It is **not an ORM**, it doesn't do type mapping at runtime.

Like SQLite, the Lighter toolset is very versatile, highly configurable, and 
applicable to a wide range of applications and project setups.
From caches in iOS apps, or documents in Mac apps, to server side datasets.
It isn't just a single tool, it is a set of tools for different usage scenarios.

In short, it takes SQL (or binary SQLite) files like this:
```sql
CREATE TABLE person (
  person_id INTEGER PRIMARY KEY NOT NULL,
  name      TEXT NOT NULL,
  title     TEXT NULL
);
```
and generates Swift code like this:
```swift
struct ContactsDB {

  struct Person: Identifiable, Hashable, Codable {
    var id       : Int
    var name     : String
    var title    : String?
  }
}
```
Alongside the necessary code to work with the tables in the database:
```swift
let people = try await db.people.fetch { $0.name.hasPrefix("Bour") }
var jason  = people[0]
jason.name = "Bourne!"
try await db.transaction { tx in
  try tx.update(jason)
  try tx.insert(jason)
  try tx.delete(jason)
}
```
It works with async/await, or without, 
with a supporting library (Lighter), or dependency free.
Lighter knows about relationships contained in the database and can also
generate code to resolve those:
```swift
let product = try await db.products.find(42)
let orders  = try await db.orders.fetch(for: product)
```
If desired, it generates beautiful DocC documentation within the generated code
([Example](https://Northwind-swift.github.io/NorthwindSQLite.swift/documentation/northwind/employee)).


## Lighter Toolkit Components

The toolkit consists of four major parts:
- The “Lighter” **support library** (only intended to be used in combination with
  generated code, not as a standalone library). It is **optional**.
- The “Enlighter” Swift 5.6 **build plugin** 
  for Xcode and the Swift Package Manager.
- The “Generate Code for SQLite3” Swift 5.6 **command plugin** 
  for Xcode and Swift Package Manager
- The “sqlite2swift” **tool** that can be used to generate SQLite code if the 
  environment doesn't allow for Xcode 14 or Swift 5.6 yet (the generated code
  runs against earlier version).

There is also the the 
 [“Code for SQLite3” application](https://apps.apple.com/us/app/code-for-sqlite3/id1638111010).
A macOS app that does the same like “sqlite2swift”, but as an app.
If you want to support this project, consider buying a copy. Thank you!

There are two associated repositories:
- [Examples](https://github.com/Lighter-swift/Examples/):
  Contains examples on how to use the toolset, including a few SwiftUI
  applications and even a server side API.
- [NorthwindSQLite.swift](https://github.com/Northwind-swift/NorthwindSQLite.swift):
  A version of the Microsoft Access 2000 Northwind sample database, 
  re-engineered for SQLite3, and packaged up as a Swift package
  ([DocC Documentation](https://Northwind-swift.github.io/NorthwindSQLite.swift/documentation/northwind/))!


## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:LighterAPI>
- <doc:Northwind>

### Advanced

- <doc:Configuration>
- <doc:Linux>
- <doc:Manual>
- <doc:SQLiteAPI>
- <doc:Mapping>
- <doc:Migrations>
- <doc:Performance>

### Support

- <doc:Who>
- <doc:FAQ>
- <doc:Troubleshooting>
