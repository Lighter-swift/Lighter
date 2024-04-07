//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * Represents a dynamic (but statically typed) predicate that can be rendered
 * into a SQL WHERE string.
 *
 * Common predicates:
 * - ``SQLColumnValuePredicate``      (e.g. `$0.id == 10`)
 * - ``SQLColumnComparisonPredicate`` (e.g. `$0.id == $0.managerId`)
 * - ``SQLNotPredicate``              (e.g. `!($0.id == 10)`)
 * - ``SQLCompoundPredicate``         (e.g. `$0.id == 10 && $0.name == "A"`)
 * - ``SQLColumnValueRangePredicate`` (e.g. `$0.age.in(49...51)`)
 * - ``SQLColumnValueSetPredicate``   (.e.g `$0.type.in([ 'table', 'view' ])`)
 *
 * Example:
 * ```
 * SQLColumnValuePredicate(Person.schema.id, .equal, 10)
 * ```
 * results in:
 * ```
 * person_id = 10
 * ```
 */
public protocol SQLPredicate: Sendable {
  
  /**
   * Append the SQL representing the predicate to the ``SQLBuilder``.
   */
  func generateSQL<Base>(into builder: inout SQLBuilder<Base>)
}
