//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A predicate containing raw SQL, that can use string interpolation to generate
 * proper values.
 *
 * Example:
 * ```swift
 * "\($0.personId) LIKE UPPER(\(name))"
 * ```
 */
public struct SQLInterpolatedPredicate: SQLPredicate,
                                        ExpressibleByStringInterpolation
{
  /// The interpolation to use.
  @usableFromInline
  let interpolation : SQLInterpolation

  @inlinable
  public init(stringInterpolation interpolation: SQLInterpolation) {
    self.interpolation = interpolation
  }
  @inlinable
  public init(stringLiteral sql: String) {
    self.interpolation = SQLInterpolation(verbatim: sql)
  }
  
  
  // MARK: - SQL Generation
  
  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    interpolation.generateSQL(into: &builder)
  }
}
