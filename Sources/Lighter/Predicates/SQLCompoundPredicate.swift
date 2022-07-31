//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A predicate that joins two predicates by either `AND` or `OR`.
 *
 * Can be used to construct more complex predicates involving boolean
 * operations.
 *
 * Example:
 * ```swift
 * $0.lastname.hasPrefix("Da") && $0.age > 10
 * ```
 */
public struct SQLCompoundPredicate<L, R>: SQLPredicate
                where L: SQLPredicate, R: SQLPredicate
{
  
  /**
   * The operator by which the predicates are joined.
   */
  public enum Operator: String {
    /// Both predicates must be true for the whole predicate to be true.
    case and = "AND"
    /// Either predicate must be true for the whole predicate to be true.
    case or  = "OR"
  }
  
  /// The operator by which the predicates are combined.
  public let operation : Operator
  
  /// The first predicate.
  public let lhs       : L
  
  /// The second predicate.
  public let rhs       : R
  
  /**
   * Initialize a compound predicate.
   *
   * It is easier to use the associated operators to create compound
   * predicates, i.e. `&&` and `||`.
   */
  @inlinable
  public init(operation: Operator, lhs: L, rhs: R) {
    self.operation = operation
    self.lhs       = lhs
    self.rhs       = rhs
  }
  
  
  // MARK: - SQL Generation
  
  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    builder.append("(")
    lhs.generateSQL(into: &builder)
    builder.append(") \(operation.rawValue) (")
    rhs.generateSQL(into: &builder)
    builder.append(")")
  }
}
