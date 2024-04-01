//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import SQLite3

public extension SQLDatabase {
  
  /**
   * A SQL transaction allows the user to run multiple SQL operations
   * as a single, atomic unit.
   *
   * Transactions can be started on database objects, like:
   * ```swift
   * try db.transaction { tx in
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
  @discardableResult
  func transaction<R>(mode    : SQLTransactionType = .default,
                      execute : ( SQLChangeTransaction<Self> ) throws -> R)
         throws -> R
  {
    return try connectionHandler.withConnection(readOnly: false) { db in
      let startSQL = "BEGIN \(mode.rawValue) TRANSACTION;"
      var errorMessage : UnsafeMutablePointer<CChar>?
      let startRC = sqlite3_exec(db, startSQL, nil, nil, &errorMessage)
      if startRC != SQLITE_OK {
        throw LighterError(.couldNotBeginTransaction, startRC, errorMessage)
      }
      
      let result : R
      do {
        let tx = SQLChangeTransaction(self, handle: db)
        result = try execute(tx)
      }
      catch {
        sqlite3_exec(db, "ROLLBACK TRANSACTION;", nil, nil, nil)
        throw error
      }
      
      errorMessage = nil
      let commitRC = sqlite3_exec(db, "COMMIT TRANSACTION;", nil, nil,
                                  &errorMessage)
      if commitRC != SQLITE_OK {
        sqlite3_exec(db, "ROLLBACK TRANSACTION;", nil, nil, nil)
        throw LighterError(.couldNotCommitTransaction, startRC, errorMessage)
      }

      return result
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
   * try db.readTransaction { tx in
   *   let person1 = tx.people.find(1)
   *   let person2 = tx.people.find(2)
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
  func readTransaction<R>(execute : ( SQLTransaction<Self> ) throws -> R)
         throws -> R
  {
    return try connectionHandler.withConnection(readOnly: true) { db in
      let startSQL = "BEGIN DEFERRED TRANSACTION;"
      var errorMessage : UnsafeMutablePointer<CChar>?
      let startRC = sqlite3_exec(db, startSQL, nil, nil, &errorMessage)
      if startRC != SQLITE_OK {
        throw LighterError(.couldNotBeginTransaction, startRC, errorMessage)
      }

      let result : R
      do {
        let tx = SQLTransaction(self, handle: db)
        result = try execute(tx)
      }
      catch {
        sqlite3_exec(db, "ROLLBACK TRANSACTION;", nil, nil, nil)
        throw error
      }
      
      errorMessage = nil
      let commitRC = sqlite3_exec(db, "ROLLBACK TRANSACTION;", nil, nil,
                                  &errorMessage)
      if commitRC != SQLITE_OK {
        throw LighterError(.couldNotRollbackTransaction, startRC, errorMessage)
      }

      return result
    }
  }
}
