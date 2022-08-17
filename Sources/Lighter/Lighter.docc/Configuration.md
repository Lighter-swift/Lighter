# Configuration

The `Lighter.json` configuration file.

## Introduction

The code generator can be configured by placing a JSON file called
`Lighter.json` in the root of the project (either Xcode project or
SPM package).

The configurations has five main areas:

- Global:            Detected file extensions.
- `CodeStyle`:       Style and Formatting, Tabs or Spaces?
- `EmbeddedLighter`: Control generation of variadic functions (`select` etc).
- `SwiftMapping`:    Mapping SQL tables to Swift types and names.
- `CodeGeneration`:  How to write the mapped schema to Swift.

### Per Target and per Database Configuration

All sections except global can be overridden on a per-target basis by including 
the target name as a subsection, and then optionally the database name.

In example below there is a specific configuration for the
`ContactsTestDB` target. 
E.g. it overrides `EmbeddedLighter` not to use an embedded Lighter API.
And then it overrides things for the `OtherDB` database within that
`EmbeddedLighter` target, e.g. not to generate the "raw" API.

Example:
```json
{
  "databaseExtensions" : [ "sqlite3", "db", "sqlite" ],
  "sqlExtensions"      : [ "sql" ],
  
  "CodeStyle": {
    "functionCommentStyle" : "**",
    "indent"               : "  ",
    "lineLength"           : 80
  },
  "EmbeddedLighter": {
    "inserts": 6
  },
  
  "ContactsTestDB": {
    "EmbeddedLighter": null,
    
    "OtherDB": {
      "CodeStyle": {
        "comments": {
          "types"      : "",
          "properties" : "",
          "functions"  : ""
        }
      },
      "CodeGeneration": {
        "Raw"                            : "none",
        "readOnly"                       : true,
        "generateAsyncFunctions"         : false,
        "embedRecordTypesInDatabaseType" : true
      }
    }
  }
}
```


### Global

At the root two keys can exist:
- `databaseExtensions`
- `sqlExtensions`

Both are arrays of strings which contains the respective file extensions and
are used by the plugins to locate input files.

Example:
```json
{
  "databaseExtensions" : [ "sqlite3", "db", "sqlite" ],
  "sqlExtensions"      : [ "sql" ]
}
```

### CodeStyle

Style and Formatting, Tabs or Spaces?

Example:
```json
"CodeStyle": {
  "comments"   : { "functions": "**" },
  "indent"     : "  ",
  "lineLength" : 80
}
```

The available comment styles are:
- `**`: DocC comments like those:
  ```swift
  /**
   * A type
   */
  struct Person {...}
  ```
- `///`: DocC comments like those:
  ```swift
  /// A primary key
  var id : ID { ... }
  ```
- `*`: Non-DocC comments:
  ```swift
  /*
   * A type
   */
  struct Person {...}
  ```
- `//`: Non-DocC comments:
  ```swift
  // A primary key
  var id : ID { ... }
  ```
- `""` (empty, no comments)

Keys:
- `comments`  (Dictionary): The comment styles for various Swift things:
  - `types`       (String): Comment style for structures and classes.
  - `properties`  (String): Comment style for Swift properties.
  - `functions`   (String): Comment style for Swift functions.
- `comments`      (String): The comment styles to use for everything.
- `indent` (String or Int): If a string, use that for indenting (e.g. `"\t"`),
                            if a number, the number of spaces to use.
- `lineLength`       (Int): The suggested maximum line length (not guaranteed).
- `neverInline`     (Bool): If true, nothing is marked `@inlinable`.


### EmbeddedLighter

Control generation of variadic functions (`select` etc).

This is only used within Lighter itself at this time. It configures the number
of variadic functions that are generated for `select`, `update` and `insert`.


### SwiftMapping

Mapping SQL tables to Swift types and names.

Keys:
- `databaseTypeName` (String): Can be used to set the type of the database
  structure. Normally derived from the input filenames.
- `databaseTypeName` (Dictionary): How to derive the database structure name
  from filenames:
  - `dropFileExtensions` (Bool)
  - `capitalize` (Bool): E.g. `person.db` becomes `Person`.
  - `camelCase`  (Bool): E.g. `person_database.sql` becomes `PersonDatabase`.
- `recordTypeNames` (Dictionary): Configure the names of the record structures
  that are generated (from table and view names):
  - `singularize` (Bool): `Orders` => `Order`.
  - `capitalize`  (Bool): `orders` => `Orders`.
  - `camelCase`   (Bool): `order_assignments` => `OrderAssignments`.
- `recordReferenceNames` (Dictionary): Configure the names of record
  "references". This is what is used to access the tables from the database,
  like `db.people.find` (the `people`):
  - `decapitalize`: `Orders` => `orders`.
  - `pluralize`:    `person` => `people`.
- `propertyNames` (Dictionary): Configure the names of the properties generated
  for database columns:
  - `decapitalize` (Bool): `OrderId` => `orderId`.
  - `camelCase`    (Bool): `person_id` => `personId`.
- `keys` (Dictionary): Configure primary and foreign key detection:
  - `primaryKeyName`: Whether to use a single fixed property name (e.g. `id`)
    for all non-compound primary keys.
  - `autodetect` (Array of Strings): The names by which keys are detected,
    defaults to "id", "ID", "Id", "pkey", "primaryKey", "PrimaryKey", "key", "Key".
  - `autodetectWithTableName`      (Bool)
  - `autodetectForeignKeys`        (Bool)
  - `autodetectForeignKeysInViews` (Bool)
- `relationships`: Whether relationships should be derived from foreign keys
  and how:
  - `deriveFromForeignKeys` (Bool)
  - `strippedForeignKeySuffixes` (Array of Strings)
- `typeMap` (Dictionary): This is used to map SQL types to Foundation types,
  or actually any type that implements ``SQLiteValueType``.
  For example `UUID` to `UUID`.
  When using Lighter own types can be added by implementing ``SQLiteValueType``.
- `columnSuffixToType` (Dictionary): Similar to `typeMap`, this matches
  against the name of a column to define the type.
  For example `_date` could be mapped to `Date` and `start_date`, `end_date`
  etc would all be generated as `Date` values.


### CodeGeneration

How to write the mapped schema to Swift.

Keys:
- `omitCreationSQL` (Bool): 
  Whether the SQL to create the database should be included.
  That is `CREATE TABLE`, `CREATE VIEW`, ... statements.
  It sames some space to disable those if Swift isn't used to bootstrap SQL
  database from scratch (vs. copying them from a file).
- `readOnly` (Bool): Only generate read operations. I.e. there will be no
  `update`, `delete` or `insert` operations.
  Useful if a database is just shipped as a backing resource, e.g. a set of
  product descriptions, countries, and so on. Saves on the codesize and makes
  sure that no accidential modifications are possible.
- `generateAsyncFunctions` (Bool): 
  Generate async/await Lighter conformances (if `useLighter` is enabled).
  This is only available for Lighter, not the dependency free API.
  It allows calling Lighter APIs using the new Swift 5.5 async/await feature.
  Example:
  ```swift
  let products = try await db.products.fetch { $0.age < 10 }
  try await db.transaction { tx in
    try tx.products.delete(10)
  }
  ```
- `embedRecordTypesInDatabaseType` (Bool):
  Whether record types should be generated as subtypes of the database types.
  Example if `true`:
  ```swift
  struct TestDatabase {
    struct Person: TableRecord { ... }
  }
  ```
  Example if `false`:
  ```swift
  struct TestDatabase {
  }
  struct Person: TableRecord { ... }
  ```
- `public` (Bool): 
  Whether the API should be generated as `public` API (vs `internal`).
  Example if `true`:
  ```swift
  public struct TestDatabase {
    public struct Person: TableRecord { ... }
  }
  ```
  Example if `false`:
  ```swift
  struct TestDatabase {
    struct Person: TableRecord { ... }
  }
  ```
- `inlinable` (Bool): 
  Whether public functions should be generated as `@inlinable`.
  This exposes the function sources in the module header, which is
  good for the Swift optimizer. Example:
  ```swift
  @inlinable
  public init(id: String, name: String, ...)
  ```
- `allowFoundation` (Bool):
  Whether `Foundation` types like `Date`, `UUID`, `URL` or `Data` can be used.
  It can be useful to disable this in some server deployment scenarios, e.g.
  when using AWS Lambda.
- `dateSerialization` (String):
  - If set to `"formatter"`, `"text"` or `"string"`, Foundation `Date` values
    will be stored as `TEXT` in the SQL database. E.g. `"1973-01-31 12:12:12"`.
  - If set to `"timestamp"`, `"utime"` or `"timeintervalsince1970"`, 
    Foundation `Date` values will be stored as `REAL` values (doubles),
    storing the seconds since 1970 (a Unix timestamp).
- `dateFormat` (String):
  This is used in circumstances when Foundation `Date` values are either
  generated as textual values for columns (`dateSerialization` is `.formatter`)
  or when String values are returned by the database and need to be parsed.
  The default SQLite date format is `"1973-01-31 12:12:12"`.
  Note: `DateFormatter` is quite slow in parsing, if performance is a concern
  prefer to store dates as timestamps.
- `uuidSerialization` (String):
  - If set to `"text"`, `"string"` or `"readable"`, Foundation `UUID` values
    will be stored as `TEXT` int he SQL database 
    (e.g. `B7D94E7E-EEE3-4E0A-A927-90748B73AA30`, 36 ASCII characters).
  - If set to `"blob"`, `"bytes"` or `"data"`, `UUID` values will be stored as
    compact, 16-byte `uuid_t` values. I.e. in a more compact manner that
    requires no parsing.
- `recordTypeAliasSuffix` (optional String):
  This is used for the case when reference names (like `\.person`) match
  the type name (e.g. `person`). Rare, but can happen.
  In this case a `personRecordType` alias would be generated (with `RecordType`
  being the configured suffix).
- `showViewHintComment` (Bool):
  Can be used to disable the hints to use 
  [SQL Views](https://www.sqlite.org/lang_createview.html)
  to define complex queries (only shown if views are not used already).
- `commentsWithSQL` (Bool):
  Whether the SQL used to create a table is put into the *documentation* of the
  associated structure.
- `qualifiedSelf` (Bool):
  Whether properties should be accessed using `self.property` instead of the
  implicit `property`.
- `extraRecordConformances` (Array of Strings):
  This is by default set to `[ "Codable" ]`. It specified additional protocols
  the generated records should conform to (apart from Lighter generated ones).
  Note that `Identifiable` and `Hashable` are usually automatic (if applicable).
- `swiftFilters` (Bool):
  Whether Swift filter matcher should be generated.
  (I.e. the ability to use a regular Swift closure instead of a SQL where 
   qualifier).
- `propertyIndexPrefix` (String):
  Each table gets a specific `PropertyIndicies` tuple type assigned. It contains
  the static (bind, value or argument) position of each property in a query.
  It looks like `PropertyIndicies = ( idx_id, idx_name, idx_city )`.
  This option configures the prefix of those tuple members (`idx_` by default).
- `optionalHelpersInDatabase` (Bool):
  Instead of creating them as local functions, put helper functions into the
  Database object as static methods.
  It is useful to keep them locally, if the generated struct is just
  intended for copy&paste use (because the source is becomes self-contained).

#### Subsection `Lighter`

If the `Lighter` key is set to `"none"`, `"no"`, `"false"` or `null`, 
the API depending on the `Lighter` support library is not generated.
This mostly affects conformances/mixins which provide the extra functionalities.
For example the records won't be marked as `SQLTableRecord` etc.

If the `Lighter` key is set to `"use"` or `"yes"`, `"import"` or `"reexport"`
the `Lighter` conformances will be generated.
If it is `"import"` the `Lighter` lib will be imported as usual, if set to
`"reexport"` it will be re-exported as part of the current module
(Useful if the package/target is itself a library providing access to a 
 database, the consumer won't have to import `Lighter` separately).

If the key is a dictionary again, it'll enable Lighter and contain those 
subkeys:
- `import` (String or Bool): The import style as described above.
- `reexport` (Bool): Whether to re-export Lighter APIs.
- `relationships` (Bool): Whether to generate specific functions to follow
  relationship (e.g. `db.orders.fetch(for: product`).
- `useSQLiteValueTypeBinds` (Bool): Whether the ``SQLiteValueType`` protocol
  should be used to bind values (vs code generating the static type).
- `Examples` (dictionary): Single bool subkey: `select`, whether select
  examples should be included in the documentation.


#### Subsection `Raw`

If the `Raw` key is set to `"none"`, `"omit"` or `null`, 
the dependency free, lower level SQLite API is not generated
(e.g. `sqlite3_fetch_people()` etc).

If it key is set to `"RecordType"` or `"attachToRecordType"`,
the low level API will be generated as methods on the structures.
E.g. instead of a global `sqlite3_fetch_people()` function, 
the generator will generated:
```swift
extension Person {
  static func fetch(in database: OpaquePointer) -> [ Person ] {...}
}
```

If the key is set to another string, it'll be used as the prefix of the
global functions (defaults to `"sqlite3_"`). 
E.g. when set to `"mydb_"`, the function names would be `mydb_people_fetch()`,
`mydb_person_insert()`.

If the key is a dictionary again, it contains those subkeys:
- `prefix`: The global function name prefix like described above, if empty or
            missing, the functions will be attached to the record.
- `relationships`: Whether functions to fetch foreign keys should be generated.
- `hashable`:      Whether the record structures should be marked as `Hashable`.



### Complete Example

```json
{
  "databaseExtensions" : [ "sqlite3", "db", "sqlite" ],
  "sqlExtensions"      : [ "sql" ],
  
  "CodeStyle": {
    "functionCommentStyle" : "**",
    "indent"               : "  ",
    "lineLength"           : 80
  },
  
  "ContactsTestDB": {
    "EmbeddedLighter": null,
    
    "CodeGeneration": {
      "Lighter": {
        "__doc__":
          "Can use re-export to re-export Lighter API as part of the DB.",
        "import": "import"
      }
    },
    
    "OtherDB": {
      "CodeStyle": {
        "comments": {
          "types"      : "",
          "properties" : "",
          "functions"  : ""
        }
      },
      "CodeGeneration": {
        "Raw"                            : "none",
        "readOnly"                       : true,
        "generateAsyncFunctions"         : false,
        "embedRecordTypesInDatabaseType" : true
      }
    }
  },
  
  "EmbeddedLighter": {
    "selects": {
      "syncYield"  : "none",
      "syncArray"  : { "columns": 6, "sorts": 2 },
      "asyncArray" : { "columns": 6, "sorts": 2 }
    },
    "updates": {
      "keyBased"       : 6,
      "predicateBased" : 6
    },
    "inserts": 6
  }
}
```
