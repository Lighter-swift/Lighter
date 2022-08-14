# Troubleshooting

When the plugin doesn't generate.

## Overview

A few things to try:
- Update the Lighter package.
- Make sure Enlighter is added to the build phases as the right plugin.
- Make sure the database and/or SQL files are _within_ the project,
  the plugin can only access files within its sandbox.
- If the database isn't available at runtime, make sure it is added as an
  Xcode resources and actually gets copied to the application bundle.

### Logfile

Enlighter writes a log to `/tmp/zzdebug.log`, which can be helpful to analyze
issues.

### sqlite2swift

The `sqlite2swift` tool is what gets eventually run, and it can be run
as a standalone tool.

The arguments:
- 1st argument:    The <doc:Configuration> or `-` if there is none.
- 2nd argument:    The name of the target the code is generated for, this is
                   used to resolve configuration options in the file.
- other arguments: The database/SQL input files.
- last argument:   The Swift output file.

### Debug Lighter itself

To debug Lighter itself, the git repository can be cloned (e.g. the `develop`
branch). To add that to an own project which already has Lighter as a network
reference, just drag the checked out Lighter folder into the project.
It'll override the network reference and make the package locally editable.

### Filing Issues

Issues with the software can be filed against the public GitHub repository:
[Lighter Issues](https://github.com/Lighter-swift/Lighter/issues).
