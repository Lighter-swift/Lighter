//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

enum Fixtures {
  
  static func makeSelectDeclaration() -> FunctionDeclaration {
    _ = """
    func select<T, C1, C2>(
      from: KeyPath<Self.RecordTypes, T.Type>,
      _ column1: KeyPath<T.Schema, C1>,
      _ column2: KeyPath<T.Schema, C2>,
      limit: Int? = nil,
      yield: ( C1.Value, C2.Value ) -> Void
    ) throws
    where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T
    """
    
    return FunctionDeclaration(
      name: "select",
      genericParameterNames: [ "T", "C1", "C2" ],
      parameters: [
        .init(keyword: "from", name: "table",
              keyPath: "Self", "RecordTypes", to: "T", "Type"),
        .init(name: "column1", keyPath: "T", "Schema", to: "C1"),
        .init(name: "column2", keyPath: "T", "Schema", to: "C2"),
        .init(name: "limit", type: .optional(.int),
              defaultValue: .literal(.nil)),
        .init(name: "yield", closureParameters: [
          ( "C1", "Value" ), ( "C2", "Value" )
        ], returns: .void)
      ],
      throws: true,
      genericConstraints: [
        .conformance("C1", to: "SQLColumn"),
        .conformance("C2", to: "SQLColumn"),
        .parameter("T", sameAs: "C1", "T"),
        .parameter("T", sameAs: "C2", "T")
      ]
    )
  }
  
  static func makeSelectDefinition() -> FunctionDefinition {
    _ = """
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    
    let sql = builder.generateSelect(limit: limit,
                                     predicate: SQLTruePredicate.shared)
    
    try fetch(sql, builder.bindings) { stmt, _ in
      yield(try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0),
            try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1))
    }
    """
    return FunctionDefinition(
      makeSelectDeclaration(),
      .group([
        .var("builder", .raw("SQLBuilder<T>()")),
        .call(instance: "builder", name: "addColumn",
              withVariables: "column1"),
        .call(instance: "builder", name: "addColumn",
              withVariables: "column2")
      ]),
      .let("sql",
        is: .call(
          instance: "builder", name: "generateSelect",
          parameters: [
            ( "limit",     .variable("limit") ),
            ( "predicate", .variable("SQLTruePredicate", "shared") )
          ]
        )
      ),
      .call(try: true, name: "fetch", parameters: [
        ( nil, .variable("sql") ),
        ( nil, .variable("builder", "bindings" ) )
      ], trailing: ( parameters: [ "stmt", "_" ], statements: [
        .call(name: "yield", parameters: [
          ( nil, .call(try: true, name: "C1.Value.init", parameters: [
            ( "unsafeSQLite3StatementHandle", .variable("stmt") ),
            ( "column", .integer(1))
          ])),
          ( nil, .call(try: true, name: "C2.Value.init", parameters: [
            ( "unsafeSQLite3StatementHandle", .variable("stmt") ),
            ( "column", .integer(2))
          ]))
        ])
      ]))
    )
  }
  
  static let personRecordStruct = TypeDefinition(
    public: true, kind: .struct, name: "Person",
    conformances: [ .name("SQLKeyedTableRecord"), .name("Identifiable") ],
    typeVariables: [
      .let("schema", is: .call(name: "Schema"),
           comment: "Static SQL type information for the `Person` record.")
    ],
    variables: [
      .var("personId"  , .optional(.int),
           comment: "Primary key `person_id`, SQL type `INT`, nullable."),
      .var("lastname"  , .string,
           comment: "Column `lastname`, SQL type `TEXT`, not null"),
      .var("firstname" , .optional(.string),
           comment: "Column `firstname`, SQL type `TEXT`, nullable"),
    ],
    computedProperties: [
      // TBD: What to do with compound keys? Would need to generate a type
      //      for the compound key (which would be quite OK?)
      .var("id", .int,
           comment: "Returns the ``personId`` primary key of the record.",
           .return(.variable("personId")))
    ],
    functions: [
      .init(
        declaration: .makeInit(
          .init(keywordArg: "personId",  .int, .integer(0)),
          .init(keywordArg: "lastname",  .string),
          .init(keywordArg: "firstname", .optional(.string), .nil)
        ),
        statements: [ "personId", "lastname", "firstname" ].map {
          // Note: backtick name!
          .set(instance: "self", $0, .variable($0))
        },
        comment: .init(
          headline: "Initialize a new ``Person`` record.",
          parameters: [
            .init(name: "personId",
                  info: "Primary key in SQL column `person_id`, defaults to `0`"),
            .init(name: "lastname",
                  info: "SQL column `lastname`, required."),
            .init(name: "firstname",
                  info: "SQL column `firstname`, optional, defaults to `nil`.")
          ]
        ),
        inlinable: true
      )
    ],
    comment: .init(
      headline: "Record representing the `person` SQL table.",
      info:
        """
        Record types represent rows within tables in a SQLite database. They are
        returned by the functions or queries/filters generated by Enlighter.
        """,
      examples: [ // generate depending on user config (i.e. what styles)
        .init(
          headline: "Perform record operations on ``Person`` records:",
          code:
            #"""
            let persons = try await db.persons.filter(orderBy: \.firstname) {
              $0.firstname != nil
            }
            
            try await db.transaction { tx in
              var person  = try tx.persons.find(2) // find by primaryKey
              person.lastname = "Hunt"
            
              try tx.update(person)
            
              let newPerson = try tx.insert(person)
              try tx.delete(newPerson)
            }
            """#
        ),
        .init(
          headline: "Perform column selects on ``Person`` records:",
          code:
            #"""
            let values = try await db.select(from: \.persons, \.lastname) {
              $0.in([ 2, 3 ])
            }
            """#
        ),
        .init( // FIXME: make example read/write in real mapper :-)
          headline: "Perform low level operations on ``Person`` records:",
          code:
            """
            var db : OpaquePointer?
            sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil)
            
            let persons = try sqlite3_persons_fetch(db, orderBy: "name", limit: 5) {
              $0.firstname != nil
            }
            
            persons[1].lastname = "Hunt"
            sqlite3_persons_update(db, persons[1])
            
            sqlite3_persons_delete(db, persons[0])
            sqlite3_persons_insert(db, persons[0]) // re-add
            """
        )
      ]
    )
  )
}
