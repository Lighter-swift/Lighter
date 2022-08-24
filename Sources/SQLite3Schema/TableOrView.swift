//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  #if swift(>=5.6)
    import func Darwin.strcasestr
  #else
    import func Darwin.strstr
  #endif
#elseif canImport(Glibc)
  import func Glibc.strstr
#else
  import Foundation
#endif

import func SQLite3.sqlite3_libversion_number

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

    /// Whether the table is a "WITHOUT ROWID" table.
    ///
    /// This only scans the ``creationSQL`` for the "WITHOUT" "ROWID" words,
    /// i.e. will fail if the table itself uses those :-)
    ///
    /// https://www.sqlite.org/withoutrowid.html
    /// - `WITHOUT ROWID` tables *MUST* have a primary key, and it must be
    ///    NOT NULL.
    /// - No special INTEGER pkey behaviours.
    /// - No `AUTOINCREMENT`.
    /// - Introduced in SQLite 3.8.2 (2013-12-06)
    @inlinable
    public var isTableWithoutRowID : Bool {
      // Introduced in 3.8.2 (2013-12-06)
      guard sqlite3_libversion_number() >= 30_08_002 else { return false }
      
      #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && swift(>=5.6)
        return info.sql.withCString { cstr in
          guard strcasestr(cstr, "WITHOUT") != nil else { return false }
          guard strcasestr(cstr, "ROWID")   != nil else { return false }
          return true
        }
      #else // Linux etc
        let s = info.sql.uppercased() // no strcasestr on Linux
        return s.withCString { cstr in
          guard strstr(cstr, "WITHOUT") != nil else { return false }
          guard strstr(cstr, "ROWID")   != nil else { return false }
          return true
        }
      #endif
    }


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
    
    if isTableWithoutRowID { ms += " without-rowid" }
    
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
