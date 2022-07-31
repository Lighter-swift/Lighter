<h2>SPM Command Plugin: WriteInternalVariadics
  <img src="https://zeezide.com/img/lighter/Lighter256.png"
       align="right" width="64" height="64" />
</h2>

This is a plugin that is used as part of this package only (i.e. it is not
a product).

The command needs to be run if the `Lighter.json` settings are changed,
or the API changes.
It is intentionally not a `BuildToolPlugin` (which also works, but hides the
generated file, which we don't want).

It is NOT necessary for embedded lighter setups, which can customize the 
settings on a per target basis as required.

It calls into the `GenerateInternalVariadics` tool to generate the
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
