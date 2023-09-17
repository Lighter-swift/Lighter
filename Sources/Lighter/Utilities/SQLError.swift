//
//  Created by Helge Heß.
//  Copyright © 2022-2023 ZeeZide GmbH.
//

import func SQLite3.sqlite3_errcode
import func SQLite3.sqlite3_errmsg

/**
 * A raw SQLite3 error.
 *
 * Encapsulates the SQLite3 error code and message in a throwable Swift error.
 *
 * It can be initialized from a raw SQLite3 database handle, e.g.:
 * ```swift
 * let rc = sqlite3_exec...(db)
 * guard rc == SQLITE3_OK else { throw SQLError(db) }
 * ```
 */
public struct SQLError: Swift.Error, Equatable {
  
  /// The SQLite3 error code.
  public let code    : Int32
  /// The SQLite3 error message.
  public let message : String?
  
  /**
   * Create a new ``SQLError`` from the SQLite3 error code and message.
   *
   * - Parameters:
   *   - code:    The SQLite3 error code.
   *   - message: The SQLite3 error message.
   */
  @inlinable
  public init(_ code: Int32, _ message: UnsafePointer<CChar>? = nil) {
    self.code    = code
    self.message = message.flatMap(String.init(cString:))
  }
  
  /**
   * Create a new ``SQLError`` from the error contained in a SQLite3 database
   * handle.
   *
   * - Parameters:
   *   - db: A SQLite3 database handle.
   */
  @inlinable
  public init(_ db: OpaquePointer!) {
    self.code    = sqlite3_errcode(db)
    self.message = sqlite3_errmsg(db).flatMap(String.init(cString:))
  }
}
