//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * Types conforming to this protocol can diff themselves against each other.
 */
public protocol SQLValueChanges {
  
  #if swift(>=5.7)
    /// Report the changes to the other record.
    func changes(from other: Self) -> [ any SQLColumnValueChange ]
  #endif
  
  /// Report the changes to the other record.
  @inlinable
  func anyChanges(from other: Self) -> [ String : Any ]
}


/**
 * Represents a value change in a ``SQLColumn`` that is attached to a
 * ``SQLTableRecord``.
 *
 * The change has access to the column itself, and to the old and new values.
 */
public protocol SQLColumnValueChange {
  
  /// The type of the ``SQLColumn`` that was changed.
  associatedtype C: SQLColumn
  
  /// The ``SQLColumn`` that was changed.
  var column   : C       { get }
  
  /// The old value of the column.
  var oldValue : C.Value { get }

  /// The new value of the column.
  var newValue : C.Value { get }
}

/**
 * A concrete implementation of the ``SQLColumnValueChange`` protocol.
 *
 * Checkout the ``SQLColumnValueChange`` description for more information.
 */
public struct MappedColumnValueChange<C>: SQLColumnValueChange
                where C: SQLColumn, C.T: SQLTableRecord
{
  // the column itself doesn't need to have identity
  public let column   : C
  public let oldValue : C.Value
  public let newValue : C.Value
}

#if swift(>=5.7) // for `any`
/**
 * A helper object for record diffing.
 */
@dynamicMemberLookup
public struct SQLRecordDiffingState<T: SQLTableRecord> {
  
  @inlinable
  var schema  : T.Schema { T.schema }

  @usableFromInline
  var changes = [ any SQLColumnValueChange ]()

  /**
   * The dynamic subscript allows the user to write `$0.personId` in:
   * ```
   * $0.addIfChanged($0.personId, ...) // <==
   * ```
   * it resolves to the ``SQLColumn`` in the ``SQLRecord``'s schema.
   */
  @inlinable
  public subscript<C>(dynamicMember path: KeyPath<T.Schema, C>) -> C
           where C: SQLColumn
  {
    T.schema[keyPath: path]
  }
  
  public mutating func addIfChanged<C>(_ column: C, old: C.Value, new: C.Value)
                  where C: SQLColumn, C.T: SQLTableRecord
  {
    guard old != new else { return }
    changes.append(MappedColumnValueChange<C>(
      column: column, oldValue: old, newValue: new)
    )
  }
}

public extension SQLTableRecord {
  
  // Later: We need a boolean variant for fast compares (i.e. didChange(from:))

  /**
   * This can be used by model classes to diff two models.
   *
   * Example:
   * ```swift
   * public extension Person {
   *
   *   func changes(from other: Self) -> [ any SQLColumnValueChange ] {
   *     calculateChanges {
   *       $0.addIfChanged($0.personId,  old: other.personId,  new: personId)
   *       $0.addIfChanged($0.firstname, old: other.firstname, new: firstname)
   *       $0.addIfChanged($0.lastname,  old: other.lastname,  new: lastname)
   *     }
   *   }
   * }
   * ```
   */
  func calculateChanges
         (using builder: (inout SQLRecordDiffingState<Self>) -> Void)
         -> [ any SQLColumnValueChange ]
  {
    var changes = SQLRecordDiffingState<Self>()
    builder(&changes)
    return changes.changes
  }
}
#endif // Swift 5.7
