//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import class  Foundation.NSNull
import class  Foundation.DateFormatter
import struct Foundation.Locale

extension EnlighterASTGenerator.Options {
  
  init(section: ConfigFile.Section?) {
    self.init()
    guard let section = section else { return }
    
    // TBD: Make `LigherAPI` configurable? Probably not that useful.

    if let v = section[bool: "readOnly"]               { readOnly        = v }
    if let v = section[bool: "omitCreationSQL"]        { omitCreationSQL = v }
    if let v = section[bool: "generateAsyncFunctions"] { asyncAwait      = v }
    if let v = section[bool: "inlinable"]              { inlinable       = v }
    if let v = section[bool: "public"]                 { `public`        = v }
    if let v = section[bool: "allowFoundation"]        { allowFoundation = v }
    if let v = section[bool: "qualifiedSelf"]          { qualifiedSelf   = v }
    if let v = section[bool: "swiftFilters"]        { generateSwiftFilters = v }
    if let v = section[bool: "showViewHintComment"] { showViewHintComment  = v }
    if let v = section[bool: "commentsWithSQL"] {
      includeCreationSQLInComments = v
    }
    if let v = section["extraRecordTypeConformances"] as? [ String ] {
      extraRecordConformances = v
    }
    if let v = section[string: "propertyIndexPrefix"] {
      propertyIndexPrefix = v
    }
    
    if section["recordTypeAliasSuffix"] is NSNull {
      recordTypeAliasSuffix = nil
    }
    else if let v = section[string: "recordTypeAliasSuffix"] {
      recordTypeAliasSuffix = (v == "none" || v == "null") ? nil : v
    }

    // Dates

    if let s = section[string: "dateFormat"], !s.isEmpty {
      dateFormatter = DateFormatter()
      dateFormatter.dateFormat = s
      dateFormatter.locale =
        Locale(identifier: section[string: "dateLocale"] ?? "en_US_POSIX")
    }

    if let s = section[string: "dateSerialization"] {
      switch s.lowercased() {
        case "formatter", "text", "string": dateStorageStyle = .formatter
        case "timestamp", "utime", "timeintervalsince1970":
          dateStorageStyle = .timeIntervalSince1970
        default:
          print("ERROR: Unknown dateStyle: '\(s)'")
      }
    }
    else if section[string: "dateFormat"] != nil {
      dateStorageStyle = .formatter
    }
    
    // UUID

    if let s = section[string: "uuidSerialization"] {
      switch s.lowercased() {
        case "text", "string", "readable" : uuidStorageStyle = .text
        case "blob", "bytes", "data"      : uuidStorageStyle = .blob
        default:
          print("ERROR: Unknown uuidStyle: '\(s)'")
      }
    }

    // Database Things

    if let v = section[bool: "embedRecordTypesInDatabaseType"] {
      nestRecordTypesInDatabase = v
    }
    if let v = section[bool: "optionalHelpersInDatabase"] {
      optionalHelpersInDatabase = v
    }
    
    // Raw Operations

    if let section = section[section: "Raw"] {
      if let s = section[string: "prefix"], !s.isEmpty {
        rawFunctions = .globalFunctions(prefix: s)
      }
      else {
        rawFunctions = .attachToRecordType
      }
      if let v = section[bool: "relationships"] { generateRawRelationships = v }
      if let v = section[bool: "hashable"] { markRawStructsAsHashable  = v }
      if let v = section[bool: "throwing"] { generateThrowingFunctions = v }
    }
    else if let s = section[string: "Raw"], s != "none" && s != "omit" {
      rawFunctions = s.lowercased() == "recordtype" || s == "attachToRecordType"
        ? .attachToRecordType
        : .globalFunctions(prefix: s)
    }
    else if section["Raw"] != nil {
      rawFunctions = .omit
    }
    
    // Lighter

    if section["Lighter"] == nil {
      // no config, use default
    }
    else if let section = section[section: "Lighter"] {
      useLighter = true
      if let v = section[string: "import"] {
        switch v {
          case "yes", "true", "import", "use"        : importLighter = .import
          case "no", "false", "none"                 : importLighter = .none
          case "reexport", "re-export", "@_exported" : importLighter = .reexport
          default: print("ERROR: Unknown Lighter import config: \(v)")
        }
      }
      else if let v = section[bool: "import"] {
        importLighter = v ? .import : .none
      }
      else if let v = section[bool: "reexport"] {
        importLighter = v ? .reexport : .import
      }

      if let v = section[bool: "relationships"] {
        generateLighterRelationships = v
      }
      if let v = section[bool: "useSQLiteValueTypeBinds"] {
        preferLighterBinds = v
      }

      if let section = section[section: "Examples"] {
        if let v = section[bool: "select"] { generateSelectExamples = v }
      }
    }
    else if let s = section[string: "Lighter"] {
      switch s {
        case "none", "no", "false" : useLighter = false
        case "use", "yes", "ok"    : useLighter = true
        case "import":
          useLighter    = true
          importLighter = .import
        case "reexport", "re-export":
          useLighter    = true
          importLighter = .reexport
        default:
          print("ERROR: Unknown Lighter config: \(s)")
      }
    }
    else if section["Lighter"] is NSNull {
      useLighter = false
    }
    else {
      print("ERROR: Unknown Lighter config: \(section["Lighter"] as Any)")
    }
  }
}
