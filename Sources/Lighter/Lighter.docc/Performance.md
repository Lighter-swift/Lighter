# Performance

A quick look at Lighter performance.

## Overview

Lighter comes with a small
[performance test suite](https://github.com/Lighter-swift/PerformanceTestSuite).
It uses the (larger, populated)
[Northwind SQLite](https://github.com/jpwhite3/northwind-SQLite3/)
database as the base set.
It doesn't have the goal to be scientifically proper.

### Results

The suite evaluates the load performance on queries against the "Orders" table,
which has 16K records. The test loads all 16K records on each iteration.

Lighter is expected to perform excellent, as it directly/statically binds
SQLite prepared statements for the generated structures.

M1 Mini with 10 rampup iterations and 500 test iterations.
```
Orders.fetchAll    setup    rampup   duration
  Enlighter SQLite 0        0,135s     6,629s   ~20% faster than Lighter (75/s)
  Lighter          0        0,162s     7,927s   Baseline                 (63/s)
  GRDB             -        -        ~12s       Handwritten Mapping
  SQLite.swift     0        0,613s    30,643s   Handwritten Mapping (>3× slower) (16/s)
  GRDB             0,001    0,995s    49,404s   Codable (>6× slower)     (10/s)
  SQLite.swift     0,001    3,109s   153,172s   Codable (>19× slower)    (3/s)
```

Essentially the specific testcase - with no handcrafting involved - needs 30 
secs on GRDB, which is state of the art, 2.5 minutes w/ SQLite.swift and
not quite 8 secs with the Lighter API.

As a chart:
```
┌─────────────────────────────────────────────────────────────────────────────┐
├─┐                                                                           │
│S│                Enlighter generated raw SQLite API Bindings   ~20% faster  │
├─┘                                                                           │
├──┐                                                                          │
│L3│               Lighter, w/ high level API (baseline)            Baseline  │
├──┘                                                                          │
├─────┐                                                                       │
│GRDB │            with handwritten record mappings              ~50% slower  │
├─────┘                                                                       │
├─────────────┐                                                               │
│SQLite.swift │    with handwritten record mappings               >3× slower  │
├─────────────┘                                                               │
├───────────────────────┐                                                     │
│GRDB with Codable      │                                         >6× slower  │
├───────────────────────┘                                                     │
├───────────────────────────────────────────────────────────────────────────┐ │
│SQLite.swift with Codable                                       >19× slower│ │
├───────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
      Time to load the Northwind "Products" table 500 times into a model.      
                              Shorter is faster.                               
```

*Main takeway*: Never ever use Codable.
