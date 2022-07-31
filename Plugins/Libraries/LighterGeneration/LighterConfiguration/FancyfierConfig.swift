//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension Fancifier.Options {
  
  // swiftMapping
  init(section: ConfigFile.Section?) {
    self.init()
    guard let section = section else { return }

    if let section = section[section: "keys"] {
      if let v = section["autodetect"] as? [ String ] {
        autodetectKeyNames = v
      }
      if let v = section[bool: "autodetectWithTableName"] {
        autodetectPrimaryKeyNamesWithTable = v
      }
      if let v = section[bool: "autodetectForeignKeys"] {
        autodetectForeignKeys = v
      }
      if let v = section[bool: "autodetectForeignKeysInViews"] {
        autodetectForeignKeysInViews = v
      }
      if let v = section[string: "primaryKeyName"] { forcePrimaryKeyName = v }
    }
    
    if let name = section[string: "databaseTypeName"], !name.isEmpty {
      forceDatabaseName = name
    }
    else if let section = section[section: "databaseTypeName"] {
      if let v = section[bool: "dropFileExtensions"] {
        dropDatabaseFileExtensions = v
      }
      if let v = section[bool: "capitalize"]  { capitalizeDatabaseName = v }
      if let v = section[bool: "camelCase"]   { camelCaseDatabaseName  = v }
    }
    
    if let section = section[section: "recordTypeNames"] {
      // false by default
      if let v = section[bool: "singularize"] { singularizeRecordNames = v }
      if let v = section[bool: "capitalize"]  { capitalizeRecordNames  = v }
      if let v = section[bool: "camelCase"]   { camelCaseRecordNames   = v }
    }
    if let section = section[section: "recordReferenceNames"] {
      if let v = section[bool: "decapitalize"] {
        decapitalizeRecordReferenceName = v
      }
      if let v = section[bool: "pluralize"] {
        pluralizeRecordReferenceName = v
      }
    }

    if let section = section[section: "propertyNames"] {
      if let v = section[bool: "decapitalize"] {
        decapitalizePropertyNames = v
      }
      if let v = section[bool: "camelCase"] { camelCasePropertyNames = v }
    }

    if let section = section[section: "CoreData"] {
      if let v = section[bool: "removeZAndCapitalizeRecordNames"] {
        capitalizeAndDeZAllUpperRecordNames = v
      }
      if let v = section[bool: "removeZAndLowercasePropertyNames"] {
        lowercaseAndDeZAllUpperZPropertyNames = v
      }
    }
    if let section = section[section: "Swift"] {
      if let s = section[string: "spaceReplacementStringForIDs"] {
        spaceReplacementStringForIDs = s
      }
    }

    if let section = section[section: "relationships"] {
      if let v = section[bool: "deriveFromForeignKeys"] {
        deriveRelationshipsFromForeignKeys = v
      }
      if let v = section["strippedForeignKeySuffixes"] as? [ String ] {
        relationshipForeignKeyStripSuffix = v
      }
    }
    
    func propertyType(for string: String) -> EntityInfo.Property.PropertyType {
      switch string {
        case "integer"    : return .integer
        case "double"     : return .double
        case "string"     : return .string
        case "uint8Array" : return .uint8Array
        case "bool"       : return .bool
        case "date"       : return .date
        case "data"       : return .data
        case "url"        : return .url
        case "decimal"    : return .decimal
        case "uuid"       : return .uuid
        default           : return .custom(string)
      }
    }

    if let v = section["typeMap"] as? [ String: String ] {
      sqlTypeToSwiftType = v.mapValues(propertyType(for:))
    }
    if let v = section["columnSuffixToType"] as? [ String: String ] {
      columnSuffixToSwiftType = v.mapValues(propertyType(for:))
    }
  }
}
