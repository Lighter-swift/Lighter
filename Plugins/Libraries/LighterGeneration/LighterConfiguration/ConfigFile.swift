//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import Foundation

/**
 * A helper object that can lookup JSON values in a configurable stack of
 * dictionaries, in a deep-overriding way.
 *
 * Example:
 * ```json
 * {
 *   "__doc__": "Configuration used for the manual, builtin codegen.",
 *
 *   "databaseExtensions" : [ "sqlite3", "db", "sqlite" ],
 *   "sqlExtensions"      : [ "sql" ],
 *
 *   "CodeStyle": {
 *     "functionCommentStyle" : "**",
 *     "indent"               : "  ",
 *     "lineLength"           : 80
 *   },
 *
 *   "ContactsTestDB": {
 *     "embeddedLighter": null
 *   },
 *
 *   "EmbeddedLighter": {
 *     "selects": {
 *       "syncYield"  : "none",
 *       "syncArray"  : { "columns": 6, "sorts": 2 },
 *       "asyncArray" : { "columns": 6, "sorts": 2 }
 *     },
 *     "updates": {
 *       "keyBased"       : 6,
 *       "predicateBased" : 6
 *     },
 *     "inserts": 6
 *   }
 * }
 * ```
 */
public final class ConfigFile {
  // Should be improved, but seems to work OK.
  
  let json   : JSONDict
  let target : JSONDict?
  let stem   : JSONDict?

  public init(json: JSONDict, for target: String? = nil, stem: String? = nil) {
    let targetJSON = target.flatMap { json[$0]        as? JSONDict }
    let stemJSON   = stem.flatMap   { targetJSON?[$0] as? JSONDict }
    
    self.json   = json
    self.target = targetJSON
    self.stem   = stemJSON
  }

  public convenience init(data: Data, for target: String? = nil,
                          stem: String? = nil) throws
  {
    self.init(
      json: try JSONSerialization.jsonObject(with: data) as? JSONDict ?? [:],
      for: target, stem: stem
    )
  }
  public convenience init(contentsOf url: URL, for target: String? = nil,
                          stem: String? = nil)
    throws
  {
    try self.init(data: try Data(contentsOf: url), for: target, stem: stem)
  }
  
  
  // MARK: - Key Lookup
  
  /**
   * Lookup in a nested dictionary structure, checking each subconfig, e.g.:
   * ```
   * let syncYield = dict["embeddedLighter", "selects", "syncYield"]
   * ```
   * Will first look in stem, then in target, then in the toplevel.
   */
  public subscript(_ path: String...) -> Any? { self[path: path] }
  /**
   * Lookup in a nested dictionary structure, checking each subconfig, e.g.:
   * ```
   * let syncYield = dict["embeddedLighter", "selects", "syncYield"]
   * ```
   * Will first look in stem, then in target, then in the toplevel.
   */
  public subscript(path path: [ String ]) -> Any? {
    stem?[path: path] ?? target?[path: path] ?? json[path: path]
  }
  public subscript(_ key: String) -> Any? {
    stem?[key] ?? target?[key] ?? json[key]
  }

  public subscript(section section: String) -> Section? {
    guard self[section] is JSONDict else { return nil }
    return Section(file: self, path: [ section ])
  }
  
  public var root : Section { .init(file: self, path: []) }

  public struct Section {
    
    let file : ConfigFile
    var path : [ String ]

    subscript(_ path: String...) -> Any? { self[path: path] }

    // This ain't no cheap :-)
    subscript(path path: [ String ]) -> Any? { file[path: self.path + path]  }
    subscript(_     key: String)     -> Any? { file[path: self.path + [key]] }

    subscript(section section: String) -> Section? {
      guard self[section] is JSONDict else { return nil }
      return Section(file: file, path: self.path + [ section ])
    }

    subscript(string key: String) -> String? { self[key] as? String }
    subscript(int    key: String) -> Int?    { self[key] as? Int    }
    subscript(bool   key: String) -> Bool?   { self[key] as? Bool   }
  }
}

fileprivate extension JSONDict {
  
  /**
   * Lookup in a nested dictionary structure, e.g.:
   * ```
   * let syncYield = dict["embeddedLighter", "selects", "syncYield"]
   * ```
   */
  subscript(path path: [ String ]) -> Any? {
    guard let lastKey = path.last else { return nil }
    
    var dict = self
    for section in path.dropLast() {
      guard let nextDict = dict[section] as? JSONDict else { return nil }
      dict = nextDict
    }
    
    return dict[lastKey]
  }
}
