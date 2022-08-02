//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

/**
 * This represents the contents of the `Lighter.json` file used to configure
 * the Enlighter SPM plugin tools.
 *
 * Example:
 * ```json
 * "codeStyle": {
 *   "functionCommentStyle" : "**",
 *   "indent"               : "  ",
 *   "lineLength"           : 80
 * },
 *
 * "embeddedLighter": {
 *   "selects": {
 *     "syncYield"  : { "columns": 8, "sorts": 2 },
 *     "syncArray"  : { "columns": 8, "sorts": 2 },
 *     "asyncArray" : { "columns": 8, "sorts": 2 }
 *   }
 * },
 *
 * "swiftMapping": {
 *   "databaseTypeName": { ... }
 * }
 * ```
 */
public struct LighterConfiguration: Equatable {
  
  public static let filename = "Lighter.json"
  
  public var codeStyle       : CodeGenerator.Configuration
  public var embeddedLighter : EmbeddedLighter
  public var swiftMapping    : Fancifier.Options
  public var codeGeneration  : EnlighterASTGenerator.Options
  
  public var isEmpty : Bool { false }
  
  public init(codeStyle       : CodeGenerator.Configuration,
              embeddedLighter : EmbeddedLighter,
              swiftMapping    : Fancifier.Options,
              codeGeneration  : EnlighterASTGenerator.Options)
  {
    self.codeStyle       = codeStyle
    self.embeddedLighter = embeddedLighter
    self.swiftMapping    = swiftMapping
    self.codeGeneration  = codeGeneration
  }
  
  public static let `default` =
    LighterConfiguration(
      codeStyle: .init(), embeddedLighter: .init(), swiftMapping: .init(),
      codeGeneration: .init()
    )
}

import struct Foundation.Data
import struct Foundation.URL

public extension LighterConfiguration {
  
  init(contentsOf url: URL, for target: String, stem: String? = nil) throws {
    let file = try ConfigFile(contentsOf: url, for: target, stem: stem)
    self.init(section: file.root)
  }
  init(data: Data, for target: String, stem: String? = nil) throws {
    let file = try ConfigFile(data: data, for: target, stem: stem)
    self.init(section: file.root)
  }
}

extension LighterConfiguration: CustomStringConvertible {
  
  public var description: String {
    var ms = "<LighterConfig:"
    ms += " style=\(codeStyle)"
    if embeddedLighter.isDisabled { ms += " embedded-lighter=disabled" }
    else { ms += " lighter=\(embeddedLighter) "}
    ms += " map=\(swiftMapping)"
    ms += " code=\(codeGeneration)"
    ms += ">"
    return ms
  }
}

// MARK: - JSON Decoding

import LighterCodeGenAST
import class Foundation.NSNull

public extension LighterConfiguration {

  init(section: ConfigFile.Section?) {
    codeStyle = .init(section: section?[section: "CodeStyle"])
    
    if let section = section,
       (section["EmbeddedLighter"] is NSNull ||
        section[string: "EmbeddedLighter"] == "none")
    {
      embeddedLighter = .disabled
    }
    else {
      embeddedLighter = .init(section: section?[section: "EmbeddedLighter"])
    }
    
    swiftMapping = .init(section: section?[section: "SwiftMapping"])

    codeGeneration = .init(section: section?[section: "CodeGeneration"])
  }
}
