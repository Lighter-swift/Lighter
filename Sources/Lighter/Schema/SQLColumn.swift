//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * Represents a SQL table or view column.
 *
 * A `Column` is tied to a specific ``SQLRecord`` type (a view or table) and
 * has a fixed associated `SQLiteValueType` (`Int`, `String`, `[ UInt8 ]` or
 * `Double`).
 *
 * The `Column` provides keyPath accessors for the associated table object,
 * and the external SQL name for query construction..
 *
 * Note that SQLite itself (w/o STRICT mode) allows columns to have arbitrary
 * types.
 */
public protocol SQLColumn: Hashable {
  
  /// The ``SQLTableRecord`` or ``SQLViewRecord`` of the column.
  associatedtype T     : SQLRecord
  
  /// The ``SQLiteValueType`` the column holds.
  associatedtype Value : SQLiteValueType & Hashable
  
  /**
   * The external SQL name of the column.
   *
   * For example `address_id`.
   */
  var externalName : String { get }

  /**
   * The `defaultValue` is used when a fetch result doesn't contain a
   * value for a particular column.
   *
   * This allows the API to keep non-optional fields, but still be used for
   * fragments or records that have not been inserted yet.
   */
  var defaultValue : Value { get }

  /**
   * A keypath that can be used to access the value of the column in the
   * associated ``SQLRecord``.
   */
  var keyPath      : KeyPath<T, Value> { get }
}


// MARK: - Concrete Types

// Maybe rename to `TableColumn` (w/ r/w keypath)
// ^^ because View's are not generated writable!!!

/**
 * A concrete implementation of the ``SQLColumn`` protocol.
 *
 * Checkout the ``SQLColumn`` description for more information.
 */
public struct MappedColumn<T, Value>: SQLColumn
         where T: SQLRecord, Value: SQLiteValueType & Hashable
{
  // the column itself doesn't need to have identity (though it has in SQLite)
  public let externalName : String
  public let defaultValue : Value
  public let keyPath      : KeyPath<T, Value>
  
  @inlinable
  public init(externalName: String, defaultValue: Value,
              keyPath: KeyPath<T, Value>)
  {
    self.externalName = externalName
    self.defaultValue = defaultValue
    self.keyPath      = keyPath
  }
}
