//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * The transaction type defines whether a transaction needs write access
 * and in non-WAL mode, whether a transaction is exclusive (i.e. forbids
 * concurrent reads).
 *
 * The default is ``immediate``, which directly acquires the database write
 * lock.
 * It is preferred over ``deferred``, because transaction upgrades will
 * immediately fail w/ `SQLITE_BUSY` if the database lock is in use.
 * While an immediate transaction will wait to acquire the lock.
 */
public enum SQLTransactionType: String, Sendable {
  
  /// Start a read transaction on the first SELECT and upgrade to a write
  /// transaction on the first modification.
  /// Careful: When transactions are upgraded by writes and the database is
  ///          locked already, a `SQLITE_BUSY` error will be issued immediately
  ///          (i.e. it won't wait for the lock becoming available).
  case deferred  = "DEFERRED"

  /// Immediatly start a writable transaction. This will acquire (and possibly
  /// wait) for the database write lock.
  case immediate = "IMMEDIATE"
  
  /// The same like ``immediate`` in WAL mode, but protects against concurrent
  /// reads in others.
  case exclusive = "EXCLUSIVE"
  
  @inlinable
  public static var `default` : SQLTransactionType { .immediate }
}
