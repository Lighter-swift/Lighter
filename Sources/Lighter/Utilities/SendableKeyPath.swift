//
//  Created by Helge Heß.
//  Copyright © 2024 ZeeZide GmbH.
//

#if compiler(<6) // Looks like the KeyPath is Sendable in Swift 6.
// Ugh. But how else? Swift 6 maybe.
extension KeyPath: @unchecked Sendable
  where Root: Sendable, Value: Sendable {}
#endif
