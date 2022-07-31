//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import Foundation

struct EnlighterTargetConfig { // that's all we need from Lighter.json

  let extensions : Set<String>
  let outputFile : String?
  
  let verbose    : Bool
  let configURL  : URL?
}
