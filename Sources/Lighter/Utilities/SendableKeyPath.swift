//
//  Created by Helge Heß.
//  Copyright © 2024 ZeeZide GmbH.
//

// Ugh. But how else? Swift 6 maybe.
extension KeyPath: @unchecked Sendable
  where Root: Sendable, Value: Sendable {}
