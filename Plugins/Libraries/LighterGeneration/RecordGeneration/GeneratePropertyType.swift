//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {
  
  func type(for property: EntityInfo.Property) -> TypeReference {
    property.isNotNull
      ?           baseType(for: property)
      : .optional(baseType(for: property))
  }
  func baseType(for property: EntityInfo.Property) -> TypeReference {
    if options.allowFoundation {
      switch property.propertyType {
        case .integer          : return .int
        case .double           : return .double
        case .string           : return .string
        case .uint8Array       : return .uint8Array
        case .bool             : return .bool
        case .date             : return .date
        case .data             : return .data
        case .url              : return .url
        case .decimal          : return .decimal
        case .uuid             : return .uuid
        case .custom(let type) : return .name(type)
      }
    }
    else { // Not Foundation Types are allowed!
      switch property.propertyType {
        case .integer          : return .int
        case .double           : return .double
        case .string           : return .string
        case .uint8Array       : return .uint8Array
        case .bool             : return .bool
        case .date             : return options.dateStorageStyle == .formatter
                                      ? .string : .int
        case .data             : return .uint8Array
        case .url              : return .string
        case .decimal          : return .string
        case .uuid             : return .string
        case .custom(let type) : return .name(type)
      }
    }
  }
}
