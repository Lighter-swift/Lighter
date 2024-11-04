//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * An AST node representing a Swift extension.
 */
public struct Extension {
  
  // MARK: - Header

  /// Is the extension public?
  public var `public`            : Bool
  /// What type is the extension on? E.g. `Person`.
  public var extendedType        : TypeReference
  /// Generic constraints to make the extension apply,
  /// e.g. `where RecordTypes == MyDatabase.RecordTypes`
  public var genericConstraints  : [ GenericConstraint ]
  
  // MARK: - Types
  
  /// The structures added to the ``extendedType``.
  public var typeDefinitions     : [ TypeDefinition ]
  
  // MARK: - Functions
  
  /// Type functions, i.e. `static` ones, added by the extension.
  public var typeFunctions       : [ FunctionDefinition ]
  /// Regular "instance" functions added by the extension.
  public var functions           : [ FunctionDefinition ]
  
  /// If set, the extension is wrapped in an `#if swift(>=major.minor)`.
  public var minimumSwiftVersion : ( major: Int, minor: Int )?
  /// If set, the extension is wrapped in an `#if canImport(Module)` for each
  /// element.
  public var requiredImports     = [ String ]()

  /// Initialize a new extension AST node.
  public init(extendedType        : TypeReference,
              `public`            : Bool                   = true,
              genericConstraints  : [ GenericConstraint ]  = [],
              typeDefinitions     : [ TypeDefinition ]             = [],
              typeFunctions       : [ FunctionDefinition ] = [],
              functions           : [ FunctionDefinition ] = [],
              minimumSwiftVersion : ( major: Int, minor: Int )? = nil,
              requiredImports     : [ String ] = [])
  {
    self.public              = `public`
    self.extendedType        = extendedType
    self.typeDefinitions     = typeDefinitions
    self.typeFunctions       = typeFunctions
    self.functions           = functions
    self.genericConstraints  = genericConstraints
    self.minimumSwiftVersion = minimumSwiftVersion
    self.requiredImports     = requiredImports
  }
  
  @inlinable
  public var isEmpty : Bool {
    functions.isEmpty && typeDefinitions.isEmpty && typeFunctions.isEmpty
  }
}

#if swift(>=5.5)
extension Extension: Sendable {}
#endif
