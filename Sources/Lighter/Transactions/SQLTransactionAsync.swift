//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

// The async/await variants of the SQLDatabase transaction operations,
// if Swift concurrency is available.

#if swift(>=5.5) && canImport(_Concurrency)

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLDatabase where Self: SQLDatabaseAsyncOperations {
  
  /**
   * A SQL transaction allows the user to run multiple SQL operations
   * as a single, atomic unit.
   *
   * Transactions can be started on database objects, like:
   * ```swift
   * try await db.transaction { tx in
   *   var person  = try tx.people.find(1)
   *   person.name = "Spitz"
   *   try tx.update(person)
   * }
   * ```
   * If the transaction is read-only (does no modifications to the database),
   * the ``SQLDatabase/readTransaction(execute:)-8mbsj`` should be used.
   * SQLite only supports one writer per database, using this method will
   * acquire such a lock by default. Using `readTransaction` avoids that
   * (multiple readers are allowed, in particular if the DB is set to the WAL
   *  mode).
   *
   * Note: Within a transaction async calls are not allowed (as they can
   *       block the transaction, and with it the database, for a unforseeable
   *       time).
   *
   * - Parameters:
   *   - mode:    The mode defaults to ``SQLTransactionType/immediate``, which
   *              opens/waits for the database lock right away.
   *              It can be set to ``SQLTransactionType/deferred`` to start with
   *              a read-lock, but note that upgrades on locked databases will
   *              fail w/ `SQLITE_BUSY` immediately.
   *   - execute: The code which is executed within the transaction
   * - Returns:   The result of the `execute` closure if the transaction got
   *              committed successfully.
   */
  @inlinable
  @discardableResult
  func transaction<R>(
    mode    : SQLTransactionType = .default,
    execute : @Sendable @escaping ( SQLChangeTransaction<Self> ) throws -> R
  ) async throws -> R
  {
    try await runOnDatabaseQueue {
      try transaction(mode: mode, execute: execute)
    }
  }

  /**
   * A read-only SQL transaction allows the user to run multiple SQL operations
   * efficiently.
   *
   * To modify records, ``SQLDatabase/transaction(mode:execute:)-kgor`` must
   * be used.
   *
   * ```swift
   * try await db.readTransaction { tx in
   *   let person1 = try tx.people.find(1)
   *   let person2 = try tx.people.find(2)
   * }
   * ```
   *
   * A read only transaction is always rolled back and never committed.
   * A read transaction is always opened in ``SQLTransactionType/deferred``
   * mode.
   *
   * Note: Within a transaction async calls are not allowed.
   *
   * - Parameters:
   *   - execute: The code which is executed within the transaction
   * - Returns:   The result of the `execute` closure if the transaction got
   *              rolled back successfully.
   */
  @inlinable
  @discardableResult
  func readTransaction<R>(execute: @Sendable @escaping
                                   (SQLTransaction<Self>) throws -> R)
         async throws -> R
  {
    try await runOnDatabaseQueue {
      try readTransaction(execute: execute)
    }
  }
}

#endif // 5.5 + Concurrency
