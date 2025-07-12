//
//  Created by Helge Heß.
//  Copyright © 2022-2025 ZeeZide GmbH.
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
  
  public struct Flags: OptionSet, Sendable {
    public let rawValue: UInt16

    @inlinable
    public init(rawValue: UInt16) { self.rawValue = rawValue }
    
    /// Does the function override another one (classes only).
    public static let `override`            = Self(rawValue: 1 << 0)
    /// Is the property mutating its associated type.
    public static let `mutating`            = Self(rawValue: 1 << 2)

    public static let `inlinable`           = Self(rawValue: 1 << 8)

    /// Whether the property can throw an error.
    public static let `throws`              = Self(rawValue: 1 << 10)
    /// Whether the function is asynchronous.
    public static let `async`               = Self(rawValue: 1 << 12)
  }

  /// Whether the definition is `@inlinable` (included in the module header).
  public var flags         : Flags
  /// A comment for the property.
  public var comment       : String?
  
  /// Is the property public?
  public let visibility    : Visibility
  
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
  public init(override: Bool = false, async: Bool = false,
              mutating: Bool = false, throwing: Bool = false,
              visibility    : Visibility? = nil,
              `public`      : Bool        = true,
              name          : String,
              type          : TypeReference,
              statements    : [ Statement ],
              setStatements : [ Statement ] = [],
              comment       : String?       = nil,
              inlinable     : Bool          = false,
              minimumSwiftVersion : ( major: Int, minor: Int )? = nil)
  {
    var flags = Flags()
    if inlinable  { flags.insert(.inlinable) }
    if `override` { flags.insert(.override)  }
    if `mutating` { flags.insert(.mutating)  }
    if throwing   { flags.insert(.throws)    }
    if `async`    { flags.insert(.async)     }
    
    self.flags               = flags
    self.visibility          = visibility ?? (`public` ? .public : .internal)
    self.name                = name
    self.type                = type
    
    self.statements          = statements
    self.setStatements       = setStatements
    self.comment             = comment
    self.minimumSwiftVersion = minimumSwiftVersion
  }
}


// MARK: - Convenience

public extension ComputedPropertyDefinition {
  
  /// Initialize a new ComputedProperty AST node with just getters.
  static func `var`(override   : Bool = false,
                    async      : Bool = false,
                    mutating   : Bool = false,
                    throwing   : Bool = false,
                    visibility : Visibility? = nil,
                    `public`: Bool = true, inlinable: Bool = true,
                    _ name: String,
                    _ type: TypeReference,
                    comment: String? = nil,
                    _ statements: Statement...) -> Self
  {
    .init(override: override, async: async, mutating: mutating,
          throwing: throwing,
          visibility: visibility, public: `public`,
          name: name, type: type,
          statements: statements, setStatements: [],
          comment: comment, inlinable: inlinable)
  }
  
  /// Initialize a new ComputedProperty AST node with setters.
  static func `var`(override   : Bool = false,
                    visibility : Visibility? = nil,
                    `public`: Bool = true, inlinable: Bool = true,
                    _ name: String,
                    _ type: TypeReference,
                    set : [ Statement ],
                    get : [ Statement ],
                    comment: String? = nil) -> Self
  {
    .init(override: override, visibility: visibility, public: `public`,
          name: name, type: type,
          statements: get, setStatements: set,
          comment: comment, inlinable: inlinable)
  }
}

#if swift(>=5.5)
extension ComputedPropertyDefinition : Sendable {}
#endif
