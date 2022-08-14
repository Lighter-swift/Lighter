# Linux

Using Lighter on Linux.

## Overview

Lighter itself, and the generated code, works on Linux.
It can be a useful option when shipping large read-only datasets alongside an 
associated endpoint, or for applications that do not require multiple servers.
SQLite is astonishingly fast and easy to deploy, it can be a great alternative
to more complex setups.

Unlike macOS, Linux Swift setups do not bundle the `SQLite3` module.
Lighter includes one for maximum convenience.

During compilation the `libsqlite3` Linux dev package must be available,
e.g. on Debian or Ubuntu systems it can be installed using:
```sh
apt-get update
apt-get install libsqlite3-dev
```

### Example

[NorthwindWebAPI](https://github.com/Lighter-swift/Examples/tree/develop/Sources/NorthwindWebAPI/) 
is a small server side Swift example exposing the DB as a JSON API endpoint, 
and providing a few pretty HTML pages showing data contained.

Example server:
```swift
#!/usr/bin/swift sh
import MacroExpress // @Macro-swift
import Northwind    // @Lighter-swift/NorthwindSQLite.swift

let db  = Northwind.module!
let app = express()

app.get("/api/products") { _, res, _ in
  res.send(try db.products.fetch())
}

app.listen(1337) // start server
```

Example `Package.swift`:
```swift
// swift-tools-version:5.7
import PackageDescription

var package = Package(
  name: "LighterExamples",

  platforms: [ .macOS(.v10_15), .iOS(.v13) ],
  products: [
    .executable(name: "NorthwindWebAPI", targets: [ "NorthwindWebAPI" ])
  ],
  
  dependencies: [
    .package(url: "https://Lighter-swift/Lighter.git", from: "1.0.2"),
    .package(url: "https://Lighter-swift/NorthwindSQLite.swift.git",
             from: "1.0.0"),
    .package(url: "https://github.com/Macro-swift/MacroExpress.git",
             from: "0.8.8")
  ],
  
  targets: [
    .executableTarget(
      name: "NorthwindWebAPI",
      dependencies: [
        .product(name: "Northwind", package: "NorthwindSQLite.swift"),
        "MacroExpress"
      ],
      exclude: [ "views", "README.md" ]
    )
  ]
)
```
