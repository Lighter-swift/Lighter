//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3
import struct Foundation.URL

// Note: Things in here are INTENTIONALLY internal, so that can be only used
//       in `@testable` imports. They are NOT for general consumption.


internal extension SQLDatabase {
  
  /// Returns an database which loads the passed in URL into memory, so that
  /// tests can't be applied on it.
  /// This is ONLY intended for testing and requires a `@testable import`.
  static func loadIntoMemoryForTesting(_ url: URL) -> Self {
    let testDB = zqlite3_load_into_memory(url.path)
    return Self(connectionHandler:
        .unsafeReuse(testDB, url: url, closeOnDeinit: true))
  }
  
  /// This is ONLY intended for testing and requires a `@testable import`.
  var testDatabaseHandle : OpaquePointer! {
    guard let ch = connectionHandler as? SQLConnectionHandler.UnsafeReuse else {
      assertionFailure("Unexpected access to test database handle!")
      return nil
    }
    return ch.handle
  }
}

/**
 * Copies the SQLite database at the path into a SQLite in-memory database.
 *
 * - Returns: The db handle to the in-memory database, if successful.
 */
internal func zqlite3_load_into_memory(_ path: String) -> OpaquePointer? {
  var db : OpaquePointer?
  
  guard sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else
  {
    return nil
  }
  defer { sqlite3_close(db) }
  
  var memDB: OpaquePointer?
  guard sqlite3_open_v2(":memory:", &memDB, SQLITE_OPEN_READWRITE,
                        nil) == SQLITE_OK else
  {
    assertionFailure("Memdb open failed")
    return nil
  }

  guard let backup = sqlite3_backup_init(memDB, "main", db, "main") else {
    assertionFailure("Backup init failed")
    sqlite3_close(memDB)
    return nil
  }

  guard sqlite3_backup_step(backup, -1) == SQLITE_DONE /* 101 */ else {
    assertionFailure("Backup failed")
    sqlite3_backup_finish(backup)
    sqlite3_close(memDB)
    return nil
  }

  if sqlite3_errcode(memDB) != SQLITE_OK {
    if let backupError = sqlite3_errmsg(memDB).flatMap(String.init(cString:)) {
      assertionFailure("Backup failed: \(backupError)")
    }
    else {
      assertionFailure("Backup failed.")
    }
    sqlite3_backup_finish(backup)
    sqlite3_close(memDB)
    return nil
  }

  sqlite3_backup_finish(backup)
  return memDB
}
