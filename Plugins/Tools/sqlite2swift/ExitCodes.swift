//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/// The exit codes the process uses.
enum ExitCodes: Int32, Swift.Error {
  case ok                         = 0
  case invalidArguments           = 1
  case couldNotOpenConfiguration  = 2
  case couldNotWriteOutput        = 3
  case couldNotLoadInMemorySchema = 4
}
