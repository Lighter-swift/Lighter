//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * The transaction type defines whether a transaction needs write access
 * and in non-WAL mode, whether a transaction is exclusive (i.e. forbids
 * concurrent reads).
 *
 * The default is ``deferred``, which keeps the transaction in read mode until
 * the first modifying operation is issued (e.g. a delete or insert).
 */
public enum SQLTransactionType: String {
  
  /// Start a read transaction on the first SELECT and upgrade to a write
  /// transaction on the first modification.
  case deferred  = "DEFERRED"
  
  /// Immediatly start a writable transaction
  case immediate = "IMMEDIATE"
  
  /// The same like ``immediate`` in WAL mode, but forbids reads in others.
  case exclusive = "EXCLUSIVE"
  
  public static let `default` = SQLTransactionType.deferred
}
