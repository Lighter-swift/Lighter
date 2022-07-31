//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

// Same like `SQLDatabaseFetchOperations`, async/await variant if available.

/**
 * A mixin protocol to add async/await variants of the "select"
 * functions.
 *
 * Example:
 * ```swift
 * let persons = try await db.select(from: \.people, \.name, orderBy: \.name)
 * ```
 */
public protocol SQLDatabaseAsyncFetchOperations
                : SQLDatabaseAsyncOperations, SQLDatabaseFetchOperations {}
