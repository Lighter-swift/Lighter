//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * An AST node that represents a computed property.
 *
 * Like:
 * ```swift
 * var _allColumns : [ any SQLColumn ] { id, street, name }
 * ```
 */
public struct ComputedPropertyDefinition {
  
  /// Whether the definition is `@inlinable` (included in the module header).
  public var inlinable     : Bool
  /// A comment for the property.
  public var comment       : String?
  
  /// Is the property public?
  public let `public`      : Bool
  
  /// The name of the property, e.g. `_allColumns`.
  public let name          : String        // e.g. `select`
  /// The type of the property, e.g. `.integer`
  public let type          : TypeReference
  
  /// The ``Statement``s for the property getter.
  public var statements    : [ Statement ]
  /// The ``Statement``s for the property setter.
  public var setStatements : [ Statement ]

  /// If set, the property is wrapped in an `#if swift(>=major.minor)`.
  public var minimumSwiftVersion : ( major: Int, minor: Int )?
  
  /// Initialize a new ComputedProperty AST node.
  public init(`public`      : Bool          = true,
              name          : String,
              type          : TypeReference,
              statements    : [ Statement ],
              setStatements : [ Statement ] = [],
              comment       : String?       = nil,
              inlinable     : Bool          = false,
              minimumSwiftVersion : ( major: Int, minor: Int )? = nil)
  {
    self.`public`            = `public`
    self.name                = name
    self.type                = type
    
    self.statements          = statements
    self.setStatements       = setStatements
    self.comment             = comment
    self.inlinable           = inlinable
    self.minimumSwiftVersion = minimumSwiftVersion
  }
}


// MARK: - Convenience

public extension ComputedPropertyDefinition {
  
  /// Initialize a new ComputedProperty AST node with just getters.
  static func `var`(`public`: Bool = true, inlinable: Bool = true,
                    _ name: String,
                    _ type: TypeReference,
                    comment: String? = nil,
                    _ statements: Statement...) -> Self
  {
    .init(public: `public`, name: name, type: type,
          statements: statements, setStatements: [],
          comment: comment, inlinable: inlinable)
  }
  
  /// Initialize a new ComputedProperty AST node with setters.
  static func `var`(`public`: Bool = true, inlinable: Bool = true,
                    _ name: String,
                    _ type: TypeReference,
                    set : [ Statement ],
                    get : [ Statement ],
                    comment: String? = nil) -> Self
  {
    .init(public: `public`, name: name, type: type,
          statements: get, setStatements: set,
          comment: comment, inlinable: inlinable)
  }
}

#if swift(>=5.5)
extension ComputedPropertyDefinition : Sendable {}
#endif
