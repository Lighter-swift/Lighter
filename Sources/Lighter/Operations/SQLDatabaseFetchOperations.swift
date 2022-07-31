//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A mixin protocol to add "select" functions.
 *
 * Example:
 * ```swift
 * let names = try db.select(from: \.people, \.name, orderBy: \.name)
 * ```
 *
 * See also: ``SQLDatabaseAsyncFetchOperations`` for async/await versions.
 */
public protocol SQLDatabaseFetchOperations: SQLDatabaseOperations {}
