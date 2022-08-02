// swift-tools-version:5.0

import PackageDescription

var package = Package(
  name: "Lighter",

  platforms: [ .macOS(.v10_14), .iOS(.v12) ],
  
  products: [
    .library(name: "Lighter",         targets: [ "Lighter"       ]),
    .library(name: "SQLite3Schema",   targets: [ "SQLite3Schema" ]),
    .executable(name: "sqlite2swift", targets: [ "sqlite2swift"  ])
  ],
  
  targets: [
    // A small library used to fetch schema information from SQLite3 databases.
    .target(name: "SQLite3Schema", exclude: [ "README.md" ]),
    
    // Lighter is a shared lib providing common protocols used by Enlighter
    // generated models and such.
    // Note that Lighter isn't that useful w/o code generation (i.e. as a
    // standalone lib).
    .target(name: "Lighter"),

    
    // MARK: - Plugin Support
    
    // The CodeGenAST is a small and hacky helper lib that can format/render
    // Swift source code.
    .target(name    : "LighterCodeGenAST",
            path    : "Plugins/Libraries/LighterCodeGenAST",
            exclude : [ "README.md" ]),
    
    // This library contains all the code generation, to be used by different
    // clients.
    .target(name         : "LighterGeneration",
            dependencies : [ "LighterCodeGenAST", "SQLite3Schema" ],
            path         : "Plugins/Libraries/LighterGeneration",
            exclude      : [ "README.md", "LighterConfiguration/README.md" ]),

    
    // MARK: - Tests
    
    .testTarget(name: "CodeGenASTTests", dependencies: [ "LighterCodeGenAST" ]),
    .testTarget(name: "EntityGenTests",  dependencies: [ "LighterGeneration" ]),
    .testTarget(name: "LighterOperationGenTests",
                dependencies: [ "LighterGeneration" ]),
    .testTarget(name: "FiveThirtyEightTests",
                dependencies: [ "LighterGeneration" ]),

    
    // MARK: - sqlite2swift

    .target(name         : "sqlite2swift",
            dependencies : [ "LighterGeneration" ],
            path         : "Plugins/Tools/sqlite2swift",
            exclude      : [ "README.md" ]),

    
    // MARK: - Internal Tool for Generating Variadics
        
    .target(name         : "GenerateInternalVariadics",
            dependencies : [ "LighterCodeGenAST", "LighterGeneration" ],
            path         : "Plugins/Tools/GenerateInternalVariadics",
            exclude      : [ "README.md" ])
  ]
)

#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
package.products += [ .library(name: "SQLite3", targets: [ "SQLite3" ]) ]
package.targets += [
  .systemLibrary(name: "SQLite3",
                 path: "Sources/SQLite3-Linux",
                 providers: [ .apt(["libsqlite3-dev"]) ])
]
package.targets
  .first(where: { $0.name == "SQLite3Schema" })?
  .dependencies.append("SQLite3")
package.targets
  .first(where: { $0.name == "Lighter" })?
  .dependencies.append("SQLite3")
#endif // not-Darwin
