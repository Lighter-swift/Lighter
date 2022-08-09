//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import PackagePlugin

#if canImport(XcodeProjectPlugin)
// Abstract those as protocols is a little harder than expected as `Target`
// in SPM is also a protocol.

import XcodeProjectPlugin

extension XcodePluginContext {

  var package : XcodeProject { xcodeProject }
}

extension XcodeProject {

  func targets(named targetNames: [ String ]) throws -> [ XcodeTarget ] {
    self.targets.filter { targetNames.contains($0.name) }
  }
}

extension XcodeTarget {
  
  var name : String { product?.name ?? displayName }
  
  var directory : Path {
    // heuristics, in Xcode the input files can come from anywhere
    var directories = [ Path ]()
    for file in inputFiles {
      let dir = file.path.removingLastComponent()
      if !directories.contains(dir) {
        directories.append(dir)
      }
    }
    if directories.isEmpty {
      assertionFailure("Target has no input files!")
      return Path("/tmp/")
    }

    if directories.count == 1, let sole = directories.first { return sole }

    let match = "/" + name
    if let matching = directories.first(where: { $0.string.hasSuffix(match) }) {
      return matching
    }
    // give up and use first :-)
    return directories[0]
  }
}

#endif // canImport(XcodeProjectPlugin)
