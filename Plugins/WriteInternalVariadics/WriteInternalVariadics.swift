//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import PackagePlugin
import Foundation
// Note: Plugins cannot use libs in the same package!

@main
struct WriteInternalVariadics: CommandPlugin {

  enum WriteInternalVariadicsError: Swift.Error {
    case couldNotFindLighter
    case couldNotFindConfigurationFile(String)
    case toolRunFailed(Int)
  }

  func performCommand(context: PackagePlugin.PluginContext,
                      arguments: [ String ]) async throws
  {
    // executed in the package root dir
    // Selected targets in Xcode are passed in like this:
    // ["--target", "Lighter"]
    let targetName = "Lighter" // could be made configurable/honor the arguments
    
    guard let target =
          try context.package.targets(named: [ targetName ])
          .first as? SwiftSourceModuleTarget else
    {
      throw WriteInternalVariadicsError.couldNotFindLighter
    }
    
    // Generate

    try generate(context: context, target: target)
  }
  
  private func generate(context: PackagePlugin.PluginContext,
                        target: SwiftSourceModuleTarget) throws
  {
    // Lookup Configuration (init is per-target)

    #if compiler(>=6)
    let configURL = context.package.directoryURL
                       .appending(component: "Ligher.json")
    guard FileManager.default.isReadableFile(atPath: configURL.path) else {
      throw WriteInternalVariadicsError
              .couldNotFindConfigurationFile(configURL.path)
    }
    
    let operationsFolder = target.directoryURL
          .appending(component: "Operations", directoryHint: .isDirectory)
    let outputFile = "GeneratedVariadicOperations.swift"
    let outputURL = operationsFolder.appending(component: outputFile)
    #else
    let configPath = context.package.directory
                       .appending(subpath: "Lighter.json")
    guard FileManager.default.isReadableFile(atPath: configPath.string) else {
      throw WriteInternalVariadicsError
              .couldNotFindConfigurationFile(configPath.string)
    }
    
    let operationsFolder = target
          .directory.appending(subpath: "Operations")
    let outputFile = "GeneratedVariadicOperations.swift"
    let outputPath = operationsFolder.appending(subpath: outputFile)
    let configURL  = URL(fileURLWithPath: configPath.string)
    let outputURL  = URL(fileURLWithPath: outputPath.string)
    #endif

    let targetName = target.name

    #if DEBUG || true
    let debugFH = fopen("/tmp/zzdebug.log", "w")
    if let debugFH = debugFH {
      fputs("Start \(Date())", debugFH)
      fclose(debugFH)
    }
    #endif // DEBUG || true
    
    // Lookup generator tool
    
    let tool = try context.tool(named: "GenerateInternalVariadics")
    
    let process = Process()
    #if compiler(>=6) && canImport(Foundation)
      process.executableURL = tool.url
    #else
      process.executableURL = URL(fileURLWithPath: tool.path.string)
    #endif
    process.arguments = [ configURL.path, targetName, outputURL.path ]
    
    try process.run()
    process.waitUntilExit()
    
    if process.terminationStatus != 0 {
      throw WriteInternalVariadicsError.toolRunFailed(
        Int(process.terminationStatus))
    }
    else {
      print("Wrote to:", outputURL.path)
    }
  }
}
