//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

// hm, this doesn't actually work:
// ```
// let `try!` = 10
// ```

let SwiftReservedWords : Set<String> = [
  "import",
  "let", "var", "static",
  "public", "private", "fileprivate", "internal", "open",
  "class", "struct", "extension", "protocol", "enum", "case", "default",
  "func", "throws", "rethrows", "mutating", "nonmutating",
  "init", "deinit", "inout", "optional", "override",
  "try",
  "operator", "infix", "subscript", "defer",
  "break", "fallthrough", "indirect", "lazy",
  "for", "do", "while", "repeat", "continue", "return", "in", "where",
  "if", "guard", "else", "switch", "catch", "throw",
  "true", "false", "nil", "self",
  "as", "is",
  "async", "await",
  "typealias", "associatedtype",
  "associativity", "dynamic", "convenience", "required", "final",
  "didSet", "willSet", "get", "set",
  "weak", "unowned"
]
