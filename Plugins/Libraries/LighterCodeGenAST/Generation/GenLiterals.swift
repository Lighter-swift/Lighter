//
//  Created by Helge Heß.
//  Copyright © 2022-2023 ZeeZide GmbH.
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
          
          if value.isMultilineASCIIString { // Meh
            // We don't want CRs in beautiful Swift code.
            let value = value.replacingOccurrences(of: "\r\n", with: "\n")
            let indent = String(
              repeating: configuration.indent,
              count: indentationLevel + 1
            )
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
                .replacingOccurrences(of: "\r", with: "\\r")
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

fileprivate struct UnsafeLiteralCharacters: @unchecked Sendable {
  
  private let set : CharacterSet = {
    var safeCharacters = CharacterSet.alphanumerics
    safeCharacters.formUnion(.whitespaces)
    safeCharacters.formUnion(.init(charactersIn: "_,;&'@#!$(){}+-*/:."))
    return safeCharacters.inverted
  }()
  
  func contains(_ c: Unicode.Scalar) -> Bool { return set.contains(c) }
}
fileprivate let unsafeSwiftStringLiteralCharacters = UnsafeLiteralCharacters()

extension String {
  
  /// Returns true if the string is a multiline string, i.e. contains LF or CR.
  /// Does *not* consider arbitrary newline Unicode characters.
  var isMultilineASCIIString : Bool {
    // Note: Don't do this: `self.contains("\n")` (Issue #23).
    // If the String contains CR LF (`\r\n`, ASCII 13,10), this doesn't
    // match! `\r\n` is turned into a Unicode composed character in the
    // Swift String. Which interestingly has an `asciiValue`, 10 and returns
    // `true` on `isASCII`.
    // This does work: `self.contains(where: \.isNewline)`, but in here
    // we really want just the ASCII codes for source.
    self.utf8.contains(where: { $0 == 10 /* NL */ || $0 == 13 /* CR */ })
  }
}
