//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import func SQLite3.sqlite3_close
import let  SQLite3.SQLITE_FAIL
import struct Foundation.URL

extension SQLConnectionHandler {
  
  /**
   * The `UnsafeReuse` handler just vends the same connection.
   *
   * This is used in transactions, which have a single connection assigned,
   * and for testing scenarios.
   * It is only applicable if operations are executed in a strictly serial
   * manner.
   */
  public final class UnsafeReuse: SQLConnectionHandler {
    
    public private(set) var handle            : OpaquePointer?
    public private(set) var openConfiguration : Configuration?
    public              let closeOnDeinit     : Bool

    /// Initialize a new UnsafeReuse handler.
    public init(url: URL, handle: OpaquePointer? = nil,
                closeOnDeinit: Bool = false)
    {
      self.closeOnDeinit = closeOnDeinit
      self.handle = handle
      super.init(url: url)
    }
    deinit {
      if closeOnDeinit, let handle = handle {
        sqlite3_close(handle)
        self.handle = nil
      }
    }
    
    /// Clear the handle w/o closing the database.
    public func clear() {
      handle = nil
    }
    /// Close the database and clear the handle
    public func close() {
      if let handle = handle { sqlite3_close(handle) }
      clear()
    }
    
    override public func openConnection(_ configuration: Configuration) throws
                         -> OpaquePointer
    {
      guard let handle = handle else {
        throw LighterError(.couldNotOpenDatabase(url), SQLITE_FAIL,
                           "Unsafe handle got cleared.")
      }
      assert(openConfiguration == nil,
             "Attempt to open an unsafe-reuse connection a second time!")
      openConfiguration = configuration
      return handle
    }
    
    override public func releaseConnection(_       connection : OpaquePointer?,
                                           with configuration : Configuration,
                                           afterError   error : Error? = nil)
    {
      guard let connection = connection else {
        assert(connection != nil,
               "Attempt to release an nil connection")
        return
      }
      guard connection == handle else {
        assert(connection == handle,
               "Attempt to release an incorrect unsafe handle?")
        return
      }
      if let openConfiguration = openConfiguration {
        assert(openConfiguration == configuration,
               "The release configuration differs from active one?")
      }
      else {
        assertionFailure("Found no open configuration on release?")
      }
      
      openConfiguration = nil
    }
  }
}

