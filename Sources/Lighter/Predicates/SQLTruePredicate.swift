//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * Returns a predicate that always matches.
 */
public struct SQLTruePredicate: SQLPredicate {

  /// A shared instance of the true predicate.
  public static let shared = SQLTruePredicate()
  
  // MARK: - SQL Generation

  static let sql = "1 = 1"
  
  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    builder.append(Self.sql)
  }
}

extension SQLPredicate where Self == SQLTruePredicate {
  
  static var `true` : SQLTruePredicate { .shared }
}

/**
 * Returns a predicate that always matches or never.
 */
public struct SQLBoolPredicate: SQLPredicate {

  public static let `true`  = Self(value: true)
  public static let `false` = Self(value: false)
  
  public let value : Bool
  
  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    builder.append(value ? "1 = 1" : "1 = 0")
  }
}

extension SQLPredicate where Self == SQLBoolPredicate {
  
  static var `false` : SQLBoolPredicate { .false }
}

extension Bool: SQLPredicate {

  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    if self {
      SQLTruePredicate.shared.generateSQL(into: &builder)
    }
    else {
      SQLBoolPredicate.false.generateSQL(into: &builder)
    }
  }
}
