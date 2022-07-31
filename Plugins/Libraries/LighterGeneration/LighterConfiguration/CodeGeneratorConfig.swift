//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension CodeGenerator.Configuration {
  
  init(section: ConfigFile.Section?) {
    self.init()
    guard let section = section else { return }
    
    func commentStyle(_ s: String) -> CommentStyle {
      if let s = CommentStyle(rawValue: s) { return s }
      if s == "none" || s == "no" || s == "false" { return .noComments }
      print("Unexpected comment style:", s)
      return .doubleStars
    }
    
    if let section = section[section: "comments"] {
      if let v = section[string: "types"]      {
        self.typeCommentStyle     = commentStyle(v)
      }
      if let v = section[string: "properties"] {
        self.propertyCommentStyle = commentStyle(v)
      }
      if let v = section[string: "functions"]  {
        self.functionCommentStyle = commentStyle(v)
      }
    }
    else if let s = section[string: "comments"] {
      let v = commentStyle(s)
      self.typeCommentStyle     = v
      self.propertyCommentStyle = v
      self.functionCommentStyle = v
    }
    
    if let v = section["indent"] {
      if let v = v as? Int { self.indent = String(repeating: " ", count: v) }
      else if let v = v as? String { self.indent = v }
    }

    if let v = section[int:  "lineLength"]  { self.lineLength  = v }
    if let v = section[bool: "neverInline"] { self.neverInline = v }

    if let v = section[string: "endOfLineString"] { self.eol = v }
    if let v = section[string: "identifierListSeparator"] {
      self.identifierListSeparator = v
    }
    if let v = section[string: "typeConformanceSeparator"] {
      self.typeConformanceSeparator = v
    }
    if let v = section[string: "propertyTypeSeparator"] {
      self.propertyTypeSeparator = v
    }
    if let v = section[string: "propertyValueSeparator"] {
      self.propertyValueSeparator = v
    }
    if let v = section[string: "multiExampleSectionHeader"] {
      self.multiExampleSectionHeader = v
    }
  }
}
