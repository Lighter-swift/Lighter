//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3

// Filter operations use regular Swift closures for filtering results (as part
// of a SQL `WHERE` expression).

public extension SQLRecordFetchOperations
                   where T.Schema: SQLSwiftMatchableSchema
{
  
  /**
   * Fetch filtered records of a view/table w/o any sorting.
   *
   * Example:
   * ```
   * let people = try db.people.filter { $0.id == 2 }
   * ```
   *
   * - Parameters:
   *   - limit:  An optional fetch limit (defaults to no limit)
   *   - filter: A Swift closure that receives the associated ``SQLRecord``
   *             and can decide whether it should be included in the result.
   * - Returns:  An array of ``SQLRecord``s matching the type specified.
   * - Throws:   A ``SQLError`` if a SQLite error occurred.
   */
  @inlinable
  func filter(limit: Int? = nil, filter: @escaping ( T ) -> Bool)
         throws -> [ T ]
         where T.Schema: SQLSwiftMatchableSchema
  {
    try connectionHandler.withConnection(readOnly: true) { db in
      try withUnsafePointer(to: filter) { ptr in
        // Register/Unregister SQLite function
        
        guard T.Schema.registerSwiftMatcher(in: db, flags: SQLITE_UTF8,
                                            matcher: ptr) == SQLITE_OK else
        {
          throw SQLError(db)
        }
        defer {
          _ = T.Schema.unregisterSwiftMatcher(in: db, flags: SQLITE_UTF8)
        }
        
        // Prepare Query
        
        let sql = T.Schema.matchSelect
        
        var maybeStmt : OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &maybeStmt, nil) == SQLITE_OK,
              let stmt = maybeStmt else
        {
          assertionFailure("Failed to prepare SQL \(sql)")
          throw SQLError(db)
         }
        defer { sqlite3_finalize(stmt) }
          
        // Run fetch loop
        
        var records = [ T ]()
        
        while true {
          let rc = sqlite3_step(stmt)
          if      rc == SQLITE_DONE { break              }
          else if rc != SQLITE_ROW  { throw SQLError(db) }
          
          let record = T(stmt, indices: T.Schema.selectColumnIndices)
          records.append(record)
        }
        
        return records
      }
    }
  }
}
