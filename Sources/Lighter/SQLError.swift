//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import struct Foundation.URL

/**
 * An error that is thrown by Lighter database operations.
 *
 * This carries a higher level error type as well as the SQLite3
 * error code and message.
 */
public struct LighterError: Swift.Error {

  /// The kind of the error that happened within Lighter.
  public enum ErrorType: Hashable {
    
    case insertFailed(record: AnyHashable)
    case updateFailed(record: AnyHashable)
    case deleteFailed(record: AnyHashable)

    case couldNotOpenDatabase(URL)
    
    case couldNotBeginTransaction
    case couldNotRollbackTransaction
    case couldNotCommitTransaction
    
    case couldNotFindRelationshipTarget
  }
  
  /// The higher level error type.
  public let type    : ErrorType
  
  /// The SQLite3 error code.
  public let code    : Int32
  /// The SQLite3 error message.
  public let message : String?
  
  @inlinable
  public init(_ type: ErrorType,
              _ code: Int32, _ message: UnsafePointer<CChar>? = nil)
  {
    self.type    = type
    self.code    = code
    self.message = message.flatMap(String.init(cString:))
  }
}

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
