//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import Foundation

public extension CodeGenerator {
  
  func string(for literal: Literal) -> String {
    switch literal {
      case .nil                : return "nil"
      
      case .true               : return "true"
      case .false              : return "false"
      
      case .integer(let value) : return String(value)
      case .double (let value) : return String(value) // Right?

      case .integerArray(let values) :
        return "[ " + values.map({ String($0) }).joined(separator: ", ") + " ]"

      case .string(let value):
        // expensive to perform on each an every string? is there a better way?
        if value.unicodeScalars.first(where: {
          unsafeSwiftStringLiteralCharacters.contains($0)
        }) == nil {
          return "\"\(value)\""
        }
        
        if let pounds = poundsForString(value) {
          assert(!pounds.isEmpty)
          // ##"Hello # "##
          
          if value.contains("\n") { // meh
            let indent =
            String(repeating: configuration.indent, count: indentationLevel + 1)
            var s = "\n"
            s += "\(indent)\(pounds)\"\"\"\n"
            for line in value.split(separator: "\n",
                                    omittingEmptySubsequences: false)
            {
              s += "\(indent)\(line)\n"
            }
            s += "\(indent)\"\"\"\(pounds)"
            return s
          }
          else {
            return "\(pounds)\"\(value)\"\(pounds)"
          }
        }
        else { // complete me :-)
          let escaped = value
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\t", with: "\\t")
                .replacingOccurrences(of: "\"", with: "\\\"")
          return "\"\(escaped)\""
        }
    }
  }
}

/// Check whether the string contains "#", "##", "###", and so on,
/// and return the first non-contained version. Or `nil` if the limit
/// has been reached.
fileprivate func poundsForString(_ string: String, max: Int = 10) -> String? {
  guard string.contains("#") else { return "#" }
  for i in 2..<max {
    let pounds = String(repeating: "#", count: i)
    if string.range(of: pounds) == nil { return pounds }
  }
  return nil
}

fileprivate let unsafeSwiftStringLiteralCharacters : CharacterSet = {
  var safeCharacters = CharacterSet.alphanumerics
  safeCharacters.formUnion(.whitespaces)
  safeCharacters.formUnion(.init(charactersIn: "_,;&'@#!$(){}+-*/:."))
  return safeCharacters.inverted
}()
