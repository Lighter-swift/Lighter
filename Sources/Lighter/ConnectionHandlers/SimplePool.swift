//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import class  Foundation.NSLock
import struct Foundation.Date
import struct Foundation.TimeInterval
import struct Foundation.URL
import Dispatch
import func SQLite3.sqlite3_close
#if os(iOS)
import UIKit
#endif

extension SQLConnectionHandler {
  
  /**
   * A simple connection pool that can free pooled connections after a timeout.
   */
  public final class SimplePool: SQLConnectionHandler {

    /// The maximum age of a pooled connection (after that it will be closed).
    public let maxAge              : TimeInterval
    
    /// The maximum number of pooled connections per configuration (r/o, r/w).
    /// If more connections are opened, they will be closed and not get pooled.
    public let maxPerConfiguration : Int
    
    private struct Entry {
      let handle      : OpaquePointer
      let releaseDate : Date
    }
    
    private let lock    = NSLock() // common, just one!
    private var caches  = [ Configuration : [ Entry ] ]()
    private var gc      : DispatchWorkItem?
    
    #if os(iOS) // Q: .main
      private var allowPooling   = true
      private var fgSubscription : NSObjectProtocol?
      private var bgSubscription : NSObjectProtocol?
    #else
      private let allowPooling   = true
    #endif
    
    /// Initialize a simple pool.
    public init(url: URL, readOnly: Bool,
                maxAge: TimeInterval = 3.0,
                maximumPoolSizePerConfiguration: Int = 8,
                writeTimeout: TimeInterval)
    {
      self.maxAge              = maxAge
      self.maxPerConfiguration = maximumPoolSizePerConfiguration
      super.init(url: url, readOnly: readOnly, writeTimeout: writeTimeout)
      
      #if os(iOS)
      subscribeForAppStateNotifications()
      #endif
    }
    deinit {
      gc?.cancel(); gc = nil
      closePooledConnections()
      
      #if os(iOS)
        unsubscribeFromAppStateNotifications()
      #endif
    }
    
    
    // MARK: - App State Handling

    #if os(iOS)
    private func subscribeForAppStateNotifications() {
      DispatchQueue.main.async {
        let nc = NotificationCenter.default
        self.fgSubscription = nc.addObserver(
          forName: UIApplication.willEnterForegroundNotification, object: nil,
          queue: nil) { [weak self] _ in self?.willEnterForeground() }
        self.bgSubscription = nc.addObserver(
          forName: UIApplication.didEnterBackgroundNotification, object: nil,
          queue: nil) { [weak self] _ in self?.didEnterBackground() }
      }
    }
    private func unsubscribeFromAppStateNotifications() {
      DispatchQueue.main.async {
        let nc = NotificationCenter.default
        if let token = self.fgSubscription { nc.removeObserver(token) }
        if let token = self.bgSubscription { nc.removeObserver(token) }
        self.fgSubscription = nil
        self.bgSubscription = nil
      }
    }
    private func willEnterForeground() {
      lock.lock()
      allowPooling = true // re-enable pooling in case it was disabled
      lock.unlock()
    }
    private func didEnterBackground() {
      lock.lock()
      allowPooling = false // disable pooling
      lock.unlock()
      closePooledConnections()
    }
    #endif
    
    
    // MARK: - Connection Handling

    /// Synchronously closes all handles in the pool.
    public func closePooledConnections() {
      lock.lock()
      let old = caches
      caches = [:]
      lock.unlock()
      
      for cache in old.values {
        for entry in cache {
          sqlite3_close(entry.handle)
        }
      }
    }
    
    override public func openConnection(_ configuration: Configuration) throws
                         -> OpaquePointer
    {
      lock.lock()
      let entry = (caches[configuration]?.isEmpty ?? true)
                ? nil
                : caches[configuration]?.removeLast()
      lock.unlock()
      if let entry = entry { return entry.handle }
      
      return try super.openConnection(configuration)
    }

    override public func releaseConnection(_       connection : OpaquePointer?,
                                           with configuration : Configuration,
                                           afterError   error : Error? = nil)
    {
      guard let connection = connection else { return }
      guard error == nil else { return } // don't pool connections w/ errors
      
      let now   = Date()
      let entry = Entry(handle: connection, releaseDate: now)
      
      lock.lock()
      if !allowPooling ||
        (caches[configuration]?.count ?? 0) > maxPerConfiguration
      {
        return lock.unlock() // cache full or backgrounding
      }
      
      if caches[configuration]?.append(entry) == nil {
        caches[configuration] = [ entry ]
      }
      lock.unlock()
      
      scheduleGCIfNecessary()
    }

    private func scheduleGCIfNecessary() {
      lock.lock()
      if gc != nil { return lock.unlock() }
      let wi = DispatchWorkItem { [weak self] in self?._collect() }
      gc = wi
      lock.unlock()
      
      // Note that handles _can_ live longer within the timeout. For simplicity
      // we just schedule at the full timeout, so handles can live up to
      // timeout*2.
      DispatchQueue.global()
        .asyncAfter(deadline: .now() + .milliseconds(Int(maxAge * 1000.0)),
                    execute: wi)
    }
    
    private func _collect() {
      // Proper pools are hard ™️
      let now              = Date()
      var hasContents      = false
      var handlesToRelease : Array<OpaquePointer> = []
      
      lock.lock()
      
      for ( config, cache ) in caches {
        for ( idx, entry ) in cache.enumerated().reversed() {
          if (entry.releaseDate.addingTimeInterval(maxAge)) < now {
            caches[config]?.remove(at: idx)
            handlesToRelease.append(entry.handle)
          }
          else {
            if !hasContents { hasContents = true }
          }
        }
      }
      
      self.gc = nil
      lock.unlock()

      if hasContents { scheduleGCIfNecessary() }
      
      // close outside the lock
      for handle in handlesToRelease {
        sqlite3_close(handle)
      }
    }
  }
}
