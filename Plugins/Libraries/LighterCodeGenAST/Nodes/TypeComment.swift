//
//  Created by Helge Heß.
//  Copyright © 2022-2023 ZeeZide GmbH.
//

/// A comment on top of e.g. a class or struct.
public struct TypeComment: Equatable {

  /// One example in the type comment. There can be multiple.
  public struct Example: Equatable {
    
    /// A title for the example.
    public var headline : String
    /// The code for the example, will be emitted in triple backticks.
    public var code     : String
    /// The programming language of the sample, e.g. `swift`.
    public var language : String?

    /// Initialize a new type example.
    public init(headline: String, code: String, language: String? = "swift") {
      self.headline = headline
      self.code     = code.replacingOccurrences(of: "\r\n", with: "\n")
      self.language = language
    }
  }
  
  /// The title of the comment for the type/structure.
  public var headline   : String

  /// If set, a larger paragraph describing the type.
  public var info       : String?
  
  /// A set of examples on how to use the structure.
  public var examples   : [ Example ]
  
  /// Special thing, SQL related to the structure.
  public var sql        : [ Example ]

  /// Initialize a new comment for a type.
  public init(headline : String, info: String? = nil,
              examples : [ Example ] = [],
              sql      : [ Example ] = [])
  {
    self.headline = headline
    self.info     = info
    self.examples = examples
    self.sql      = sql
  }
}
