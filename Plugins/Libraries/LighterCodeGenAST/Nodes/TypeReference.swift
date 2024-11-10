//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * A reference to some type, e.g. `Void` or `Person` or `Int`.
 */
public indirect enum TypeReference: Equatable {
  
  /// `Void`
  case void
  
  /// Simple type name, like `SQLColumn`
  case name(String)
  
  /// `some SQLColumn`
  case some(String)
  
  /// `Self.RecordTypes` or `T.Type`
  case qualifiedType(baseName: String, name: String)
  
  /// `KeyPath<Self.RecordTypes, T.Type>`
  case keyPath(fromType: TypeReference, toType: TypeReference)
  
  /// ( C1.Value, C2.Value ) -> Void
  case closure(escaping: Bool, parameters: [ TypeReference ],
               `throws`: Bool, returns: TypeReference)
  
  /// ( column1: C1.Value, column2: C2.Value )
  case tuple(names: [ String? ], types: [ TypeReference ])
  
  /// [ ( column1: C1.Value, column2: C2.Value ) ]
  case array(TypeReference)
  
  /// `Int?`
  case optional(TypeReference)

  /// `inout Person`
  case `inout`(TypeReference)
}

public extension TypeReference {
  

  /// Swift `Any`.
  static var any         : TypeReference { .name("Any")       }

  /// Swift `Int`.
  static let int         = TypeReference.name("Int")
  /// Swift `String`.
  static let string      = TypeReference.name("String")
  /// Swift `Double`.
  static let double      = TypeReference.name("Double")
  /// Swift `Bool`.
  static let bool        = TypeReference.name("Bool")
  
  // common in SQLite
  /// Swift `Int32`.
  static let int32       = TypeReference.name("Int32")
  /// Swift `Int64`.
  static let int64       = TypeReference.name("Int64")
}

public extension TypeReference {
  /// Swift `[ UInt8 ]`. Aka `Data`, w/o the need for Foundation.
  static let uint8Array  = TypeReference.array(.name("UInt8"))
}

public extension TypeReference {

  /// A Foundation `URL`.
  static let url         = TypeReference.name("URL")
  /// A Foundation `Decimal` number.
  static let decimal     = TypeReference.name("Decimal")
  /// A Foundation `Date`.
  static let date        = TypeReference.name("Date")
  /// A Foundation `Data`.
  static let data        = TypeReference.name("Data")
  /// A Foundation `UUID`.
  static let uuid        = TypeReference .name("UUID")
}

#if swift(>=5.5)
extension TypeReference : Sendable {}
#endif
