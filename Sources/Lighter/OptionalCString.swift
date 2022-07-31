//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension Optional where Wrapped == String {
  
  /**
   * Call a closure with the C string representation of the optional String,
   * or `nil` if the optional is `.none`.
   *
   * This is a helper to deal with optional String values.
   */
  @inlinable
  func withCString<R>(_ body: (UnsafePointer<CChar>?) throws -> R)
         rethrows -> R
  {
    // try breaks this trick: try self?.withCString(body) ?? body(nil)
    if let v = self { return try v.withCString(body) }
    else            { return try body(nil)           }
  }
}
