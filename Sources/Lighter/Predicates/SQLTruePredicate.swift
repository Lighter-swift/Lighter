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
