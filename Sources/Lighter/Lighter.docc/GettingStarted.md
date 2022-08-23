# Getting Started

Setting up Lighter for network caches or as resource databases.


### Quick Setup

The fastest way to get started is to configure it with the Enlighter plugin 
in Xcode 14+.

Five quick steps:
1. **Add** the Lighter **package**:
   In an existing or new Xcode project, add
   **`https://github.com/Lighter-swift/Lighter.git`** as a Swift
   package (e.g. using the "File / Add Packages..." menu, paste the URL
   in the search field).
   **Add the "Lighter" library** when asked for products to add.
2. **Enable** the "Enlighter" build **plugin**:
   1. Select the project in Xcode
   2. Select the Xcode target to be used
   3. Select the **"Build Phases tab"**
   4. Add "Enlighter" to the **"Run Build Tool Plug-ins"** section.
3. **Add a** SQLite **database** to your project (just as a regular file),
   make sure it is copied into the project (i.e. not a reference to some 
   outside file).
   Don't have one handy? The
   [Northwind](https://github.com/Lighter-swift/NorthwindSQLite.swift) 
   database is a nice one to play with:
   [download here](https://github.com/Lighter-swift/NorthwindSQLite.swift/blob/develop/dist/northwind.db).
   **Make sure it is** selected as **a resource** of the Xcode target.
4. **Build** the project. Xcode may ask you to "trust" the "Enlighter" plugin.
   (it is pretty safe, plugins can't do network operations and only write in 
    the assigned sandbox).
5. **Start using the database**. E.g. if the Northwind SQLite file was just
   dropped into a small SwiftUI app:

```swift
@main
struct TestOutLighterApp: App {
  
  let db = Northwind.module!
  @State var products = [ Products ]()
  
  var body: some Scene {
    WindowGroup {
      List(products) { product in
        Text("\(product.productName) (\(product.id))")
      }
      .task {
        products = try! await db.products.fetch()
      }
    }
  }
}
```

> Note: Try Xcode autocompletion! An advantage of the generator is that the
>       Swift compiler knows about all tables, views and columns in the database 
>       and can offer autocompletion on them (similar to SwiftGen).


### Next Steps

When adding the Lighter library as a small dependency is OK,
this covers the Lighter API:

- <doc:LighterAPI>
- [Bodies](https://github.com/Lighter-swift/Examples/tree/develop/Sources/Bodies/):
  a small network cache SwiftUI example app.

If dependency free code is desired, the lower level API is described here:

- <doc:SQLiteAPI>

The 
[Northwind](https://github.com/Lighter-swift/NorthwindSQLite.swift)
database is provided as a Swift package using Lighter, it makes
a nice prefilled database for demo projects:

- <doc:Northwind>


### SQLite3

[SQLite3](https://www.sqlite.org) 
has its own 
 [Getting Started](https://www.sqlite.org/quickstart.html)
page, which is a nice introduction to SQLite itself.
SQLite3 is shipping as a system component with both macOS and iOS and can be 
directly imported (and used from) Swift:
```swift
import SQLite3
```
For <doc:Linux> setups, Lighter includes the necessary `SQLite3` module 
definition.


### Examples

One way to get started is using the 
[Examples](https://github.com/Lighter-swift/Examples/)
repository that is available alongsid Lighter. E.g. it has:

- Demos based on the
  [Northwind](https://Lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/) 
  Database:
  - [NorthwindWebAPI](https://github.com/Lighter-swift/Examples/tree/develop/Sources/NorthwindWebAPI/) 
    (A server side Swift example exposing the DB as a JSON API endpoint, 
     and providing a few pretty HTML pages showing data contained.)
  - [NorthwindSwiftUI](https://github.com/Lighter-swift/Examples/tree/develop/Sources/NorthwindSwiftUI/) 
    (A SwiftUI example that lets one browse the Northwind database. 
     Uses the Lighter API in combination and its async/await supports.)
- Custom database (own SQL):
  - [Bodies](https://github.com/Lighter-swift/Examples/tree/develop/Sources/Bodies/) 
    (A SwiftUI example which loads a list of solar bodies from the
     [web](https://api.le-systeme-solaire.net/en/) and keeps
     an offline-first, local cache in a SQL source based Lighter setup.)

The [Northwind](https://Lighter-swift.github.io/NorthwindSQLite.swift/)
package itself is a demo on how to package up an existing SQLite database as
an own Swift module, for reuse in multiple applications.
