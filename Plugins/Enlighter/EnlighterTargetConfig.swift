//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import struct Foundation.URL

struct EnlighterTargetConfig { // that's all we need from Lighter.json

  let dbExtensions : Set<String>
  let extensions   : Set<String>
  let outputFile   : String?
  
  let verbose      : Bool
  let configURL    : URL?
}
