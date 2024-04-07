//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * The schema information for either a SQLite table or view.
 */
public protocol SQLEntitySchema: Sendable {

  /**
   * A tuple containing the SQL statement (or parameter) index of each
   * property.
   *
   * This is used when extracting values from result sets, without the need to
   * lookup a column name by string.
   * And similarily when binding properties as parameters.
   */
  associatedtype PropertyIndices

  /// The SQL name of the table or view.
  static var externalName        : String { get }

  /// A SQL `SELECT` statement selecting all columns of the table.
  static var select              : String { get }
  
  /// The indices of the properties in the ``select`` SQL.
  static var selectColumnIndices : PropertyIndices { get }
  
  /**
   * Given a SQLite prepared statement handle, this looks up the property
   * indices by external name (SQL column name).
   * This is used as a fallback when the SQL input is dynamic (i.e. not a
   * code generated statement).
   *
   * If the properties are not found in the result set, `-1` is returned as the
   * index for the property.
   *
   * - Parameters:
   *   - statement: A valid SQLite prepared statement handle.
   * - Returns:     The indices of the properties found (or -1 if missing).
   */
  static func lookupColumnIndices(in statement: OpaquePointer!)
              -> PropertyIndices

}

/// A schema that contains the SQL necessary to create the entity
public protocol SQLCreatableSchema : SQLEntitySchema {
  
  /// The SQL used to create the table or view.
  static var create : String { get }
}

// Those exist to account for modifiable VIEWs:
/**
 * The schema information for either a SQLite table or view that allows
 * insertion.
 */
public protocol SQLInsertableSchema : SQLEntitySchema {
  
  /// A SQL `INSERT` statement that can be used to insert a full record.
  static var insert                 : String { get }
  
  /// A SQL `INSERT` statement that can be used to insert a full record and
  /// receive the new values.
  /// `RETURNING` requires SQLite3 3.35.0+ (2021-03-12).
  static var insertReturning        : String { get }
  
  /// The indices of the properties in the ``insert`` SQL.
  static var insertParameterIndices : PropertyIndices { get }
}

/**
 * The schema information for either a SQLite table or view that allows
 * updates.
 */
public protocol SQLUpdatableSchema  : SQLEntitySchema {
  
  /// A SQL `UPDATE` statement that can be used to update a full record.
  static var update                 : String { get }
  
  /// The indices of the properties in the ``update`` SQL.
  static var updateParameterIndices : PropertyIndices { get }
}
/**
 * The schema information for either a SQLite table or view that allows
 * deletions.
 */
public protocol SQLDeletableSchema  : SQLEntitySchema {
  /// A SQL `DELETE` statement that can be used to delete a record.
  static var delete                 : String { get }
  /// The indices of the properties in the ``delete`` SQL.
  static var deleteParameterIndices : PropertyIndices { get }
}


/**
 * The schema information for either a SQLite view.
 */
public protocol SQLViewSchema: SQLEntitySchema {}

/**
 * The schema information for either a SQLite table.
 */
public protocol SQLTableSchema: SQLInsertableSchema, SQLDeletableSchema {
  // Note: SQLUpdatableSchema requires a primary key!
}

/**
 * The schema information for either a SQLite table with a single primary key.
 */
public protocol SQLKeyedTableSchema: SQLTableSchema, SQLUpdatableSchema {

  /// The sole primary column associated with the table.
  associatedtype PrimaryKeyColumn: SQLColumn
  
  static var primaryKeyColumn : PrimaryKeyColumn { get }
}
