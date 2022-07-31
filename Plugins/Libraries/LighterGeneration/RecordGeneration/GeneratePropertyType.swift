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
}
