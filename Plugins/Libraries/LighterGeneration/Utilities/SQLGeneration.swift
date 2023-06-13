//
//  Created by Helge Heß.
//  Copyright © 2022-2023 ZeeZide GmbH.
//

#if canImport(Foundation)
import Foundation // for replacingOccurrencesOf

/// Escape the `id` (e.g. a column or table name) and surround it by quotes.
@inlinable
func escapeAndQuoteIdentifier(_ id: String) -> String {
  id.contains("\"")
    ? "\"\(id.replacingOccurrences(of: "\"", with: "\"\""))\""
    : "\"\(id)\""
}
#else // no Foundation

/// Escape the `id` (e.g. a column or table name) and surround it by quotes.
@inlinable
func escapeAndQuoteIdentifier(_ id: String) -> String {
  id.firstIndex(of: "\"") != nil
    ? "\"\(id.split(whereSeparator: { $0 == "\""}).joined(separator: "\"\""))\""
    : "\"\(id)\""
}
#endif
