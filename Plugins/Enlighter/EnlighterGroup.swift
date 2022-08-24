//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import Foundation

/**
 * A group is a set of files that together to form a single database.
 *
 * E.g.:
 * - Contacts-01.sql
 * - Contacts-02.sql
 * - Contacts-03.sql
 * Will build a single "Contacts" database.
 */
struct EnlighterGroup: CustomStringConvertible {
  
  // The base name of the group, e.g. `Contacts`. This will become the name of
  // the database as known to Swift.
  let stem         : String
  // URLs to all input files for the group, e.g. `Contacts.db`,
  // `Contacts-01.sql`.
  var matches      : [ URL ]
  // All `matches` that match the resource pathes passed in to the `load`
  // function (i.e. all inputs that will be copied as resource files into the
  // target).
  var resourceURLs = [ URL ]()
  
  var description: String {
    "<Group[\(stem)]: " +
    matches.map(\.lastPathComponent).joined(separator: ",") + ">"
  }
  
  func moduleFilename(using extensions: Set<String>) -> String? {
    guard !resourceURLs.isEmpty && !extensions.isEmpty else { return nil }
    for url in resourceURLs {
      if extensions.contains(url.pathExtension) { return url.lastPathComponent }
    }
    return nil
  }
  
  static func load(from    baseURL : URL,
                   resourcesPathes : Set<String>,
                   configuration   : EnlighterTargetConfig)
                throws -> [ EnlighterGroup ]
  {
    var groups = [ String : EnlighterGroup ]()
    
    let fm = FileManager.default
    let e  = fm.enumerator(atPath: baseURL.path)
    while let path = e?.nextObject() as? String {
      guard let idx = path.lastIndex(of: ".")      else { continue } // no ext
      let ext = String(path[path.index(after: idx)...])
      guard configuration.extensions.contains(ext) else { continue } // diff
      guard !path.contains("NoSQL")                else { continue } // NoSQL
      
      let url = baseURL.appendingPathComponent(path)
      var isDir : ObjCBool = false
      guard fm.fileExists(atPath: url.path, isDirectory: &isDir),
            !isDir.boolValue else { continue }
    
      let stem = stemForPath(path)
      
      if configuration.verbose {
        print("   Found candidate for enlightment:", url.path)
      }
      if groups[stem]?.matches.append(url) == nil {
        groups[stem] = EnlighterGroup(stem: stem, matches: [ url ])
      }
      
      if resourcesPathes.contains(url.path) {
        groups[stem]?.resourceURLs.append(url)
      }
    }

    var array = groups.values.filter { !$0.matches.isEmpty }

    for idx in array.indices {
      array[idx].matches.sort(by: compareGroupURLs)
    }
    
    return array
  }
  
  // We also break at `-`
  private static let stemChars : Set<Character> = [ "-", "." ]
  
  private static func stemForPath(_ path: String) -> String {
    guard let idx = path.firstIndex(where: { stemChars.contains($0) }) else {
      return path
    }
    return String(path[..<idx])
  }
}

/// Ups, quite a lot of rules.
private func compareGroupURLs(lhs: URL, rhs: URL) -> Bool {
  let lhs = lhs.path, rhs = rhs.path
  
  // Items in higher up in the hierarchy are considered first.
  let lhsSlashCount = lhs.reduce(0, { $0 + ($1 == "/" ? 1 : 0 ) })
  let rhsSlashCount = rhs.reduce(0, { $0 + ($1 == "/" ? 1 : 0 ) })
  if lhsSlashCount != rhsSlashCount { return lhsSlashCount < rhsSlashCount }
  
  let lhsStem = lhs.lastIndex(of: ".").flatMap { String(lhs[..<$0]) } ?? lhs
  let rhsStem = rhs.lastIndex(of: ".").flatMap { String(rhs[..<$0]) } ?? rhs

  // This is for dealing with:
  //   MyDB.db            // the DB
  //   MyDB-AddView.sql   // adds a View
  if      rhsStem.hasPrefix(lhsStem) { return true  }
  else if lhsStem.hasPrefix(rhsStem) { return false }
  
  return lhsStem < rhsStem
}
