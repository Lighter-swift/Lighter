//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * An entity schema which supports selects that filter using a Swift closure
 * (vs a SQL `WHERE` condition).
 */
public protocol SQLSwiftMatchableSchema: SQLEntitySchema {
  
  /// The query used for filter operations.
  ///
  /// It starts with the ``SQLEntitySchema/select`` and has the Swift matcher
  /// in a `WHERE` clause.
  static var  matchSelect : String { get }
  
  /**
   * Register the Swift matcher closure used to filter SQL results.
   * This is called before filter queries are issued.
   *
   * - Parameters:
   *   - db:      A SQLite3 database handle.
   *   - flags:   Flags to pass over to the function registration.
   *   - matcher: A raw pointer to the Swift closure used for evaluation.
   * - Returns:   The SQLite3 error code if something failed.
   */
  static func registerSwiftMatcher  (in db: OpaquePointer!, flags: Int32,
                                     matcher: UnsafeRawPointer)
              -> Int32
  /**
   * Unregister the Swift matcher closure used to filter SQL results.
   * This is called after filter queries had been issued.
   *
   * - Parameters:
   *   - db:      A SQLite3 database handle.
   *   - flags:   Flags to pass over to the function registration.
   * - Returns:   The SQLite3 error code if something failed.
   */
  static func unregisterSwiftMatcher(in db: OpaquePointer!, flags: Int32)
              -> Int32
}
