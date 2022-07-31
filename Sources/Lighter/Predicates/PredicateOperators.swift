//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

// Overloaded Operators used to compose `SQLPredicate`s.

public extension SQLPredicate {
  
  /// Negate the `SQLPredicate`.
  @inlinable
  static prefix func !(predicate: Self) -> SQLNotPredicate<Self> {
    return SQLNotPredicate(predicate)
  }
}
public extension SQLNotPredicate {
  
  /// Negate the `SQLNotPredicate`.
  @inlinable
  static prefix func !(predicate: Self) -> P { predicate.predicate }
}

// MARK: - Compound Predicate

public extension SQLPredicate {
  
  @inlinable
  static func &&<O: SQLPredicate>(lhs: Self, rhs: O)
         -> SQLCompoundPredicate<Self, O>
  {
    SQLCompoundPredicate(operation: .and, lhs: lhs, rhs: rhs)
  }
  @inlinable
  static func ||<O: SQLPredicate>(lhs: Self, rhs: O)
         -> SQLCompoundPredicate<Self, O>
  {
    SQLCompoundPredicate(operation: .or, lhs: lhs, rhs: rhs)
  }

  @inlinable
  static func &&(lhs: Self, rhs: SQLInterpolatedPredicate)
         -> SQLCompoundPredicate<Self, SQLInterpolatedPredicate>
  {
    SQLCompoundPredicate(operation: .and, lhs: lhs, rhs: rhs)
  }
  @inlinable
  static func ||(lhs: Self, rhs: SQLInterpolatedPredicate)
         -> SQLCompoundPredicate<Self, SQLInterpolatedPredicate>
  {
    SQLCompoundPredicate(operation: .or, lhs: lhs, rhs: rhs)
  }
}

// MARK: - KeyValuePredicate

public extension SQLColumn {
  
  /**
   * Check whether the ``SQLColumn`` is the same like the given value.
   *
   * Example:
   * ```swift
   * $0.personId == 1
   * $0.name     == "Duck"
   * ```
   */
  @inlinable
  static func ==(lhs: Self, rhs: Self.Value?) -> SQLColumnValuePredicate<Self> {
    SQLColumnValuePredicate(lhs, .equal, rhs)
  }
  
  /**
   * Check whether the ``SQLColumn`` is different from the given value.
   *
   * Example:
   * ```swift
   * $0.personId != 1
   * $0.name     != "Duck"
   * ```
   */
  @inlinable
  static func !=(lhs: Self, rhs: Self.Value?) -> SQLColumnValuePredicate<Self> {
    SQLColumnValuePredicate(lhs, .notEqual, rhs)
  }
  
  /**
   * Check whether the ``SQLColumn`` is smaller than the given value.
   *
   * Example:
   * ```swift
   * $0.personId < 1
   * $0.name     < "Duck"
   * ```
   */
  @inlinable
  static func <(lhs: Self, rhs: Self.Value) -> SQLColumnValuePredicate<Self> {
    SQLColumnValuePredicate(lhs, .lessThan, rhs)
  }
  
  /**
   * Check whether the ``SQLColumn`` is smaller or equal to the given value.
   *
   * Example:
   * ```swift
   * $0.personId <= 1
   * $0.name     <= "Duck"
   * ```
   */
  @inlinable
  static func <=(lhs: Self, rhs: Self.Value) -> SQLColumnValuePredicate<Self> {
    SQLColumnValuePredicate(lhs, .lessThanOrEqual, rhs)
  }
  
  /**
   * Check whether the ``SQLColumn`` is greater than the given value.
   *
   * Example:
   * ```swift
   * $0.personId > 1
   * $0.name     > "Duck"
   * ```
   */
  @inlinable
  static func >(lhs: Self, rhs: Self.Value) -> SQLColumnValuePredicate<Self> {
    SQLColumnValuePredicate(lhs, .greaterThan, rhs)
  }
  
  /**
   * Check whether the ``SQLColumn`` is greater or equal to the given value.
   *
   * Example:
   * ```swift
   * $0.personId >= 1
   * $0.name     >= "Duck"
   * ```
   */
  @inlinable
  static func >=(lhs: Self, rhs: Self.Value) -> SQLColumnValuePredicate<Self> {
    SQLColumnValuePredicate(lhs, .greaterThanOrEqual, rhs)
  }
}

public extension SQLColumn where Self.Value: StringProtocol {
  
  /**
   * Checks whether the value in the column has a certain prefix.
   *
   * Example:
   * ```swift
   * $0.name.hasPrefix("D") // does a `name LIKE 'D%'`
   * ```
   *
   * Note: By default all SQLite `LIKE` operations are case insensitive!
   *       To enable case sensitive `LIKE`, a `PRAGMA` has to be set:
   *       `PRAGMA case_sensitive_like = ON`.
   *
   * - Parameters:
   *   - prefix:          The prefix string to match.
   *   - caseInsensitive: Whether the match should ignore case, defaults to
   *                      `true` (`false` requires pragma!)
   */
  @inlinable
  func hasPrefix(_ prefix: Self.Value, caseInsensitive: Bool = true)
       -> SQLColumnValuePredicate<Self>
  {
    SQLColumnValuePredicate(self, .hasPrefix, prefix,
                            caseInsensitive: caseInsensitive)
  }
  
  /**
   * Checks whether the value in the column has a certain suffix.
   *
   * Example:
   * ```swift
   * $0.name.hasSuffix("uck") // does a `name LIKE '%uck'`
   * ```
   *
   * Note: By default all SQLite `LIKE` operations are case insensitive!
   *       To enable case sensitive `LIKE`, a `PRAGMA` has to be set:
   *       `PRAGMA case_sensitive_like = ON`.
   *
   * - Parameters:
   *   - suffix:          The suffix string to match.
   *   - caseInsensitive: Whether the match should ignore case, defaults to
   *                      `true` (`false` requires pragma!)
   */
  @inlinable
  func hasSuffix(_ suffix: Self.Value, caseInsensitive: Bool = true)
       -> SQLColumnValuePredicate<Self>
  {
    SQLColumnValuePredicate(self, .hasSuffix, suffix,
                            caseInsensitive: caseInsensitive)
  }
  
  /**
   * Checks whether the value in the column contains a certain string.
   *
   * Example:
   * ```swift
   * $0.name.contains("uc") // does a `name LIKE '%uc%'`
   * ```
   *
   * Note: By default all SQLite `LIKE` operations are case insensitive!
   *       To enable case sensitive `LIKE`, a `PRAGMA` has to be set:
   *       `PRAGMA case_sensitive_like = ON`.
   *
   * - Parameters:
   *   - needle:          The string to search for.
   *   - caseInsensitive: Whether the match should ignore case, defaults to
   *                      `true` (`false` requires pragma!)
   */
  @inlinable
  func contains(_ needle: Self.Value, caseInsensitive: Bool = true)
       -> SQLColumnValuePredicate<Self>
  {
    SQLColumnValuePredicate(self, .contains, needle,
                            caseInsensitive: caseInsensitive)
  }
  
  /**
   * Checks whether the value in the column matches a SQL LIKE pattern.
   *
   * Special match characters are `%` and `_`.
   *
   * Example:
   * ```swift
   * $0.name.like("Du%") // does a `name LIKE 'Du%'`
   * ```
   *
   * Note: By default all SQLite `LIKE` operations are case insensitive!
   *       To enable case sensitive `LIKE`, a `PRAGMA` has to be set:
   *       `PRAGMA case_sensitive_like = ON`.
   *
   * - Parameters:
   *   - pattern:         The string to search for.
   *   - caseInsensitive: Whether the match should ignore case, defaults to
   *                      `true` (`false` requires pragma!)
   */
  @inlinable
  func like(_ pattern: Self.Value, caseInsensitive: Bool = true)
       -> SQLColumnValuePredicate<Self>
  {
    SQLColumnValuePredicate(self, .like, pattern,
                            caseInsensitive: caseInsensitive)
  }
  
  /**
   * Checks whether the value in the column matches a SQLite GLOB pattern.
   *
   * Special match characters are `*` and `?`.
   *
   * Example:
   * ```swift
   * $0.name.glob("Du*") // does a `name GLOB 'Du*'`
   * ```
   *
   * - Parameters:
   *   - pattern:         The string to search for.
   *   - caseInsensitive: Whether the match should ignore case, defaults to
   *                      `false`.
   */
  @inlinable
  func glob(_ pattern: Self.Value, caseInsensitive: Bool = false)
       -> SQLColumnValuePredicate<Self>
  {
    SQLColumnValuePredicate(self, .glob, pattern,
                            caseInsensitive: caseInsensitive)
  }
}


// MARK: - KeyColumnValueSetPredicate

public extension SQLColumn {
  
  @inlinable
  func `in`(_ values: Set<Value>) -> SQLColumnValueSetPredicate<Self> {
    SQLColumnValueSetPredicate(self, values)
  }
  @inlinable
  func notIn(_ values: Set<Value>) -> SQLColumnValueSetPredicate<Self> {
    SQLColumnValueSetPredicate(self, values, negate: true)
  }
  
  @inlinable
  func `in`(_ values: Value...) -> SQLColumnValueSetPredicate<Self> {
    SQLColumnValueSetPredicate(self, values)
  }
  @inlinable
  func `in`<S>(_ values: S) -> SQLColumnValueSetPredicate<Self>
         where S: Sequence, S.Element == Value
  {
    SQLColumnValueSetPredicate(self, values)
  }
  @inlinable
  func notIn<S>(_ values: S) -> SQLColumnValueSetPredicate<Self>
         where S: Sequence, S.Element == Value
  {
    SQLColumnValueSetPredicate(self, values, negate: true)
  }
  @inlinable
  func notIn(_ values: Value...) -> SQLColumnValueSetPredicate<Self> {
    SQLColumnValueSetPredicate(self, values, negate: true)
  }
}

public extension Collection {
  
  @inlinable
  func contains<C>(_ column: C) -> SQLColumnValueSetPredicate<C>
         where C: SQLColumn, C.Value == Element
  {
    SQLColumnValueSetPredicate<C>(column, self)
  }
}
public extension Range {
  
  @inlinable
  func contains<C>(_ column: C) -> SQLColumnValueRangePredicate<C>
         where C: SQLColumn, C.Value == Element
  {
    SQLColumnValueRangePredicate<C>(column, self)
  }
}
public extension ClosedRange {
  
  @inlinable
  func contains<C>(_ column: C) -> SQLColumnValueRangePredicate<C>
         where C: SQLColumn, C.Value == Element
  {
    SQLColumnValueRangePredicate<C>(column, self)
  }
}

public extension SQLColumn where Value: Comparable {
  
  @inlinable
  func `in`(_ values: ClosedRange<Value>)
       -> SQLColumnValueRangePredicate<Self>
  {
    SQLColumnValueRangePredicate(self, values)
  }
}

public extension SQLKeyedTableSchema where PrimaryKeyColumn.Value: Comparable {
  
  @inlinable
  func `in`(_ values: ClosedRange<PrimaryKeyColumn.Value>)
       -> SQLColumnValueRangePredicate<PrimaryKeyColumn>
  {
    Self.primaryKeyColumn.in(values)
  }
}

public extension SQLKeyedTableSchema {
  // TBD: We could also match keyed records? (`$0.in(donald, mickey)`)

  /**
   * Check whether the primary key of a table is the same like the given value.
   *
   * Example:
   * ```swift
   * $0 == 1
   * ```
   */
  @inlinable
  static func ==(lhs: Self, rhs: Self.PrimaryKeyColumn.Value?)
         -> SQLColumnValuePredicate<Self.PrimaryKeyColumn>
  {
    Self.primaryKeyColumn == rhs
  }

  /**
   * Check whether the primary key of a table is a set of values
   *
   * Example:
   * ```swift
   * $0.in([ 1, 2 ])
   * ```
   */
  @inlinable
  func `in`(_ values: Set<PrimaryKeyColumn.Value>)
       -> SQLColumnValueSetPredicate<PrimaryKeyColumn>
  {
    Self.primaryKeyColumn.in(values)
  }
  /**
   * Check whether the primary key of a table is a set of values.
   *
   * Example:
   * ```swift
   * $0.in(1, 2)
   * ```
   */
  @inlinable
  func `in`(_ values: PrimaryKeyColumn.Value...)
       -> SQLColumnValueSetPredicate<PrimaryKeyColumn>
  {
    Self.primaryKeyColumn.in(values)
  }

  /**
   * Check whether the primary key of a table is a set of values.
   *
   * Example:
   * ```swift
   * $0.notIn([ 1, 2 ])
   * ```
   */
  @inlinable
  func notIn(_ values: Set<PrimaryKeyColumn.Value>)
       -> SQLColumnValueSetPredicate<PrimaryKeyColumn>
  {
    Self.primaryKeyColumn.notIn(values)
  }
  /**
   * Check whether the primary key of a table is a set of values.
   *
   * Example:
   * ```swift
   * $0.notIn(1, 2)
   * ```
   */
  @inlinable
  func notIn(_ values: PrimaryKeyColumn.Value...)
       -> SQLColumnValueSetPredicate<PrimaryKeyColumn>
  {
    Self.primaryKeyColumn.notIn(values)
  }
}

public extension SQLColumnValueSetPredicate {
  
  @inlinable
  static prefix func !(predicate: Self) -> SQLColumnValueSetPredicate<C> {
    SQLColumnValueSetPredicate(
      predicate.column, predicate.values, negate: !predicate.negate
    )
  }
}


// MARK: - KeyComparisonPredicate

public extension SQLColumn {
  
  /**
   * Check whether the ``SQLColumn`` is the same like the other column
   *
   * Example:
   * ```swift
   * $0.personId == $0.managerId
   * $0.name     == $0.maidenName
   * ```
   */
  @inlinable
  static func ==<O>(lhs: Self, rhs: O) -> SQLColumnComparisonPredicate<Self, O>
                where O: SQLColumn, Self.Value == O.Value
  {
    SQLColumnComparisonPredicate(lhs, .equal, rhs)
  }
  
  /**
   * Check whether the ``SQLColumn`` is different from the other.
   *
   * Example:
   * ```swift
   * $0.personId != $0.managerId
   * $0.name     != $0.maidenName
   * ```
   */
  @inlinable
  static func !=<O>(lhs: Self, rhs: O) -> SQLColumnComparisonPredicate<Self, O>
  where O: SQLColumn, Self.Value == O.Value
  {
    SQLColumnComparisonPredicate(lhs, .notEqual, rhs)
  }
  
  
  /**
   * Check whether the ``SQLColumn`` is smaller than the other.
   *
   * Example:
   * ```swift
   * $0.personId < $0.motherId
   * $0.name     < $0.lastname
   * ```
   */
  @inlinable
  static func < <O>(lhs: Self, rhs: O) -> SQLColumnComparisonPredicate<Self, O>
           where O: SQLColumn, Self.Value == O.Value
  {
    SQLColumnComparisonPredicate(lhs, .lessThan, rhs)
  }
  
  /**
   * Check whether the ``SQLColumn`` is smaller or equal to the other.
   *
   * Example:
   * ```swift
   * $0.personId <= $0.motherId
   * $0.name     <= $0.lastname
   * ```
   */
  @inlinable
  static func <= <O>(lhs: Self, rhs: O) -> SQLColumnComparisonPredicate<Self, O>
           where O: SQLColumn, Self.Value == O.Value
  {
    SQLColumnComparisonPredicate(lhs, .lessThanOrEqual, rhs)
  }
  
  /**
   * Check whether the ``SQLColumn`` is greater than the other.
   *
   * Example:
   * ```swift
   * $0.personId > $0.motherId
   * $0.name     > $0.lastname
   * ```
   */
  @inlinable
  static func > <O>(lhs: Self, rhs: O) -> SQLColumnComparisonPredicate<Self, O>
           where O: SQLColumn, Self.Value == O.Value
  {
    SQLColumnComparisonPredicate(lhs, .greaterThan, rhs)
  }
  
  /**
   * Check whether the ``SQLColumn`` is greater or equal to the other.
   *
   * Example:
   * ```swift
   * $0.personId >= $0.motherId
   * $0.name     >= $0.lastname
   * ```
   */
  @inlinable
  static func >=<O>(lhs: Self, rhs: O) -> SQLColumnComparisonPredicate<Self, O>
           where O: SQLColumn, Self.Value == O.Value
  {
    SQLColumnComparisonPredicate(lhs, .greaterThanOrEqual, rhs)
  }
}
