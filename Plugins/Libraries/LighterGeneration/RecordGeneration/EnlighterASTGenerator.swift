//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import LighterCodeGenAST
import class  Foundation.DateFormatter
import struct Foundation.Locale

/**
 * This is class converts the in-memory model of the database (``DatabaseInfo``)
 * into a Swift AST representation of the associated code.
 * That AST can then be written to Swift source code using the `CodeGenerator`.
 */
public final class EnlighterASTGenerator {
  
  /// The database model.
  public let database : DatabaseInfo
  /// The name of the Swift file that is being generated.
  public let filename : String
  
  public struct Options: Equatable, Sendable {
    
    /// How to bind Date values into the database.
    public enum DateStorageStyle: String, Sendable {
      /// Save as a REAL containing the unix timestamp
      case timeIntervalSince1970 = "utime"
      /// Save as text, using a formatter.
      case formatter
    }
    /// How to store UUID columns, as strings or blobs
    public enum UUIDStorageStyle: String, Sendable {
      /// Store UUIDs as string, e.g. `81E42B93-3DA3-47BB-8D82-9BDE9E60242F`
      case text
      /// Store UUIDs as compact 16-byte BLOBs (efficient)
      case blob
    }
    
    /// How the generated code should import Lighter (if enabled)
    public enum LighterImport: String, Sendable {
      case none
      case `import`
      case reexport
    }
    
    /// Whether or how to generate low-level SQLite functions.
    public enum RawFunctionStyle: Hashable, Sendable {
      /// Do not generate low level `sqlite3_record_fetch` style functions.
      case omit
      /// Attach the low-level functions to the Record type itself,
      /// e.g. `Person.fetch(from: db) { match }` or `person.insert(into: db)`
      case attachToRecordType
      /// Generate global functions, e.g. `sqlite3_people_fetch()` and
      /// `sqlite3_person_insert`.
      case globalFunctions(prefix: String) // default prefix: `sqlite3_`
    }
    
    public enum RawOperationNames: Equatable, Sendable {
      case lowercaseAndPluralize
    }
    
    public var api             = LighterAPI()
    
    /// Whether the SQL to create the database should be included.
    /// I.e. `CREATE TABLE` etc statements.
    public var omitCreationSQL = false
    
    /// Only generate read operations.
    public var readOnly        = false
    
    /// Generate async/await Lighter conformances (``useLighter`` is enabled).
    public var asyncAwait      = true
    
    /// Whether record types should be generated as subtypes of the database
    /// type.
    /// E.g.
    /// ```swift
    /// struct TestDatabase {
    ///   struct Person: TableRecord { ... }
    /// }
    /// ```
    public var nestRecordTypesInDatabase = false
    
    /// Whether the API should be generated as `public` API (vs `internal`)
    public var `public`        = true
    
    /// Whether public functions should be generated as `@inlinable`.
    /// This exposes the function sources in the module header, which is
    /// good for the Swift optimizer.
    public var inlinable       = true
    
    /// Whether the Lighter library should be used. Lighter has a set of
    /// types to make typesafe queries against the database.
    public var useLighter      = true
    
    /// Whether the Lighter library should be imported. The other option is
    /// to embed the lib directly in the source.
    public var importLighter   = LighterImport.import
    
    /// Whether the use of Foundation is allowed.
    public var allowFoundation = true
    
    /// Whether property access should be prefixed with `.self`,
    /// e.g. `self.id`.
    public var qualifiedSelf   = false
    
    // Later: derive from useLighter AND the select generation settings
    /// Whether examples for column select operations should be generated into
    /// the comments.
    public var generateSelectExamples = true
    
    /// Whether or how to generate low-level SQLite functions
    public var rawFunctions : RawFunctionStyle
    = .globalFunctions(prefix: "sqlite3_")
    
    /// How to adjust the names of `sqlite3_persons_update` and such.
    public var generateRawOperations = RawOperationNames.lowercaseAndPluralize
    
    /// Whether to generate functions that fetch relationships.
    public var generateRawRelationships = true
    
    /// If `INSERT RETURNING` is not available, use a select fallback, like in
    /// Lighter.
    public var provideRawInsertReturningFallback = true
    
    /// Whether to generate functions that fetch relationships.
    public var generateLighterRelationships = true
    
    /// If ``useLighter`` is enabled, the records will conform to `Hashable`
    /// automatically by means of other protocols.
    /// If not, this can be used to mark them as `Hashable`.
    /// Records are always Hashable, because all supported column value types
    /// are Hashabe.
    public var markRawStructsAsHashable     = true
    
    /// Additional protocol conformances that should be attached to the
    /// record structures. Defaults to `Codable`.
    public var extraRecordConformances  = [ "Codable" ]
    
    /// Whether Swift filter matcher should be generated.
    /// (i.e. the ability to use a Swift closure instead of a SQL where).
    public var generateSwiftFilters     = true
    
    /// The prefix used to name property index variables within the
    /// `PropertyIndices` struct (e.g. `idx_id, idx_street`)
    public var propertyIndexPrefix      = "idx_"
    
    /// Instead of creating them as local functions, put them into the
    /// Database object as static methods.
    /// It is useful to keep them locally, if the generated struct is just
    /// intended for copy&paste use (because the source is self-contained).
    public var optionalHelpersInDatabase = true
    
    /// If ``useLighter`` is enabled, this will use `SQLiteValueType` bindings
    /// if appropriate (vs inlining the binding).
    public var preferLighterBinds = false
    
    /// This setting affects how dates are going to be bound _if_ ``useLighter``
    /// and ``preferLighterBinds`` are disabled.
    public var dateStorageStyle = DateStorageStyle.timeIntervalSince1970
    /// This formatter is used to parse SQLite3 default values, e.g.
    /// `start_date TIMESTAMP '1973-01-31 12:12:12'`.
    public var dateFormatter    : DateFormatter = defaultSQLiteDateFormatter
    
    /// This setting affects how UUIDs are going to be bound _if_ ``useLighter``
    /// and ``preferLighterBinds`` are disabled.
    public var uuidStorageStyle = UUIDStorageStyle.blob
    
    /// This is used for the case when reference names (like `\.person`) match
    /// the type name (e.g. `person`). Rare, but can happen.
    /// In this case a `personRecordType` alias would be generated
    public var recordTypeAliasSuffix : String? = "RecordType"
    
    /// Whether to show hints in comments, that views can be useful to
    /// predeclare fragment queries.
    public var showViewHintComment = true
    
    /// Include the SQL used to create a table/view in the record documentation.
    public var includeCreationSQLInComments = true
  }
  public internal(set) var options : Options // internal for testing purposes
  
  var api : LighterAPI { options.api }
  
  public
  init(database: DatabaseInfo, filename: String, options: Options? = nil) {
    self.database = database
    self.filename = filename
    self.options  = options ?? Options()
  }
  
  
  // MARK: - Common Naming Functions
  
  func globalName(of entity: EntityInfo) -> String {
    options.nestRecordTypesInDatabase
    ? "\(database.name).\(entity.name)"
    : entity.name
  }
  func globalTypeRef(of entity: EntityInfo) -> TypeReference {
    options.nestRecordTypesInDatabase
    ? .qualifiedType(baseName: database.name, name: entity.name)
    : .name(entity.name)
  }
  func globalDocRef(of entity: EntityInfo, property: String? = nil) -> String {
    let n = options.nestRecordTypesInDatabase
    ? "\(database.name)/\(entity.name)"
    : "\(entity.name)"
    if let property = property {
      return "``\(n)/\(property)``"
    }
    else {
      return "``\(n)``"
    }
  }
  
  // MARK: - Bind Mappers
  
  // This returns an optional!
  func stringMap(initPrefix: String, initSuffix: String = ")") -> Expression {
    .raw("{ \(initPrefix)String(cString: $0)\(initSuffix) }")
  }
  
  /// This requires the ``dateFormatter`` property in the associated database
  /// structure.
  /// This can still return nil!
  func dateFormatterMap() -> Expression {
    stringMap(initPrefix: "\(database.name).dateFormatter?.date(from: ",
              initSuffix: ")")
  }
  /// This can still return nil!
  func uuidFormatterMap() -> Expression {
    stringMap(initPrefix: "UUID(uuidString: ", initSuffix: ")")
  }
}

fileprivate let defaultSQLiteDateFormatter : DateFormatter = {
  // `SELECT datetime();` gives: `2004-08-19 18:51:06` in UTC
  let df = DateFormatter()
  df.dateFormat = "yyyy-MM-dd HH:mm:ss"
  df.locale     = Locale(identifier: "en_US_POSIX")
  return df
}()
