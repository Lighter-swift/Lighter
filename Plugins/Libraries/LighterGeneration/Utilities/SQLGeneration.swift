//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

/// Escape the `id` (e.g. a column or table name) and surround it by quotes.
@inlinable
func escapeAndQuoteIdentifier(_ id: String) -> String {
  id.contains("\"")
    ? "\"\(id.replacingOccurrences(of: "\"", with: "\"\""))\""
    : "\"\(id)\""
}
