//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * A comment for a function.
 *
 * Has all the function specific things, like parameters and such.
 */
public struct FunctionComment: Equatable {
  
  /// A comment for a function parameter.
  public struct Parameter: Equatable {
    
    /// The name of the function parameter being documented.
    public var name : String
    /// The documentation for the parameter.
    public var info : String
    
    /// Initialize a function parameter comment.
    public init(name: String, info: String) {
      self.name = name
      self.info = info
    }
  }
  
  /// The introducing headline of the comment.
  public var headline   : String
  /// A paragraph with more information about the function.
  public var info       : String?
  /// A single example that will be emitted in triple-backticks.
  public var example    : String?
  
  /// Documentation for the parameters of the function.
  public var parameters = [ Parameter ]()
  
  /// Whether the function throws errors.
  public var `throws`   : Bool = false
  /// The documentation for the return value of the function.
  public var returnInfo : String?
  
  /// Initialize a new function comment AST node.
  public init(headline: String, info: String? = nil, example: String? = nil,
              parameters: [ Parameter ] = [], `throws`: Bool = false,
              returnInfo: String? = nil)
  {
    self.headline   = headline
    self.info       = info
    self.example    = example
    self.parameters = parameters
    self.throws     = `throws`
    self.returnInfo = returnInfo
  }
}

#if swift(>=5.5)
extension FunctionComment           : Sendable {}
extension FunctionComment.Parameter : Sendable {}
#endif
