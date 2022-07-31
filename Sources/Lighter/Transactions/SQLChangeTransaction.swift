//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A SQL transaction allows the user to run multiple SQL operations
 * as a single, atomic unit.
 *
 * A SQLChangeTransaction allows modifications to the database (updates,
 * inserts and deletes), as provided by ``SQLDatabaseChangeOperations``.
 *
 * Transactions can be started on database objects, like:
 * ```swift
 * try await db.transaction { tx in
 *   let firstPerson  = try tx.people.find(1)
 *   var secondPerson = try tx.people.find(2)
 *
 *   secondPerson.lastName = "New Name"
 *   try tx.update(secondPerson)
 * }
 * ```
 * 
 * Note: Within a transaction async calls are not allowed.
 */
public final class SQLChangeTransaction<DB: SQLDatabase>
                   : SQLTransaction<DB>, SQLDatabaseChangeOperations
{
}
