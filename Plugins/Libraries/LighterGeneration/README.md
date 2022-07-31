<h2>Lighter Code Generation
  <img src="https://zeezide.com/img/lighter/Lighter256.png"
       align="right" width="64" height="64" />
</h2>

This contains the code generation parts of Enlighter.

Not a beautiful thing, but hey, it is a code generator! :-)

Parts:

- [RecordGeneration](RecordGeneration/) is the main code generator that produces
  Swift AST nodes from the [GenModel](GenModel/) as configured in the
  [LighterConfiguration](LighterConfiguration/).
- [GenModel](GenModel/) represents the database model that should be generated.
  If is derived from a schema as loaded by the 
  [SchemaLoader](SchemaLoader.swift).
- [LighterConfiguration](LighterConfiguration/) deals with loading and
  processing the `Lighter.json` configuration file.
- [VariadicGeneration](VariadicGeneration/) implements the generation of the
  variadic functions for column selects and updates (e.g. `select<C1>(...),
  `select<C1, C2>(...)` etc).


### Who

Lighter is brought to you by
[Helge Heß](https://github.com/helje5/) / [ZeeZide](https://zeezide.de).
We like feedback, GitHub stars, cool contract work, 
presumably any form of praise you can think of.
