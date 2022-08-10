<h2>Lighter
  <img src="https://zeezide.com/img/lighter/Lighter256.png"
       align="right" width="64" height="64" />
</h2>

**Lighter** is a set of technologies applying code generation to access 
[SQLite3](https://www.sqlite.org) databases from 
[Swift](https://swift.org/), e.g. in iOS applications or on the server.
Like [SwiftGen](https://github.com/SwiftGen/SwiftGen) but for SQLite3.

- Type-safe down to the SQL schema.
- Very, **very**, [fast](https://github.com/Lighter-swift/PerformanceTestSuite).
- Dependency free.

Lighter is useful for two main scenarios:

<details><summary>Shipping SQLite databases within your app (e.g. containing a product database).</summary>

SQLite databases are very resource efficient way to ship and access small
and big amounts of data. As an alternative to bundling JSON resources files that
are large and have to be parsed fully into memory on each start.

With a SQLite database only the required data needs to be loaded and the database files
are extremely compact (e.g. no duplicate keys).

> SQLite database are also efficient and useful for downloading
> data from the network!
</details>

<details><summary>Maintaing a fast local SQL cache or database.</summary>

If the needs are simpler than a full 
[ORM](https://en.wikipedia.org/wiki/Object–relational_mapping)
like
[CoreData](https://developer.apple.com/documentation/coredata), Lighter can be a great way to produce neat and typesafe
APIs for local caches or databases.
It is basic but convenient to use and very very fast as no runtime mapping
or parsing has to happen at all. The code directly binds the generated
structures to the SQLite API.

Databases can be created on the fly or from prefilled database files shipped
as part of the application resources.

> Linux is also supported, and Lighter can be a great choice for simple servers that
> primarily access a readonly set or run on a single host.
</details>

### Overview

Lighter works the reverse from other "mapping" tools or SQLite wrappers. Instead of
writing Swift code that generates SQLite tables dynamically, Lighter generates Swift
code _for a_ SQLite database.
Either literally from SQLite database files, or from SQL files that create SQLite
databases.

<details open>
<summary>Small Example Database (stored in either a SQLite db or created from .sql files):</summary>
  
```sql
CREATE TABLE person (
  person_id INTEGER PRIMARY KEY NOT NULL,
  name      TEXT NOT NULL,
  title     TEXT NULL
);

CREATE TABLE address (
  address_id INTEGER PRIMARY KEY NOT NULL,
  
  street  VARCHAR NULL,
  city    VARCHAR NULL,
  
  person_id INTEGER,
  FOREIGN KEY(person_id) REFERENCES person(person_id) ON DELETE CASCADE DEFERRABLE
);
```

Can be converted to a structure like this (in a highly [configurable](Documentation/Configuration.md) way):
```swift
struct ContactsDB {

  struct Person: Identifiable, Hashable {
    var id       : Int
    var name     : String
    var title    : String?
  }

  struct Address: Identifiable, Hashable {
    var id       : Int
    var street   : String?
    var city     : String?
    var personId : Int?
  }
}
```

The code generator can either generate dependency free code that only uses
the raw SQLite3 API or code that uses the [Lighter](Sources/Lighter/) library.
The Lighter library is not an
[ORM](https://en.wikipedia.org/wiki/Object–relational_mapping),
but just a set of Swift protocols that allow for typesafe queries
(and it is only intended to be used to support the code generator, not as a
 standalone library).
</details>

<details><summary>How does the code generation work?</summary><br/>

The setup is intended to work with the new
[Swift Package Plugins](https://developer.apple.com/videos/play/wwdc2022/110359/)
feature of the
[Swift Package Manager](https://www.swift.org/package-manager/),
available since Swift 5.6 (and exposed in Xcode 14+).
If SPM plugins cannot be used yet, the
[sqlite2swift](Plugins/Tools/sqlite2swift/)
tool can be called directly as well.<br>
If you want to support the project, there is also the
[Code for SQLite3](https://apps.apple.com/us/app/code-for-sqlite3/id1638111010/)
app on the Mac AppStore. It does the same code generation as this FOSS project
in a little more interactive way.

The Lighter package comes with a "build tool plugin" called 
[Enlighter](Plugins/Enlighter/),
that automatically integrates the code generation results into the build process.
If it is added to a target, it'll scan for databases and SQL files and create the
Swift accessors for them:
```swift
.target(name: "ContactsDB", dependencies: [ "Lighter" ],
        resources: [ .copy("ContactsDB.sqlite3") ],
        plugins: [ "Enlighter" ]) // <== tell SPM to use Enlighter on this target
```
This variant is fully automatic, i.e. other code within the `ContactsDB` target
has direct access to the database types (e.g. the `Person` struct above).

As a manual alternative the
[Generate Code for SQLite](Plugins/GenerateCodeForSQLite/)
"command plugin" is provided.
This plugin does the same generation as Enlighter, but is explicitly run by the
developer using the Xcode "File / Packages" menu. It places the resulting code
into the "Sources" folder of the app (where it can be inspected or modified).
</details>

<details open><summary>Accessing a database using the higher level Lighter API</summary>

```swift
// Open a SQLite database embedded in the module resources:
let db = ContactsDB.module!

// Fetch the number of records:
print("Total number of people stored:", 
      try db.people.fetchCount())

// There are various ways to filter, including a plain Swift closure:
let people = try db.people.filter { person in
  person.title == nil
}

// Primary & foreign keys are directly supported:
let person    = try db.people.find(1)
let addresses = try db.addresses.fetch(for: person)

// Updates can be done one-shot or, better, using a transaction:
try await db.transaction { tx in
  var person = try tx.people.find(2)!
  
  // Update a record.
  person.title = "ZEO"
  try tx.update(person)

  // Delete a record.
  try tx.delete(person)
  
  // Reinsert thew same record
  let newPerson = try tx.insert(person) // gets new ID!
}
```
</details>

<details>
<summary>Fetching Individual Columns</summary><br/>

One of the advantages of SQL is that individual columns can be selected
and updated for maximum efficiency. Only things that are
required need to be fetched (vs. full records):
```swift
// Fetch just the `id` and `name` columns:
let people = try await db.select(from: \.people, \.id, \.name) {
  $0.id > 2 && $0.title == nil
}

// Bulk update a specific column:
try db.update(\.people, set: \.title, to: nil, where: { record in
  record.name.hasPrefix("Duck")
})
```

The references are fully typesafe down to the schema, only columns
contained in the `person` table can be specified.
</details>

<details>
<summary>Dependency free SQLite3 API</summary><br/>

The toolkit is also useful for cases in which the extra dependency on
Lighter is not desirable. For such the generator can
produce database specific Swift APIs that work alongside the regular
SQLite API.
```swift
// Open the database, can also just use `sqlite3_open_v2`:
var db : OpaquePointer!
sqlite3_open_contacts("contacts.db", &db)
defer { sqlite3_close(db) }

// Fetch a person by primary key:
let person = sqlite3_person_find(db, 2)
  
// Fetch and filter people:
let people = sqlite3_people_fetch(db) {
  $0.name.hasPrefix("Ja")
}

// Insert a record
var person = Person(id: 0, name: "Jason Bourne")
sqlite3_person_insert(db, &person)
```

There is another style the code generator can produce, it attaches the same
functions to the generated types, e.g.:
```swift
let people = Person.fetch(in: db) { $0.name.hasPrefix("So") }
var person = Person.find(2, in: db)

person.name = "Bourne"
person.update(in: db)
person.delete(in: db)
person.insert(into: db)
```

The main advantage of using the raw API is that no extra dependency
is necessary at all. The generated functions are completely
self-contained and can literally be copied&pasted into places where
needed.
</details>

<details><summary>Beautiful, autogenerated DocC API Comments</summary><br/>
The Lighter code generator can also generate API comments for the database
types.
Example: [Northwind Database](https://Lighter-swift.github.io/NorthwindSQLite.swift/documentation/northwind/employee).
  
<img src="https://zeezide.com/img/lighter/docc-record-type.png" />
<img src="https://zeezide.com/img/lighter/docc-target.png" />

</details>


Interested? 👉 [Getting Started](Documentation/GettingStarted.md).


### Who

Lighter is brought to you by
[Helge Heß](https://github.com/helje5/) / [ZeeZide](https://zeezide.de).
We like feedback, GitHub stars, cool contract work, 
presumably any form of praise you can think of.

**Want to support my work**?
Buy an app:
[Code for SQLite3](https://apps.apple.com/us/app/code-for-sqlite3/id1638111010/),
[Past for iChat](https://apps.apple.com/us/app/past-for-ichat/id1554897185),
[SVG Shaper](https://apps.apple.com/us/app/svg-shaper-for-swiftui/id1566140414),
[Shrugs](https://shrugs.app/),
[HMScriptEditor](https://apps.apple.com/us/app/hmscripteditor/id1483239744).
You don't have to use it! 😀
