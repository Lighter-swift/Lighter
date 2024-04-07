//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * Returns a predicate that always matches.
 */
public struct SQLTruePredicate: SQLPredicate {

  @inlinable
  static var shared : SQLTruePredicate { SQLTruePredicate() }

  // MARK: - SQL Generation

  static let sql = "1 = 1"
  
  @inlinable
  public init() {}
  
  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    builder.append(Self.sql)
  }
}

extension SQLPredicate where Self == SQLTruePredicate {
  
  @inlinable
  static var `true` : SQLTruePredicate { SQLTruePredicate() }
}

/**
 * Returns a predicate that always matches or never.
 */
public struct SQLBoolPredicate: SQLPredicate {

  @inlinable
  public static var `true`  : Self { Self(true)  }
  @inlinable
  public static var `false` : Self { Self(false) }
  
  public let value : Bool
  
  @inlinable
  public init(_ value: Bool) { self.value = value }
  
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
