//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * A Swift file, containing structs, funcs, extensions and more.
 *
 * It does intentionally not support arbitrary order of things, but groups
 * stuff by type.
 */
public struct CompilationUnit {
  
  /// The (file)name of the unit.
  public let name       : String
  
  /// A set of imports, e.g. `[ Foundation, SQLite3 ]`
  public var imports    : [ String ]
  /// A set of imports that are re-exported (`@_exported import Lighter`)
  public var reexports  : [ String ] = []

  /// The structures that are part of the unit.
  public var typeDefinitions : [ TypeDefinition ]
  /// The functions that are part of the unit.
  public var functions       : [ FunctionDefinition ]
  /// The extensions that are part of the unit.
  public var extensions      : [ Extension ]

  /// Initialize a new CompilationUnit, only name and extensions are required.
  public init(name            : String,
              imports         : [ String             ] = [],
              typeDefinitions : [ TypeDefinition     ] = [],
              functions       : [ FunctionDefinition ] = [],
              extensions      : [ Extension          ] = [])
  {
    self.name       = name
    self.imports    = imports
    self.typeDefinitions = typeDefinitions
    self.functions  = functions
    self.extensions = extensions
  }
  /// Initialize a new CompilationUnit, only name and extensions are required.
  public init(name       : String,
              imports    : [ String             ] = [],
              structures : [ TypeDefinition     ], // legacy compat
              functions  : [ FunctionDefinition ] = [],
              extensions : [ Extension          ] = [])
  {
    self.init(name: name, imports: imports, typeDefinitions: structures,
              functions: functions, extensions: extensions)
  }
}


// MARK: - Convenience

public extension CompilationUnit {
  
  /// Add an ``Extension`` to a compilation unit if it actually contains
  /// something.
  mutating func addIfNotEmpty(_ ext: Extension?) {
    guard let ext = ext, !ext.isEmpty else { return }
    extensions.append(ext)
  }
}

#if swift(>=5.5)
extension CompilationUnit: Sendable {}
#endif
