//
//  Created by Helge Heß.
//  Copyright © 2022-2023 ZeeZide GmbH.
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
