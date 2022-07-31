//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import struct Foundation.URL
import struct Foundation.TimeInterval
import SQLite3

/**
 * An object used to open a database connection.
 *
 * This can be subclassed by users to implement custom pooling strategies.
 */
open class SQLConnectionHandler {
  
  /**
   * Returns a connection handler that will open a new database handle on
   * each request.
   *
   * That is safe to use, but can be slow when used w/o transactions or with
   * a lot of async calls.
   */
  public static func reopen(url: URL, readOnly: Bool = false,
                            writeTimeout: TimeInterval = 10.0)
                     -> SQLConnectionHandler
  {
    SQLConnectionHandler(url: url, readOnly: readOnly,
                         writeTimeout: writeTimeout)
  }
  
  public static func simplePool(url: URL, readOnly: Bool,
                                maxAge: TimeInterval = 3.0,
                                maximumPoolSizePerConfiguration: Int = 8,
                                writeTimeout: TimeInterval = 10.0)
                     -> SimplePool
  {
    SimplePool(url: url, readOnly: readOnly, maxAge: maxAge,
               maximumPoolSizePerConfiguration: maximumPoolSizePerConfiguration,
               writeTimeout: writeTimeout)
  }
  
  /**
   * Create a connection handle from an existing, open handle.
   *
   * This is useful when a SQLite3 database handle was already acquired by
   * other means.
   */
  public static func unsafeReuse(_ unsafeHandle: OpaquePointer?, url: URL,
                                 closeOnDeinit: Bool = false)
                     -> UnsafeReuse
  {
    UnsafeReuse(url: url, handle: unsafeHandle, closeOnDeinit: closeOnDeinit)
  }

  
  // MARK: - Configuration

  public struct Configuration: Hashable {
    // Note: Would be nicer to just have the URL attached to a config and have
    //       the handlers independent of specific URLs, but that makes other
    //       stuff more involved.
    
    public let readOnly : Bool
    
    @inlinable
    public init(readOnly: Bool = false) {
      self.readOnly = readOnly
    }
  }

  public let url          : URL
  public let readOnly     : Bool
  public let writeTimeout : TimeInterval
  
  @inlinable
  public init(url: URL, readOnly: Bool = false,
              writeTimeout: TimeInterval = 10.0)
  {
    self.url          = url
    self.readOnly     = readOnly
    self.writeTimeout = writeTimeout
  }

  
  // MARK: - Operation
  
  /**
   * Execute the provided closure with an open connection.
   */
  public func withConnection<R>(readOnly : Bool,
                                execute  : ( OpaquePointer ) throws -> R)
                throws -> R
  {
    let cfg = SQLConnectionHandler
                .Configuration(readOnly: readOnly || self.readOnly)
    let db  = try openConnection(cfg)
    do {
      let result = try execute(db)
      releaseConnection(db, with: cfg)
      return result
    }
    catch {
      releaseConnection(db, with: cfg, afterError: error)
      throw error
    }
  }
  
  /**
   * Acquire a new database connection.
   *
   * The default implementation opens a new database handle on each request
   * and tracks no information about the handle.
   * This can still be performant if transactions are used to execute queries
   * (as they will reuse a connection).
   *
   * The caller can close the handle (using `sqlite3_close`), or return a
   * handle for potential reuse using ``releaseConnection(_:with:afterError:)``.
   *
   * - Parameters:
   *   - configuration: The ``Configuration`` for the connection
   * - Returns:         A SQLite3 database connection handle.
   */
  open func openConnection(_ configuration: Configuration) throws
            -> OpaquePointer
  {
    var flags : Int32 = SQLITE_OPEN_URI | SQLITE_OPEN_NOMUTEX
    flags |= configuration.readOnly
           ? SQLITE_OPEN_READONLY
           : SQLITE_OPEN_READWRITE
    var db : OpaquePointer?
    let rc = sqlite3_open_v2(url.absoluteString, &db, flags, nil)
    
    guard let db = db, rc == SQLITE_OK else {
      let error = LighterError(.couldNotOpenDatabase(url),
                               rc, db.flatMap { sqlite3_errmsg($0) })
      if let db = db { sqlite3_close(db) }
      throw error
    }
    
    sqlite3_busy_timeout(db, Int32(writeTimeout * 1000 /* ms */))
    
    return db
  }
  
  /**
   * Release a database connection for potential reuse.
   *
   * The default implementation just closes the handle using `sqlite3_close`
   * and ignores the other parameters.
   */
  open func releaseConnection(_       connection : OpaquePointer?,
                              with configuration : Configuration,
                              afterError   error : Swift.Error? = nil)
  {
    guard let connection = connection else { return }
    sqlite3_close(connection)
  }
}
