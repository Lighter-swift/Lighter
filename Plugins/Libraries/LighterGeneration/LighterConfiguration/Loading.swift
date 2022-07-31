//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import Foundation

public extension LighterConfiguration {
  
  init(contentsOf url: URL, for target: String, stem: String? = nil) throws {
    let file = try ConfigFile(contentsOf: url, for: target, stem: stem)    
    self.init(section: file.root)
  }
}
