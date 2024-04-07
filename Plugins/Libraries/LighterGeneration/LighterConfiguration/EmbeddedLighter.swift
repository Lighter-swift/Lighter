//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

public extension LighterConfiguration {

  struct EmbeddedLighter: Equatable, Sendable {
    
    public struct Selects: Equatable, Sendable {
      
      public struct Config: Equatable, Sendable {
        public var columns : Int
        public var sorts   : Int
        
        public var isDisabled : Bool { columns < 1 }
        
        public static let disabled = Config(columns: 0, sorts: 0)
      }
      
      public var syncYield  : Config
      public var syncArray  : Config
      public var asyncArray : Config

      public var isDisabled : Bool {
        syncYield.isDisabled && syncArray.isDisabled && asyncArray.isDisabled
      }
      public static let disabled = Selects(
        syncYield: .disabled, syncArray: .disabled, asyncArray: .disabled
      )

      public init(syncYield  : Config? = nil,
                  syncArray  : Config? = nil,
                  asyncArray : Config? = nil)
      {
        self.syncYield  = syncYield  ?? .init(columns: 0, sorts: 0)
        self.syncArray  = syncArray  ?? .init(columns: 8, sorts: 2)
        self.asyncArray = asyncArray ?? .init(columns: 8, sorts: 2)
      }
    }
    
    public struct Updates: Equatable, Sendable {
      
      public var keyBased       : Int
      public var predicateBased : Int
      
      public var isDisabled : Bool { keyBased < 1 && predicateBased < 1 }
      public static let disabled = Updates(keyBased: 0, predicateBased: 0)

      public init(keyBased: Int? = nil, predicateBased: Int? = nil) {
        self.keyBased       = keyBased       ?? 0
        self.predicateBased = predicateBased ?? 0
      }
    }

    public var selects : Selects
    public var updates : Updates
    public var inserts : Int
    
    public var isDisabled : Bool {
      selects.isDisabled && updates.isDisabled && inserts < 1
    }

    public static let disabled =
      EmbeddedLighter(selects: .disabled, updates: .disabled, inserts: 0)

    public init(selects : Selects? = nil,
                updates : Updates? = nil,
                inserts : Int?     = nil)
    {
      self.selects = selects ?? .init(
        syncYield  : .init(columns: 8, sorts: 2),
        syncArray  : .init(columns: 8, sorts: 2),
        asyncArray : .init(columns: 8, sorts: 2)
      )
      self.updates = updates ?? .init()
      self.inserts = inserts ?? 0
    }
  }
}


// MARK: - Description

extension LighterConfiguration.EmbeddedLighter.Selects.Config
          : CustomStringConvertible
{
  
  public var description: String {
    if isDisabled { return "DISABLED" }
    if columns > 0 {
      if sorts > 0    { return "#\(columns)(#sorts=\(sorts))" }
      else            { return "#\(columns)" }
    }
    else if sorts > 0 { return "#sorts=\(sorts)" }
    else              { return "EMPTY" }
  }
}

extension LighterConfiguration.EmbeddedLighter.Selects: CustomStringConvertible
{

  public var description: String {
    if isDisabled { return "<Selects: DISABLED>" }
    var ms = "<Selects:"
    if !syncYield.isDisabled  { ms += " yield=\(syncYield)" }
    if !syncArray.isDisabled  { ms += " array=\(syncArray)" }
    if !asyncArray.isDisabled { ms += " async=\(asyncArray)" }
    ms += ">"
    return ms
  }
}

extension LighterConfiguration.EmbeddedLighter.Updates: CustomStringConvertible
{

  public var description: String {
    if isDisabled { return "<Updates: DISABLED>" }
    var ms = "<Updates:"
    if keyBased       > 0 { ms += " key=#\(keyBased)"             }
    if predicateBased > 0 { ms += " predicate=#\(predicateBased)" }
    ms += ">"
    return ms
  }
}

extension LighterConfiguration.EmbeddedLighter: CustomStringConvertible {

  public var description: String {
    if isDisabled { return "<Lighter: DISABLED>" }
    var ms = "<Lighter:"
    if !selects.isDisabled { ms += " selects=\(selects)"  }
    if !updates.isDisabled { ms += " updates=\(updates)"  }
    if inserts > 0         { ms += " inserts=#\(inserts)" }
    ms += ">"
    return ms
  }
}


// MARK: - JSON Decoding

import class Foundation.NSNull

public extension LighterConfiguration.EmbeddedLighter.Selects.Config {

  init?(_ json: Any?) {
    guard let json = json else { return nil }
    if let json = json as? JSONDict {
      self.init(columns : (json["columns"] as? Int) ?? 8,
                sorts   : (json["sorts"]   as? Int) ?? 2)
    }
    else if let json = json as? String, json == "none" {
      self.init(columns: 0, sorts: 0)
    }
    else if json is NSNull {
      self.init(columns: 0, sorts: 0)
    }
    else {
      assertionFailure("Unexpected field value")
      return nil
    }
  }
}

public extension LighterConfiguration.EmbeddedLighter.Updates {
  
  init(section: ConfigFile.Section?) { // section is "updates"
    self.init(
      keyBased       : section?[int: "keyBased"],
      predicateBased : section?[int: "predicateBased"]
    )
  }
}
public extension LighterConfiguration.EmbeddedLighter.Selects {
  
  init(section: ConfigFile.Section?) { // section is "selects"
    self.init(
      syncYield  : section?["syncYield"] .flatMap(Config.init),
      syncArray  : section?["syncArray"] .flatMap(Config.init),
      asyncArray : section?["asyncArray"].flatMap(Config.init)
    )
  }
}

public extension LighterConfiguration.EmbeddedLighter {

  init(section: ConfigFile.Section?) {
    self.init(
      selects : Selects(section: section?[section: "selects"]),
      updates : Updates(section: section?[section: "updates"]),
      inserts : section?[int: "inserts"]
    )
  }
}
