//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * A generic constraint attached to a ``FunctionDeclaration`` generic parameter
 * or an ``Extension``.
 */
public enum GenericConstraint: Equatable, Sendable {
  
  /// `C1: SQLColumn`
  case conformance(name: String, type: TypeReference)
  
  /// `T == C1.T`
  case equal(name: String, type: TypeReference)
}


// MARK: - Convenience

public extension GenericConstraint {
  
  /// `C1: SQLColumn`
  static func conformance(_ name: String, to typeName: String) -> Self {
    .conformance(name: name, type: .name(typeName))
  }

  /// `T == C1.T`
  static func parameter(_ name: String,
                        sameAs typeNameBase: String, _ typeName: String) -> Self
  {
    .equal(name: name,
           type: .qualifiedType(baseName: typeNameBase, name: typeName))
  }
}
