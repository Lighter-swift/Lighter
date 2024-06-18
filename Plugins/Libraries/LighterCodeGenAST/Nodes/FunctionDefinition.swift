//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * A function definition is the ``FunctionDeclaration`` alongside the
 * ``Statement``s that make up the function.
 *
 * Plus extra annotations like ``inlinable`` and the ``comment``.
 */
public struct FunctionDefinition: Equatable {
  
  /// Whether the definition is `@inlinable` (included in the module header).
  public var inlinable    : Bool
  // TBD: decl or def?
  
  /// Whether the result is `@discardableResult`.
  public var discardableResult : Bool
  
  /// A comment for the function.
  public var comment      : FunctionComment?
  
  /// The type (declaration) of the function. Has the parameter types, the
  /// return types, whether it throws etc.
  public let declaration  : FunctionDeclaration
  
  /// The implementation of the function as a set of ``Statement``s.
  public var statements   : [ Statement ]
  
  /// Initialize a new function definition AST node.
  public init(declaration : FunctionDeclaration,
              statements  : [ Statement ],
              comment     : FunctionComment? = nil,
              inlinable   : Bool = false, discardableResult: Bool = false)
  {
    self.declaration = declaration
    self.statements  = statements
    self.comment     = comment
    self.inlinable   = inlinable
    self.discardableResult = discardableResult
  }
}


// MARK: - Convenience

public extension FunctionDefinition {
  
  /// Initialize a new function definition AST node.
  init(_ declaration : FunctionDeclaration,
       _ statements  : Statement...)
  {
    self.init(declaration: declaration, statements: statements)
  }
}

#if swift(>=5.5)
extension FunctionDefinition: Sendable {}
#endif
