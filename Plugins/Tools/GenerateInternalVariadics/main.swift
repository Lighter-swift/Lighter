//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import Foundation
import LighterGeneration
import LighterCodeGenAST

fileprivate enum ExitCodes: Int32 {
  case invalidArguments          = 1
  case couldNotOpenConfiguration = 2
  case couldNotWriteOutput       = 3
}


// MARK: - Process Arguments

fileprivate let args     = CommandLine.arguments
fileprivate let toolName = URL(fileURLWithPath: args.first ?? "tool").lastPathComponent

guard args.count > 3 else {
  print("Usage: \(toolName) <config-file> <target> <output-file>")
  exit(ExitCodes.invalidArguments.rawValue)
}

fileprivate let configURL  = URL(fileURLWithPath: args[1])
fileprivate let targetName = args[2]
fileprivate let outputURL  = URL(fileURLWithPath: args[3])


// MARK: - Load Configuration

fileprivate let config : LighterConfiguration
do {
  config = try LighterConfiguration(contentsOf: configURL, for: targetName)
}
catch {
  print("Failed to load config from:\n ", configURL.path, "\n  error:", error)
  exit(ExitCodes.couldNotOpenConfiguration.rawValue)
}


// MARK: - Generate the AST

fileprivate let unit = generateInternalVariadics(
  filename: outputURL.lastPathComponent,
  configuration: config
)


// MARK: - Write the AST

do {
  try unit.writeCode(to: outputURL, configuration: config, headerName: toolName)
}
catch {
  print("Failed to write to", outputURL.path, "error:", error)
  exit(ExitCodes.couldNotWriteOutput.rawValue)
}
