<h2>Tool: GenerateInternalVariadics
  <img src="https://zeezide.com/img/lighter/Lighter256.png"
       align="right" width="64" height="64" />
</h2>

This is a tool that is used as part of this package only (i.e. it is not
a product).

It is called by the `WriteInternalVariadics` command plugin to generate the
"Lighter/Operations/GeneratedVariadicOperations.swift" file.

Which contains the variadic functions for `select`, `update` etc, e.g.:
```swift
@inlinable
func select<T, C1, C2, CS>(
  from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
  _ column1: KeyPath<T.Schema, C1>,
  _ column2: KeyPath<T.Schema, C2>,
  orderBy sortColumn: KeyPath<T.Schema, CS>,
  _ direction: SQLSortOrder = .ascending,
  _ limit: Int? = nil
) async throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
  where C1: SQLColumn, C2: SQLColumn, CS: SQLColumn, T == C1.T, T == C2.T, T == CS.T
```


### Who

Lighter is brought to you by
[Helge Heß](https://github.com/helje5/) / [ZeeZide](https://zeezide.de).
We like feedback, GitHub stars, cool contract work, 
presumably any form of praise you can think of.
