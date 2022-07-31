//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A predicate that matches a ``SQLColumn`` of a table/view against
 * a range of values.
 *
 * This generates a SQL `BETWEEN` query.
 *
 * Example:
 * ```swift
 * let people = try await db.select(from: \.people, \.id, \.lastname) {
 *      $0.id.in(1...4)
 *   || $0.id.in(8..<9)
 *   && 13...14.contains($0.id)
 * }
 * ```
 */
public struct SQLColumnValueRangePredicate<C: SQLColumn>: SQLPredicate
                where C.Value: Comparable
{
  
  /// The column to compare the value range against.
  public let column : C
  
  /// The range to compare the column against.
  public let values : ClosedRange<C.Value>

  /**
   * Setup a new ``SQLColumnValueRangePredicate``.
   *
   * Examples:
   * ```swift
   * $0.id.in(1...4)
   * $0.id.in(8..<9)
   * 13...14.contains($0.id)
   * ```
   *
   * - Parameters:
   *   - column: The ``SQLColumn`` to compare.
   *   - values: The values to compare the column against.
   */
  @inlinable
  public init(_ column: C, _ values: ClosedRange<C.Value>) {
    self.column = column
    self.values = values
  }

  /**
   * Setup a new ``SQLColumnValueRangePredicate``.
   *
   * Examples:
   * ```swift
   * $0.personId.in(1...4)
   * $0.personId.in(8..<9)
   * 13...14.contains($0.personId)
   * ```
   *
   * - Parameters:
   *   - column: The ``SQLColumn`` to compare.
   *   - values: The values to compare the column against.
   */
  @inlinable
  public init(_ column: C, _ values: Range<C.Value>)
           where C.Value: Strideable, C.Value.Stride: SignedInteger
  {
    self.column = column
    self.values = ClosedRange(values)
  }

  
  // MARK: - SQL Generation
  
  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    // in ZeeQL this is done using `is` checks, i.e. not dispatched out to the
    // qualifiers. But we want to have it as part of the protocol here.
    
    builder.append(builder.sqlString(for: column))
    builder.append(" BETWEEN ")
    builder.append(builder.sqlString(for: values.lowerBound))
    builder.append(" AND ")
    builder.append(builder.sqlString(for: values.upperBound))
  }
}
