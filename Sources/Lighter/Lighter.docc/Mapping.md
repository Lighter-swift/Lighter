# Mapping

Mapping Data retrieved from the Database.

## Overview

Lighter directly represents the SQLite database schema as Swift structures
and has only limited mapping capabilities.
This is intentional, the library isn't supposed to be a mapping framework.

### Column Value Mapping

Lighter and Enlighter has support for those types builtin (the 
[core SQLite types](https://www.sqlite.org/datatype3.html)):
- `Int`       (SQL `INTEGER`)
- `Double`    (SQL `REAL`)
- `String`    (SQL `TEXT`)
- `[ UInt8 ]` (SQL `BLOB`)

And those Foundation types (if Foundation is enabled in the 
<doc:Configuration>):
- `URL`
- `Data`
- `UUID`
- `Date`
- `Decimal`

All column values must conform to `Hashable` (which also makes all Lighter 
record structures `Hashable`&`Equatable`, often a convinient thing.

The type used for a column is derived from the database schema type for the
core SQLite3 types, and can be further configured by the 
`typeMap` and `columnSuffixToType` <doc:Configuration>'s:

- `typeMap` (Dictionary): This is used to map SQL types to Foundation types,
  or actually any type that implements ``SQLiteValueType``.
  For example `UUID` to `UUID`.
  When using Lighter own types can be added by implementing ``SQLiteValueType``.
- `columnSuffixToType` (Dictionary): Similar to `typeMap`, this matches
  against the name of a column to define the type.
  For example `_date` could be mapped to `Date` and `start_date`, `end_date`
  etc would all be generated as `Date` values.

The default `typeMap` for Foundation types:
```swift
[ "uuid"      : .uuid,
  "UUID"      : .uuid,
  "url"       : .url,
  "URL"       : .url,
  "Data"      : .date,
  "DECIMAL"   : .decimal,
  "decimal"   : .decimal,
  "NUMERIC"   : .decimal,
  "numeric"   : .decimal,
  "TIMESTAMP" : .date,
  "timestamp" : .date,
  "DATETIME"  : .date,
  "datetime"  : .date ]
```


### User Defined Column Types

When using the dependency-free SQLite3 API additional types cannot be used.
Additional mapping has to be done at a higher level.

When using the Lighter API, new types can be introduced by adding the type
name to the configuration and implementing the ``SQLiteValueType`` protocol.
Since the custom values must be backed by one of SQLite builtin types,
it is often possible to work on top of the existing implementations of
``SQLiteValueType`` by `Int`, `String` etc.

`RawRepresentable` Enumerations have predefined support, 
e.g. that works just by tagging the enum as ``SQLiteValueType``:
```swift
enum SolarBodyType: String, SQLiteValueType {
  case asteroid = "Asteroid"
  case moon     = "Moon"
  case planet   = "Planet"
}
```

Manual example implementation for `UUID`s, backed by Strings:
```swift
extension UUID : SQLiteValueType {
      
  init(unsafeSQLite3StatementHandle stmt: OpaquePointer!, column: Int32) throws {
    let s = try String(unsafeSQLite3StatementHandle: stmt, column: column)
    guard let value = UUID(uuidString: s) else { throw Error() }
    self = value
  }
  init(unsafeSQLite3ValueHandle value: OpaquePointer?) throws {
    let s = try String(unsafeSQLite3ValueHandle: value)
    guard let value = UUID(uuidString: s) else { throw Error() }
    self = value
  }
  
  var sqlStringValue     : String { uuidString.sqlStringValue }
  var requiresSQLBinding : Bool   { true }
  
  func bind(unsafeSQLite3StatementHandle stmt: OpaquePointer!,
            index: Int32, then execute: () -> Void)
  {
    uuidString
      .bind(unsafeSQLite3StatementHandle: stmt, index: index, then: execute)
  }
}
```
Those are the things required during column mapping both ways.


## Mapping at a Higher Level

There are various options on where to place more general mapping code.

Let's assume the record structure mapped for the Northwind 
[Product Category](https://lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/category)
table. It looks like this:
```swift
public struct Category : Identifiable, Codable {
  
  public var id           : Int?
  public var categoryName : String?
  public var description  : String?
  public var picture      : [ UInt8 ]?
}
```

It carries an embedded JPEG in the
[picture](https://lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/category/picture)
column, as a BLOB (i.e. just bytes).
It would be nice to have this mapped to a `UIImage` for display.
And maybe make the `categoryName` available as just `name`, and remove the
optionality and make it an empty String when `nil`.

### Map Using Swift Type Extensions

The generated code can be extended just like normal code. To add our `image`
column, we could so a simple:
```swift
extension Category {

  var name  : String   { categoryName ?? "" }
  var image : UIImage? { UIImage(data: Data(picture ?? [])) }
}
```

### Map Using a View Model

Something which is commonly done anyways is mapping model data to a view model:
```swift
struct CategoryViewModel: Equatable, Identifiable {

  let id    : Int
  let name  : String
  let image : UIImage?

  init(_ category: Category) {
    self.id    = category.id ?? -1
    self.name  = category.categoryName ?? ""
    self.image = UIImage(data: Data(category.picture ?? []))
  }
}
```

### Map using `@dynamicMemberLookup`

The [`@dynamicMemberLookup`](http://www.alwaysrightinstitute.com/swift-dynamic-callable/)
feature is useful during mapping, as it allows easing wrapping of existing
types.

For example to enhance the `Category` structure with the additional properties,
but _also_ keep the `Category` properties available this can be done:
```swift
@dynamicMemberLookup
struct ExtendedCategory {
  
  let category : Category
  
  var name  : String   { self.categoryName ?? "" }
  var image : UIImage? { UIImage(data: Data(self.picture ?? [])) }
  
  subscript<V>(dynamicMember keyPath: KeyPath<Category, V>) -> V {
    category[keyPath: keyPath]
  }
}
```
The extended category can be used like this:
```swift
let categories = try db.categories.fetch().map(ExtendedCategory.init)
categories[0].id    // works because of the `@dynamicMemberLookup`
categories[0].image // also works
```


## Topics

### Types

- ``SQLiteValueType``
