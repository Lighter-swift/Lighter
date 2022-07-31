//
//  Pluralize.swift
//  ZeeQL3
//
//  Created by Helge Hess on 04.06.17.
//  Copyright © 2017-2022 ZeeZide GmbH. All rights reserved.
//

public extension String {
  // Inspired by:
  //   https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflections.rb
  
  var singularized : String {
    // FIXME: case
    
    switch self { // case compare
      // irregular
      case "people":   return "person"
      case "men":      return "man"
      case "children": return "child"
      case "sexes":    return "sex"
      case "moves":    return "move"
      case "zombies":  return "zombie"
      case "staff":    return "staff"
      
      // regular
      case "mice":     return "mouse"
      case "lice":     return "louse"
      case "mouse":    return "mouse"
      case "louse":    return "louse"

      // other
      case "axis",     "axes":     return "axis"
      case "analysis", "analyses": return "analysis"
      
      default: break
    }
    
    let len = self.count

    if len > 2 {
      if hasCISuffix("octopi")    { return dropLast(1) + "us"  }
      if hasCISuffix("viri")      { return dropLast(1) + "us"  }
      if hasCISuffix("aliases")   { return String(dropLast(2)) }
      if hasCISuffix("statuses")  { return String(dropLast(2)) }
      if hasCISuffix("oxen")      { return String(dropLast(2)) }
      if hasCISuffix("vertices")  { return dropLast(4) + "ex"  }
      if hasCISuffix("indices")   { return dropLast(4) + "ex"  }
      if hasCISuffix("matrices")  { return dropLast(3) + "x"   }
      if hasCISuffix("quizzes")   { return String(dropLast(3)) }
      if hasCISuffix("databases") { return String(dropLast(1)) }
      if hasCISuffix("crises")    { return dropLast(2) + "is"  }
      if hasCISuffix("crises")    { return self }
      if hasCISuffix("testes")    { return dropLast(2) + "is"  }
      if hasCISuffix("testis")    { return self }
      if hasCISuffix("shoes")     { return String(dropLast(1)) }
      if hasCISuffix("oes")       { return String(dropLast(2)) }
      if hasCISuffix("buses")     { return String(dropLast(2)) }
      if hasCISuffix("bus")       { return self }
      if hasCISuffix("mice")      { return dropLast(3) + "ouse" }
      if hasCISuffix("lice")      { return dropLast(3) + "ouse" }
      
      if hasCISuffix("xes")       { return String(dropLast(2)) }
      if hasCISuffix("ches")      { return String(dropLast(2)) }
      if hasCISuffix("sses")      { return String(dropLast(2)) }
      if hasCISuffix("shes")      { return String(dropLast(2)) }

      if hasCISuffix("ies") && len > 3 {
        if hasCISuffix("movies")  { return String(dropLast(1)) }
        if hasCISuffix("series")  { return self }
        
        if hasCISuffix("quies")   { return dropLast(3) + "y" }

        let cidx = self.index(endIndex, offsetBy: -4)
        let c    = self[cidx]
        if c != "a" && c != "e" && c != "i" && c != "o" && c != "u" && c != "y"
        {
          return dropLast(3) + "y"
        }
      }
      
      if hasCISuffix("lves")          { return dropLast(3) + "f" }
      if hasCISuffix("rves")          { return dropLast(3) + "f" }

      if hasCISuffix("tives")         { return String(dropLast(1)) }
      if hasCISuffix("hives")         { return String(dropLast(1)) }
      
      if hasCISuffix("ves") && len > 3 {
        let cidx = self.index(endIndex, offsetBy: -4)
        if self[cidx] != "f" { return dropLast(3) + "fe" }
      }
      
      if hasCISuffix("sis") {
        if hasCISuffix("analysis")    { return self }
        if hasCISuffix("basis")       { return self }
        if hasCISuffix("diagnosis")   { return self }
        if hasCISuffix("parenthesis") { return self }
        if hasCISuffix("prognosis")   { return self }
        if hasCISuffix("synopsis")    { return self }
        if hasCISuffix("thesis")      { return self }
      }
      else if hasCISuffix("ses") {
        if hasCISuffix("analyses")    { return dropLast(3) + "sis" }
        if hasCISuffix("bases")       { return dropLast(3) + "sis" }
        if hasCISuffix("diagnoses")   { return dropLast(3) + "sis" }
        if hasCISuffix("parentheses") { return dropLast(3) + "sis" }
        if hasCISuffix("prognoses")   { return dropLast(3) + "sis" }
        if hasCISuffix("synopses")    { return dropLast(3) + "sis" }
        if hasCISuffix("theses")      { return dropLast(3) + "sis" }
      }
      
      if hasCISuffix("ta")            { return dropLast(2) + "um" }
      if hasCISuffix("ia")            { return dropLast(2) + "um" }
      if hasCISuffix("news")          { return self }
    }
    
    if hasCISuffix("ss") { return String(dropLast(2)) }
    if hasCISuffix("s")  { return String(dropLast(1)) }
  
    return self
  }

  var pluralized : String {
    // FIXME: case
    
    switch self {
      // irregular
      case "person": return "people"
      case "man":    return "men"
      case "child":  return "children"
      case "sex":    return "sexes"
      case "move":   return "moves"
      case "zombie": return "zombies"
      case "staff":  return "staff"
      
      // regular
      case "mice":   return "mice"
      case "lice":   return "lice"
      case "mouse":  return "mice"
      case "louse":  return "lice"
      
      default: break
    }
    
    if hasCISuffix("quiz")   { return self + "zes" }
    if hasCISuffix("oxen")   { return self }
    if hasCISuffix("ox")     { return self + "en" }

    if hasCISuffix("matrix") { return replaceSuffix("matrix", "matrices") }
    if hasCISuffix("vertex") { return replaceSuffix("vertex", "vertices") }
    if hasCISuffix("index")  { return replaceSuffix("index",  "indices")  }

    if hasCISuffix("ch")     { return self + "es" }
    if hasCISuffix("ss")     { return self + "es" }
    if hasCISuffix("sh")     { return self + "es" }
    
    if hasCISuffix("quy")    { return replaceSuffix("quy", "quies") }
    if hasCISuffix("y") {
      if self.count > 2 {
        let idx = self.index(self.endIndex, offsetBy: -2)
        let cbY = self[idx]
        switch cbY {
          // https://www.youtube.com/watch?v=gUrJKN7F_so
          case "a", "e", "i", "o", "u": break
          default: return replaceSuffix("y",  "ies")
        }
        if hasCISuffix("ry")   { return replaceSuffix("ry",  "ries")  }
      }
    }
    
    if hasCISuffix("hive")    { return self + "hives" }
    
    // Missing, can be done w/ Swift Regex?: (?:([^f])fe|([lr])f) => '\1\2ves'
    
    if hasCISuffix("sis")     { return self + "ses" } // TBD: replace?

    if hasCISuffix("ta")      { return self }
    if hasCISuffix("ia")      { return self }
    
    if hasCISuffix("tum")     { return replaceSuffix("tum", "ta") }
    if hasCISuffix("ium")     { return replaceSuffix("ium", "ia") }

    if hasCISuffix("buffalo") { return replaceSuffix("buffalo", "buffaloes") }
    if hasCISuffix("tomato")  { return replaceSuffix("tomato",  "tomatoes")  }
    
    if hasCISuffix("bus")     { return replaceSuffix("bus", "buses") }

    if hasCISuffix("alias")   { return self + "es" }
    if hasCISuffix("status")  { return self + "es" }

    if hasCISuffix("octopi")  { return self }
    if hasCISuffix("viri")    { return self }
    if hasCISuffix("octopus") { return replaceSuffix("octopus", "octopi") }
    if hasCISuffix("virus")   { return replaceSuffix("virus",   "viri")   }
    
    if self == "axis"         { return "axes"   }
    if self == "testis"       { return "testes" }
    
    if hasCISuffix("s")       { return self }

    return self + "s"
  }
}

fileprivate extension String {
  
  func hasCIPrefix(_ s: String) -> Bool { // urks
    lowercased().hasPrefix(s.lowercased())
  }
  func hasCISuffix(_ s: String) -> Bool { // urks
    lowercased().hasSuffix(s.lowercased())
  }
  
  func replaceSuffix(_ suffix: String, _ with: String) -> String {
    hasSuffix(suffix) ? (dropLast(suffix.count) + with) : self
  }
}
