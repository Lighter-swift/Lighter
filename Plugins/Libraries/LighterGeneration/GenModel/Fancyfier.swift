//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3Schema
import struct Foundation.CharacterSet

/**
 * `Fancifier` is here to make plain schemas (fetched from the DB) fancy.
 *
 * The core idea is that you keep your SQL schema SQL-ish but your Swift model
 * Swifty.
 *
 * Example SQL:
 *
 *     CREATE TABLE person (
 *       person_id       SERIAL PRIMARY KEY NOT NULL,
 *       firstname       VARCHAR NULL,
 *       lastname        VARCHAR NOT NULL
 *       office_location VARCHAR
 *     )
 *
 * Derived Record:
 *
 *     struct Person: SQLKeyedTableRecord, Identifiable {
 *       var id             : Int
 *
 *       var firstname      : String?
 *       var lastname       : String
 *
 *       var officeLocation : String?
 *     }
 *
 * The fancifier can also detect primary and foreign keys if not setup properly.
 */
public final class Fancifier {
  
  public struct Options: Equatable {
    
    // Detect Keys

    /// If a record has no primary key assigned, check whether it has a column
    /// matching one of those (external) names.
    public var autodetectKeyNames = [
      "id", "ID", "Id", "pkey", "primaryKey", "PrimaryKey", "key", "Key"
    ]
    /// If a record has no primary key assigned, check whether it has a column
    /// matching the table-name plus one of the ``autodetectKeyNames``,
    /// with an optional `_` between.
    /// E.g.: `PersonId` or `person_id` would be detected as primary keys.
    public var autodetectPrimaryKeyNamesWithTable = true
    
    /// If a record has no foreign keys assigned, this tries to detect them.
    /// For example if table `address` would have a `person_id`, and `person_id`
    /// is the primary key of the `person` table, this would create a
    /// synthesized foreign key for that.
    public var autodetectForeignKeys = true
    /// Whether to create "foreign keys" for Views :-)
    public var autodetectForeignKeysInViews = true

    
    // Rename
    
    public var forceDatabaseName          : String? = nil
    /// `persons.db` => `persons`
    public var dropDatabaseFileExtensions = true
    /// `persons.db` => `Persons.db`
    public var capitalizeDatabaseName     = true
    /// `air_funny_records.db` => `airFunnyRecords.db`
    public var camelCaseDatabaseName      = true
    
    /// Rename all primary keys to this name (e.g. `id`)
    public var forcePrimaryKeyName                   : String? = "id"

    /// `ZABCDPHONENUMBER` => `Abcdphonenumber`
    public var capitalizeAndDeZAllUpperRecordNames   = true
    /// `persons` => `person` (off by default, assuming proper SQL names)
    public var singularizeRecordNames                = false
    
    /// `Person` => `person`
    public var decapitalizeRecordReferenceName       = true
    /// `Person` => `Persons`
    public var pluralizeRecordReferenceName          = true

    /// `ZDETECTION` => `detection`
    public var lowercaseAndDeZAllUpperZPropertyNames = true

    /// `"My Table"`  => `My_Table`
    /// `"my column"` => `my_column`
    public var spaceReplacementStringForIDs : String? = "_"

    /// `"My-Table"`  => `My_Table`
    /// `"my-column"` => `my_column`
    public var minusReplacementStringForIDs : String? = "_"
    /// `"My/Table"`  => `My__Table`
    /// `"my/column"` => `my__column`
    public var slashReplacementStringForIDs : String? = "__"

    /// `person` => `Person`
    public var capitalizeRecordNames     = true
    /// `PersonId` => `personId`
    public var decapitalizePropertyNames = true
    
    /// `person_assignment` => `PersonAssignment`
    public var camelCaseRecordNames      = true
    /// `person_id` => `personId`
    public var camelCasePropertyNames    = true
    
    
    // Relationships
    
    /// Convert foreign keys, either synthesized or specified, to relationships
    /// for generation.
    public var deriveRelationshipsFromForeignKeys = true
    /// If a record has no primary key assigned, check whether it has a column
    /// matching one of those (external) names.
    public var relationshipForeignKeyStripSuffix = [
      "_id", "_ID",
      "id", "ID", "Id", "_fkey", "_fk",
      "_foreignKey", "ForeignKey",
      "_key", "_Key",
      "key", "Key"
    ]

    
    // Foundation type assignments
    
    /**
     * Lighter and Enlighter has support for those types builtin:
     * - `Int`       (SQL `INTEGER`)
     * - `Double`    (SQL `REAL`)
     * - `String`    (SQL `TEXT`)
     * - `[ UInt8 ]` (SQL `BLOB`)
     * and Foundation types:
     * - `URL`
     * - `Data`
     * - `UUID`
     * - `Date`
     * - `Decimal`
     * This map is used to map custom SQL types like `TIMESTAMP` to a property
     * type for the RecordMaps.
     *
     * Note: The code generator can only generate the known
     *       ``EntityInfo/Property/PropertyType-swift.enum``'s.
     *       It will use the `SQLiteValueType` protocol for custom ones.
     */
    public var sqlTypeToSwiftType
               : [ String : EntityInfo.Property.PropertyType ]
               =
    [
      "uuid"      : .uuid,
      "UUID"      : .uuid,
      "url"       : .url,
      "URL"       : .url,
      "Data"      : .date,
      "DECIMAL"   : .decimal,
      "decimal"   : .decimal,
      "NUMERIC"   : .decimal,
      "numeric"   : .decimal,
      "TIMESTAMP" : .date,
      "timestamp" : .date,
      "DATETIME"  : .date,
      "datetime"  : .date,
    ]
    /**
     * Lighter and Enlighter has support for those types builtin:
     * - `Int`       (SQL `INTEGER`)
     * - `Double`    (SQL `REAL`)
     * - `String`    (SQL `TEXT`)
     * - `[ UInt8 ]` (SQL `BLOB`)
     * and Foundation types:
     * - `URL`
     * - `Data`
     * - `UUID`
     * - `Date`
     * - `Decimal`
     * This map is used to map custom column name suffixes to specific types,
     * e.g. this:
     * ```swift
     * start_date INT
     * ```
     * to `Date`.
     *
     * Note: The code generator can only generate the known
     *       ``EntityInfo/Property/PropertyType-swift.enum``'s.
     *       It will use the `SQLiteValueType` protocol for custom ones.
     */
    public var columnSuffixToSwiftType
               : [ String : EntityInfo.Property.PropertyType ] = [:]

    
    // Swift ID characters
    
    public var validSwiftIdentifierCharacters : CharacterSet
               = .alphanumerics.union(CharacterSet(charactersIn: "_"))
    public var validFirstSwiftIdentifierCharacters : CharacterSet
               = .letters.union(CharacterSet(charactersIn: "_"))
    
    public init() {}
  }
  
  public let options : Options
  
  public init(options: Options) {
    self.options = options
  }
  
  
  // MARK: - Main Entry Point
  
  public func fancifyDatabaseInfo(_ db: DatabaseInfo) {
    if !options.sqlTypeToSwiftType.isEmpty ||
       !options.columnSuffixToSwiftType.isEmpty
    {
      assignSpecificTypes(db)
    }
    autodetectPrimaryKeys(db)
    autodetectForeignKeys(db)
    
    performNameCleanup(db)
    
    if options.deriveRelationshipsFromForeignKeys {
      findRelationships(db)
    }
  }
  
  
  // MARK: - Workers
  
  private func assignSpecificTypes(_ db: DatabaseInfo) {
    let suffixes = Array(options.columnSuffixToSwiftType.keys)
    for entity in db.entities {
      for ( idx, property ) in entity.properties.enumerated() {
        if let suffix = suffixes
                        .first(where: { property.externalName.hasSuffix($0 )}),
           let propertyType = options.columnSuffixToSwiftType[suffix]
        {
          entity.properties[idx].propertyType = propertyType
        }
        else if let sqlType = property.columnType?.rawValue,
                let propertyType = options.sqlTypeToSwiftType[sqlType]
        {
          entity.properties[idx].propertyType = propertyType
        }
      }
    }
  }
  
  private func autodetectPrimaryKeys(_ db: DatabaseInfo) {
    // This only works on external names!
    guard !options.autodetectKeyNames.isEmpty else { return }
    
    for entity in db.entities {
      guard !entity.properties.contains(where: { $0.isPrimaryKey }) else {
        continue // has an explicit pkey
      }
      
      let propertyNames = Set(entity.properties.map(\.externalName))
      
      var matchingExternalName : String?
      for keyName in options.autodetectKeyNames {
        if propertyNames.contains(keyName) {
          matchingExternalName = keyName
          break
        }
      }
      if matchingExternalName == nil, options.autodetectPrimaryKeyNamesWithTable
      {
        for keyName in options.autodetectKeyNames {
          let fqn1 = entity.externalName + keyName
          if propertyNames.contains(fqn1) {
            matchingExternalName = fqn1
            break
          }
          let fqn2 = entity.externalName + "_" + keyName
          if propertyNames.contains(fqn2) {
            matchingExternalName = fqn2
            break
          }
        }
      }
      if let matchingExternalName = matchingExternalName {
        if let idx = entity.properties
           .firstIndex(where: { $0.externalName == matchingExternalName })
        {
          entity.properties[idx].isPrimaryKey            = true
          entity.properties[idx].isPrimaryKeySynthesized = true
        }
      }
    }
  }
  private func autodetectForeignKeys(_ db: DatabaseInfo) {
    // This only works on external names!
    guard options.autodetectForeignKeys       else { return }
    guard !options.autodetectKeyNames.isEmpty else { return }
    
    // This even works for views! (i.e. setting up a relationship to another
    // table!)
    // But only tables can have primary keys.
    // E.g.: `[ "person_id": ( "person", PersonIdProperty ) ]
    // (this is really a "primary key rewritten" map).
    var foreignKeyNameToDestination =
          [ String : ( table: String, property: EntityInfo.Property ) ]()
    for entity in db.entities
      where entity.type == .table && !entity.hasCompoundPrimaryKey
    {
      guard let pkey = entity.properties.first(where: \.isPrimaryKey) else {
        continue
      }
      
      // Id, id etc
      for suffix in options.autodetectKeyNames {
        let ename       = entity.externalName
        let destination = ( ename, pkey )
        foreignKeyNameToDestination["\(ename)\(suffix)"]  = destination
        foreignKeyNameToDestination["\(ename)_\(suffix)"] = destination
      }
    }
    guard !foreignKeyNameToDestination.isEmpty else { return }
    
    for entity in db.entities {
      guard entity.type == .table || options.autodetectForeignKeysInViews else {
        continue
      }
      for ( idx, property ) in entity.properties.enumerated()
        where !property.isPrimaryKey && property.foreignKey == nil
      {
        // TBD: we could restrict by type? (e.g. just "ints"?)
        guard let ( destinationTable, destinationProperty ) =
          foreignKeyNameToDestination[property.externalName] else { continue }
        guard !(destinationTable == entity.externalName &&
                destinationProperty.externalName == property.externalName) else
        {
          // don't do self-refs
          continue
        }

        // Must have the same type!
        guard destinationProperty.propertyType == property.propertyType else {
          continue
        }
        
        // found one
        entity.properties[idx].isForeignKeySynthesized = true
        entity.properties[idx].foreignKey = .init(
          id: -1, seq: -1,
          sourceColumn      : property.externalName,
          destinationTable  : destinationTable,
          destinationColumn : destinationProperty.externalName,
          updateAction: .noAction, deleteAction: .noAction, match: .simple
        )
      }
    }
  }
  
  // Replaces spaces in SQL identifiers with `_`,
  // e.g. `A Long Table` becomes `A_Long_Table`.
  private func replaceSpecificIDCharacters(in name: String) -> String {
    var name = name
    if let s = options.spaceReplacementStringForIDs {
      name = name.replacingOccurrences(of: " ", with: s)
    }
    if let s = options.minusReplacementStringForIDs {
      name = name.replacingOccurrences(of: "-", with: s)
    }
    if let s = options.slashReplacementStringForIDs {
      name = name.replacingOccurrences(of: "/", with: s)
    }
    return name
  }
  
  /// Cleanup database name
  private func fancifyDatabaseName(_ name: String) -> String {
    if let name = options.forceDatabaseName { return name }
    var name = name
    if options.dropDatabaseFileExtensions,
       let idx = name.firstIndex(of: "."), idx != name.startIndex
    {
      name = String(name[..<idx])
    }
    
    name = replaceSpecificIDCharacters(in: name)

    if options.capitalizeDatabaseName, let c0 = name.first, c0.isLowercase {
      name = c0.uppercased() + name.dropFirst()
    }
    if options.camelCaseDatabaseName {
      name = name.makeCamelCase(upperFirst: false)
    }
    return makeValidSwiftIdentifier(from: name)
  }

  private func fancifyEntityName(_ name: String) -> String {
    var name = name
    
    // ZADDRESS => Address
    if options.capitalizeAndDeZAllUpperRecordNames,
       name.hasPrefix("Z") && !name.hasPrefix("Z_"), // "Z", not "Z_"
       name.uppercased() == name // Those are always uppercased, check that
    {
      name = name.dropFirst().lowercased().upperFirst
    }

    name = replaceSpecificIDCharacters(in: name)

    // Make sure that the record and property names are valid Swift
    // identifiers, e.g. `A Long Table` becomes `ALongTable`.
    name = makeValidSwiftIdentifier(from: name)
    
    if options.capitalizeRecordNames, let c0 = name.first, c0.isLowercase {
      name = c0.uppercased() + name.dropFirst()
    }
    if options.camelCaseRecordNames {
      name = name.makeCamelCase(upperFirst: false)
    }
    if options.singularizeRecordNames {
      name = name.singularized
    }
    
    return name
  }
  
  // Reference Names (as in `db.persons.find(10)` or
  // `select(from: \.people)`).
  // Derived from cleaned up entity name.
  private func referenceNameForEntityName(_ name: String) -> String {
    var refName = name
    if options.decapitalizeRecordReferenceName,
        let c0 = refName.first, c0.isUppercase
    {
      refName = c0.lowercased() + refName.dropFirst() // Person => person
    }
    if options.pluralizeRecordReferenceName {
      refName = refName.pluralized // person => persons
    }
    return refName
  }

  private func performNameCleanup(_ db: DatabaseInfo) {
    
    // Cleanup database name
    db.name = fancifyDatabaseName(db.name)
    
    
    // Walk over entities
    
    var entityNames = Set<String>()
    var refNames    = Set<String>()
    var rawNames    = Set<String>()
    for entity in db.entities {
      entity.name = dedupe(fancifyEntityName(entity.name), using: &entityNames)
      entity.referenceName =
        dedupe(referenceNameForEntityName(entity.name), using: &refNames)

      // Raw Names (as in `sqlite3_person_update(10)`
      // Derived from cleaned up entity name.
      
      do {
        var rawName = entity.name.snake_case(lowercase: true)
        if options.singularizeRecordNames {
          rawName = rawName.singularized
        }
        entity.singularRawName = dedupe(rawName, using: &rawNames)
      }
      do {
        var rawName = entity.name.snake_case(lowercase: true)
        if options.pluralizeRecordReferenceName {
          rawName = rawName.pluralized
        }
        entity.pluralRawName = dedupe(rawName, using: &rawNames)
      }

      // Properties

      var propertyNames = Set<String>()
      for ( idx, property ) in entity.properties.enumerated() {
        if let newIDName = options.forcePrimaryKeyName,
           property.isPrimaryKey,
           !entity.hasCompoundPrimaryKey,
           !entity.properties.contains(where: { $0.name == newIDName })
        {
          // TBD: could/should detect compound keys
          entity.properties[idx].name = newIDName
          propertyNames.insert(newIDName)
          continue
        }

        var name = property.name
        
        if options.lowercaseAndDeZAllUpperZPropertyNames,
           name.hasPrefix("Z") && !name.hasPrefix("Z_"),
           name.uppercased() == name
        {
          name = name.dropFirst().lowercased()
        }

        name = replaceSpecificIDCharacters(in: name)
        name = makeValidSwiftIdentifier(from: name)
        
        if options.decapitalizePropertyNames, let c0 = name.first,
           c0.isUppercase
        {
          name = c0.lowercased() + name.dropFirst()
        }
        if options.camelCasePropertyNames {
          name = name.makeCamelCase(upperFirst: false)
        }

        entity.properties[idx].name = dedupe(name, using: &propertyNames)
      }
    }
  }
  
  private func findRelationships(_ db: DatabaseInfo) {
    for sourceEntity in db.entities {
      // Always the same: `Addresses`, in plural if requested.
      let toManyName = options.pluralizeRecordReferenceName
          ? sourceEntity.name.pluralized.upperFirst
          : sourceEntity.name.upperFirst

      var names                   = Set<String>()
      var hadPrimaryToOneForType  = Set<String>()
      var hadPrimaryToManyForType = Set<String>()
      var foreignKeyCount = 0
      var destinationTableToForeignKeyCounts = [ String : Int ]()
      for property in sourceEntity.properties {
        guard let fkey = property.foreignKey else { continue }
        let old = destinationTableToForeignKeyCounts[fkey.destinationTable] ?? 0
        destinationTableToForeignKeyCounts[fkey.destinationTable] = old + 1
        foreignKeyCount += 1
      }

      // first we collect all, but assign the same name to them.
      for sourceProperty in sourceEntity.properties {
        guard let foreignKey = sourceProperty.foreignKey else { continue }
        
        guard let destinationEntity =
                db[externalName: foreignKey.destinationTable] else
        {
          print("WARN: Missing entity for foreign-key dest: \(foreignKey)")
          continue
        }
        
        guard let destinationProperty =
              destinationEntity[externalName: foreignKey.destinationColumn] else
        {
          print("WARN: Missing column for foreign-key dest: \(foreignKey)")
          continue
        }
        
        // calc the foreign-key nice name.
        // person_id => Person
        // ownerId   => Owner
        let name : String = {
          var name = sourceProperty.name.upperFirst
          if let matchSuffix = options.relationshipForeignKeyStripSuffix
              .first(where: { name.hasSuffix($0) && name != $0 })
          {
            name = String(name.dropLast(matchSuffix.count))
          }
          return dedupe(name, using: &names)
        }()
        
        // toOne
        
        let isPrimaryToOne : Bool
        if hadPrimaryToOneForType.contains(destinationEntity.name) {
          isPrimaryToOne = false
          // This can be removed if hit
          assert(isPrimaryToOne) // would be ok, but we haven't seen this :-)
        }
        else if
          (destinationTableToForeignKeyCounts[destinationEntity.externalName]
           ?? 0) < 2
        {
          isPrimaryToOne = true
        }
        else {
          isPrimaryToOne = isForeignKeyPrimary(
            sourceProperty, destination: destinationEntity, destinationProperty)
          
          #if false // Happens in Northwind for Orders.shipVia => Shippers.id
          assert(isPrimaryToOne)
          #endif
        }
        if isPrimaryToOne {
          hadPrimaryToOneForType.insert(destinationEntity.name)
        }
        
        // toMany

        // For toMany we need this:
        // fetchAddresses(for      record: Person) // use personId
        // fetchAddresses(forOwner record: Person) // use ownerId
        let isPrimaryToMany : Bool
        let qualifierArg    : String?
        if hadPrimaryToManyForType.contains(destinationEntity.name) {
          // plain `for` already taken
          qualifierArg = name // the cleaned property, `Owner` or `Person`
          isPrimaryToMany = false
          // This can be removed if hit
          assert(isPrimaryToMany) // would be ok, but we haven't seen this :-)
        }
        else if foreignKeyCount == 1 { // there is only one, so we are good
          qualifierArg = nil
          isPrimaryToMany = true
        }
        else { // we need to check whether our name qualifies
          isPrimaryToMany = isForeignKeyPrimary(
            sourceProperty, destination: destinationEntity, destinationProperty)
          qualifierArg = isPrimaryToMany ? nil : name
        }
        if isPrimaryToMany {
          hadPrimaryToManyForType.insert(destinationEntity.name)
        }

        // We have a unique name for the source (the cleaned property name).
        // findPerson(for address: Address) -> Person?
        // findOwner (for address: Address) -> Person?
        sourceEntity.toOneRelationships.append(
          .init(name: name, destinationEntity: destinationEntity,
                sourcePropertyName: sourceProperty.name,
                isPrimary: isPrimaryToOne)
        )
        
        destinationEntity.toManyRelationships.append(.init(
          name: toManyName, // e.g. "Addresses"
          sourceEntity: sourceEntity, sourcePropertyName: sourceProperty.name,
          qualifierParameter: qualifierArg // nil or `Owner`
        ))
      }
    }
  }
  
  private func isForeignKeyPrimary(_ sourceProperty: EntityInfo.Property,
                                   destination destinationEntity: EntityInfo,
                                   _ destinationProperty: EntityInfo.Property)
               -> Bool
  {
    /*
    - external name match: address.person_id == person.person_id
    - table_id match:      address.person_id == person.id
    - tableId match:       address.personid  == person.id
    - primary key doesn't help, destination usually is the pkey
    */
    // address.person_id = person.person_id (the proper SQL way)
    if destinationProperty.externalName == sourceProperty.externalName {
      return true
    }
    // Person.Id = PersonId
    else if (destinationEntity.name + destinationProperty.name)
              .lowercased()
              == sourceProperty.name.lowercased()
    {
      return true
    }
    // person + id = person_id
    else if (destinationEntity.externalName + "_" +
             destinationProperty.externalName)
              .lowercased()
              == sourceProperty.externalName.lowercased()
    {
      return true
    }
    
    return false
  }

  
  // MARK: - Helpers
  
  private func dedupe(_ name: String, using set: inout Set<String>) -> String {
    var name = name
    if set.contains(name) {
      for i in 0..<1000 {
        if !set.contains("\(name)\(i)") {
          name = "\(name)\(i)"
          break
        }
      }
    }
    set.insert(name)
    return name
  }
  
  private func makeValidSwiftIdentifier(from sqlIdentifier: String) -> String {
    // we just only allow alnum
    guard !sqlIdentifier.isEmpty else { return "NoName" }
    
    var onlyValid = String(sqlIdentifier.unicodeScalars.filter {
      options.validSwiftIdentifierCharacters.contains($0)
    })
    if onlyValid.isEmpty { onlyValid = "NoName" }
    
    return options.validFirstSwiftIdentifierCharacters
                  .contains(onlyValid.unicodeScalars.first!)
         ? onlyValid : ("_" + onlyValid)
  }
}
