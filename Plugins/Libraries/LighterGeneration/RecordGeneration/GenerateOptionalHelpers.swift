//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import LighterCodeGenAST

extension EnlighterASTGenerator {

  /**
   * Generate this:
   * ```swift
   * func stringForDecimal(_ decimal: Decimal) -> String {
   *   var copy = decimal
   *   return NSDecimalString(&copy, Locale(identifier: "en_US_POSIX"))
   * }
   * ```
   */
  func makeStringForDecimal() -> FunctionDefinition {
    FunctionDefinition(
      declaration: FunctionDeclaration(
        public: options.public, name: "stringForDecimal",
        parameters: [ .init(name: "decimal", type: .name("Decimal")) ],
        returnType: .string
      ),
      statements: [
        .raw("var copy = decimal"),
        .raw(
          #"return NSDecimalString(&copy, Locale(identifier: "en_US_POSIX"))"#)
      ]
    )
  }
  /**
   * Generate this:
   * ```swift
   * func stringForDecimal(_ decimal: Decimal?) -> String? {
   *   guard var copy = decimal else { return nil }
   *   return NSDecimalString(&copy, Locale(identifier: "en_US_POSIX"))
   * }
   * ```
   */
  func makeStringForOptDecimal() -> FunctionDefinition {
    FunctionDefinition(
      declaration: FunctionDeclaration(
        public: options.public, name: "stringForDecimal",
        parameters: [
          .init(name: "decimal", type: .optional(.name("Decimal")))
        ],
        returnType: .optional(.string)
      ),
      statements: [
        .raw("guard var copy = decimal else { return nil }"),
        .raw(
          #"return NSDecimalString(&copy, Locale(identifier: "en_US_POSIX"))"#)
      ]
    )
  }

  /**
   * Generate this:
   * ```swift
   * func withOptCString<R>(_ s: String?, _ body:
   *                                      (UnsafePointer<CChar>?) throws -> R)
   *        rethrows -> R
   * {
   *   if let s = s { return try s.withCString(body) }
   *   else { return try body(nil) }
   * }
   * ```
   */
  func makeWithOptCString() -> FunctionDefinition {
    FunctionDefinition(
      declaration: FunctionDeclaration(
        public: options.public, name: "withOptCString",
        genericParameterNames: [ "R" ],
        parameters: [
          .init(name: "s", type: .optional(.string)),
          .init(name: "body", type: .closure(
            escaping: false,
            parameters: [ .optional(.name("UnsafePointer<CChar>")) ],
            throws: true, returns: .name("R")
          ))
        ],
        rethrows: true, returnType: .name("R")
      ),
      statements: [
        .raw("if let s = s { return try s.withCString(body) }"),
        .raw("else { return try body(nil) }")
      ]
    )
  }
  
  /**
   * Note: `start` seems to be always non-nil for both empty Data and `[UInt8]`,
   *       so we reuse `start: nil` to signal `NULL` to SQLite.
   *
   * Generate this:
   * ```swift
   * func withOptBlob<R>(_ data: [ UInt8 ]?,
   *                  _ body: (UnsafeRawBufferPointer) throws -> R)
   *        rethrows -> R
   * {
   *   if let data = data { return try data.withUnsafeBytes(body) }
   *   else { return try body(UnsafeRawBufferPointer(start: nil, count: 0)) }
   * }
   * ```
   */
  func makeWithOptBlob(name: String = "withOptBlob",
                       type: TypeReference = .uint8Array) -> FunctionDefinition
  {
    FunctionDefinition(
      declaration: FunctionDeclaration(
        public: options.public, name: name,
        genericParameterNames: [ "R" ],
        parameters: [
          .init(name: "data", type: .optional(type)),
          .init(name: "body", type: .closure(
            escaping   : false,
            parameters : [ .name("UnsafeRawBufferPointer") ],
            throws     : true, returns: .name("R")
          ))
        ],
        rethrows: true, returnType: .name("R")
      ),
      statements: [
        .raw("if let data = data { return try data.withUnsafeBytes(body) }"),
        .raw("else { return try body(UnsafeRawBufferPointer(start: nil, count: 0)) }")
      ]
    )
  }
  
  func makeWithOptUUIDBytes() -> FunctionDefinition {
    FunctionDefinition(
      declaration: FunctionDeclaration(
        public: options.public, name: "withOptUUIDBytes",
        genericParameterNames: [ "R" ],
        parameters: [
          .init(name: "uuid", type: .optional(.uuid)),
          .init(name: "body", type: .closure(
            escaping   : false,
            parameters : [ .name("UnsafeRawBufferPointer") ],
            throws     : true, returns: .name("R")
          ))
        ],
        rethrows: true, returnType: .name("R")
      ),
      statements: [
        .raw("if let uuid = uuid { return try withUnsafeBytes(of: &uuid, body) }"),
        .raw("else { return try body(UnsafeRawBufferPointer(start: nil, count: 0)) }")
      ]
    )
  }
}
