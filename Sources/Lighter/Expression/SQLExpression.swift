//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A raw SQL expression, that can use string interpolation to generate
 * proper values.
 *
 * Example:
 * ```swift
 * "SELECT * FROM person WHERE \($0.personId) LIKE UPPER(\(name))"
 * ```
 */
public struct SQLExpression: ExpressibleByStringInterpolation {
  
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
