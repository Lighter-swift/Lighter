//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import Foundation

/// The settings specific to the API usage of the Lighter lib
/// (embedded or not).
public struct LighterAPI: Equatable, Sendable {
  
  /// `SQLRecord`
  public var recordType               = "SQLRecord"
  /// `SQLViewRecord`
  public var viewRecordType           = "SQLViewRecord"
  /// `SQLTableRecord`
  public var tableRecordType          = "SQLTableRecord"
  /// `SQLKeyedTableRecord`
  public var keyedTableRecordType     = "SQLKeyedTableRecord"
  public var insertableRecord         = "SQLInsertableRecord"
  public var updatableRecord          = "SQLUpdatableRecord"
  public var deletableRecord          = "SQLDeletableRecord"
  
  /// `SQLViewSchema`
  public var viewSchemaType           = "SQLViewSchema"
  /// `SQLTableSchema`
  public var tableSchemaType          = "SQLTableSchema"
  /// `SQLKeyedTableSchema`
  public var keyedTableSchemaType     = "SQLKeyedTableSchema"
  public var insertableSchema         = "SQLInsertableSchema"
  public var updatableSchema          = "SQLUpdatableSchema"
  public var deletableSchema          = "SQLDeletableSchema"
  public var swiftMatchableSchemaType = "SQLSwiftMatchableSchema"
  public var creatableSchema          = "SQLCreatableSchema"
  /// `RecordType`
  public var schemaRecordType         = "RecordType"
  /// `lookupColumnIndices`
  public var lookupColumnIndices      = "lookupColumnIndices"
  /// `columnCount`
  public var columnCount              = "columnCount"
  /// `MappedColumn`
  public var mappedColumnType         = "MappedColumn"
  /// `MappedForeignKey`
  public var mappedForeignKeyType     = "MappedForeignKey"

  /// `SQLColumn`
  public var columnType               = "SQLColumn"
  /// `SQLBuilder`
  public var builderType              = "SQLBuilder"
  /// `SQLPredicate`
  public var predicateType            = "SQLPredicate"
  /// `SQLSortOrder`
  public var sortOrderType            = "SQLSortOrder"

  /// `RecordTypes`
  public var recordTypeLookupTarget   = "RecordTypes"
  /// `recordTypes`
  public var recordTypesVariable      = "recordTypes"
  /// `Schema`
  public var recordSchemaName         = "Schema"
  /// `schema`
  public var recordSchemaVariableName = "schema"
  
  public var propertyIndicesType      = "PropertyIndices"

  public var columnValuePAT           = "Value"
  public var columnTablePAT           = "T"
  
  /// runOnDatabaseQueue
  public var asyncRunFunction         = "runOnDatabaseQueue"
  /// connectionHandler
  public var connectionHandler        = "connectionHandler"
  /// ConnectionHandler
  public var connectionHandlerType    = "SQLConnectionHandler"

  /// sqlString(for: column1)
  public var builderColumnKeyPathSQL  = "sqlString"
  
  public var registerSwiftMatcher     = "registerSwiftMatcher"
  public var unregisterSwiftMatcher   = "unregisterSwiftMatcher"
  
  /// SQLRecordFetchOperations
  public var recordFetchOperationsProtocol = "SQLRecordFetchOperations"
  /// SQLDatabaseFetchOperations
  public var dbFetchOperationsProtocol     = "SQLDatabaseFetchOperations"
  /// SQLDatabaseAsyncOperations
  public var dbAyncOperationsProtocol      = "SQLDatabaseAsyncOperations"

  public init() {}
}
