# Northwind

Using the Northwind example database.

## Overview

The Northwind database is a common database example that has been ported
to SQLite. 
Lighter provides a Swift version of that in the
[NorthwindSQLite.swift](https://github.com/Lighter-swift/NorthwindSQLite.swift)
repository.

> Note: The particular SQLite version of the Northwind database is quite 
> lacking. For example booleans are stored as TEXTs, many columns are
> inappropriately marked as `NULL`able.<br>
> That actually makes it a good example on how to deal with such databases in
> Lighter.

The Swift Northwind API: [Documentation](https://Lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/).

## Demos

Examples based on the [Northwind](https://Lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/) Database:

- [NorthwindWebAPI](https://github.com/Lighter-swift/Examples/tree/develop/Sources/NorthwindWebAPI/) 
  (A server side Swift example
   exposing the DB as a JSON API endpoint, and providing a few pretty HTML
   pages showing data contained.)

- [NorthwindSwiftUI](https://github.com/Lighter-swift/Examples/tree/develop/Sources/NorthwindSwiftUI/)
  (A SwiftUI example that lets
   one browse the Northwind database. Uses the Lighter API in combination and
   its async/await supports.)

## Getting Started

Add the `https://Lighter-swift.github.io/NorthwindSQLite.swift` as a package
dependency to a Swift Package Manager package.

Then just import `Northwind` and run queries against the database:
```swift
import Northwind

let db = Northwind.module!
for product in try db.products.fetch() {
  print("Product:", product.id, product.productName)
}
```

> Note: It looks like Xcode 14b5 still has an issue when adding Northwind
> (or any package w/ embedded databases) to an Xcode package root.
> In those cases a "local package" can be used to make it work.
> Apple has documented the process in:
> [Organizing Your Code with Local Packages](https://developer.apple.com/documentation/xcode/organizing-your-code-with-local-packages).
