//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension FunctionDeclaration {
  
  /// A parameter, like `from table: KeyPath<Self.RecordTypes, T.Type>`
  /// Or: `limit: Int? = nil`
  struct Parameter: Equatable {
    
    /// The "label" of the parameter, e.g. the `from` in `select(from table:)`.
    /// Can be `nil` for a wildcard (`_`).
    public let keyword      : String?       // `from`
    /// The name of the parameter, not to be confused with the ``keyword``.
    public let name         : String        // `table`
    /// The type of the parameter, e.g. `.integer`.
    public let type         : TypeReference // e.g. `KeyPath<...>` or `Int?`
    /// If set, the default value of the parameter (like in `limit: Int = 10`).
    public let defaultValue : Expression?   // e.g. `nil`
    
    /// Initialize a new parameter for a function declaration.
    public init(keyword: String? = nil, name: String, type: TypeReference,
                defaultValue: Expression? = nil)
    {
      self.keyword      = keyword
      self.name         = name
      self.type         = type
      self.defaultValue = defaultValue
    }
  }
}


// MARK: - Convenience

public extension FunctionDeclaration.Parameter {

  /// Initialize a new parameter for a function declaration where the
  /// label is the same like the parameter name, e.g. `func x(a: Int)`.
  init(keywordArg name: String, _ type: TypeReference,
       _ defaultValue: Literal? = nil)
  {
    self.init(keyword: name, name: name, type: type,
              defaultValue: defaultValue.flatMap { .literal($0) })
  }

  /// Initialize a new parameter for a function declaration.
  init(keyword: String? = nil, name: String,
       keyPath fromBase : String, _ fromBaseName : String,
       to      toBase   : String, _ toBaseName   : String)
  {
    self.init(
      keyword: keyword, name: name,
      type: .keyPath(
        fromType : .qualifiedType(baseName: fromBase, name: fromBaseName),
        toType   : .qualifiedType(baseName: toBase,   name: toBaseName)
      )
    )
  }
  
  /// Initialize a new parameter for a function declaration.
  init(keyword: String? = nil, name: String,
       keyPath fromBase: String, _ fromBaseName: String,
       to      toBaseName: String)
  {
    self.init(
      keyword: keyword, name: name,
      type: .keyPath(
        fromType : .qualifiedType(baseName: fromBase, name: fromBaseName),
        toType   : .name(toBaseName)
      )
    )
  }
  
  /// Initialize a new parameter for a function declaration.
  init(keyword: String? = nil, name: String,
       closureParameters: [ ( base: String, name: String ) ],
       `throws`: Bool = false,
       returns: TypeReference = .void)
  {
    self.init(
      keyword: keyword, name: name,
      type: .closure(
        escaping: false,
        parameters: closureParameters.map {
          ( base, name ) in .qualifiedType(baseName: base, name: name)
        },
        throws: `throws`,
        returns: returns
      )
    )
  }
}
