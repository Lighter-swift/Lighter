//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

/**
 * The sort order that can be applied in select. Ascending or descending.
 */
public enum SQLSortOrder: String, Sendable {
  case ascending  = "ASC"
  case descending = "DESC"
}
