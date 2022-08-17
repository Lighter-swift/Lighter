// Autocreated by GenerateInternalVariadics at 2022-08-17T15:57:10Z

public extension SQLDatabaseFetchOperations {
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ C.Value ]
    where C: SQLColumn, T == C.T, P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ C.Value ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T, P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ C.Value ]
    where C: SQLColumn, CS: SQLColumn, T == C.T, T == CS.T, P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ C.Value ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ C.Value ]
    where
      C: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ C.Value ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    _ limit: Int? = nil
  ) throws -> [ C.Value ]
    where C: SQLColumn, T == C.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ C.Value ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where C1: SQLColumn, C2: SQLColumn, C3: SQLColumn, T == C1.T, T == C2.T, T == C3.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ C.Value ]
    where C: SQLColumn, CS: SQLColumn, T == C.T, T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ C.Value ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where C1: SQLColumn, C2: SQLColumn, CS: SQLColumn, T == C1.T, T == C2.T, T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness,
   *            orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ C.Value ]
    where C: SQLColumn, CS1: SQLColumn, CS2: SQLColumn, T == C.T, T == CS1.T, T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ C.Value ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness,
   *            orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
      )
    }
    return records
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
    try fetch(sql, builder.bindings) { ( stmt, _ ) in
      records.append(
        ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
      )
    }
    return records
  }
}

#if swift(>=5.5)
#if canImport(_Concurrency)
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension SQLDatabaseAsyncFetchOperations {
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ C.Value ]
    where C: SQLColumn, T == C.T, P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ C.Value ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T, P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ C.Value ]
    where C: SQLColumn, CS: SQLColumn, T == C.T, T == CS.T, P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ C.Value ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, CS, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      T == CS.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ C.Value ]
    where
      C: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ C.Value ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   *   - predicate: A closure that returns the predicate used for filtering. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, CS1, CS2, P>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil,
    `where` predicate: ( T.Schema ) -> P
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      T == CS1.T,
      T == CS2.T,
      P: SQLPredicate
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: predicate(T.schema))
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    _ limit: Int? = nil
  ) async throws -> [ C.Value ]
    where C: SQLColumn, T == C.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ C.Value ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where C1: SQLColumn, C2: SQLColumn, C3: SQLColumn, T == C1.T, T == C2.T, T == C3.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ C.Value ]
    where C: SQLColumn, CS: SQLColumn, T == C.T, T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ C.Value ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where C1: SQLColumn, C2: SQLColumn, CS: SQLColumn, T == C1.T, T == C2.T, T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness,
   *                  orderBy: \.personId) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, CS>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    orderBy sortColumn: KeyPath<T.Schema, CS>,
    _ direction: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      CS: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      T == CS.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.addSort(sortColumn, direction)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column: The 1st selected column. E.g. `\.personId`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ C.Value ]
    where C: SQLColumn, CS1: SQLColumn, CS2: SQLColumn, T == C.T, T == CS1.T, T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ C.Value ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(try C.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0))
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * Example:
   * ```swift
   * let records = try await select(from: \.person, \.personId, \.lastname, \.city, \.street, \.leetness,
   *                  orderBy: \.personId.descending, \.lastname, .ascending) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4) )
        )
      }
      return records
    }
  }
  
  /**
   * Select columns from a SQL table or view in a typesafe way.
   * 
   * - Parameters:
   *   - tableOrView: A keypath to the table/view to fetch from e.g. `\.person`.
   *   - column1: The 1st selected column. E.g. `\.personId`.
   *   - column2: The 2nd selected column. E.g. `\.lastname`.
   *   - column3: The 3rd selected column. E.g. `\.city`.
   *   - column4: The 4th selected column. E.g. `\.street`.
   *   - column5: The 5th selected column. E.g. `\.leetness`.
   *   - column6: The 6th selected column.
   *   - limit: An optional limit on the number of records returned.
   *   - sortColumn1: The 1st column the result is sorted by. E.g. `\.personId`.
   *   - direction1: The sort direction for the column (`.ascending`/`.descending`).
   *   - sortColumn2: The 2nd column the result is sorted by. E.g. `\.lastname`.
   *   - direction2: The sort direction for the column (`.ascending`/`.descending`).
   * - Returns: Returns an array of tuples for each requested row.
   */
  @inlinable
  func select<T, C1, C2, C3, C4, C5, C6, CS1, CS2>(
    from tableOrView: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    orderBy sortColumn1: KeyPath<T.Schema, CS1>,
    _ direction1: SQLSortOrder = .ascending,
    _ sortColumn2: KeyPath<T.Schema, CS2>,
    _ direction2: SQLSortOrder = .ascending,
    _ limit: Int? = nil
  ) async throws -> [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]
    where
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      CS1: SQLColumn,
      CS2: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      T == CS1.T,
      T == CS2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.addSort(sortColumn1, direction1)
    builder.addSort(sortColumn2, direction2)
    let sql = builder.generateSelect(limit: limit, predicate: SQLTruePredicate.shared)
    return try await runOnDatabaseQueue() {
      var records = [ ( column1: C1.Value, column2: C2.Value, column3: C3.Value, column4: C4.Value, column5: C5.Value, column6: C6.Value ) ]()
      try fetch(sql, builder.bindings) { ( stmt, _ ) in
        records.append(
          ( try C1.Value.init(unsafeSQLite3StatementHandle: stmt, column: 0), try C2.Value.init(unsafeSQLite3StatementHandle: stmt, column: 1), try C3.Value.init(unsafeSQLite3StatementHandle: stmt, column: 2), try C4.Value.init(unsafeSQLite3StatementHandle: stmt, column: 3), try C5.Value.init(unsafeSQLite3StatementHandle: stmt, column: 4), try C6.Value.init(unsafeSQLite3StatementHandle: stmt, column: 5) )
        )
      }
      return records
    }
  }
}
#endif // required canImports
#endif // swift(>=5.5)

public extension SQLDatabaseChangeOperations {
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10, where: \.personId, is: 10)
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column: The 1st column to update. E.g. `\.personId`.
   *   - value: The value to update the column with.
   *   - key: A keypath to a column used to qualify the update e.g. `\.personId`.
   *   - id: The value the key has to have to make the update apply, e.g. `10`.
   */
  @inlinable
  func update<T, C, PK>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column: KeyPath<T.Schema, C>,
    to value: C.Value,
    `where` key: KeyPath<T.Schema, PK>,
    `is` id: PK.Value
  ) throws
    where T: SQLTableRecord, C: SQLColumn, T == C.T, PK: SQLColumn, T == PK.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value,
      where: T.schema[keyPath: key] == id
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10, set: \.lastname, to: "Duck", where: \.personId, is: 10)
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - key: A keypath to a column used to qualify the update e.g. `\.personId`.
   *   - id: The value the key has to have to make the update apply, e.g. `10`.
   */
  @inlinable
  func update<T, C1, C2, PK>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `where` key: KeyPath<T.Schema, PK>,
    `is` id: PK.Value
  ) throws
    where
      T: SQLTableRecord,
      C1: SQLColumn,
      C2: SQLColumn,
      T == C1.T,
      T == C2.T,
      PK: SQLColumn,
      T == PK.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2,
      where: T.schema[keyPath: key] == id
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10, set: \.lastname, to: "Duck", set: \.city, to: "Entenhausen", where: \.personId, is: 10)
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - column3: The 3rd column to update. E.g. `\.city`.
   *   - value3: The value to update the column with.
   *   - key: A keypath to a column used to qualify the update e.g. `\.personId`.
   *   - id: The value the key has to have to make the update apply, e.g. `10`.
   */
  @inlinable
  func update<T, C1, C2, C3, PK>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `set` column3: KeyPath<T.Schema, C3>,
    to value3: C3.Value,
    `where` key: KeyPath<T.Schema, PK>,
    `is` id: PK.Value
  ) throws
    where
      T: SQLTableRecord,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      PK: SQLColumn,
      T == PK.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2, value3,
      where: T.schema[keyPath: key] == id
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10, set: \.lastname, to: "Duck", set: \.city, to: "Entenhausen", set: \.street, to: "Am Geldspeicher 1", where: \.personId, is: 10)
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - column3: The 3rd column to update. E.g. `\.city`.
   *   - value3: The value to update the column with.
   *   - column4: The 4th column to update. E.g. `\.street`.
   *   - value4: The value to update the column with.
   *   - key: A keypath to a column used to qualify the update e.g. `\.personId`.
   *   - id: The value the key has to have to make the update apply, e.g. `10`.
   */
  @inlinable
  func update<T, C1, C2, C3, C4, PK>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `set` column3: KeyPath<T.Schema, C3>,
    to value3: C3.Value,
    `set` column4: KeyPath<T.Schema, C4>,
    to value4: C4.Value,
    `where` key: KeyPath<T.Schema, PK>,
    `is` id: PK.Value
  ) throws
    where
      T: SQLTableRecord,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      PK: SQLColumn,
      T == PK.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2, value3, value4,
      where: T.schema[keyPath: key] == id
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10, set: \.lastname, to: "Duck", set: \.city, to: "Entenhausen", set: \.street, to: "Am Geldspeicher 1", set: \.leetness, to: 1337, where: \.personId, is: 10)
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - column3: The 3rd column to update. E.g. `\.city`.
   *   - value3: The value to update the column with.
   *   - column4: The 4th column to update. E.g. `\.street`.
   *   - value4: The value to update the column with.
   *   - column5: The 5th column to update. E.g. `\.leetness`.
   *   - value5: The value to update the column with.
   *   - key: A keypath to a column used to qualify the update e.g. `\.personId`.
   *   - id: The value the key has to have to make the update apply, e.g. `10`.
   */
  @inlinable
  func update<T, C1, C2, C3, C4, C5, PK>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `set` column3: KeyPath<T.Schema, C3>,
    to value3: C3.Value,
    `set` column4: KeyPath<T.Schema, C4>,
    to value4: C4.Value,
    `set` column5: KeyPath<T.Schema, C5>,
    to value5: C5.Value,
    `where` key: KeyPath<T.Schema, PK>,
    `is` id: PK.Value
  ) throws
    where
      T: SQLTableRecord,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      PK: SQLColumn,
      T == PK.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2, value3, value4, value5,
      where: T.schema[keyPath: key] == id
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - column3: The 3rd column to update. E.g. `\.city`.
   *   - value3: The value to update the column with.
   *   - column4: The 4th column to update. E.g. `\.street`.
   *   - value4: The value to update the column with.
   *   - column5: The 5th column to update. E.g. `\.leetness`.
   *   - value5: The value to update the column with.
   *   - column6: The 6th column to update.
   *   - value6: The value to update the column with.
   *   - key: A keypath to a column used to qualify the update e.g. `\.personId`.
   *   - id: The value the key has to have to make the update apply, e.g. `10`.
   */
  @inlinable
  func update<T, C1, C2, C3, C4, C5, C6, PK>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `set` column3: KeyPath<T.Schema, C3>,
    to value3: C3.Value,
    `set` column4: KeyPath<T.Schema, C4>,
    to value4: C4.Value,
    `set` column5: KeyPath<T.Schema, C5>,
    to value5: C5.Value,
    `set` column6: KeyPath<T.Schema, C6>,
    to value6: C6.Value,
    `where` key: KeyPath<T.Schema, PK>,
    `is` id: PK.Value
  ) throws
    where
      T: SQLTableRecord,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T,
      PK: SQLColumn,
      T == PK.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2, value3, value4, value5, value6,
      where: T.schema[keyPath: key] == id
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column: The 1st column to update. E.g. `\.personId`.
   *   - value: The value to update the column with.
   *   - predicate: A closure that returns the predicate to select the records to update. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   */
  @inlinable
  func update<T, C, P>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column: KeyPath<T.Schema, C>,
    to value: C.Value,
    `where` predicate: ( T.Schema ) -> P
  ) throws
    where T: SQLTableRecord, P: SQLPredicate, C: SQLColumn, T == C.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value,
      where: predicate(T.schema)
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10, set: \.lastname, to: "Duck") {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - predicate: A closure that returns the predicate to select the records to update. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   */
  @inlinable
  func update<T, C1, C2, P>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `where` predicate: ( T.Schema ) -> P
  ) throws
    where
      T: SQLTableRecord,
      P: SQLPredicate,
      C1: SQLColumn,
      C2: SQLColumn,
      T == C1.T,
      T == C2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2,
      where: predicate(T.schema)
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10, set: \.lastname, to: "Duck", set: \.city, to: "Entenhausen") {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - column3: The 3rd column to update. E.g. `\.city`.
   *   - value3: The value to update the column with.
   *   - predicate: A closure that returns the predicate to select the records to update. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   */
  @inlinable
  func update<T, C1, C2, C3, P>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `set` column3: KeyPath<T.Schema, C3>,
    to value3: C3.Value,
    `where` predicate: ( T.Schema ) -> P
  ) throws
    where
      T: SQLTableRecord,
      P: SQLPredicate,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2, value3,
      where: predicate(T.schema)
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10, set: \.lastname, to: "Duck", set: \.city, to: "Entenhausen", set: \.street, to: "Am Geldspeicher 1") {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - column3: The 3rd column to update. E.g. `\.city`.
   *   - value3: The value to update the column with.
   *   - column4: The 4th column to update. E.g. `\.street`.
   *   - value4: The value to update the column with.
   *   - predicate: A closure that returns the predicate to select the records to update. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   */
  @inlinable
  func update<T, C1, C2, C3, C4, P>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `set` column3: KeyPath<T.Schema, C3>,
    to value3: C3.Value,
    `set` column4: KeyPath<T.Schema, C4>,
    to value4: C4.Value,
    `where` predicate: ( T.Schema ) -> P
  ) throws
    where
      T: SQLTableRecord,
      P: SQLPredicate,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2, value3, value4,
      where: predicate(T.schema)
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try update(\.person, set: \.personId, to: 10, set: \.lastname, to: "Duck", set: \.city, to: "Entenhausen", set: \.street, to: "Am Geldspeicher 1", set: \.leetness, to: 1337) {
   *   \.personId == 10 && \.lastname.hasPrefix("D")
   * }
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - column3: The 3rd column to update. E.g. `\.city`.
   *   - value3: The value to update the column with.
   *   - column4: The 4th column to update. E.g. `\.street`.
   *   - value4: The value to update the column with.
   *   - column5: The 5th column to update. E.g. `\.leetness`.
   *   - value5: The value to update the column with.
   *   - predicate: A closure that returns the predicate to select the records to update. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   */
  @inlinable
  func update<T, C1, C2, C3, C4, C5, P>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `set` column3: KeyPath<T.Schema, C3>,
    to value3: C3.Value,
    `set` column4: KeyPath<T.Schema, C4>,
    to value4: C4.Value,
    `set` column5: KeyPath<T.Schema, C5>,
    to value5: C5.Value,
    `where` predicate: ( T.Schema ) -> P
  ) throws
    where
      T: SQLTableRecord,
      P: SQLPredicate,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2, value3, value4, value5,
      where: predicate(T.schema)
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Update columns in a SQL table in a typesafe way.
   * 
   * - Parameters:
   *   - table: A keypath to the table to update e.g. `\.person`.
   *   - column1: The 1st column to update. E.g. `\.personId`.
   *   - value1: The value to update the column with.
   *   - column2: The 2nd column to update. E.g. `\.lastname`.
   *   - value2: The value to update the column with.
   *   - column3: The 3rd column to update. E.g. `\.city`.
   *   - value3: The value to update the column with.
   *   - column4: The 4th column to update. E.g. `\.street`.
   *   - value4: The value to update the column with.
   *   - column5: The 5th column to update. E.g. `\.leetness`.
   *   - value5: The value to update the column with.
   *   - column6: The 6th column to update.
   *   - value6: The value to update the column with.
   *   - predicate: A closure that returns the predicate to select the records to update. The first argument is the schema of the associated record. E.g. `{ $0.personId == 10 }`.
   */
  @inlinable
  func update<T, C1, C2, C3, C4, C5, C6, P>(
    _ table: KeyPath<Self.RecordTypes, T.Type>,
    `set` column1: KeyPath<T.Schema, C1>,
    to value1: C1.Value,
    `set` column2: KeyPath<T.Schema, C2>,
    to value2: C2.Value,
    `set` column3: KeyPath<T.Schema, C3>,
    to value3: C3.Value,
    `set` column4: KeyPath<T.Schema, C4>,
    to value4: C4.Value,
    `set` column5: KeyPath<T.Schema, C5>,
    to value5: C5.Value,
    `set` column6: KeyPath<T.Schema, C6>,
    to value6: C6.Value,
    `where` predicate: ( T.Schema ) -> P
  ) throws
    where
      T: SQLTableRecord,
      P: SQLPredicate,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.generateUpdate(
      T.Schema.externalName,
      set: value1, value2, value3, value4, value5, value6,
      where: predicate(T.schema)
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Insert a record into a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try insert(into: \.person, \.personId, values: 10)
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to fill e.g. `\.person`.
   *   - column: The 1st column of the new record. E.g. `\.personId`.
   *   - value: The 1st value of the new record. E.g. `10`.
   */
  @inlinable
  func insert<T, C>(
    into table: KeyPath<Self.RecordTypes, T.Type>,
    _ column: KeyPath<T.Schema, C>,
    values value: C.Value
  ) throws
    where T: SQLTableRecord, C: SQLColumn, T == C.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column)
    builder.generateInsert(into: T.Schema.externalName, values: value)
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Insert a record into a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try insert(into: \.person, \.personId, \.lastname, values: 10, "Duck")
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to fill e.g. `\.person`.
   *   - column1: The 1st column of the new record. E.g. `\.personId`.
   *   - column2: The 2nd column of the new record. E.g. `\.lastname`.
   *   - value1: The 1st value of the new record. E.g. `10`.
   *   - value2: The 2nd value of the new record. E.g. `"Duck"`.
   */
  @inlinable
  func insert<T, C1, C2>(
    into table: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    values value1: C1.Value,
    _ value2: C2.Value
  ) throws
    where T: SQLTableRecord, C1: SQLColumn, C2: SQLColumn, T == C1.T, T == C2.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.generateInsert(into: T.Schema.externalName, values: value1, value2)
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Insert a record into a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try insert(into: \.person, \.personId, \.lastname, \.city, values: 10, "Duck", "Entenhausen")
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to fill e.g. `\.person`.
   *   - column1: The 1st column of the new record. E.g. `\.personId`.
   *   - column2: The 2nd column of the new record. E.g. `\.lastname`.
   *   - column3: The 3rd column of the new record. E.g. `\.city`.
   *   - value1: The 1st value of the new record. E.g. `10`.
   *   - value2: The 2nd value of the new record. E.g. `"Duck"`.
   *   - value3: The 3rd value of the new record. E.g. `"Entenhausen"`.
   */
  @inlinable
  func insert<T, C1, C2, C3>(
    into table: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    values value1: C1.Value,
    _ value2: C2.Value,
    _ value3: C3.Value
  ) throws
    where
      T: SQLTableRecord,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.generateInsert(
      into: T.Schema.externalName,
      values: value1, value2, value3
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Insert a record into a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try insert(into: \.person, \.personId, \.lastname, \.city, \.street, values: 10, "Duck", "Entenhausen", "Am Geldspeicher 1")
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to fill e.g. `\.person`.
   *   - column1: The 1st column of the new record. E.g. `\.personId`.
   *   - column2: The 2nd column of the new record. E.g. `\.lastname`.
   *   - column3: The 3rd column of the new record. E.g. `\.city`.
   *   - column4: The 4th column of the new record. E.g. `\.street`.
   *   - value1: The 1st value of the new record. E.g. `10`.
   *   - value2: The 2nd value of the new record. E.g. `"Duck"`.
   *   - value3: The 3rd value of the new record. E.g. `"Entenhausen"`.
   *   - value4: The 4th value of the new record. E.g. `"Am Geldspeicher 1"`.
   */
  @inlinable
  func insert<T, C1, C2, C3, C4>(
    into table: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    values value1: C1.Value,
    _ value2: C2.Value,
    _ value3: C3.Value,
    _ value4: C4.Value
  ) throws
    where
      T: SQLTableRecord,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.generateInsert(
      into: T.Schema.externalName,
      values: value1, value2, value3, value4
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Insert a record into a SQL table in a typesafe way.
   * 
   * Example:
   * ```swift
   * try insert(into: \.person, \.personId, \.lastname, \.city, \.street, \.leetness, values: 10, "Duck", "Entenhausen", "Am Geldspeicher 1", 1337)
   * ```
   * 
   * - Parameters:
   *   - table: A keypath to the table to fill e.g. `\.person`.
   *   - column1: The 1st column of the new record. E.g. `\.personId`.
   *   - column2: The 2nd column of the new record. E.g. `\.lastname`.
   *   - column3: The 3rd column of the new record. E.g. `\.city`.
   *   - column4: The 4th column of the new record. E.g. `\.street`.
   *   - column5: The 5th column of the new record. E.g. `\.leetness`.
   *   - value1: The 1st value of the new record. E.g. `10`.
   *   - value2: The 2nd value of the new record. E.g. `"Duck"`.
   *   - value3: The 3rd value of the new record. E.g. `"Entenhausen"`.
   *   - value4: The 4th value of the new record. E.g. `"Am Geldspeicher 1"`.
   *   - value5: The 5th value of the new record. E.g. `1337`.
   */
  @inlinable
  func insert<T, C1, C2, C3, C4, C5>(
    into table: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    values value1: C1.Value,
    _ value2: C2.Value,
    _ value3: C3.Value,
    _ value4: C4.Value,
    _ value5: C5.Value
  ) throws
    where
      T: SQLTableRecord,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.generateInsert(
      into: T.Schema.externalName,
      values: value1, value2, value3, value4, value5
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
  
  /**
   * Insert a record into a SQL table in a typesafe way.
   * 
   * - Parameters:
   *   - table: A keypath to the table to fill e.g. `\.person`.
   *   - column1: The 1st column of the new record. E.g. `\.personId`.
   *   - column2: The 2nd column of the new record. E.g. `\.lastname`.
   *   - column3: The 3rd column of the new record. E.g. `\.city`.
   *   - column4: The 4th column of the new record. E.g. `\.street`.
   *   - column5: The 5th column of the new record. E.g. `\.leetness`.
   *   - column6: The 6th column of the new record.
   *   - value1: The 1st value of the new record. E.g. `10`.
   *   - value2: The 2nd value of the new record. E.g. `"Duck"`.
   *   - value3: The 3rd value of the new record. E.g. `"Entenhausen"`.
   *   - value4: The 4th value of the new record. E.g. `"Am Geldspeicher 1"`.
   *   - value5: The 5th value of the new record. E.g. `1337`.
   *   - value6: The 6th value of the new record.
   */
  @inlinable
  func insert<T, C1, C2, C3, C4, C5, C6>(
    into table: KeyPath<Self.RecordTypes, T.Type>,
    _ column1: KeyPath<T.Schema, C1>,
    _ column2: KeyPath<T.Schema, C2>,
    _ column3: KeyPath<T.Schema, C3>,
    _ column4: KeyPath<T.Schema, C4>,
    _ column5: KeyPath<T.Schema, C5>,
    _ column6: KeyPath<T.Schema, C6>,
    values value1: C1.Value,
    _ value2: C2.Value,
    _ value3: C3.Value,
    _ value4: C4.Value,
    _ value5: C5.Value,
    _ value6: C6.Value
  ) throws
    where
      T: SQLTableRecord,
      C1: SQLColumn,
      C2: SQLColumn,
      C3: SQLColumn,
      C4: SQLColumn,
      C5: SQLColumn,
      C6: SQLColumn,
      T == C1.T,
      T == C2.T,
      T == C3.T,
      T == C4.T,
      T == C5.T,
      T == C6.T
  {
    var builder = SQLBuilder<T>()
    builder.addColumn(column1)
    builder.addColumn(column2)
    builder.addColumn(column3)
    builder.addColumn(column4)
    builder.addColumn(column5)
    builder.addColumn(column6)
    builder.generateInsert(
      into: T.Schema.externalName,
      values: value1, value2, value3, value4, value5, value6
    )
    try execute(builder.sql, builder.bindings, readOnly: false)
  }
}
