//
//  Created by Helge Heß.
//  Copyright © 2024 ZeeZide GmbH.
//


#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS)) && swift(>=5.9)
  #if compiler(<6) // seems necessary?
    import struct Foundation.CharacterSet
    import class  Foundation.DateFormatter
    extension CharacterSet  : @unchecked Sendable {}
    extension DateFormatter : @unchecked Sendable {}
  #endif
#endif
