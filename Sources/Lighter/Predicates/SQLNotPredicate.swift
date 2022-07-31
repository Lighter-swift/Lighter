//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A predicate that negates the outcome of another.
 *
 * Example:
 * ```swift
 * !$0.lastname.contains("uck")
 * ```
 */
public struct SQLNotPredicate<P: SQLPredicate>: SQLPredicate {

  /// The predicate to be negated.
  public let predicate : P
  
  /**
   * Create a new not-predicate using another predicate to be negated.
   *
   * Note: It is easier to use the `!` operator to negate a predicate.
   */
  @inlinable
  public init(_ predicate: P) { self.predicate = predicate }

  
  // MARK: - SQL Generation

  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    builder.append("NOT (")
    predicate.generateSQL(into: &builder)
    builder.append(")")
  }
}
