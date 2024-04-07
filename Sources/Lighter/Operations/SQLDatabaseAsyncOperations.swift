//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import Dispatch

/**
 * An object that can host asynchronous operations.
 * 
 * To accomplish that, it provides the ``asyncDatabaseQueue-5emzh``
 * (which defaults to the `DispatchQueue.global()`).
 *
 * The actual operations can be found in:
 * - ``SQLDatabaseFetchOperations``
 * - ``SQLDatabaseAsyncChangeOperations``
 */
public protocol SQLDatabaseAsyncOperations: SQLDatabaseOperations, Sendable {
  
  /**
   * The queue that is used to run concurrent async SQL operations.
   *
   * The maximum SQLite currently supports is multi-reader/single-writer.
   *
   * Defaults to `DispatchQueue.global()`.
   */
  var asyncDatabaseQueue : DispatchQueue { get }
  
}
public extension SQLDatabaseAsyncOperations {
  
  // It might make sense to schedule updates on a single update queue,
  // but then updates should generally be run in a transaction anyways.
  // So not worth optimizing for.
  
  /// The default `DispatchQueue` used for asynchronous operations.
  @inlinable
  var asyncDatabaseQueue : DispatchQueue {
    DispatchQueue.global()
  }
  
#if swift(>=5.5) && canImport(_Concurrency)
  /**
   * Asynchronously runs the given block in the
   * ``SQLDatabaseAsyncOperations/asyncDatabaseQueue-89vi8``.
   *
   * - Parameters:
   *   - block: The block to execute in the queue.
   * - Returns: The return value of the block.
   * - Throws:  Rethrows any errors the block throws.
   */
  @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
  @inlinable
  func runOnDatabaseQueue<R>(block: @Sendable @escaping () throws -> R) async throws -> R
  {
    return try await withCheckedThrowingContinuation { continuation in
      asyncDatabaseQueue.async {
        do    { continuation.resume(returning : try block()) }
        catch { continuation.resume(throwing  : error) }
      }
    }
  }
#endif // 5.5 + Concurrency
}

