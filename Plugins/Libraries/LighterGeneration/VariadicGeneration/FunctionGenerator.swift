//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

import struct Foundation.Locale
import class  Foundation.NumberFormatter
import LighterCodeGenAST

/**
 * Common base class for Lighter variadic function generators.
 */
public class FunctionGenerator {

  public var columnCount : Int = 6 {
    didSet { assert(columnCount >= 1 && columnCount < 32) }
  }

  public var api = LighterAPI()

  public var recordGenericParameterPrefix    = "T"
  public var predicateGenericParameterPrefix = "P"
  public var columnGenericParameterPrefix    = "C"
  public var columnParameterName             = "column"
  
  public var builderVariableName             = "builder"

  // Note: Those should be filled based on the schema, if available!!
  //       I.e. take an actual table + columns from the schema.
  //       Though that affects the qualifier?
  public var commentRecordExample  = "person"
  public var commentColumnValueExamples : [ (column: String, value: String)] = [
    ( "personId" , "10"                    ),
    ( "lastname" , "\"Duck\""              ),
    ( "city"     , "\"Entenhausen\""       ),
    ( "street"   , "\"Am Geldspeicher 1\"" ),
    ( "leetness" , "1337"                  )
  ]
  public lazy var commentColumnExamples =
                    commentColumnValueExamples.map { $0.column }
    
  /* Result */
  public var functions = [ FunctionDefinition ]()

  
  /**
   * Returns names with a certain prefix:
   * - count 0:  `[]`
   * - count 1:  `[ prefix ]`
   * - count 2+: `[ prefix1, prefix2, ... ]`
   */
  func oneBasedNames(prefix: String, count: Int) -> [ String ] {
    guard count > 0 else { return [] }
    if count == 1 { return [ `prefix` ] }
    return (1...count).map { "\(prefix)\($0)" }
  }
  
  /**
   * Format numbers into English ordinal numbers (1=>1st, 2=>2nd)
   */
  private let ordinalFormatter : NumberFormatter = {
    let fmt = NumberFormatter()
    fmt.numberStyle = .ordinal
    fmt.locale = Locale(identifier: "en_US")
    return fmt
  }()
  func ordinal(_ value: Int) -> String {
    ordinalFormatter.string(for: value) ?? String(value)
  }
  
  public init() {}
}
