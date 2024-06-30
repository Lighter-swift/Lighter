//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import PackagePlugin
import Foundation
// Note: Plugins cannot use libs in the same package!

/**
 * This is a build tool plugin which looks for SQLite databases and SQL files
 * in specified targets and then generates the Swift access code for those
 * files.
 *
 * Alongside this there is the `GenerateCodeForSQLite` command plugin, which can
 * manually generate wrapper code into the `Sources/target/dbname.swift` file.
 */
@main
struct Enlighter: BuildToolPlugin {
  
  #if DEBUG
    let verbose = true
  #else
    let verbose = false
  #endif
  
  let configFileName = "Lighter.json"
  let defaultConfig  : [ String : Any ] = [
    "databaseExtensions" : [ "sqlite3", "db", "sqlite" ],
    "sqlExtensions"      : [ "sql" ]
  ]

  enum PluginError: Swift.Error {
    
    case invalidConfigFile(String)
    
    case toolRunFailed(Int)
  }

  func createBuildCommands(context: PluginContext, target: Target) async throws
       -> [ Command ]
  {
    guard let target = target as? SwiftSourceModuleTarget else {
      debugLog("Not a Swift source module target:", target.name)
      return []
    }
    
    debugLog("Perform \(#fileID):", Date(), target.name)

    do {
      let tool      = try context.tool(named: "sqlite2swift")
      let configURL = locateConfigFile(in: context)
      let rootJSON  = try loadConfigFile(from: configURL)
      
      let outputFile =
        ((rootJSON[target.name] as? [String:Any])?["outputFile"] as? String)
      ?? (rootJSON["outputFile"] as? String)
      
      let targetConfig = EnlighterTargetConfig(
        dbExtensions : dbExtensions(in: rootJSON, target: target.name),
        extensions   : extensions(in: rootJSON, target: target.name),
        outputFile   : outputFile,
        verbose      : verbose,
        configURL    : configURL
      )
      guard !targetConfig.extensions.isEmpty else {
        print("Skipping \"\(target.name)\",",
              "has no SQL/db extensions configured.")
        debugLog("Skipping:", target.name, "…")
        return []
      }
      
      if verbose {
        print("Looking for databases/SQL in:", target.name, "…")
      }
      debugLog("Looking for databases/SQL in:", target.name, "…")

      return try generate(context: context, target: target,
                          configuration: targetConfig, sqlite2swift: tool)
    }
    catch {
      debugLog("Catched error:", error)
      throw error
    }
  }
  
  
  fileprivate func debugLog(_ message: Any...) {
    #if DEBUG || true
    let msg = message.map { String(describing: $0) }.joined(separator: " ")
            + "\n"
    
    let debugFH = fopen("/tmp/zzdebug.log", "a")
    assert(debugFH != nil)
    if let debugFH = debugFH {
      fputs(msg, debugFH)
      fflush(debugFH)
      fclose(debugFH)
    }
    #endif // DEBUG || true
  }

  fileprivate func dbExtensions(in rootJSON: [ String : Any ], target: String)
                   -> Set<String>
  {
    let targetJSON = rootJSON[target] as? [ String : Any ]
    let exts1 = (targetJSON?  ["databaseExtensions"] as? [ String ])
             ?? (rootJSON     ["databaseExtensions"] as? [ String ])
             ?? (defaultConfig["databaseExtensions"] as? [ String ])
             ?? []
    return Set(exts1)
  }
  fileprivate func extensions(in rootJSON: [ String : Any ], target: String)
                   -> Set<String>
  {
    let targetJSON = rootJSON[target] as? [ String : Any ]
    let exts1 = (targetJSON?  ["databaseExtensions"] as? [ String ])
             ?? (rootJSON     ["databaseExtensions"] as? [ String ])
             ?? (defaultConfig["databaseExtensions"] as? [ String ])
             ?? []
    let exts2 = (targetJSON?  ["sqlExtensions"] as? [ String ])
             ?? (rootJSON     ["sqlExtensions"] as? [ String ])
             ?? (defaultConfig["sqlExtensions"] as? [ String ])
             ?? []
    
    return Set(exts1).union(exts2)
  }
    
  fileprivate func locateConfigFile(in context: PackagePlugin.PluginContext)
                   -> URL?
  {
    #if compiler(>=6) && canImport(Foundation)
      let url = context.package.directoryURL
        .appending(component: configFileName, directoryHint: .notDirectory)
    #else
      let configPath = context.package.directory
                         .appending(subpath: configFileName)
      let url = URL(fileURLWithPath: configPath.string)
    #endif
    let fm = FileManager.default
    guard fm.fileExists(atPath: url.path) else { return nil }
    return url
  }
  
  fileprivate func loadConfigFile(from url: URL?) throws -> [ String : Any ] {
    guard let url = url else { return defaultConfig }

    // Unfortunately we cannot reuse the `LighterConfiguration` file. Plugins
    // do not really support dependencies.
    let data = try Data(contentsOf: url)
    let json = try JSONSerialization.jsonObject(with: data)
    guard let dict = json as? [ String : Any ] else {
      throw PluginError.invalidConfigFile(url.path)
    }
    return dict
  }
  
  #if compiler(>=6) && canImport(Foundation)
  private func collectResources(in target: SwiftSourceModuleTarget,
                                extensions: Set<String>)
               -> Set<URL>
  {
    var result = Set<URL>()
    for ext in extensions {
      for file in target.sourceFiles(withSuffix: "." + ext)
            where file.type == .resource
      {
        result.insert(file.url)
      }
    }
    return result
  }
  #else
  private func collectResources(in target: SwiftSourceModuleTarget,
                                extensions: Set<String>)
               -> Set<String>
  {
    var result = Set<String>()
    for ext in extensions {
      for file in target.sourceFiles(withSuffix: "." + ext)
            where file.type == .resource
      {
        result.insert(file.path.string)
      }
    }
    return result
  }
  #endif
    
  private func generate(context       : PackagePlugin.PluginContext,
                        target        : SwiftSourceModuleTarget,
                        configuration : EnlighterTargetConfig,
                        sqlite2swift  : PluginContext.Tool) throws
               -> [ Command ]
  {
    #if compiler(>=6) && canImport(Foundation)
    let groups = try EnlighterGroup.load(
      from: target.directoryURL,
      resourcesPaths:
        collectResources(in: target, extensions: configuration.extensions),
      configuration: configuration
    )
    guard !groups.isEmpty else {
      print("Could not find matching files in", target.directoryURL.path())
      debugLog("Could not find matching files in", target.directoryURL.path())
      return []
    }
    #else
    let groups = try EnlighterGroup.load(
      from: URL(fileURLWithPath: target.directory.string),
      resourcesPaths:
        collectResources(in: target, extensions: configuration.extensions),
      configuration: configuration
    )
    guard !groups.isEmpty else {
      print("Could not find matching files in", target.directory)
      debugLog("Could not find matching files in", target.directory)
      return []
    }
    #endif

    if configuration.verbose {
      print("Generating \(groups.count) databases for:", target.name)
    }
    debugLog("Generate target:", target.name, "#groups=\(groups.count)", groups)

    var buildCommands = [ Command ]()

    for group in groups {
      #if compiler(>=6) && canImport(Foundation)
        let outputURL = configuration.outputFile.flatMap {
          context.pluginWorkDirectoryURL.appending(component: $0)
        } ?? context.pluginWorkDirectoryURL
                    .appending(component: group.stem + ".swift")
      #else
          let outputPath = configuration.outputFile.flatMap {
            context.pluginWorkDirectory.appending(subpath: $0)
          } ?? context.pluginWorkDirectory
                      .appending(subpath: group.stem + ".swift")
          
          let outputURL = URL(fileURLWithPath: outputPath.string)
      #endif

      // sqlite2swift.path
      // configuration.configURL
      let args : [ String ] = {
        var args = [ String ]()
        if configuration.verbose {
          args.append("--verbose")
        }
        if let name = group.moduleFilename(using: configuration.dbExtensions) {
          args.append("--module-filename")
          args.append(name)
        }
        args.append(configuration.configURL?.path ?? "default")
        args.append(target.name) // required to resolve configs
        args += group.matches.map(\.path)
        args.append(outputURL.path)
        return args
      }()
      
      #if compiler(>=6) && canImport(Foundation)
      let inputFiles : [ URL ] = {
        var inputFiles = group.matches.map { URL(fileURLWithPath: $0.path) }
        if let configURL = configuration.configURL {
          inputFiles.append(configURL)
        }
        return inputFiles
      }()
      let outputFiles : [ URL ] = {
        // Generate Lighter amalgamation if not in dependencies.
        // Generate Lighter variadics if not in dependencies.
        let linksLighter =
              target.doesRecursivelyDependOnTarget(named: "Lighter")
        if verbose {
          if linksLighter { debugLog("Is linking Lighter.")  }
          else            { debugLog("Not linking Lighter!") }
        }
        return [ outputURL ]
      }()

      if configuration.verbose {
        debugLog("  Adding sqlite2swift for:", group.stem)
        debugLog("    \(sqlite2swift.url.path())")
        debugLog("    Args:", args)
      }
      buildCommands.append(.buildCommand(
        displayName : "Enlighten \(group.stem) database in \(target.name)",
        executable  : sqlite2swift.url,
        arguments   : args,
        inputFiles  : inputFiles,
        outputFiles : outputFiles
      ))
      #else
      let inputFiles : [ Path ] = {
        var inputFiles = group.matches.map { Path($0.path) }
        if let configURL = configuration.configURL {
          inputFiles.append(Path(configURL.path))
        }
        return inputFiles
      }()
      let outputFiles : [ Path ] = {
        // Generate Lighter amalgamation if not in dependencies.
        // Generate Lighter variadics if not in dependencies.
        let linksLighter =
              target.doesRecursivelyDependOnTarget(named: "Lighter")
        if verbose {
          if linksLighter { debugLog("Is linking Lighter.")  }
          else            { debugLog("Not linking Lighter!") }
        }
        return [ outputPath ]
      }()

      if configuration.verbose {
        debugLog("  Adding sqlite2swift for:", group.stem)
        debugLog("    \(sqlite2swift.path.string)")
        debugLog("    Args:", args)
      }
      buildCommands.append(.buildCommand(
        displayName : "Enlighten \(group.stem) database in \(target.name)",
        executable  : sqlite2swift.path,
        arguments   : args,
        inputFiles  : inputFiles,
        outputFiles : outputFiles
      ))
      #endif
    }
    debugLog("Finished target:", target.name,
             "#\(buildCommands.count) commands.")
    return buildCommands
  }
}


// MARK: - Xcode Support

#if canImport(XcodeProjectPlugin)
// This is mostly a copy, as the types don't match up.
import XcodeProjectPlugin

extension Enlighter: XcodeBuildToolPlugin {
  
  func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext,
                           target: XcodeProjectPlugin.XcodeTarget)
         throws -> [ PackagePlugin.Command ]
  {
    debugLog("Perform Xcode \(#fileID):", Date(), target.name)

    do {
      let tool      = try context.tool(named: "sqlite2swift")
      let configURL = locateConfigFile(in: context)
      let rootJSON  = try loadConfigFile(from: configURL)
      
      let outputFile =
        ((rootJSON[target.name] as? [String:Any])?["outputFile"] as? String)
      ?? (rootJSON["outputFile"] as? String)
      
      let targetConfig = EnlighterTargetConfig(
        dbExtensions : dbExtensions(in: rootJSON, target: target.name),
        extensions   : extensions(in: rootJSON, target: target.name),
        outputFile   : outputFile,
        verbose      : verbose,
        configURL    : configURL
      )
      guard !targetConfig.extensions.isEmpty else {
        print("Skipping \"\(target.name)\",",
              "has no SQL/db extensions configured.")
        debugLog("Skipping:", target.name, "…")
        return []
      }
      
      if verbose {
        print("Looking for databases/SQL in:", target.name, "…")
      }
      debugLog("Looking for databases/SQL in:", target.name, "…")

      return try generate(context: context, target: target,
                          configuration: targetConfig, sqlite2swift: tool)
    }
    catch {
      debugLog("Catched error:", error)
      throw error
    }
  }
  
  
  fileprivate func locateConfigFile(in context: XcodePluginContext) -> URL? {
    #if false && compiler(>=6) && canImport(Foundation) // TODO: 16 Beta 2?
      let dirURL = URL(filePath: context.package.directory.string)
      let url = dirURL.appending(component: configFileName,
                                 directoryHint: .notDirectory)
    #else
      let configPath = context.package.directory
        .appending(subpath: configFileName)
      let url = URL(fileURLWithPath: configPath.string)
    #endif
    let fm = FileManager.default
    guard fm.fileExists(atPath: url.path) else { return nil }
    return url
  }
  
  #if compiler(>=6) && canImport(Foundation)
  fileprivate func collectResources(in target: XcodeTarget,
                                    extensions: Set<String>) -> Set<URL>
  {
    var result = Set<URL>()
    for ext in extensions {
      for file in target.inputFiles
        where file.type == .resource && file.url.pathExtension == ext
      {
        result.insert(file.url)
      }
    }
    return result
  }
  #else
  fileprivate func collectResources(in target: XcodeTarget,
                                    extensions: Set<String>) -> Set<String>
  {
    var result = Set<String>()
    for ext in extensions {
      for file in target.inputFiles
        where file.type == .resource && file.path.extension == ext
      {
        result.insert(file.path.string)
      }
    }
    return result
  }
  #endif
  
  private func generate(context       : XcodeProjectPlugin.XcodePluginContext,
                        target        : XcodeProjectPlugin.XcodeTarget,
                        configuration : EnlighterTargetConfig,
                        sqlite2swift  : PluginContext.Tool) throws
               -> [ Command ]
  {
    #if compiler(>=6) && canImport(Foundation)
    let groups = try EnlighterGroup.load(
      from: target.directoryURL,
      resourcesPaths:
        collectResources(in: target, extensions: configuration.extensions),
      configuration: configuration
    )
    guard !groups.isEmpty else {
      print("Could not find matching files in", target.directoryURL.path())
      debugLog("Could not find matching files in", target.directoryURL.path())
      return []
    }
    #else
    let groups = try EnlighterGroup.load(
      from: URL(fileURLWithPath: target.directory.string),
      resourcesPaths:
        collectResources(in: target, extensions: configuration.extensions),
      configuration: configuration
    )
    guard !groups.isEmpty else {
      print("Could not find matching files in", target.directory)
      debugLog("Could not find matching files in", target.directory)
      return []
    }
    #endif

    if configuration.verbose {
      print("Generating \(groups.count) databases for:", target.name)
    }
    debugLog("Generate target:", target.name, "#groups=\(groups.count)", groups)

    var buildCommands = [ Command ]()

    for group in groups {
      #if false && compiler(>=6) && canImport(Foundation)
        let outputURL = configuration.outputFile.flatMap {
          context.pluginWorkDirectoryURL.appending(component: $0)
        } ?? context.pluginWorkDirectoryURL
                    .appending(component: group.stem + ".swift")
      #else
        let outputPath = configuration.outputFile.flatMap {
          context.pluginWorkDirectory.appending(subpath: $0)
        } ?? context.pluginWorkDirectory
                    .appending(subpath: group.stem + ".swift")
        
        let outputURL = URL(fileURLWithPath: outputPath.string)
      #endif

      // sqlite2swift.path
      // configuration.configURL
      let args : [ String ] = {
        var args = [ String ]()
        if configuration.verbose {
          args.append("--verbose")
        }
        if let name = group.moduleFilename(using: configuration.dbExtensions) {
          args.append("--module-filename")
          args.append(name)
        }
        args.append(configuration.configURL?.path ?? "default")
        args.append(target.name) // required to resolve configs
        args += group.matches.map(\.path)
        args.append(outputURL.path)
        return args
      }()
      
      #if compiler(>=6) && canImport(Foundation)
      let inputFiles : [ URL ] = {
        var inputFiles = group.matches.map { URL(fileURLWithPath: $0.path) }
        if let configURL = configuration.configURL {
          inputFiles.append(configURL)
        }
        return inputFiles
      }()
      let outputFiles : [ URL ] = {
        // Generate Lighter amalgamation if not in dependencies.
        // Generate Lighter variadics if not in dependencies.
        let linksLighter =
              target.doesRecursivelyDependOnTarget(named: "Lighter")
        if verbose {
          if linksLighter { debugLog("Is linking Lighter.")  }
          else            { debugLog("Not linking Lighter!") }
        }
        return [ outputURL ]
      }()

      if configuration.verbose {
        print("  Adding sqlite2swift for:", group.stem)
        print("    \(sqlite2swift.url.path())")
        print("    Args:", args)
      }
      buildCommands.append(.buildCommand(
        displayName : "Enlighten \(group.stem) database in \(target.name)",
        executable  : sqlite2swift.url,
        arguments   : args,
        inputFiles  : inputFiles,
        outputFiles : outputFiles
      ))
      
      // So, in Xcode, if a resource is handled by Enlighter, Xcode itself
      // doesn't copy the resource anymore. Likely a bug.
      // So what we do is copy them ourselves into the plugin dir. They then
      // get bundled properly.
      let inResourceURLs  = groups.map({ $0.resourceURLs }).reduce([], +)
      try inResourceURLs.forEach { ( inputResource : URL ) in
        let outResourceFile = context.pluginWorkDirectory // TODO: Xcode16b2?
          .appending(inputResource.lastPathComponent)
        let outResourceURL = URL(fileURLWithPath: outResourceFile.string)

        buildCommands.append(.buildCommand(
          displayName : "Copy \(group.stem) resource "
                    + "\(inputResource.lastPathComponent) into \(target.name)",
          executable  : try context.tool(named: "cp").url,
          arguments   : [ "-a", 
                          inputResource .path(percentEncoded: false),
                          outResourceURL.path(percentEncoded: false) ],
          inputFiles  : [ inputResource  ],
          outputFiles : [ outResourceURL ]
        ))
      }
      #else
      let inputFiles : [ Path ] = {
        var inputFiles = group.matches.map { Path($0.path) }
        if let configURL = configuration.configURL {
          inputFiles.append(Path(configURL.path))
        }
        return inputFiles
      }()
      let outputFiles : [ Path ] = {
        // Generate Lighter amalgamation if not in dependencies.
        // Generate Lighter variadics if not in dependencies.
        let linksLighter =
              target.doesRecursivelyDependOnTarget(named: "Lighter")
        if verbose {
          if linksLighter { debugLog("Is linking Lighter.")  }
          else            { debugLog("Not linking Lighter!") }
        }
        return [ outputPath ]
      }()

      if configuration.verbose {
        print("  Adding sqlite2swift for:", group.stem)
        print("    \(sqlite2swift.path.string)")
        print("    Args:", args)
      }
      buildCommands.append(.buildCommand(
        displayName : "Enlighten \(group.stem) database in \(target.name)",
        executable  : sqlite2swift.path,
        arguments   : args,
        inputFiles  : inputFiles,
        outputFiles : outputFiles
      ))
      
      // So, in Xcode, if a resource is handled by Enlighter, Xcode itself
      // doesn't copy the resource anymore. Likely a bug.
      // So what we do is copy them ourselves into the plugin dir. They then
      // get bundled properly.
      let inResourceFiles  = groups.map({ $0.resourceURLs }).reduce([], +)
                                   .map { Path($0.path) }
      try inResourceFiles.forEach { inputResource in
        let outResourceFile =
          context.pluginWorkDirectory.appending(inputResource.lastComponent)

        buildCommands.append(.buildCommand(
          displayName : "Copy \(group.stem) resource "
                      + "\(inputResource.lastComponent) into \(target.name)",
          executable  : try context.tool(named: "cp").path,
          arguments   : [ "-a", inputResource.string, outResourceFile.string ],
          inputFiles  : [ inputResource   ],
          outputFiles : [ outResourceFile ]
        ))
      }
      #endif
    }
    debugLog("Finished Xcode target:", target.name,
             "#\(buildCommands.count) commands.")
    return buildCommands
  }
}

#endif // canImport(XcodeProjectPlugin)
