//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension CodeGenerator {
  
  /// Returns a Swift string for the given type.
  /// E.g. ``TypeReference/void`` becomes `"Void"`.
  func string(for typeRef: TypeReference) -> String {
    switch typeRef {
      case .void            : return "Void"
      case .optional(let t) : return "\(string(for: t))?"
      case .name (let name) : return name
      case .some (let name) : return "some \(name)"
      case .array(let type) : return "[ \(string(for: type)) ]"
      case .inout(let type) : return "inout \(string(for: type))"
      
      case .qualifiedType(let baseName, let name): return "\(baseName).\(name)"
      
      case .keyPath(let fromType, let toType):
        return "KeyPath<\(string(for: fromType)), \(string(for: toType))>"
      
      case .closure(let escaping, let parameters, let doesThrow, let returns):
        let prefix = escaping ? "@escaping " : ""
        let ts     = doesThrow ? "throws " : ""
        let res    = string(for: returns)
        if parameters.isEmpty { return "\(prefix)() \(ts)-> \(res)" }
        return "\(prefix)( "
             + parameters.map({ string(for: $0) }).joined(separator: ", ")
             + " ) \(ts)-> \(res)"
      
      case .tuple(let names, let types):
        guard !types.isEmpty else { return "()" } // aka `Void
        var s = "( "
        var isFirst = true
        for ( idx, type ) in types.enumerated() {
          if isFirst { isFirst = false } else { s += ", " }
          if let name = idx < names.count ? names[idx] : nil {
            s += "\(name): "
            s += string(for: type)
          }
        }
        s += " )"
        return s
    }
  }
  
  /// Returns a Swift string for the given generic constraint.
  /// E.g. `"C: SQLColumn"`.
  func string(for constraint: GenericConstraint) -> String {
    switch constraint {
      
      case .conformance(let name, let type):
        return "\(name): \(string(for: type))"
   
      case .equal(let name, let type):
        return "\(name) == \(string(for: type))"
    }
  }
}
