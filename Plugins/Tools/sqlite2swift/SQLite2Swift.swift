//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import Foundation
import LighterGeneration
import LighterCodeGenAST
import SQLite3Schema

/// This is a tool to generate the Swift to represent one single SQL database,
/// though that database can be composed from different input databases and/or
/// SQL source files.
struct SQLite2Swift {

  let args   : Arguments
  var config = LighterConfiguration.default
  
  /// Parse the arguments and initialize the tool.
  init(_ arguments: [ String ]) throws {
    args = try Arguments()
  }
  
  /// Start the tool logic.
  mutating func run() throws {
    if args.verbose {
      args.dump()
    }
    
    if args.configURL.scheme != "default" {
      try loadConfiguration()
    }
    
    if args.verbose {
      print("Config Values:", config)
    }

    let schema = try loadSchema(from: args.inputURLs)
    if args.verbose {
      print("User Version:", schema.userVersion)
    }

    let database = buildGenerationModel(for: schema)
    if args.verbose {
      print("DB Info:", database)
    }

    let unit = generateCombinedFile(for: database)

    try writeToOutput(unit)
    
    #if DEBUG && false
      dumpOutputFile()
    #endif

    if args.verbose {
      print("Wrote to:", args.outputURL.path)
    }
  }
  
  
  // MARK: - Implementation
  
  private mutating func loadConfiguration() throws {
    do {
      config = try LighterConfiguration(
        contentsOf : args.configURL,
        for        : args.targetName,
        stem       : args.stem
      )
    }
    catch {
      print("Failed to load config from:\n ", args.configURL.path,
            "\n  error:", error)
      throw ExitCodes.couldNotOpenConfiguration
    }
  }
  
  private func loadSchema(from inputURLs: [ URL ]) throws -> Schema {
    do    { return try SchemaLoader.buildSchemaFromURLs(args.inputURLs) }
    catch {
      print("Could not fetch schema:", error)
      throw ExitCodes.couldNotLoadInMemorySchema
    }
  }
  
  private func buildGenerationModel(for schema: Schema) -> DatabaseInfo {
    let dbInfo    = DatabaseInfo(name: args.stem, schema: schema)
    let fancifier = Fancifier(options: config.swiftMapping)
    fancifier.fancifyDatabaseInfo(dbInfo)
    return dbInfo
  }
  
  private func generateCombinedFile(for database: DatabaseInfo)
               -> CompilationUnit
  {
    let gen = EnlighterASTGenerator(
      database : database,
      filename : args.outputURL.lastPathComponent,
      options  : config.codeGeneration
    )
    return gen.generateCombinedFile(moduleFileName: args.moduleFilename)
  }
    
  private func writeToOutput(_ unit: CompilationUnit) throws {
    do {
      try unit.writeCode(to: args.outputURL,
                         configuration: config,
                         headerName: args.toolName)
    }
    catch {
      print("Failed to write to", args.outputURL.path, "error:", error)
      throw ExitCodes.couldNotWriteOutput
    }
  }
  
  private func dumpOutputFile() throws {
    let string = try String(contentsOf: args.outputURL)
    print("Generated:\n-----\n\(string)\n-----")
  }
}
