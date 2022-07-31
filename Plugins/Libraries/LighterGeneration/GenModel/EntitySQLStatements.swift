//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3Schema

public extension EntityInfo {
  
  // Note:
  // Each item in a "PropertyIndices" tuple always corresponds to the ordering
  // of the properties!
  
  // MARK: - Select
  
  /// Returns the select columns, e.g. `"person_id", "lastname", "firstname"`
  var selectColumnsSQL : String {
    assert(!properties.isEmpty)
    return properties.map(\.externalName).map(escapeAndQuoteIdentifier)
                     .joined(separator: ", ")
  }
  /// Returns the indices of the properties in the ``selectColumnsSQL``
  /// (always `0..<count`, i.e. same order as the properties)
  var selectColumnIndices : [ Int ] { Array(properties.indices) }
  
  /// Returns the base SELECT statement, e.g.
  /// `SELECT "person_id", "lastname", "firstname" FROM "person"`
  var selectSQL: String {
    "SELECT \(selectColumnsSQL) FROM \(escapeAndQuoteIdentifier(externalName))"
  }
  
  // MARK: - Delete
  
  /// Returns the delete SQL, requires primary key columns to make most sense!
  /// E.g. `DELETE FROM person WHERE person_id = ?`
  /// If no primary keys are set, this expects all properties of the record.
  var deleteSQL: String {
    assert(!properties.isEmpty)
    return "DELETE FROM \(escapeAndQuoteIdentifier(externalName)) WHERE "
         + (recordMatchProperties
              .map(\.externalName).map(escapeAndQuoteIdentifier)
              .map { "\($0) = ?" })
           .joined(separator: " AND ")
  }
  /// Associates the property position with the parameter index in ``deleteSQL``
  /// Usually `1, -1, -1` when the first property is the primary key
  /// Returns `[]` if the entity has no properties
  var deleteParameterIndices: [ Int ] {
    var propertyIndices = [ Int ](repeating: -1, count: properties.count)
    
    for ( parameterIndex, pkey ) in recordMatchProperties.enumerated() {
      let propertyIndex = indexOfProperty(pkey)
      assert(propertyIndex >= 0)
      propertyIndices[propertyIndex] = parameterIndex + 1
    }
    return propertyIndices
  }
  
  // MARK: - Update
  
  /// Returns the update SQL, requires primary key columns to make sense!
  /// And value properties (non-pkey) too :-)
  /// E.g. `UPDATE person SET lastname = ?, firstname = ? WHERE person_id = ?`
  var updateSQL: String? {
    // Note: This really needs pkeys for the current "position tuple" based
    //       approach because a property can only appear once within the
    //       parameters.
    let valueProperties = properties.filter { !$0.isPrimaryKey }
    let pkeys           = primaryKeyProperties
    guard !pkeys.isEmpty && !valueProperties.isEmpty else { return nil }
    
    var sql = "UPDATE \(escapeAndQuoteIdentifier(externalName)) SET "
    sql += valueProperties.map(\.externalName).map(escapeAndQuoteIdentifier)
                          .map { "\($0) = ?" }
                          .joined(separator: ", ")
    sql += " WHERE "
    sql += pkeys.map(\.externalName).map(escapeAndQuoteIdentifier)
                .map { "\($0) = ?" }
                .joined(separator: " AND ")
    return sql
  }
  
  /// Associates the property position with the parameter index in ``updateSQL``
  /// Usually has the last parameter in the first position, when the first
  /// property is the primary key.
  /// E.g.: `UPDATE person SET lastname = ?, firstname = ? WHERE person_id = ?`
  /// Gives: `[ 3, 1, 2 ]`
  /// When `person_id` is the first property.
  /// Returns `[]` if the entity has no properties
  var updateParameterIndices: [ Int ] {
    var propertyIndices = [ Int ](repeating: -1, count: properties.count)
    
    let parameterProperties = properties.filter { !$0.isPrimaryKey }
                            + primaryKeyProperties
    for ( parameterIndex, pkey ) in parameterProperties.enumerated() {
      let propertyIndex = indexOfProperty(pkey)
      assert(propertyIndex >= 0)
      propertyIndices[propertyIndex] = parameterIndex + 1
    }
    return propertyIndices
  }

  // MARK: - Insert
  
  /// Returns the insert SQL. If there are not "auto" primary keys (INTEGER
  /// PRIMARY KEY, INTEGER PRIMARY KEY AUTOINCREMENT).
  /// E.g. `INSERT INTO person ( lastname, firstname ) VALUES ( ?, ? )` (plus
  /// returning select clause, which will yield the auto keys).
  var insertSQL: String {
    let valueProperties = properties.filter {
      !($0.isPrimaryKey && $0.canBeDatabaseGenerated)
    }
    
    var sql = "INSERT INTO \(escapeAndQuoteIdentifier(externalName)) ( "
    sql += valueProperties.map(\.externalName).map(escapeAndQuoteIdentifier)
                     .joined(separator: ", ")
    sql += " ) VALUES ( "
    sql += ([ String ](repeating: "?", count: valueProperties.count))
           .joined(separator: ", ")
    sql += " )"
    return sql
  }
  /// Returns the insert SQL. If there are not "auto" primary keys (INTEGER
  /// PRIMARY KEY, INTEGER PRIMARY KEY AUTOINCREMENT).
  /// E.g. `INSERT INTO person ( lastname, firstname ) VALUES ( ?, ? )` (plus
  /// returning select clause, which will yield the auto keys).
  var insertReturningSQL: String {
    return insertSQL + " RETURNING " + selectColumnsSQL
  }
  /// Associates the property position with the parameter index in ``insertSQL``
  /// Usually that has a `-1` in the first position, when the first
  /// property is the primary key.
  /// E.g.: `INSERT INTO person ( lastname, firstname ) VALUES ( ?, ? )`
  /// Gives: `[ -1, 1, 2 ]`
  /// When `person_id` is the first property.
  /// Returns `[]` if the entity has no properties
  var insertParameterIndices: [ Int ] {
    var propertyIndices = [ Int ](repeating: -1, count: properties.count)
    
    let valueProperties = properties.filter {
      !($0.isPrimaryKey && $0.canBeDatabaseGenerated)
    }
    for ( parameterIndex, pkey ) in valueProperties.enumerated() {
      let propertyIndex = indexOfProperty(pkey)
      assert(propertyIndex >= 0)
      propertyIndices[propertyIndex] = parameterIndex + 1
    }
    return propertyIndices
  }
}
