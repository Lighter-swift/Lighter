//
//  FancyModelMaker.swift
//  ZeeQL3
//
//  Created by Helge Hess on 19/05/17.
//  Copyright © 2017-2024 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.CharacterSet

extension String {
  
  /// employee => toEmployee
  var toName : String {
    return "to" + capitalized
  }

  /// helloWorld => HelloWorld
  /// Note: `capitalized` does "Helloworld"! (lower second part)
  var upperFirst : String {
    guard let c0 = first, c0.isLowercase else { return self }
    return c0.uppercased() + dropFirst()
  }
  
  /// personAddress    => `person_address`  (lowercase true)
  /// personAddress    => `person_Address`  (lowercase false)
  /// PersonAddress    => `person_address`  (lowercase true)
  /// personADDRESS    => `person_address`  (lowercase true)
  /// personADDRESS    => `person_ADDRESS`  (lowercase false)
  /// personADDRess    => `person_ADDRess`  (lowercase false)
  /// personADdrEss    => `person_ADdr_Ess` (lowercase false)
  /// `person_Address` => `person_address`  (lowercase true)
  func snake_case(lowercase: Bool = true) -> String {
    guard !self.isEmpty else { return "" }
    let upper = CharacterSet.uppercaseLetters
    var newChars = [ String.UnicodeScalarView.Element ]()
    
    var isFirst = true
    for unicodeScalar in unicodeScalars {
      defer { if isFirst { isFirst = false } }
      
      if isFirst {
        newChars.append(unicodeScalar)
        continue
      }
      
      if upper.contains(unicodeScalar) {
        if newChars.last.flatMap({ upper.contains($0) })
           ?? (newChars.last != "_")
        {
          newChars.append(unicodeScalar)
        }
        else {
          newChars.append("_")
          newChars.append(unicodeScalar)
        }
      }
      else {
        newChars.append(unicodeScalar)
      }
    }
    
    guard !newChars.isEmpty else { return self }
    let s = String(UnicodeScalarView(newChars))
    return lowercase ? s.lowercased() : s
  }

  /// `person_address`  => `personAddress`  (w/o upperFirst)
  /// `person_address`  => `PersonAddress`  (w/  upperFirst)
  /// `person__address` => `Person_Address`  (w/  upperFirst)
  /// `Person Address`  => `PersonAddress`
  /// `_private_column` => `_privateColumn` (w/o upperFirst)
  /// - Parameters:
  ///   - upperFirst: Whether to upper the first letter.
  func makeCamelCase(upperFirst: Bool) -> String {
    guard !self.isEmpty else { return "" }
    var newChars = [ Character ]()
    
    var isFirst   = true
    var upperNext = upperFirst
    for ( idx, c ) in zip(indices, self) {
      defer { if isFirst { isFirst = false } }
      
      switch c {
        case " ": // skip and upper next
          upperNext = !isFirst || upperFirst

        case "_": // skip and upper next
          let idx1 = index(after: idx)
          if isFirst || (idx1 < endIndex && self[idx1] == "_") {
            newChars.append(c)
          }
          upperNext = !isFirst || upperFirst
        
        case "a"..."z":
          if upperNext {
            if let uc = c.uppercased().first { newChars.append(uc) }
            else                             { newChars.append(c)  }
            upperNext = false
          }
          else {
            newChars.append(c)
          }
        
        default:
          upperNext = false
          newChars.append(c)
      }
    }
    guard !newChars.isEmpty else { return self }
    return String(newChars)
  }

  /// `person_address`  => `PersonAddress`
  /// `Person Address`  => `PersonAddress`
  /// `_private_column` => `_PrivateColumn`
  var capCamelCase : String { return makeCamelCase(upperFirst: true)  }
  /// `person_address`  => `personAddress`
  /// `Person Address`  => `PersonAddress`
  /// `_private_column` => `_privateColumn`
  var camelCase    : String { return makeCamelCase(upperFirst: false) }
  
  /// Checks whether the String contains any `uppercaseLetters`
  var isLowerCase : Bool {
    guard !isEmpty else { return false }
    return !self.unicodeScalars.contains(where: { upper.contains($0) })
  }
  
  /// Checks whether the String contains both `uppercaseLetters` and
  /// `lowercaseLetters` letters.
  var isMixedCase : Bool {
    guard !isEmpty else { return false }
    let upper = CharacterSet.uppercaseLetters
    let lower = CharacterSet.lowercaseLetters
    
    var hadUpper = false
    var hadLower = false
    for unicodeScalar in self.unicodeScalars {
      if upper.contains(unicodeScalar) {
        if hadLower { return true }
        hadUpper = true
      }
      else if lower.contains(unicodeScalar) {
        if hadUpper { return true }
        hadLower = true
      }
    }
    return false
  }
}

fileprivate let upper = CharacterSet.uppercaseLetters
