//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

import LighterCodeGenAST
import SQLite3Schema
import struct Foundation.Decimal
import struct Foundation.URL
import struct Foundation.UUID

extension EnlighterASTGenerator {
  
  /**
   * If the SQL had an associated default value, return an expression to
   * recreate that for the property type.
   *
   * Example:
   * ```
   * CREATE TABLE temperature (
   *   temperature_id INT PRIMARY KEY,
   *   info           TEXT NOT NULL DEFAULT 'Nothing to see here'
   * )
   * ```
   */
  func defaultValue(for property: EntityInfo.Property) -> Expression? {
    guard let value = property.defaultValue else {
      if !property.isNotNull { return .nil } // optionals always default to nil
      return nil // this means _no_ default (e.g. for `init` parameters)
    }
    
    func cannotConvert() -> Expression? {
      // Later: Better Logs
      print("Cannot convert default value of property:", property)
      return nil
    }
    
    // Nice Matrix ;-)
    switch value {
      case .null:
        return property.isNotNull ? cannotConvert() : .nil
      
      // 0...8 bytes depending on the magnitude of the value
      case .integer(let value):
        switch property.propertyType {
          case .integer    : return .integer(Int(value))
          case .double     : return .integer(Int(value))
          case .string     : return .string("\(value)")
          case .bool       : return value != 0 ? .true : .false
          case .decimal    : return .call(name: "Decimal", .integer(Int(value)))

          case .date:
            return .call(name: "Date", parameters: [
              ("timeIntervalSince1970", .integer(Int(value)))
            ])
          
          case .uint8Array, .data, .url, .uuid, .custom: return cannotConvert()
        }

      case .real(let value):
        switch property.propertyType {
          case .integer    : return .double(value)
          case .double     : return .double(value)
          case .string     : return .string("\(value)")
          case .bool       : return value != 0 ? .true : .false
          case .decimal    : return .call(name: "Decimal", .double(value))

          case .date:
            return .call(name: "Date", parameters: [
              ("timeIntervalSince1970", .double(value))
            ])
          
          case .uint8Array, .data, .url, .uuid, .custom: return cannotConvert()
        }
      
      case .text(let value):
        switch property.propertyType {
          case .string  : return .string(value)
          case .integer : return Int(value).flatMap({ .integer($0) })
                              ?? cannotConvert()
          case .double  : return Double(value).flatMap({ .double($0) })
                              ?? cannotConvert()
          case .decimal :
            guard nil != Decimal(string: value) else { return cannotConvert() }
            return .nilCoalesce(
              .call(name: "Decimal", parameters: [("string", .string(value))]),
              .call(name: "Decimal", .integer(-1)) // should never happen
            )
          
          case .bool:
            switch value {
              case "true", "YES", "1", "TRUE"  : return .true
              case "false", "NO", "0", "FALSE" : return .false
              default                          : return cannotConvert()
            }

          case .date:
            if let date = options.dateFormatter.date(from: value) {
              return .call(name: "Date", parameters: [
                ("timeIntervalSince1970", .double(date.timeIntervalSince1970))
              ])
            }
            if let timestamp = Double(value) {
              return .call(name: "Date", parameters: [
                ("timeIntervalSince1970", .double(timestamp))
              ])
            }
            return cannotConvert()
          
          case .url:
            guard nil != URL(string: value) else { return cannotConvert() }
            return .forceUnwrap(
              .call(name: "URL", parameters: [("string", .string(value))])
            )
          
          case .uuid:
            guard nil != UUID(uuidString: value) else { return cannotConvert() }
            return .forceUnwrap(
              .call(name: "UUID", parameters: [("uuidString", .string(value))])
            )

          case .uint8Array, .data, .custom: return cannotConvert()
        }
      
      case .blob(let value):
        switch property.propertyType {
          case .integer, .double, .decimal, .bool, .date, .url:
            return cannotConvert()
          case .string: // makes no sense, right?
            return cannotConvert()
          case .custom:
            return cannotConvert()
          case .uint8Array:
            return .call(name: "[ UInt8 ]", .integerArray(value))
          case .data:
            return .call(name: "Data", .integerArray(value))
          case .uuid:
            guard value.count == 16 else { return cannotConvert() }
            return .call(name: "UUID", parameters: [
              ( "uuid", .tuple(value.map { .integer(Int($0)) }) )
            ])
        }
      case .currentDate, .currentTime: // YYYY-MM-DD & HH:MM:SS
        // those only make sense for string properties?
        switch property.propertyType {
          case .integer, .double, .decimal, .bool, .date, .url, .uint8Array,
               .data, .uuid, .custom:
            return cannotConvert()
          case .string:
            return .formattedCurrentDate(format: (value == .currentDate
                                                  ? "yyyy-MM-dd"
                                                  : "HH:mm:ss"))
        }
      case .currentTimestamp:
        switch property.propertyType {
          case .decimal, .bool, .url, .uint8Array, .data, .uuid, .custom:
            return cannotConvert()
          case .date:
            return .call(name: "Foundation.Date")
          case .double:
            return .variableReference(
              instance: "Foundation.Date()", name: "timeIntervalSince1970")
          case .integer:
            return .cast(
              .variableReference(
                instance: "Foundation.Date()", name: "timeIntervalSince1970"),
              to: .int
            )
          case .string:
            return .formattedCurrentDate(format: "yyyy-MM-dd HH:mm:ss")
        }
    }
  }
  
  /// Retrieve a non-optional default value for the property.
  /// This first checks ``defaultValue(for:)``, but then falls back to property
  /// type based values.
  func nonOptionalDefaultValue(for property: EntityInfo.Property) -> Expression
  {
    if let value = defaultValue(for: property) { return value }
    if !property.isNotNull                     { return .nil  }
    
    switch property.propertyType {
      case .integer    : return .integer(-1)
      case .double     : return .integer(-1)
      case .string     : return .string("")
      case .uint8Array : return .raw("[]")
      case .bool       : return .false
      case .data       : return .call(name: "Data")

      case .date: // utime 0 makes more sense than now, right?
        return .call(name: "Date",
                     parameters: [ ( "timeIntervalSince1970", .integer(0)) ])
      case .url :
        return .call(name: "URL", parameters: [ ("string", .string("blank:"))])
      case .decimal:
        return .call(name: "Decimal", .integer(1))
      case .uuid: // 0000-0000-... makes more sense than create a new?
        return .call(name: "UUID", parameters: [
          ( "uuid", .tuple(.init(repeating: .integer(0), count: 16)) )
        ])
      
      case .custom(let type): return .call(name: type) // XYZ()
    }
  }
}
