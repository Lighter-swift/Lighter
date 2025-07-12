//
//  Created by Helge Heß.
//  Copyright © 2022-2025 ZeeZide GmbH.
//

/**
 * A function declaration (i.e. the function type, not the statements of the
 * body).
 *
 * Like:
 * ```
 * func select<T, C1, C2>(
 *   from: KeyPath<Self.RecordTypes, T.Type>,
 *   _ column1: KeyPath<T.Schema, C1>,
 *   _ column2: KeyPath<T.Schema, C2>,
 *   limit: Int? = nil,
 *   yield: ( C1.Value, C2.Value ) -> Void
 * ) throws
 * where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T
 * ```
 */
public struct FunctionDeclaration: Equatable {
  
  public struct Flags: OptionSet, Sendable {
    public let rawValue: UInt16

    @inlinable
    public init(rawValue: UInt16) { self.rawValue = rawValue }
    
    /// Does the function override another one (classes only).
    public static let `override`            = Self(rawValue: 1 << 0)
    /// Is the property mutating its associated type.
    public static let `mutating`            = Self(rawValue: 1 << 2)
    /// A `convenience` initializer (classes only).
    public static let convenience           = Self(rawValue: 1 << 3)
    /// A `required` initializer (classes only).
    public static let required              = Self(rawValue: 1 << 4)

    /// Whether the function can throw an error.
    public static let `throws`              = Self(rawValue: 1 << 10)
    /// Whether the function is rethrowing errors.
    public static let `rethrows`            = Self(rawValue: 1 << 11)
      // either one or the other
    /// Whether the function is asynchronous.
    public static let `async`               = Self(rawValue: 1 << 12)
  }

  public let flags      : Flags
  public let visibility : Visibility

  /// The name of the function (e.g. `select`)
  public let name                  : String
  
  /// The list of generic parameters, e.g. `[C1,C2]` for `select<C1,C2>`
  public let genericParameterNames : [ String    ]
  /// The list of parameters the function takes (keyword, name, type, default)
  public let parameters            : [ Parameter ]
  
  /// The return type of the function, e.g. `.void` or `.integer`.
  public let returnType            : TypeReference
  
  /// Generic constraints attached to a function, like `where C: SQLColumn`.
  public let genericConstraints    : [ GenericConstraint ] // e.g. `C1: SQLColumn`
  
  /// Initialize a new function declaration.
  public init(`override`            : Bool = false,
              visibility            : Visibility? = nil,
              `public`              : Bool = true,
              `mutating`            : Bool = false,
              `convenience`         : Bool = false,
              `required`            : Bool = false,
              name                  : String,
              genericParameterNames : [ String            ] = [],
              parameters            : [ Parameter         ] = [],
              `async`               : Bool                  = false,
              `throws`              : Bool                  = false,
              `rethrows`            : Bool                  = false,
              returnType            : TypeReference         = .void,
              genericConstraints    : [ GenericConstraint ] = [])
  {
    var flags = Flags()
    if `override`    { flags.insert(.override)    }
    if `mutating`    { flags.insert(.mutating)    }
    if `convenience` { flags.insert(.convenience) }
    if `required`    { flags.insert(.required)    }
    if `throws`      { flags.insert(.throws)      }
    if `rethrows`    { flags.insert(.rethrows)    }
    if `async`       { flags.insert(.async)       }
    
    self.flags                 = flags
    self.visibility            = visibility ?? (`public` ? .public : .internal)
    self.name                  = name
    self.genericParameterNames = genericParameterNames
    self.parameters            = parameters
    self.returnType            = returnType
    self.genericConstraints    = genericConstraints
  }
}


// MARK: - Convenience

public extension FunctionDeclaration {

  /// Initialize a new function declaration.
  static func call(`public`: Bool = true, _ name: String,
                   returns returnType : TypeReference = .void,
                   _ parameters: Parameter...) -> FunctionDeclaration
  {
    self.init(public: `public`, name: name, genericParameterNames: [],
              parameters: parameters, async: false, throws: false,
              returnType: returnType, genericConstraints: [])
  }

  /// Initialize a new function declaration.
  static func makeInit(`public`: Bool = true,
                       _ parameters: Parameter...) -> FunctionDeclaration
  {
    self.init(public: `public`, name: "init", genericParameterNames: [],
              parameters: parameters, async: false, throws: false,
              returnType: .void, genericConstraints: [])
  }
}

#if swift(>=5.5)
extension FunctionDeclaration: Sendable {}
#endif
