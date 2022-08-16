# Frequently Asked Questions

A collection of questions and possible answers.

## Overview

Any question we should add: [info@zeezide.de](mailto:info@zeezide.de).


## Object Relational Mappers (ORM)

Relationship to [ORMs](https://en.wikipedia.org/wiki/Object–relational_mapping).

### What is different to an ORM?

An **Object** Relational Mapper usually maintains a graph of interconnected
objects (as objects, reference types).

Lighter doesn't do any objects, the Lighter generated model types are structures
that directly map to the SQLite tables and views, in a typesafe manner.

While it can also generate fetchers for relationships, 
it doesn't represent such within the models. 
For example a Northwind `Order` model doesn't have an associated `product`
reference property
(Lighter _does_ generate the `db.products.fetch(for: order)` fetch function 
 though).

Lighter also doesn't do any caching or invalidation, i.e. no 
"managed object context". Lighter record structures are context free (i.e. also
do not refer to the database in any way).


### Is Lighter a replacement for CoreData?

It can be, but it is a lot lower level than CoreData. Which can be an advantage,
especially for performance. It also keeps things simple, less surprises.

CoreData is a rich framework that goes as far as providing direct SwiftUI
integration. 
Lighter doesn't do anything like that **intentionally**. It is supposed to be
_lighter_.
(Stay tuned for Heavier™️.)


### Is Lighter a replacement for ZeeQL?

The [ZeeQL](https://zeeql.io) situation is similar to CoreData.


## SQLite Access Libraries

A set of SQLite Swift libraries are already available.
The most popular one is 
[GRDB.swift](https://github.com/groue/GRDB.swift), 
another is SQLite.swift. ORMs like
ZeeQL also provide low level SQLite access.

### What are advantages over SQLite.swift or GRDB?

Lighter has two main advantages over "regular" libraries:
1. It pre-generates fully typesafe (down to the SQL schema) structures for
   all tables, one doesn't have to type out the structures manually.
2. It pre-generates common queries in highly efficient code, avoiding
   a lot of runtime "mapping overhead" and a lot of temporary allocations.

Both libraries provide `Codable` support that can somewhat mirror the generated
structures (i.e. provide more convenience).
We found Codable to be extraordinarily slow (e.g. >19× slower when using 
SQLite.swift).

- <doc:Performance>
