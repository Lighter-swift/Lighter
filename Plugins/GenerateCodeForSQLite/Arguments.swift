//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

struct Arguments {
  
  let verbose : Bool
  let targets : [ String ]
  
  init(_ arguments: [ String ]) {
    
    func extractValuesOfOption(_ option: String, from args: inout [ String ])
         -> [ String ]
    {
      var values = [ String ]()
      let long = "--" + option
      while let idx = args.firstIndex(of: long) {
        guard (idx + 1) < args.count else {
          print("ERROR: trailing `\(long)` option")
          break
        }
        values.append(args.remove(at: idx + 1))
        args.remove(at: idx)
      }
      return values
    }
    
    var args = arguments
    targets = extractValuesOfOption("target", from: &args)
    
    if let idx = args.firstIndex(of: "--verbose") {
      verbose = true
      args.remove(at: idx)
    }
    else {
      #if DEBUG // remove me
      verbose = true
      #else
      verbose = false
      #endif
    }
    
    assert(args.isEmpty, "other options left: \(args)")
  }
}

