//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import PackagePlugin

extension Target {
  
  func doesRecursivelyDependOnTarget(named name: String) -> Bool {
    recursiveTargetDependencies.contains(where: { $0.name == name })
  }
}

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
  
  func doesRecursivelyDependOnTarget(named name: String) -> Bool {
    for dep in self.dependencies {
      switch dep {
        case .product(let packageProduct):
          if packageProduct.name == name { return true }
          for target in packageProduct.targets {
            if target.doesRecursivelyDependOnTarget(named: name) { return true }
          }
          return false
        
        case .target(let xcodeTarget):
          if xcodeTarget.name == name { return true }
          return xcodeTarget.doesRecursivelyDependOnTarget(named: name)
        
        @unknown default:
          return false
      }
    }
    return false
  }
}

#endif // canImport(XcodeProjectPlugin)
