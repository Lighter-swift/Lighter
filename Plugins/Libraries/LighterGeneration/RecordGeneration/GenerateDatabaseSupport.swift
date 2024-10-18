//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {

  func generateRawCreateFunction(name: String, moduleFileName: String? = nil)
       -> FunctionDefinition
  {
    let isTypeFunc = options.rawFunctions == .attachToRecordType
    assert(shouldGenerateCreateSQL)
    
    return FunctionDefinition(
      declaration: .init(
        public: options.public, name: name,
        parameters: [
          .init(keyword: nil, name: "path",
                type: .name("UnsafePointer<CChar>!")),
          .init(keyword: nil, name: "flags",
                type: .int32,
                defaultValue:
                  .raw("SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE")),
          .init(keyword: isTypeFunc ? "in" : nil, name: "db",
                type: .inout(.optional(.name("OpaquePointer"))))
        ],
        throws: false, returnType: .int32
      ),
      statements: [
        .let("openrc",
             is: .call(name: "sqlite3_open_v2",
                       .variable("path"), .raw("&db"), .variable("flags"),
                       .nil)),
        .ifSwitch((
          .cmp(.variable("openrc"), .notEqual, .variable("SQLITE_OK")),
          .return(.variable("openrc"))
        )),

        .let("execrc",
             is: .call(name: "sqlite3_exec",
                       .variable("db"), .variable(database.name, "creationSQL"),
                       .nil, .nil, .nil)),
        .ifSwitch((
          .cmp(.variable("execrc"), .notEqual, .variable("SQLITE_OK")),
          .group([
            .call(name: "sqlite3_close", .variable("db")),
            .set("db", .nil),
            .return(.variable("execrc"))
          ])
        )),
        .return(.variable("SQLITE_OK"))
      ],
      comment: FunctionComment(
        headline: "Create a SQLite3 database",
        info:
          """
          The database is created using the SQL `create` statements in the
          Schema structures.
          
          If the operation is successful, the open database handle will be
          returned in the `db` `inout` parameter.
          If the open succeeds, but the SQL execution fails, an incomplete
          database can be left behind. I.e. if an error happens, the path
          should be tested and deleted if appropriate.
          """,
        example:
          isTypeFunc
          ? """
            var db : OpaquePointer!
            let rc = \(database.name).\(name)(path, in: &db)
            """
          : """
            var db : OpaquePointer!
            let rc = \(name)(path, &db)
            """,
        parameters: [
          .init(name: "path",  info: "Path of the database."),
          .init(name: "flags", info: "Custom open flags."),
          .init(name: "db", info: "A SQLite3 database handle, if successful.")
        ],
        throws: false,
        returnInfo: "The SQLite3 error code (`SQLITE_OK` on success)."
      ),
      inlinable: options.inlinable
    )
  }
  
  /// This doesn't really do much.
  func generateRawModuleOpenFunction(name: String, for filename: String)
       -> FunctionDefinition
  {
    // Either as global or as type attached!
    let isTypeFunc = options.rawFunctions == .attachToRecordType
    return FunctionDefinition(
      declaration: .init(
        public: options.public, name: name, parameters: [
          .init(keyword: nil, name: "path",
                type: .name("UnsafePointer<CChar>!")),
          .init(keyword: nil, name: "flags",
                type: .int32,
                defaultValue: options.readOnly
                ? .variable("SQLITE_OPEN_READONLY")
                : .variable("SQLITE_OPEN_READWRITE")),
          .init(keyword: isTypeFunc ? "in" : nil, name: "db",
                type: .inout(.optional(.name("OpaquePointer"))))
        ],
        returnType: .int32
      ),
      statements: [
        .return(
          .call(name: "sqlite3_open_v2",
                .variable("path"), .raw("&db"), .variable("flags"), .nil)
        )
      ],
      comment: .init(
        headline : "Open the embedded SQLite3 database.",
        info     : nil, // Later
        example  : nil, // Later
        parameters: [
          .init(name: "path",  info: "Path of the database."),
          .init(name: "flags", info: "Open flags, e.g. `SQLITE_OPEN_READONLY`"),
          .init(name: "db", info: "A SQLite3 database handle, if successful.")
        ],
        returnInfo: "Returns the SQLite3 error code"),
      inlinable: options.inlinable
    )
  }

  /**
   * Generate the static `module` for resource based database structs.
   *
   * ```
   * static let module : OurDatabase! = {
   *   guard let url = Bundle.module.url(forResource: "contacts",
   *                                     withExtension: "sqlite3") else {
   *     assertionFailure("Did not find database resource?")
   *     return nil
   *   }
   *   return OurDatabase(simplePoolForURL: url, readOnly: true)
   * }()
   * ```
   */
  func generateModuleSingleton(name propertyName: String = "module",
                               for filename: String) -> Struct.InstanceVariable
  {
    let name : Expression
    let ext  : Expression
    if let idx = filename.lastIndex(of: ".") {
      name = .string(String(filename[..<idx]))
      ext  = .string(String(filename[idx...].dropFirst()))
    }
    else {
      name = .string(filename)
      ext  = .nil
    }
    
    return .let(public: options.public,
                propertyName,
                type: .name(database.name + "!"),
         is: .inlineClosureCall([
          // `.module` is not available in Xcode app targets! It is generated
          // by SPM it seems.
          .raw("#if SWIFT_PACKAGE"),
          .let("bundle", is: .variable("Bundle", "module")),
          .raw("#else"),
          .raw("final class Helper {}"),
          // let bundle = Bundle(for: Helper.self)
          .let("bundle", is: .call(name: "Bundle", parameters: [
            ( "for", .raw("Helper.self") ) // otherwise `self` gets quoted
          ])),
          .raw("#endif"),
          .ifLetElse(
            "url",
              .call(instance: "bundle", name: "url", parameters: [
                ( "forResource"   , name ),
                ( "withExtension" , ext  )
              ]),
            [ .return(.call(name: database.name, parameters: [
                  ( "url", .variable("url") ), ( "readOnly", .true ) ])) ],
            else: [
              .call(name: "fatalError",
                .string("Missing db resource \(filename), not copied?"))
            ]
          )
         ]),
         comment: "The database associated with the `\(filename)` resource.")
  }
  
  /**
   * Generate the SQLError struct, required when not used w/ Lighter.
   */
  func generateSQLError(name: String = "SQLError") -> Struct {
    return Struct(
      public: options.public, name: name,
      conformances: [.name("Swift.Error"), .name("Equatable")],
      variables: [
        .let(public: options.public, "code" , .int32,
             comment: "The SQLite3 error code (`sqlite3_errcode`)."),
        .let(public: options.public, "message" , .optional(.string),
             comment: "The SQLite3 error message (`sqlite3_errmsg`).")
      ],
      functions: [
        .init(
          declaration: .makeInit(
            public: options.public,
            .init(name: "code"    , type: .int32),
            .init(name: "message" , type: .name("UnsafePointer<CChar>?"),
                  defaultValue: .nil)
          ),
          statements: [
            .raw("self.code    = code"),
            .raw("self.message = message.flatMap(String.init(cString:))")
          ]
        ),
        .init(
          declaration: .makeInit(
            public: options.public,
            .init(name: "db", type: .name("OpaquePointer!"))
          ),
          statements: [
            .raw("self.code    = sqlite3_errcode(db)"),
            .raw("self.message = sqlite3_errmsg(db).flatMap(String.init(cString:))")
          ]
        )
      ],
      comment: .init(
        headline: "A SQLError that can be used with SQLite.",
        examples: [
          .init(headline: "Setup from SQLite3 database handle",
                code:
                  """
                  if rc != SQLITE_OK { throw SQLError(dbHandle) }
                  """)
        ]
      )
    )
  }
}
