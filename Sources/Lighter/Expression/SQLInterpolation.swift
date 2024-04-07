//
//  Created by Helge Heß.
//  Copyright © 2022-2024 ZeeZide GmbH.
//

public struct SQLInterpolation: StringInterpolationProtocol, Sendable {
  
  @usableFromInline
  enum Fragment: Sendable {
    // Would be nice to support columns, but those would make the fragment
    // generic and non-hashable?
    case raw      (String)
    case parameter(SQLiteValueType)
  }
  
  @usableFromInline
  var fragments = [ Fragment ]()

  @inlinable
  public init(literalCapacity: Int, interpolationCount: Int) {
    fragments.reserveCapacity(interpolationCount)
  }
  
  public init(verbatim sql: String) {
    fragments = [ .raw(sql) ]
  }
  
  // MARK: - Literals
  
  @inlinable
  public mutating func appendLiteral(_ sql: String) {
    guard !sql.isEmpty else { return }
    if case .raw(let lastSQL) = fragments.last {
      fragments.removeLast()
      fragments.append(.raw(lastSQL + sql))
    }
    else {
      fragments.append(.raw(sql))
    }
  }
  
  
  // MARK: - Interpolations

  @inlinable
  public mutating func appendInterpolation(_ value: Int) {
    appendLiteral(String(value))
  }
  @inlinable
  public mutating func appendInterpolation(_ value: Double) {
    appendLiteral(String(value))
  }

  @inlinable
  public mutating func appendInterpolation(verbatim sql: String) {
    appendLiteral(sql)
  }
  
  @inlinable
  public mutating func appendInterpolation(_ data: [ UInt8 ]) {
    fragments.append(.parameter(data))
  }
  @inlinable
  public mutating func appendInterpolation<S>(_ data: S)
                         where S: Sequence, S.Element == UInt8
  {
    appendInterpolation([ UInt8 ](data))
  }

  @inlinable
  public mutating func appendInterpolation(_ string: String) {
    fragments.append(.parameter(string))
  }
  @inlinable
  public mutating func appendInterpolation(_ string: Substring) {
    self.appendInterpolation(String(string))
  }
  
  @inlinable
  public mutating func appendInterpolation<T: SQLRecord>(_ table: T.Type) {
    fragments.append(.raw("\"" + table.Schema.externalName + "\""))
  }
  @inlinable
  public mutating func appendInterpolation<C: SQLColumn>(_ column: C) {
    // Not ideal, but we'd need to type erase?
    fragments.append(.raw("\"" + column.externalName + "\""))
  }

  @inlinable
  public mutating func appendInterpolation(_ value: SQLiteValueType) {
    if value.requiresSQLBinding {
      fragments.append(.parameter(value))
    }
    else {
      appendLiteral(value.sqlStringValue)
    }
  }

  @inlinable
  public mutating func appendInterpolation<V: SQLiteValueType>(_ value: V) {
    if value.requiresSQLBinding {
      fragments.append(.parameter(value))
    }
    else {
      appendLiteral(value.sqlStringValue)
    }
  }
}

extension SQLInterpolation {
  
  public func generateSQL<Base>(into builder: inout SQLBuilder<Base>) {
    for fragment in fragments {
      switch fragment {
        
        case .raw(let sqlFragment):
          builder.append(sqlFragment)
        
        case .parameter(let value):
          builder.append(" ")
          builder.append(builder.sqlString(for: value))
          builder.append(" ")
      }
    }
  }
}
