//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

// This is a tool to generate the Swift to represent one single SQL database,
// though that database can be composed from different input databases and/or
// SQL source files.

import func Foundation.exit

do {
  var tool = try SQLite2Swift(CommandLine.arguments)
  try tool.run()
}
catch let error as ExitCodes {
  exit(error.rawValue)
}
catch {
  print("Unexpected error:", error)
  exit(42)
}
