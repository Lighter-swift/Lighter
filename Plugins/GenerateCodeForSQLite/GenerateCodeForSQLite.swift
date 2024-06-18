//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import PackagePlugin
import Foundation
// Note: Plugins cannot use libs in the same package!

/**
 * This is a command plugin which looks for SQLite databases and SQL files
 * in specified targets and then generates the Swift access code for those
 * files.
 *
 * Command plugins can be triggered from the "File / Packages" menu,
 * from the context menu on the package entry in the "Project Navigator",
 * or on the commandline, e.g.:
 * ```bash
 * swift package plugin \
 *   --allow-writing-to-package-directory \
 *   sqlite2swift \
 *   --target ContactsTestDB
 * ```
 * Note: The commandline name is `sqlite2swift`.
 *
 * The function can be configured using a `Lighter.json` config file in the
 * package root.
 *
 * Alongside this there is the `Enlighter` build tool plugin, which can generate
 * the wrapper code automatically.
 * This command plugin tool does it manually and directly generates into the
 * `Sources/target/dbname.swift` file!
 */
@main
struct GenerateCodeForSQLite: CommandPlugin {
  
  let configFileName = "Lighter.json"
  let defaultConfig  : [ String : Any ] = [
    "databaseExtensions" : [ "sqlite3", "db", "sqlite" ],
    "sqlExtensions"      : [ "sql" ]
  ]

  enum PluginError: Swift.Error {
    case invalidConfigFile(String)
    
    case toolRunFailed(Int)
  }

  func performCommand(context   : PackagePlugin.PluginContext,
                      arguments : [ String ]) async throws
  {
    debugLog("Perform \(#fileID):", Date())
    
    let args = Arguments(arguments)
    guard !args.targets.isEmpty else {
      if args.verbose { print("No targets specified.") }
      return debugLog("No targets specified.")
    }

    do {
      let tool    = try context.tool(named: "sqlite2swift")
      let targets = try context.package.targets(named: args.targets)
                               .compactMap { $0 as? SwiftSourceModuleTarget }
      if targets.isEmpty {
        if args.verbose { print("No Swift targets specified:", args.targets) }
        return debugLog("Did not find Swift targets in:", args.targets)
      }

      let configURL = locateConfigFile(in: context)
      let rootJSON  = try loadConfigFile(from: configURL)
      
      for target in targets {
        let outputFile =
          ((rootJSON[target.name] as? [String:Any])?["outputFile"] as? String)
        ?? (rootJSON["outputFile"] as? String)
        
        let targetConfig = EnlighterTargetConfig(
          dbExtensions : dbExtensions(in: rootJSON, target: target.name),
          extensions   : extensions(in: rootJSON, target: target.name),
          outputFile   : outputFile,
          verbose      : args.verbose,
          configURL    : configURL
        )
        guard !targetConfig.extensions.isEmpty else {
          if args.verbose {
            print("Skipping \"\(target.name)\",",
                  "has no SQL/db extensions configured.")
          }
          debugLog("Skipping:", target.name, "…")
          continue
        }
        
        if args.verbose {
          print("Looking for databases/SQL in:", target.name, "…")
        }
        debugLog("Looking for databases/SQL in:", target.name, "…")

        try generate(context: context, target: target,
                     configuration: targetConfig, sqlite2swift: tool)
      }
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
    let configPath = context.package.directory
                       .appending(subpath: configFileName)
    let url = URL(fileURLWithPath: configPath.string)
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
  
  private func generate(context       : PackagePlugin.PluginContext,
                        target        : SwiftSourceModuleTarget,
                        configuration : EnlighterTargetConfig,
                        sqlite2swift  : PluginContext.Tool) throws
  {
    let groups = try EnlighterGroup.load(
      from: URL(fileURLWithPath: target.directory.string),
      resourcesPaths:
        collectResources(in: target, extensions: configuration.extensions),
      configuration: configuration
    )
    guard !groups.isEmpty else {
      if configuration.verbose {
        print("Target contains not matching files:", target.name)
      }
      return debugLog("Target contains not matching files:", target.name)
    }

    if configuration.verbose {
      print("Generating \(groups.count) databases for:", target.name)
    }
    debugLog("Generate target:", target.name, "#groups=\(groups.count)", groups)
      

    for group in groups {
      let outputPath = configuration.outputFile.flatMap {
        target.directory.appending(subpath: $0)
      } ?? target.directory.appending(subpath: group.stem + ".swift")
      
      let outputURL = URL(fileURLWithPath: outputPath.string)

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

      let process = Process()
      process.executableURL = URL(fileURLWithPath: sqlite2swift.path.string)
      process.arguments = args
      
      if configuration.verbose {
        print("  Starting sqlite2swift for:", group.stem)
        print("    \(sqlite2swift.path.string)")
        print("    Args:", args)
      }
      try process.run()
      process.waitUntilExit()
      
      if process.terminationStatus != 0 {
        print("  sqlite2swift failed for:", group.stem)
        throw PluginError.toolRunFailed(
          Int(process.terminationStatus))
      }
      else {
        if configuration.verbose {
          print("  Wrote to:", outputURL.path)
        }
      }
    }
    
    debugLog("Finished target:", target.name)
  }
}


// MARK: - Xcode Support

#if canImport(XcodeProjectPlugin)
// This is mostly a copy, as the types don't match up.
import XcodeProjectPlugin

extension GenerateCodeForSQLite: XcodeCommandPlugin {
  
  func performCommand(context: XcodePluginContext, arguments: [String]) throws {
    debugLog("Perform Xcode \(#fileID):", Date())
    
    let args = Arguments(arguments)
    guard !args.targets.isEmpty else {
      if args.verbose { print("No targets specified.") }
      return debugLog("No targets specified.")
    }
    
    do {
      let tool    = try context.tool(named: "sqlite2swift")
      let targets = try context.package.targets(named: args.targets)
      if targets.isEmpty {
        if args.verbose { print("No Swift targets specified:", args.targets) }
        return debugLog("Did not find Swift targets in:", args.targets)
      }
      
      let configURL = locateConfigFile(in: context)
      let rootJSON  = try loadConfigFile(from: configURL)
      
      for target in targets {
        let outputFile =
        ((rootJSON[target.name] as? [String:Any])?["outputFile"] as? String)
        ?? (rootJSON["outputFile"] as? String)
        
        let targetConfig = EnlighterTargetConfig(
          dbExtensions : dbExtensions(in: rootJSON, target: target.name),
          extensions   : extensions(in: rootJSON, target: target.name),
          outputFile   : outputFile,
          verbose      : args.verbose,
          configURL    : configURL
        )
        guard !targetConfig.extensions.isEmpty else {
          if args.verbose {
            print("Skipping \"\(target.name)\",",
                  "has no SQL/db extensions configured.")
          }
          debugLog("Skipping:", target.name, "…")
          continue
        }
        
        if args.verbose {
          print("Looking for databases/SQL in:", target.name, "…")
        }
        debugLog("Looking for databases/SQL in:", target.name, "…")
        
        try generate(context: context, target: target,
                     configuration: targetConfig, sqlite2swift: tool)
      }
    }
    catch {
      debugLog("Catched error:", error)
      throw error
    }
  }
  
  fileprivate func locateConfigFile(in context: XcodePluginContext) -> URL? {
    let configPath = context.package.directory
      .appending(subpath: configFileName)
    let url = URL(fileURLWithPath: configPath.string)
    let fm = FileManager.default
    guard fm.fileExists(atPath: url.path) else { return nil }
    return url
  }

  fileprivate func collectResources(in target: XcodeTarget,
                                    extensions: Set<String>)
               -> Set<String>
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

  private func generate(context       : XcodePluginContext,
                        target        : XcodeTarget,
                        configuration : EnlighterTargetConfig,
                        sqlite2swift  : PluginContext.Tool) throws
  {
    let groups = try EnlighterGroup.load(
      from: URL(fileURLWithPath: target.directory.string),
      resourcesPaths:
        collectResources(in: target, extensions: configuration.extensions),
      configuration: configuration
    )
    guard !groups.isEmpty else {
      if configuration.verbose {
        print("Target contains not matching files:", target.name)
      }
      return debugLog("Target contains not matching files:", target.name)
    }

    if configuration.verbose {
      print("Generating \(groups.count) databases for:", target.name)
    }
    debugLog("Generate target:", target.name, "#groups=\(groups.count)", groups)
      
    for group in groups {
      let outputPath = configuration.outputFile.flatMap {
        target.directory.appending(subpath: $0)
      } ?? target.directory.appending(subpath: group.stem + ".swift")
      
      let outputURL = URL(fileURLWithPath: outputPath.string)

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

      let process = Process()
      process.executableURL = URL(fileURLWithPath: sqlite2swift.path.string)
      process.arguments = args
      
      if configuration.verbose {
        print("  Starting sqlite2swift for:", group.stem)
        print("    \(sqlite2swift.path.string)")
        print("    Args:", args)
      }
      try process.run()
      process.waitUntilExit()
      
      if process.terminationStatus != 0 {
        print("  sqlite2swift failed for:", group.stem)
        throw PluginError.toolRunFailed(
          Int(process.terminationStatus))
      }
      else {
        if configuration.verbose {
          print("  Wrote to:", outputURL.path)
        }
      }
    }
    debugLog("Finished target:", target.name)
  }
}
#endif // Xcode
