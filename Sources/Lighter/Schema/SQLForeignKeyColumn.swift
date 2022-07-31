//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/**
 * A ``SQLColumn`` that is a (single) foreign key targetting a different column
 * in another table.
 */
public protocol SQLForeignKeyColumn: SQLColumn {

  /// The type of the ``SQLColumn`` the foreign key is targetting.
  associatedtype DestinationColumn : SQLColumn
  
  /// The type of the ``SQLTableRecord`` the foreign key is targetting.
  typealias Destination = DestinationColumn.T

  /// The destination ``SQLColumn`` the foreign key is targetting.
  var destinationColumn : DestinationColumn { get }
}


/**
 * A concrete implementation of the ``SQLForeignKeyColumn`` protocol.
 *
 * Checkout the ``SQLForeignKeyColumn`` description for more information.
 */
public struct MappedForeignKey<T, Value, DestinationColumn>: SQLForeignKeyColumn
         where T: SQLRecord, Value: SQLiteValueType & Hashable,
               DestinationColumn: SQLColumn
{
  // the column itself doesn't need to have identity (though it has in SQLite)
  public let externalName      : String
  public let defaultValue      : Value
  public let keyPath           : KeyPath<T, Value>
  public let destinationColumn : DestinationColumn

  @inlinable
  public init(externalName: String, defaultValue: Value,
              keyPath: KeyPath<T, Value>,
              destinationColumn: DestinationColumn)
  {
    self.externalName      = externalName
    self.defaultValue      = defaultValue
    self.keyPath           = keyPath
    self.destinationColumn = destinationColumn
  }
}
