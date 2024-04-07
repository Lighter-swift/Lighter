//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

public extension SQLRecordFetchOperations {
  
  // MARK: - Destination Multi Fetch

  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses = try db.addresses.fetch(for: \.personId, in: persons)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to the ``SQLForeignKeyColumn`` (e.g. `\.personId`)
   *   - destinationRecords: A sequence of records matching the destination of
   *                 the foreign key (e.g. `[ donald, dagobert ]`.
   *   - omitEmpty:  Whether to omit destination records that have no values
   *                 in the foreign key table.
   *   - limit:      An optional limit on the results.
   */
  @inlinable
  func fetch<FK, S>(for foreignKey: KeyPath<T.Schema, FK>,
                    in destinationRecords: S,
                    omitEmpty : Bool = false,
                    limit     : Int? = nil)
         throws -> [ FK.Destination : [ T ] ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value,
               S: Sequence, S.Element == FK.Destination
  {
    try fetch(for: T.schema[keyPath: foreignKey], in: destinationRecords,
              omitEmpty: omitEmpty, limit: limit)
  }

  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses =
   *       try db.addresses.fetch(for: Person.Schema.personId, in: persons)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to the ``SQLForeignKeyColumn`` (e.g. `\.personId`)
   *   - destinationRecords: A sequence of records matching the destination of
   *                 the foreign key (e.g. `[ donald, dagobert ]`.
   *   - omitEmpty:  Whether to omit destination records that have no values
   *                 in the foreign key table.
   *   - limit:      An optional limit on the results.
   */
  @_disfavoredOverload
  @inlinable
  func fetch<FK, S>(for foreignKey: FK,
                    in destinationRecords: S,
                    omitEmpty : Bool = false,
                    limit     : Int? = nil)
         throws -> [ FK.Destination : [ T ] ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value,
               S: Sequence, S.Element == FK.Destination
  {
    var destinationKeys   = [ FK.DestinationColumn.Value ]()
    var keyedDestinations = [ FK.DestinationColumn.Value :  FK.Destination ]()
    for record in destinationRecords {
      let value = record[keyPath: foreignKey.destinationColumn.keyPath]
      destinationKeys.append(value)
      assert(keyedDestinations[value] == nil)
      keyedDestinations[value] = record
    }
    
    var builder    = SQLBuilder<T>()
    let predicate  = foreignKey.in(destinationKeys)
    builder.generateSelect(limit: limit, predicate: predicate)
    
    var resultMap = [ FK.Destination : [ T ] ]()
    resultMap.reserveCapacity(destinationKeys.count)
    if !omitEmpty {
      for destinationRecord in destinationRecords {
        resultMap[destinationRecord] = []
      }
    }
    
    try operations.fetch(builder.sql, builder.bindings) { stmt, _ in
      let sourceRecord = T(stmt, indices: T.Schema.selectColumnIndices)
      let sourceValue  = sourceRecord[keyPath: foreignKey.keyPath]
      guard let destinationRecord = keyedDestinations[sourceValue] else {
        assertionFailure("Got unexpected record?")
        return
      }
      if resultMap[destinationRecord]?.append(sourceRecord) == nil {
        resultMap[destinationRecord] = [ sourceRecord ]
      }
    }
    
    return resultMap
  }
  
  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses = try db.addresses.fetch(for: \.personId, in: personIDs)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to the ``SQLForeignKeyColumn`` (e.g. `\.personId`)
   *   - destinationsColumns: A sequence of records matching the destination of
   *                 the foreign key (e.g. `[ donald, dagobert ]`.
   *   - omitEmpty:  Whether to omit destination records that have no values
   *                 in the foreign key table.
   *   - limit:      An optional limit on the results.
   */
  @inlinable
  func fetch<FK, S>(for foreignKey: KeyPath<T.Schema, FK>,
                    in destinationsColumns: S,
                    omitEmpty : Bool = false,
                    limit     : Int? = nil)
         throws -> [ FK.DestinationColumn.Value : [ T ] ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value,
               S: Sequence, S.Element == FK.DestinationColumn.Value
  {
    try fetch(for: T.schema[keyPath: foreignKey], in: destinationsColumns,
              omitEmpty: omitEmpty, limit: limit)
  }

  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses =
   *   try db.addresses.fetch(for: Address.schema.personId, in: personIDs)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to the ``SQLForeignKeyColumn`` (e.g. `\.personId`)
   *   - destinationsColumns: A sequence of records matching the destination of
   *                 the foreign key (e.g. `[ donald, dagobert ]`.
   *   - omitEmpty:  Whether to omit destination records that have no values
   *                 in the foreign key table.
   *   - limit:      An optional limit on the results.
   */
  @_disfavoredOverload
  @inlinable
  func fetch<FK, S>(for foreignKey: FK, in destinationsColumns: S,
                    omitEmpty: Bool = false, limit: Int? = nil)
         throws -> [ FK.DestinationColumn.Value : [ T ] ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value,
               S: Sequence, S.Element == FK.DestinationColumn.Value
  {
    var builder    = SQLBuilder<T>()
    let predicate  = foreignKey.in(destinationsColumns)
    builder.generateSelect(limit: limit, predicate: predicate)
    
    var resultMap = [ FK.DestinationColumn.Value : [ T ] ]()
    resultMap.reserveCapacity(predicate.values.count)
    if !omitEmpty {
      for destinationColumn in destinationsColumns {
        resultMap[destinationColumn] = []
      }
    }
    
    try operations.fetch(builder.sql, builder.bindings) { stmt, _ in
      let sourceRecord = T(stmt, indices: T.Schema.selectColumnIndices)
      let sourceValue  = sourceRecord[keyPath: foreignKey.keyPath]
      if resultMap[sourceValue]?.append(sourceRecord) == nil {
        resultMap[sourceValue] = [ sourceRecord ]
      }
    }
    
    return resultMap
  }


  // MARK: - Destination Fetch
  
  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses = try db.addresses.fetch(for: \.personId, in: person)
   * ```
   */
  @inlinable
  func fetch<FK>(for foreignKey: KeyPath<T.Schema, FK>,
                 in destinationRecord: FK.Destination,
                 limit: Int? = nil)
         throws -> [ T ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value
  {
    try fetch(for: T.schema[keyPath: foreignKey], in: destinationRecord,
              limit: limit)
  }

  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses = try db.addresses.fetch(for: \.personId, in: person)
   * ```
   */
  @_disfavoredOverload
  @inlinable
  func fetch<FK>(for foreignKey: FK, in destinationRecord: FK.Destination,
                 limit: Int? = nil)
         throws -> [ T ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value
  {
    let value = destinationRecord[keyPath: foreignKey.destinationColumn.keyPath]
    
    var builder    = SQLBuilder<T>()
    let predicate  = foreignKey == value
    builder.generateSelect(limit: limit, predicate: predicate)
    
    var records = [ T ]()
    try operations.fetch(builder.sql, builder.bindings) { stmt, _ in
      let record = T(stmt, indices: T.Schema.selectColumnIndices)
      records.append(record)
    }
    
    return records
  }
  
  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses = try db.addresses.fetch(for: \.personId, in: person)
   * ```
   */
  @inlinable
  func fetch<FK>(for foreignKey: KeyPath<T.Schema, FK>,
                 in destinationRecord: FK.Destination,
                 limit: Int? = nil)
         throws -> [ T ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value? // source is optional
  {
    try fetch(for: T.schema[keyPath: foreignKey], in: destinationRecord,
              limit: limit)
  }
  
  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses =
   *   try db.addresses.fetch(for: Address.schema.personId, in: person)
   * ```
   */
  @_disfavoredOverload
  @inlinable
  func fetch<FK>(for foreignKey: FK,
                 in destinationRecord: FK.Destination,
                 limit: Int? = nil)
         throws -> [ T ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value? // source is optional
  {
    let value = destinationRecord[keyPath: foreignKey.destinationColumn.keyPath]
    
    var builder    = SQLBuilder<T>()
    let predicate  = foreignKey == value
    builder.generateSelect(limit: limit, predicate: predicate)
    
    var records = [ T ]()
    try operations.fetch(builder.sql, builder.bindings) { stmt, _ in
      let record = T(stmt, indices: T.Schema.selectColumnIndices)
      records.append(record)
    }
    
    return records
  }
  
  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses = try db.addresses.fetch(for: \.personId, in: person)
   * ```
   */
  @inlinable
  func fetch<FK>(for foreignKey: KeyPath<T.Schema, FK>,
                 in destinationRecord: FK.Destination,
                 limit: Int? = nil)
         throws -> [ T ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value? == FK.DestinationColumn.Value // dest is optional
  {
    try fetch(for: T.schema[keyPath: foreignKey], in: destinationRecord,
              limit: limit)
  }
  /**
   * Fetch the records associated with the foreign key.
   *
   * ```swift
   * let addresses = try db.addresses.fetch(for: \.personId, in: person)
   * ```
   */
  @_disfavoredOverload
  @inlinable
  func fetch<FK>(for foreignKey: FK, in destinationRecord: FK.Destination,
                 limit: Int? = nil)
         throws -> [ T ]
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value? == FK.DestinationColumn.Value // dest is optional
  {
    let value = destinationRecord[keyPath: foreignKey.destinationColumn.keyPath]
    
    var builder    = SQLBuilder<T>()
    let predicate  = foreignKey == value
    builder.generateSelect(limit: limit, predicate: predicate)
    
    var records = [ T ]()
    try operations.fetch(builder.sql, builder.bindings) { stmt, _ in
      let record = T(stmt, indices: T.Schema.selectColumnIndices)
      records.append(record)
    }
    
    return records
  }

  
  // MARK: - Source Find
  
  /**
   * Locate the record connected to a specific foreign key.
   *
   * Example:
   * ```swift
   * let person = try db.addresses.findTarget(for: \.personId, in: address)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to foreign key to match (e.g. `\.personId`).
   *   - record:     The record containing the foreign key.
   * - Returns:      The destination record, if found.
   */
  @inlinable
  func findTarget<FK>(for foreignKey: KeyPath<T.Schema, FK>, in record: T)
         throws -> FK.Destination?
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value
  {
    try findTarget(for: T.schema[keyPath: foreignKey], in: record)
  }
  /**
   * Locate the record connected to a specific foreign key.
   *
   * Example:
   * ```swift
   * let person = try db.addresses.findTarget(for: \.personId, in: address)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to foreign key to match (e.g. `\.personId`).
   *   - record:     The record containing the foreign key.
   * - Returns:      The destination record, if found.
   */
  @_disfavoredOverload
  @inlinable
  func findTarget<FK>(for foreignKey: FK, in record: T)
         throws -> FK.Destination?
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == FK.DestinationColumn.Value
  {
    // This could still be `Int? == Int?`, we might also want a non-optional
    // variant? (that doesn't return an optional destination, but throws
    // instead).
    let value      = record[keyPath: foreignKey.keyPath]
    
    var builder    = SQLBuilder<FK.Destination>()
    let predicate  = foreignKey.destinationColumn == value
    builder.generateSelect(limit: 1, predicate: predicate)
    
    var record : FK.Destination? = nil
    try operations.fetch(builder.sql, builder.bindings) { stmt, stop in
      record = FK.Destination(stmt,
                              indices: FK.Destination.Schema.selectColumnIndices)
      stop = true
    }
    
    return record
  }
  
  /**
   * Locate the record connected to a specific (nullable) foreign key.
   *
   * Example:
   * ```swift
   * let person = try db.addresses.findTarget(for: \.personId, in: address)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to foreign key to match (e.g. `\.personId`).
   *   - record:     The record containing the foreign key.
   * - Returns:      The destination record, if found.
   */
  @inlinable
  func findTarget<FK>(for foreignKey: KeyPath<T.Schema, FK>, in record: T)
         throws -> FK.Destination?
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == Optional<FK.DestinationColumn.Value> // source is optional
  {
    try findTarget(for: T.schema[keyPath: foreignKey], in: record)
  }
  /**
   * Locate the record connected to a specific (nullable) foreign key.
   *
   * Example:
   * ```swift
   * let person = try db.addresses.findTarget(for: \.personId, in: address)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to foreign key to match (e.g. `\.personId`).
   *   - record:     The record containing the foreign key.
   * - Returns:      The destination record, if found.
   */
  @_disfavoredOverload
  @inlinable
  func findTarget<FK>(for foreignKey: FK, in record: T)
         throws -> FK.Destination?
         where FK: SQLForeignKeyColumn, FK.T == T,
               FK.Value == Optional<FK.DestinationColumn.Value> // source is optional
  {
    // This is the variant where an optional foreign-key matches the
    // non-optional destination column.
    guard let value = record[keyPath: foreignKey.keyPath] else { return nil }

    var builder   = SQLBuilder<FK.Destination>()
    let predicate = foreignKey.destinationColumn == value
    builder.generateSelect(limit: 1, predicate: predicate)
    
    var record : FK.Destination? = nil
    try operations.fetch(builder.sql, builder.bindings) { stmt, stop in
      record = FK.Destination(stmt,
                    indices: FK.Destination.Schema.selectColumnIndices)
      stop = true
    }
    
    return record
  }
  
  /**
   * Locate the record connected to a specific (nullable) foreign key.
   *
   * Example:
   * ```swift
   * let person = try db.addresses.findTarget(for: \.personId, in: address)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to foreign key to match (e.g. `\.personId`).
   *   - record:     The record containing the foreign key.
   * - Returns:      The destination record, if found.
   */
  @inlinable
  func findTarget<FK>(for foreignKey: KeyPath<T.Schema, FK>, in record: T)
         throws -> FK.Destination?
         where FK: SQLForeignKeyColumn, FK.T == T,
               Optional<FK.Value> == FK.DestinationColumn.Value // dest is optional
  {
    try findTarget(for: T.schema[keyPath: foreignKey], in: record)
  }
  
  /**
   * Locate the record connected to a specific (nullable) foreign key.
   *
   * Example:
   * ```swift
   * let person = try db.addresses.findTarget(for: \.personId, in: address)
   * ```
   *
   * - Parameters:
   *   - foreignKey: KeyPath to foreign key to match (e.g. `\.personId`).
   *   - record:     The record containing the foreign key.
   * - Returns:      The destination record, if found.
   */
  @_disfavoredOverload
  @inlinable
  func findTarget<FK>(for foreignKey: FK, in record: T)
         throws -> FK.Destination?
         where FK: SQLForeignKeyColumn, FK.T == T,
               Optional<FK.Value> == FK.DestinationColumn.Value // dest is optional
  {
    // This is the variant where an non-optional foreign-key matches an
    // optional destination column (e.g. the primary can be NULL! Northwind...).
    let value     = record[keyPath: foreignKey.keyPath]
    
    var builder   = SQLBuilder<FK.Destination>()
    let predicate = foreignKey.destinationColumn == value
    builder.generateSelect(limit: 1, predicate: predicate)
    
    var record : FK.Destination? = nil
    try operations.fetch(builder.sql, builder.bindings) { stmt, stop in
      record = FK.Destination(stmt,
                    indices: FK.Destination.Schema.selectColumnIndices)
      stop = true
    }
    
    return record
  }
}
