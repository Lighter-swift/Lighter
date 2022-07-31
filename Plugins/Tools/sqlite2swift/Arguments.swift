//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import struct Foundation.URL
import func   Foundation.exit

/**
 * Arguments:
 * - path to Lighter.json config file
 * - name of target, for Lighter.json processing
 * - array of input files, either SQL source or SQLite databases
 * - the path to the output file
 */
struct Arguments {
  
  /// Name of the tool, `sqlite2swift`
  let toolName     : String
  /// Enable verbose logging
  let verbose      : Bool
  /// Whether one of the input files is also a package resource.
  let hasResources : Bool
  
  /// The URL to the configuration file, Lighter.json.
  let configURL    : URL
  /// The name of the Swift package target, used for resolving configuration.
  let targetName   : String // used for config resolution
  /// The input files to be processed.
  let inputURLs    : [ URL ]
  /// The single output file to emit the code into.
  let outputURL    : URL
  
  /// The first input filename w/o its extension.
  let stem         : String
  
  /// Parse the arguments from an array of String's.
  init(arguments: [ String ] = CommandLine.arguments) throws {
    var args = arguments
    toolName = URL(fileURLWithPath: args.first ?? "tool").lastPathComponent
    
    let asksForHelp = args.contains("-h") || args.contains("--help")
    if asksForHelp || args.count < 5 {
      Self.usage(toolName)
      throw asksForHelp ? ExitCodes.ok : ExitCodes.invalidArguments
    }

    args.remove(at: args.startIndex)
    
    if let idx = (args.firstIndex(of: "--verbose") ?? args.firstIndex(of: "-v"))
    {
      verbose = true
      args.remove(at: idx)
    }
    else {
      verbose = false
    }
    if let idx = args.firstIndex(of: "--has-resources") {
      hasResources = true
      args.remove(at: idx)
    }
    else {
      hasResources = false
    }

    configURL  = args[0] != "default"
               ? URL(fileURLWithPath: args[0])
               : URL(string: "default:")!
    targetName = args[1]
    inputURLs  = args.dropFirst(2).dropLast().map(URL.init(fileURLWithPath:))
    outputURL  = args.last.map(URL.init(fileURLWithPath:))!
    
    guard let firstFileName = inputURLs
      .first.flatMap({ $0.lastPathComponent }) else
    {
      exit(ExitCodes.invalidArguments.rawValue)
    }
    stem = firstFileName.firstIndex(where: { $0 == "-" || $0 == "." })
      .flatMap { String(firstFileName[..<$0]) }
    ?? firstFileName
  }
  
  /// Print the arguments.
  func dump() {
    print("Config:", configURL.path)
    print("Target:", targetName)
    print("Input: ", inputURLs.map(\.path))
    print("Output:", outputURL.path)
    print("Stem:  ", stem)
  }
  
  private static func usage(_ toolName: String) {
    print(
      """
      Usage: \(toolName) <config-file> <target> <input-files> <output-file>
      """
    )
  }
}

