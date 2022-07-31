<h2>Generate Code for SQLite (Command Plugin)
  <img src="https://zeezide.com/img/lighter/Lighter256.png"
       align="right" width="64" height="64" />
</h2>

A SwiftPM command plugin that searches for SQLite databases and `.sql` files
within the selected targets, and then generates Swift sources to use those
databases.

The databases can be copied as a resource, but don't have to be. This looks at
all database/SQL files, unless contained in a `NoSQL` directory.

The generated Swift database types are grouped by the stem within a target.
E.g. a target could contain:

  ContactsDB.01.create.sql
  ContactsDB.02.setup-indices.sql
  ContactsDB.03.migrate-to-v3.sql
  ContactsDB.04.migrate-to-v4.sql
  TodosDB.db
  
This will create two Swift database types: `ContactsDB` and `TodosDB`.
Within the group the files are sorted by name and executed in that order to
produces the actual database.

Command plugins can be triggered from the "File / Packages" menu,
from the context menu on the package entry in the "Project Navigator",
or on the commandline, e.g.:
```bash
swift package plugin \
  --allow-writing-to-package-directory \
  sqlite2swift \
  --target ContactsTestDB
```
Note: The commandline name is `sqlite2swift`.

The function can be configured using a `Lighter.json` config file in the
package root.

Alongside this there is the `Enlighter` build tool plugin, which can generate
the wrapper code automatically.
This command plugin tool does it manually and directly generates into the
`Sources/target/dbname.swift` file!


### Who

Lighter is brought to you by
[Helge Heß](https://github.com/helje5/) / [ZeeZide](https://zeezide.de).
We like feedback, GitHub stars, cool contract work, 
presumably any form of praise you can think of.
