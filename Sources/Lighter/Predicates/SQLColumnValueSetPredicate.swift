//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A predicate that matches a ``SQLColumn`` of a table/view against
 * a set of values.
 *
 * This generates a SQL `IN` or `NOT IN` query.
 *
 * Example:
 * ```swift
 * let people = try await db.select(from: \.people, \.id, \.lastname) {
 *      $0.id.in([ 2, 3, 4 ])
 *   || $0.id.in(2, 3, 4)
 *   && $0.id.notIn([ 7, 8 ])
 *   && ![ 13, 14 ].contains($0.people)
 *   && $0.in([ 2, 3 ]
 * }
 * ```
 */
public struct SQLColumnValueSetPredicate<C: SQLColumn>: SQLPredicate {
    
  /// The column to compare the values against.
  public let column : C
  
  /// A set of values to compare the colum against.
  public let values : Set<C.Value>
  
  /// Whether the predicate should be negated (i.e. emit a `NOT IN`).
  public let negate : Bool

  /**
   * Setup a new ``SQLColumnValueSetPredicate``.
   *
   * Examples:
   * ```swift
   * $0.personId.in(values)
   * $0.personId.notIn(values)
   * ![ 13, 14].contains($0.personId)
   * ```
   *
   * - Parameters:
   *   - column: The ``SQLColumn`` to compare.
   *   - values: The values to compare the column against.
   *   - negate: Whether the check should negate the query (`NOT IN`).
   */
  @inlinable
  public init(_ column: C, _ values: Set<C.Value>, negate: Bool = false) {
    self.column = column
    self.values = values
    self.negate = negate
  }
  @inlinable
  public init<S: Sequence>(_ column: C, _ values: S, negate: Bool = false)
           where S.Element == C.Value
  {
    self.init(column, Set(values), negate: negate)
  }
  
  
  // MARK: - SQL Generation
  
  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    // in ZeeQL this is done using `is` checks, i.e. not dispatched out to the
    // qualifiers. But we want to have it as part of the protocol here.
    
    let column = builder.sqlString(for: column)
    builder.append(column)
    builder.append(negate ? " NOT IN ( " : " IN ( ")
    var isFirst = true
    for value in values {
      if isFirst { isFirst = false } else { builder.append(", ") }
      builder.append(builder.sqlString(for: value))
    }
    builder.append(" )")
  }
}
