# Migrations

Detecting schema changes and performing schema upgrades.

## Overview

In the context the term "migration" means dealing with changes to the database
schema.
For example v1 of an app might have created a database table that looks like
this:
```sql
CREATE TABLE contact (
    id   INT  NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);
```
And v2 of the app added an `age` field:
```sql
ALTER TABLE contact ADD COLUMN age INT NULL;
```
Resulting in a new schema:
```sql
CREATE TABLE contact (
    id   INT  NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    age  INT  NULL
);
```

> Note: This only is relevant for databases that are not packaged as resources,
> e.g. caches or document databases. Resource database always automatically
> match up with the generated code.

When the new v2 version of the app is released, existing users might still
have a v1 database.
"Migrations" is the process to deal with that.

How migrations should be handled depends a *lot* on the actual use case. 
There are various approaches on dealing with them.
Lighter (like SQLite) itself doesn't have migration functionality builtin, 
but it is easy to build such on top.


### Detecting Old Database Versions

One (and the recommended) SQLite way to communicate schema changes is the
[`PRAGMA user_version`](https://www.sqlite.org/pragma.html#pragma_user_version).
This pragma is simply an persistent integer value that the user can set to 
anything.
But its most common use is as a schema change indicator.

For example the above SQL should be done like this:
```sql
CREATE TABLE contact (
    id   INT  NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);
PRAGMA user_version = 1; -- tag the schema version
```
Then if the schema is modified, that version should be bumped:
```sql
ALTER TABLE contact ADD COLUMN age INT NULL;
PRAGMA user_version = 2; -- tag the new schema version
```

Now when the application starts up (or a document is opened), it can retrieve
this version:
```swift
let fileVersion = try database.get(pragma: "user_version", as: Int.self)
```
Which will return `1` for old database files and `2` for v2 database files.

The version the database had when generating the Swift code for it
is stored in the `userVersion` property of the database structure.
To detect whether something has changed with respect to the running code:
```swift
let fileVersion = try database.get(pragma: "user_version", as: Int.self)
if fileVersion != BodiesDB.userVersion {
    print("The database version has changed!")
}
```

> Important: What a version change **means** is entirely application specific,
> and its requirements for downwards and upwards compatibility.
> It is tempting to say that each version bump needs to result in a migration,
> but that isn't necessarily true.
> If the change was purely additive (e.g. another table got added), 
> an application might still work with the "older" database file but reduce
> the available functionality (maybe letting the user decide to "upgrade").


### Simple Solution for Caches: Drop & Recreate

If the database is really just used as a network cache for offline first,
and not so large that a cache rebuild would be expensive,
just dropping the cache database can be quick option.

A good place to do this is the `init` of an application for app-wide databases
e.g. from the 
[Solar Bodies](https://github.com/Lighter-swift/Examples/tree/develop/Sources/Bodies/)
example:
```swift
@main
struct BodiesApp: App {
    
    let database = try! BodiesDB.bootstrap(into: .cachesDirectory)
    
    init() {
        let schemaVersion =
            try! database.get(pragma: "user_version", as: Int.self)
        if schemaVersion != BodiesDB.userVersion {
            print("Dumping cache, the version is outdated.")
            _ = try! BodiesDB.bootstrap(into: .cachesDirectory, overwrite: true)
        }
    }
...
}
```
This makes sure the database is the latest prior being used by any
SwiftUI Views.

### Simple Solution for Caches: Version the Filename

If different applications or extensions share the same cache, it can also
be useful to put it into a version filename:
```swift
let filename = "BodiesDB-\(BodiesDB.userVersion).sqlite3"
let database = 
    try BodiesDB.bootstrap(into: .cachesDirectory, filename: filename)
```
This way different versions can co-exist.


### SQL Resource File Based Migrations

When generating the Swift code, Enlighter and companions do not only look at
individual files, e.g. `BodiesDB.sql`. They actually group files with the same
name together, e.g. `BodiesDB.sql` and `BodiesDB-create-indices.sql` would both
form a group that results in the `BodiesDB` database.

Since the group is applied after being sorted, this can be used to implement
a really easy migration mechanism. Simply put each migration into a simple
file with the version being part of the file name:

1. File `ContactsDB-001.sql`:
   ```sql
   CREATE TABLE contact (
       id   INT  NOT NULL PRIMARY KEY,
       name TEXT NOT NULL
   );
   PRAGMA user_version = 1; -- tag the schema version
   ```
2. File `ContactsDB-002.sql`:
   ```sql
   ALTER TABLE contact ADD COLUMN age INT NULL;
   PRAGMA user_version = 2; -- tag the new schema version
   ```

Enlighter will combine both files into the `ContactsDB` structure. If the files
are also embedded as resource files into the application bundle, they can be
executed at runtime (pseudo code):
```swift
let fileVersion = try database.get(pragma: "user_version", as: Int.self)
guard fileVersion < BodiesDB.userVersion else { return }

for i in (fileVersion + 1)...BodiesDB.userVersion {
    let filename = "ContactsDB-\(leftpad(i, 3)).sql" // ;-)
    let url = Bundle.main.urlForResource(filename, ofType: "sql")
    let sql = try String(contentsOf: url)
    try database.execute(sql)
}
```


### During Development

When the SQL for a database is still being developed on and modified often, 
the developer may want to start out with a clean database with the latest schema
on startup.
This can be done using the `overwrite` parameter in the `bootstrap` functions,
e.g. from the 
[Solar Bodies](https://github.com/Lighter-swift/Examples/tree/develop/Sources/Bodies/)
example:
```swift
@main
struct BodiesApp: App {
  
    #if DEBUG
    let database = try! BodiesDB.bootstrap(overwrite: true)
    #else
    let database = try! BodiesDB.bootstrap()
    #endif
    ...
}
```
Using the `#if DEBUG` is recommended, so that an `overwrite` doesn't 
accidentially leak into a production deployment.


### Keeping Multiple Code Versions in the App

It is also possible to keep generated Swift code for multiple version in a
single app.
Simply keep both versions as separate "databases". E.g. `OldContactsDB.sql` and
`NewContactsDB.sql`.

Then use the `embedRecordTypesInDatabaseType` <doc:Configuration>, and only
set it to `false` for the latest database 
(or set it to `true` for all versions).
It'll end up with something like this:

```swift
struct OldContactsDB: SQLDatabase {

    struct Contact: SQLTableRecord {} // the older version
}
struct NewContactsDB: SQLDatabase {
}
struct Contact: SQLTableRecord {} // the latest version
```

This way different versions of database files can be used with generated code,
only the database struct has to be toggled.

The same is possible w/ the SQLite3 API when the type-attached function 
generators are used.


### SQLite Schema Modification Specifics

Schema migrations sometimes require custom work due to SQLite limitations,
this is a good document on the specifics:
[SQLite ALTER TABLE](https://www.sqlite.org/lang_altertable.html#making_other_kinds_of_table_schema_changes).
