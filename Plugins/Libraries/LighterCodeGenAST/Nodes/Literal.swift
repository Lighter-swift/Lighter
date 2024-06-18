//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * A Swift literal
 *
 * E.g. as used in default values like: `limit: Int? = nil` (the `nil`).
 */
public enum Literal: Equatable {

  /// `nil`
  case `nil`
  /// Bool `true`
  case `true`
  /// Bool `false`
  case `false`

  /// An integer literal, like `42`
  case integer(Int)

  /// A double literal, like `42.1337`
  case double(Double)

  /// A string literal, like `"Hello World"`
  case string(String)
  
  /// A literal array, like `[ 1973, 1, 31 ]`
  case integerArray([ Int ])
}

#if swift(>=5.5)
extension Literal: Sendable {}
#endif
