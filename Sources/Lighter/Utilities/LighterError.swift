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
public struct LighterError: Swift.Error, Sendable {
  
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

  /// The kind of the error that happened within Lighter.
  public enum ErrorType: Hashable, Sendable {
    
    // Those are Sendable, they are the record types internally.
    case insertFailed(record: any SQLInsertableRecord)
    case updateFailed(record: any SQLUpdatableRecord)
    case deleteFailed(record: any SQLDeletableRecord)

    case couldNotOpenDatabase(URL)
    
    case couldNotBeginTransaction
    case couldNotRollbackTransaction
    case couldNotCommitTransaction
    
    case couldNotFindRelationshipTarget
    
    @inlinable
    public static func ==(lhs: Self, rhs: Self) -> Bool {
      func isEqual<T: Equatable>(lhs: T, rhs: any Equatable) -> Bool {
        guard let rhs = rhs as? T else { return false }
        return lhs == rhs
      }
      
      switch ( lhs, rhs ) {
        case ( .insertFailed(let lhs), .insertFailed(let rhs)):
          return isEqual(lhs: lhs, rhs: rhs)
        case ( .updateFailed(let lhs), .updateFailed(let rhs)):
          return isEqual(lhs: lhs, rhs: rhs)
        case ( .deleteFailed(let lhs), .deleteFailed(let rhs)):
          return isEqual(lhs: lhs, rhs: rhs)

        case ( .couldNotOpenDatabase(let lhs), .couldNotOpenDatabase(let rhs)):
          return lhs == rhs
          
        case ( .couldNotBeginTransaction,    .couldNotBeginTransaction    ):
          return true
        case ( .couldNotRollbackTransaction, .couldNotRollbackTransaction ):
          return true
        case ( .couldNotCommitTransaction,   .couldNotCommitTransaction   ):
          return true
        case ( .couldNotFindRelationshipTarget, 
               .couldNotFindRelationshipTarget ):
          return true

        default:
          return false
      }
    }
    
    public func hash(into hasher: inout Hasher) {
      switch self {
        case .insertFailed(let record) : record.hash(into: &hasher)
        case .updateFailed(let record) : record.hash(into: &hasher)
        case .deleteFailed(let record) : record.hash(into: &hasher)
          
        case .couldNotOpenDatabase(let url): url.hash(into: &hasher)
          
        // TBD:
        case .couldNotBeginTransaction       : 1.hash(into: &hasher)
        case .couldNotRollbackTransaction    : 2.hash(into: &hasher)
        case .couldNotCommitTransaction      : 3.hash(into: &hasher)
        case .couldNotFindRelationshipTarget : 4.hash(into: &hasher)
      }
    }
  }
}
