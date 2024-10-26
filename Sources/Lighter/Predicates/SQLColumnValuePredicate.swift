//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

#if canImport(Foundation)
import struct Foundation.Data
#endif

/**
 * A predicate that compares a ``SQLColumn`` of a table/view against
 * a literal value.
 *
 * Example:
 * ```swift
 * let people = try await db.select(from: \.people, \.id, \.lastname) {
 *   $0.id == 2 && ($0.lastname == "Duck" || $0.lastname == "Duck")
 * }
 * ```
 */
public struct SQLColumnValuePredicate<C: SQLColumn>: SQLPredicate {
  
  public enum ComparisonOperator: String {
    
    /**
     * Check whether the ``SQLColumn`` is the same like the given value.
     *
     * Example:
     * ```swift
     * $0.personId == 1
     * $0.name     == "Duck"
     * ```
     */
    case equal              = "="

    /**
     * Check whether the ``SQLColumn`` is different from the given value.
     *
     * Example:
     * ```swift
     * $0.personId != 1
     * $0.name     != "Duck"
     * ```
     */
    case notEqual           = "!="

    /**
     * Check whether the ``SQLColumn`` is smaller than the given value.
     *
     * Example:
     * ```swift
     * $0.personId < 1
     * $0.name     < "Duck"
     * ```
     */
    case lessThan           = "<"

    /**
     * Check whether the ``SQLColumn`` is smaller or equal to the given value.
     *
     * Example:
     * ```swift
     * $0.personId <= 1
     * $0.name     <= "Duck"
     * ```
     */
    case lessThanOrEqual    = "<="

    /**
     * Check whether the ``SQLColumn`` is greater than the given value.
     *
     * Example:
     * ```swift
     * $0.personId > 1
     * $0.name     > "Duck"
     * ```
     */
    case greaterThan        = ">"

    /**
     * Check whether the ``SQLColumn`` is greater or equal to the given value.
     *
     * Example:
     * ```swift
     * $0.personId >= 1
     * $0.name     >= "Duck"
     * ```
     */
    case greaterThanOrEqual = ">="
    
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
    case hasPrefix          = "LIKE[_*]"

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
    case hasSuffix          = "LIKE[*_]"

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
    case contains           = "LIKE[*_*]"

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
    case like               = "LIKE"

    /**
     * Checks whether the value in the column matches a SQLite GLOB pattern.
     *
     * Special match characters are `*` and `?`.
     *
     * Example:
     * ```swift
     * $0.name.glob("D*ck") // does a `name GLOB 'D*ck'`
     * ```
     *
     * - Parameters:
     *   - pattern:         The string to search for.
     *   - caseInsensitive: Whether the match should ignore case, defaults to
     *                      `false`.
     */
    case glob               = "GLOB"
    
    @inlinable
    public var isCaseSensitiveByDefault : Bool {
      switch self {
        case .equal, .notEqual, .lessThan, .lessThanOrEqual,
             .greaterThan, .greaterThanOrEqual: return true
        case .hasPrefix, .hasSuffix, .contains, .like: return false
        case .glob: return true
      }
    }
  }
  
  /// The operation to use for the comparison.
  public let comparator      : ComparisonOperator
  
  /// The column to compare the value against.
  public let column          : C

  /// The value to compare the column against.
  public let value           : C.Value?
  
  /// Note that SQLite does case _insensitve_ compares by default,
  /// to enable case-sensitive, `PRAGMA case_sensitive_like = ON;` has
  /// to be run on the connection.
  public let caseInsensitive : Bool

  /**
   * Setup a new ``SQLColumnValuePredicate``,
   * note that using the provided operators/functions on the column are the
   * preferred way to do this.
   *
   * Examples:
   * ```swift
   * $0.personId == 2      // `person_id = 2`
   * $0.name.contains("e") // `name LIKE ?`, 1: `%e%`
   * $0.name.hasPrefix("A", caseInsensitive: false)
   *                       // `LOWER(name) LIKE LOWER(?)`, 1: `%A`
   * ```
   *
   * - Parameters:
   *   - column:          The ``SQLColumn`` to compare
   *   - comparator:      The comparison operation, e.g. `equals` or `glob`
   *   - value:           The value to compare the column against, can be `nil`!
   *                      (will produce `IS NULL` queries)
   *   - caseInsensitive: Whether the comparison should ignore the case
   *                      (defaults to `true` for LIKE operators!)
   */
  @inlinable
  public init(_ column: C, _ comparator: ComparisonOperator, _ value: C.Value?,
              caseInsensitive: Bool? = nil)
  {
    self.comparator      = comparator
    self.column          = column
    self.value           = value
    self.caseInsensitive = caseInsensitive
                        ?? !comparator.isCaseSensitiveByDefault
  }
  
  
  // MARK: - SQL Generation

  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    // in ZeeQL this is done using `is` checks, i.e. not dispatched out to the
    // qualifiers. But we want to have it as part of the protocol here.
    
    let column     = builder.sqlString(for: column)
    
    if value == nil {
      if      comparator == .equal    {
        return builder.append(column + " IS NULL")
      }
      else if comparator == .notEqual {
        return builder.append(column + " IS NOT NULL")
      }
    }
    
    switch comparator {
      
      case .equal, .notEqual, .lessThan, .lessThanOrEqual,
           .greaterThan, .greaterThanOrEqual, .like, .glob:
        if caseInsensitive { builder.append("LOWER(") }
        builder.append(column)
        builder.append(caseInsensitive ? ") " : " ")
        builder.append(comparator.rawValue)
        builder.append(caseInsensitive ? " LOWER(" : " ")
        builder.append(builder.sqlString(for: value))
        if caseInsensitive { builder.append(")") }
      
      case .hasPrefix, .hasSuffix, .contains:
        guard let value = value else {
          builder.append("1 = 0") // column LIKE *NULL doesn't even compile
          return
        }
      
        generateLike(
          for: column, with: value,
          prefix:
            comparator == .contains || comparator == .hasSuffix ? "%" : "",
          suffix:
            comparator == .contains || comparator == .hasPrefix ? "%" : "",
          into: &builder
        )
    }
  }
  
  public func generateLike<Base>(for column: String,
                                 with value: SQLiteValueType,
                                 prefix: String, suffix: String,
                                 into builder: inout SQLBuilder<Base>)
  {
    var castColumn : String { "CAST(\(column) AS TEXT)" }

#if canImport(Foundation)
    if let data = value as? Data {
      generateLike(for: column, with: [ UInt8 ](data),
                   prefix: prefix, suffix: suffix, into: &builder)
      return
    }
#endif

    switch value {
      case let s as String:
        // still need to escape the pattern!
        let escapeChar : String?
        let escaped    : String
        if !s.contains(where: { specialLikeChars.contains($0) }) {
          escaped    = s
          escapeChar = nil
        }
        else {
          escapeChar = "^"
          escaped = s
            .replacingOccurrences(of: "^", with: "^^")
            .replacingOccurrences(of: "_", with: "^_")
            .replacingOccurrences(of: "%", with: "^%")
            .replacingOccurrences(of: "'", with: "^'")
            .replacingOccurrences(of: "\"", with: "^\"")
        }
      
        // LOWER around the pattern works, tested
        if caseInsensitive { builder.append("LOWER(") }
        builder.append(column)
        builder.append(caseInsensitive ? ") LIKE LOWER(" : " LIKE ")
        
        let pattern = prefix + escaped + suffix // binds the full pattern
        builder.append(builder.sqlString(for: pattern))
        if caseInsensitive { builder.append(")") }
        if let c = escapeChar { builder.append(" ESCAPE '\(c)'") }

      case let v as Int: // case has no effect on numbers, right?
        builder.append("\(castColumn) LIKE '\(prefix)\(v)\(suffix)'")
      
      case let v as Double:
        builder.append("\(castColumn) LIKE '\(prefix)\(v)\(suffix)'")
      
      case is [ UInt8 ]: // Later
        fatalError("BLOB LIKE not supported yet!")
      
      default:
        var sqlString = value.sqlStringValue
        if sqlString.first == "'" { // it is a string
          assert(sqlString.count >= 2 && sqlString.last == "'")
          sqlString = String(sqlString.dropFirst().dropLast())
        }
        generateLike(for: column, with: sqlString,
                     prefix: prefix, suffix: suffix, into: &builder)
    }
  }
}

private let specialLikeChars : Set<Character> = [ "_", "%", "'", "\"" ]

#if swift(>=5.5)
extension SQLColumnValuePredicate.ComparisonOperator : Sendable {}
#endif
