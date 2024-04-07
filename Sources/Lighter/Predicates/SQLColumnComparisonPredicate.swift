//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A predicate that compares two ``SQLColumn``s of a table/view against
 * each other.
 *
 * Example:
 * ```swift
 * let people = try await db.select(from: \.people, \.id, \.lastname) {
 *   $0.lastname == $0.firstname
 * }
 * ```
 */
public struct SQLColumnComparisonPredicate<L, R>: SQLPredicate
                where L: SQLColumn,
                      R: SQLColumn,
                      L.Value == R.Value
{
  
  public enum ComparisonOperator: String, Sendable {
    
    /**
     * Check whether the ``SQLColumn`` is the same like the other column
     *
     * Example:
     * ```swift
     * $0.personId == $0.managerId
     * $0.name     == $0.maidenName
     * ```
     */
    case equal              = "="
    
    /**
     * Check whether the ``SQLColumn`` is different from the other.
     *
     * Example:
     * ```swift
     * $0.personId != $0.managerId
     * $0.name     != $0.maidenName
     * ```
     */
    case notEqual           = "!="

    /**
     * Check whether the ``SQLColumn`` is smaller than the other.
     *
     * Example:
     * ```swift
     * $0.personId < $0.motherId
     * $0.name     < $0.lastname
     * ```
     */
    case lessThan           = "<"

    /**
     * Check whether the ``SQLColumn`` is smaller or equal to the other.
     *
     * Example:
     * ```swift
     * $0.personId <= $0.motherId
     * $0.name     <= $0.lastname
     * ```
     */
    case lessThanOrEqual    = "<="

    /**
     * Check whether the ``SQLColumn`` is greater than the other.
     *
     * Example:
     * ```swift
     * $0.personId > $0.motherId
     * $0.name     > $0.lastname
     * ```
     */
    case greaterThan        = ">"

    /**
     * Check whether the ``SQLColumn`` is greater or equal to the other.
     *
     * Example:
     * ```swift
     * $0.personId >= $0.motherId
     * $0.name     >= $0.lastname
     * ```
     */
    case greaterThanOrEqual = ">="
  }
  
  public let comparator : ComparisonOperator
  public let lhs        : L
  public let rhs        : R
  
  @inlinable
  public init(_ lhs: L, _ comparator: ComparisonOperator, _ rhs: R) {
    self.comparator = comparator
    self.lhs = lhs
    self.rhs = rhs
  }
  
  
  // MARK: - SQL Generation
  
  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    builder.append(builder.sqlString(for: lhs))
    builder.append(" ")
    builder.append(comparator.rawValue)
    builder.append(" ")
    builder.append(builder.sqlString(for: rhs))
  }
}
