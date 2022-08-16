# Manual Generation

How to generate Lighter content by hand.

## Overview

The easiest way to use Lighter is to use the "Enlighter" build tool plugin
which is automatically run by Swift Package Manager or Xcode (14+) if the
database files change.
But if that isn't an option (e.g. Xcode 14 can't be used yet), Lighter
provides a set of options to do it otherwise.


### Using the "Generate Code for SQLite" command plugin.

Command plugins are new Swift 5.6 feature that allows running commands embedded
in packages manually (vs automatically as with "build tool plugins" like 
Enlighter).

"Generate Code for SQLite" is a command plugin which looks at the database/SQL 
files just like Enlighter and produces Swift files for them. Unlike Enlighter
it doesn't write them into the build path, but into the sources of the project
or package (SPM/Xcode is prompting to allow for that).

In Xcode 14 the plugin can be run from the "File / Packages / Plugin" menu.
Note that Xcode 14 is only needed at generation time for that. Afterwards the
file can be checked into the repository as source code.

Even with Xcode 13 the command plugin can be run using swift on the commandline.

> Note: Unless working on packages, Xcode doesn't automatically add the
>       generate Swift file. 
>       So on first run, one may need to look into the filesystem and drag the
>       generated file into the project.


### Using the "Code for SQLite3" Application

[“Code for SQLite3” application](https://apps.apple.com/us/app/code-for-sqlite3/id1638111010)
is a macOS app that does the same like the “`swift2sqlite3`” tool, but as an app.
It can be useful to play w/ the Lighter options and to manually generate the
code.

Just drag the database files into the app, and it'll generate the Swift code.
Which can then be copy/pasted into the Xcode project.


### Using the `sqlite2swift` tool manually

This is a useful option if Swift 5.6 is not yet available in a CI environment,
but the code should be automatically generated. The tool can be added as a
traditional script phase to a project.

The arguments:
- 1st argument:    The <doc:Configuration> or `-` if there is none.
- 2nd argument:    The name of the target the code is generated for, this is
                   used to resolve configuration options in the file.
- other arguments: The database/SQL input files.
- last argument:   The Swift output file.

`sqlite2swift` is shipped as a tool product in the Lighter package, and should
compile with Swift 5.0 and beyond.
