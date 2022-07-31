//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

public extension Schema {

  /**
   * A structure representing a SQLite3 table.
   *
   * It is similar to a ``Schema/View``, but has the ``foreignKeys`` of the
   * table in addtion.
   */
  struct Table: Hashable {
    
    /// The raw catalog information on the table.
    public let info        : CatalogObject

    /// The ``Schema/Column``s of the table.
    public let columns     : [ Column     ]

    /// The ``Schema/ForeignKey``s of the table.
    public let foreignKeys : [ ForeignKey ]
    

    // MARK: - Convenience
    
    /// Returns the catalog object type (aka .table).
    @inlinable public var type        : CatalogObjectType { info.type }

    /// The name of the table.
    @inlinable public var name        : String            { info.name }

    /// The SQL that is used to create the table.
    @inlinable public var creationSQL : String            { info.sql  }
    

    /// Initialize a new `Table` value.
    @inlinable
    public init(info: CatalogObject, columns: [ Column ],
                foreignKeys: [ ForeignKey ] = [])
    {
      assert(!columns.isEmpty)
      self.info        = info
      self.columns     = columns
      self.foreignKeys = foreignKeys
    }
    
    /// Returns a ``Schema/Column`` for the given colum name. If available.
    @inlinable
    subscript(_ column: String) -> Column? {
      return columns.first(where: { $0.name == column })
    }
  }

  struct View: Hashable {
    
    /// The raw catalog information on the view.
    public let info        : CatalogObject

    /// The ``Schema/Column``s of the table.
    public let columns     : [ Column     ]
    

    // MARK: - Convenience
    
    /// Returns the catalog object type (aka .view).
    @inlinable public var type        : CatalogObjectType { info.type }

    /// The name of the view.
    @inlinable public var name        : String            { info.name }

    /// The SQL that is used to create the view.
    @inlinable public var creationSQL : String            { info.sql  }
    
    
    /// Initialize a new `View` value.
    @inlinable
    public init(info: CatalogObject, columns: [ Column ]) {
      assert(!columns.isEmpty)
      self.info    = info
      self.columns = columns
    }
    
    /// Returns a ``Schema/Column`` for the given colum name. If available.
    @inlinable
    subscript(_ column: String) -> Column? {
      columns.first(where: { $0.name == column })
    }
  }
}


// MARK: - Description

extension Schema.Table: CustomStringConvertible {
  
  /// Returns a debug description for the table.
  public var description: String {
    var ms = "<Table[\(name)]:"
    
    if columns.isEmpty { ms += " NO-COLUMNS?" }
    else {
      for column in columns {
        ms += " "
        ms += column.description
      }
    }
    
    if !foreignKeys.isEmpty {
      ms += " foreign-keys:["
      for fkey in foreignKeys {
        ms += " "
        ms += fkey.description
      }
      ms += " ]"
    }
    
    if creationSQL.isEmpty { ms += " NO-SQL" }
    ms += ">"
    return ms
  }
}


extension Schema.View: CustomStringConvertible {
  
  /// Returns a debug description for the view.
  public var description: String {
    var ms = "<View[\(name)]:"
    
    if columns.isEmpty { ms += " NO-COLUMNS?" }
    else {
      for column in columns {
        ms += " "
        ms += column.description
      }
    }
    if creationSQL.isEmpty { ms += " NO-SQL" }
    ms += ">"
    return ms
  }
}
