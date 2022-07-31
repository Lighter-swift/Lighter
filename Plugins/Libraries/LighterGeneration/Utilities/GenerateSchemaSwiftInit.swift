//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import SQLite3Schema

/// Small helper function to generate schemas for tests. Not supposed to escape
/// everything right.
public func generateSwiftInitForSchema(_ schema: Schema,
                                       nesting: Int = 1,
                                       indent: Int = 2)
            -> String
{
  var source = "Schema(\n"
  
  func startLine(_ extraIndent: Int, _ line: String? = nil) {
    source += String(repeating: " ", count: indent * (nesting + extraIndent))
    if let line = line { source += line + "\n" }
  }
  
  func escapeAndQuoteString(_ s: String) -> String {
    return "\"" + (s.replacingOccurrences(of: "\n", with: "\\n")
                    .replacingOccurrences(of: "\"", with: "\\\"")) + "\""
  }
  
  func generateColumn(_ column: Schema.Column) {
    startLine(3, nil)
    source += ".init(id: \(column.id), name: \"\(column.name)\""
    switch column.type {
      case .none             : source += ", type: nil"
      case .some(.integer)   : source += ", type: .integer"
      case .some(.real)      : source += ", type: .real"
      case .some(.text)      : break // default: source += ", type: .text"
      case .some(.blob)      : source += ", type: .blob"
      case .some(.any)       : source += ", type: .any"
      case .some(.boolean)   : source += ", type: .boolean"
      case .some(.varchar(width: .none)):
        source += ", type: .varchar(width: nil)"
      case .some(.varchar(width: .some(let w))):
        source += ", type: .varchar(width: \(w))"
      case .some(.date)      : source += ", type: .date"
      case .some(.datetime)  : source += ", type: .datetime"
      case .some(.timestamp) : source += ", type: .timestamp"
      case .some(.decimal)   : source += ", type: .decimal"
      case .some(.custom(let type)): source += ", type: .custom(\"\(type)\")"
    }
    if column.isNotNull { source += ", isNotNull: true" }
    if let value = column.defaultValue {
      source += ", defaultValue: "
      switch value {
        case .null           : source += ".null"
        case .integer(let v) : source += ".integer(\(v))"
        case .real   (let v) : source += ".real(\(v))"
        case .text   (let v) : source += ".text(\"\(v)\")"
        case .blob   (let v) : source += ".blob(\(v) /* Not implemented */)"
      }
    }
    if column.isPrimaryKey { source += ", isPrimaryKey: true" }
    source += "),\n"
  }
  
  startLine(0,
            "version: \(schema.version), userVersion: \(schema.userVersion),")
  startLine(0,"tables: [")

  for table in schema.tables {
    let sqlExtra = table.creationSQL.isEmpty ? "" : {
      ", sql: " + escapeAndQuoteString(table.creationSQL)
    }()
    
    startLine(1, "Schema.Table(")
    startLine(2, "info: .init(type: .table, name: \"\(table.name)\"\(sqlExtra)),")
    startLine(2, "columns: [")
    for column in table.columns {
      generateColumn(column)
    }
    if table.foreignKeys.isEmpty {
      startLine(2, "]")
    }
    else {
      startLine(2, "],")
      startLine(2, "foreignKeys: [")
      for fkey in table.foreignKeys {
        startLine(3, nil)
        source += ".init(id: \(fkey.id)"
        source += ", sourceColumn: \"\(fkey.sourceColumn)\""
        source += ", destinationTable: \"\(fkey.destinationTable)\""
        if fkey.sourceColumn != fkey.destinationColumn {
          source += ", destinationColumn: \"\(fkey.destinationColumn)\""
        }
        if fkey.updateAction != .noAction {
          source += ", updateAction: "
          switch fkey.updateAction {
            case .noAction   : source += ".noAction"
            case .cascade    : source += ".cascade"
            case .restrict   : source += ".restrict"
            case .setNull    : source += ".setNull"
            case .setDefault : source += ".setDefault"
          }
        }
        if fkey.deleteAction != .noAction {
          source += ", deleteAction: "
          switch fkey.updateAction {
            case .noAction   : source += ".noAction"
            case .cascade    : source += ".cascade"
            case .restrict   : source += ".restrict"
            case .setNull    : source += ".setNull"
            case .setDefault : source += ".setDefault"
          }
        }
        if fkey.match != .simple {
          source += ", match: "
          switch fkey.match {
            case .none    : source += ".none"
            case .simple  : source += ".simple"
            case .partial : source += ".partial"
            case .full    : source += ".full"
          }
        }
        source += "),\n"
      }
      startLine(2, "],")
    }
    startLine(1, "),")
  }
  startLine(0, schema.views.isEmpty && schema.indices.isEmpty ? "]" : "],")
  if !schema.views.isEmpty {
    startLine(0, "views: [")
    
    for view in schema.views {
      let sqlExtra = view.creationSQL.isEmpty ? "" : {
        ", sql: " + escapeAndQuoteString(view.creationSQL)
      }()
      
      startLine(1, "Schema.View(")
      startLine(2,
                "info: .init(type: .view, name: \"\(view.name)\"\(sqlExtra)),")
      startLine(2, "columns: [")
      for column in view.columns {
        generateColumn(column)
      }
      startLine(2, "]")
      startLine(1, "),")
    }

    startLine(0, schema.indices.isEmpty ? "]" : "],")
  }
  if !schema.indices.isEmpty {
    startLine(0, "indices: [")
    for ( table, indices ) in schema.indices {
      guard !indices.isEmpty else { continue }
      startLine(1, "\"\(table)\": [")
      for index in indices {
        startLine(2, nil)
        /*
         public init(type: CatalogObjectType = .table,
         name: String, tableName: String? = nil, rootPage: Int64 = 1,
         sql: String = "")
         */
        source += ".init(type: .index"
        source += ", name: \"\(index.name)\""
        source += ", tableName: \"\(index.tableName)\""
        source += ", rootPage: \(index.rootPage)"
        if !index.sql.isEmpty {
          let escaped = escapeAndQuoteString(index.sql)
          source += ", sql: \(escaped)" // TBD: indent, escape?
        }
        
        source += "),\n"
      }
      startLine(1, "],")
    }
    startLine(0, "]")
  }
  
  source += String(repeating: " ", count: indent * (nesting - 1))
  source += ")\n"
  return source
}
