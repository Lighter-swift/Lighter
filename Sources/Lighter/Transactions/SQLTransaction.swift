//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * A SQL transaction allows the user to run multiple SQL operations
 * as a single, atomic unit.
 *
 * Transactions are rolled back if anything within throws an error.
 *
 * Transactions can be started on database objects, like:
 * ```swift
 * try await db.transaction { tx in
 *   var person  = try tx.people.find(1)
 *   person.name = "Spitz"
 *   try tx.update(person)
 * }
 * ```
 * If the transaction is read-only, the optimized version can be used
 * (it also ensures that modifications are not triggered accidentially by
 *  statically not-providing the relevant methods):
 * ```swift
 * try await db.readTransaction { tx in
 *   let firstPerson  = try tx.people.find(1)
 *   let secondPerson = try tx.people.find(2)
 * }
 * ```
 *
 * Note: Within a transaction async calls are not allowed.
 *       This is intentional. A transaction can lock database objects,
 *       often the whole database. An async call can take an unspecified amount
 *       of time and there are no guarantees when it completes as it is
 *       cooperatively scheduled. This should leave a DB tx hanging.
 *
 * #### Performance
 *
 * A transaction has a fixed SQLite3 database assigned, which is why it is
 * also good when the best possible performance is required.
 *
 * It also avoids thread hops when async/await is being used. I.e. this:
 * ```swift
 * try await db.readTransaction { tx in
 *   let firstPerson  = try tx.people.find(1)
 *   let secondPerson = try tx.people.find(2)
 * }
 * ```
 * is better than:
 * ```swift
 * let firstPerson  = try await db.people.find(1)
 * let secondPerson = try await db.people.find(2)
 * ```
 * Though if concurrency is really wanted, this can be appropriate too:
 * ```swift
 * async let firstPerson  = db.people.find(1)
 * async let secondPerson = db.people.find(2)
 * try await doSth(with: firstPerson, and: secondPerson)
 * ```
 * (be careful w/ thrashing though)
 */
@dynamicMemberLookup
public class SQLTransaction<DB: SQLDatabase>: SQLDatabaseFetchOperations {
  
  /// The ``SQLDatabase`` the transaction is running against.
  public let database : DB

  /// The ``SQLRecordFetchOperations/recordTypes`` associated w/ the database.
  @inlinable
  public static var recordTypes : DB.RecordTypes { DB.recordTypes }

  /// The ``SQLConnectionHandler`` used for the transaction. This is only valid
  /// for one specific transaction.
  public let connectionHandler : SQLConnectionHandler
  
  /**
   * Initialize a new ``SQLTransaction``. Do not use directly.
   *
   * Instead call the ``SQLDatabase/transaction(mode:execute:)-kgor`` function
   * and companions.
   *
   * - Parameters:
   *   - database: The ``SQLDatabase`` the transaction is running against.
   *   - handle:   The SQLite3 database handle that was assigned to the
   *               transaction by the database.
   */
  @inlinable
  public init(_ database: DB, handle: OpaquePointer) {
    self.database = database
    self.connectionHandler =
      .unsafeReuse(handle, url: database.connectionHandler.url)
  }
  
  // Later: request manual rollback/commit (can already be done by throwing).
}
