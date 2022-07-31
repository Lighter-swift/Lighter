//
//  Created by Helge Heß.
//  Copyright © 2022 ZeeZide GmbH.
//

// Yes, this isn't particularily nice, but does the job. Keep in mind that
// code generators are evil and supposed to look that bad.
// - writeXYZ write the indent
// - appendXYZ do not write the indent

/**
 * A class that can convert a Swift AST tree into textual Swift code.
 */
public final class CodeGenerator {
  
  /// The configuration of the CodeGenerator.
  public struct Configuration: Equatable {
    
    /// How comments should be rendered.
    public enum CommentStyle: String {
      case dashes = "//", tripleDashes = "///"
      case stars  = "*",  doubleStars  = "**"
      case noComments = ""
    }
    
    /// How type comments should be rendered, by default `/**`.
    public var typeCommentStyle          : CommentStyle
    /// How function comments should be rendered, by default `/**`.
    public var functionCommentStyle      : CommentStyle
    /// How property comments should be rendered, by default `///`.
    public var propertyCommentStyle      : CommentStyle
    
    /// The string which is used for indentation, e.g. `"  "` or `"\t"`.
    public var indent                    : String
    /// The end of line marker, i.e. `\n`.
    public var eol                       : String
    /// How lists of identifiers are separated, `", "`.
    public var identifierListSeparator   : String
    /// The _suggested_ maximum line length. The generator will do its best, but
    /// no guarantees.
    public var lineLength                : Int
    /// Ignore ``FunctionDefinition/inlinable`` settings and never generate
    /// those. Useful for private modules.
    public var neverInline               = false
    /// `struct A : Identifiable`
    public var typeConformanceSeparator  = " : "
    /// `var x : Type`
    public var propertyTypeSeparator     = " : "
    /// `var x = 10`
    public var propertyValueSeparator    = " = "
    /// A header text inserted if there are multiple examples for e.g. a type.
    public var multiExampleSectionHeader =
    """
    
    ### Examples
    """
    /// A header text inserted if there are multiple SQL infos for e.g. a type.
    public var multiSQLSectionHeader =
    """
    
    ### SQL
    """

    /// Initialize the configuration.
    public init(typeCommentStyle        : CommentStyle = .doubleStars,
                functionCommentStyle    : CommentStyle = .doubleStars,
                propertyCommentStyle    : CommentStyle = .tripleDashes,
                indent                  : String = "  ",
                eol                     : String = "\n",
                identifierListSeparator : String = ", ",
                lineLength              : Int    = 80)
    {
      self.typeCommentStyle        = typeCommentStyle
      self.functionCommentStyle    = functionCommentStyle
      self.propertyCommentStyle    = propertyCommentStyle
      self.indent                  = indent
      self.eol                     = eol
      self.identifierListSeparator = identifierListSeparator
      self.lineLength              = lineLength
    }
  }
  
  /// The configuration of the code generation.
  public let configuration : Configuration
  
  /// The generated Swift source code.
  public       var source           = ""
  
  /// The current indentation level.
  private(set) var indentationLevel = 0
  
  /// Initialize a ``CodeGenerator`` for generation.
  public init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
    source.reserveCapacity(10_000)
  }
  
  /// Whether the ``source`` currently ends in a newline.
  var endsInEOL   : Bool { source.hasSuffix(configuration.eol) }
  /// Whether the ``source`` currently ends in a space.
  var endsInSpace : Bool { source.last == " " }
}

public extension CodeGenerator { // MARK: - Primitives

  /// Append a raw string to the ``source``.
  func append(_ string: String) {
    source += string
  }
  
  /// Append a newline to the ``source``.
  func appendEOL()            { append(configuration.eol) }
  /// Append a newline to the ``source`` if it doesn't have one already.
  func appendEOLIfMissing()   { if !endsInEOL { appendEOL() } }
  /// Append a space to the ``source`` if it doesn't have one already.
  func appendSpaceIfMissing() { if !endsInSpace { append(" ") } }

  /// Execute the closure with an increased indentation level.
  func indent(execute: () -> Void) {
    indentationLevel += 1
    execute()
    indentationLevel -= 1
  }
  
  /// Writes a code block, like:
  /// ```
  /// if a {
  ///   ...
  /// }
  /// ```
  func indentedCodeBlock(startSuffix       : String? = nil,
                         endSuffix         : String? = nil,
                         addSpaceIfMissing : Bool    = true,
                         execute: () -> Void) {
    // Later: could support "start on newline"
    if addSpaceIfMissing { appendSpaceIfMissing() }
    append("{")
    if let suffix = startSuffix { append(suffix) }
    else                        { appendEOL()    }
    indent(execute: execute)
    appendEOLIfMissing()
    if let endSuffix = endSuffix { appendIndent(); append("}\(endSuffix)") }
    else                         { writeln("}") }
  }

  /// Just writes the current indentation
  func appendIndent() {
    append(String(repeating: configuration.indent, count: indentationLevel))
  }

  /// Writes and indented line
  func writeln(_ line: String = "") {
    appendIndent()
    append(line)
    append(configuration.eol)
  }
  
  /// Splits the string by `\n` and writes each line with the given `prefix`.
  func writeLines(in string: String?, with prefix: String) {
    guard let string = string, !string.isEmpty else { return }
    let lines = string.split(separator: "\n", omittingEmptySubsequences: false)
    for line in lines {
      writeln(prefix + line)
    }
  }

  /// If the string contains a Swift reserved word (like `for`), backtick it.
  /// E.g. if a column name is the same like a Swift name.
  func tickedWhenReserved(_ string: String) -> String {
    SwiftReservedWords.contains(string) ? "`\(string)`" : string
  }
  
  /// Write the comment for a property or instance variable.
  func writePropertyComment(_ comment: String?) {
    // propertyCommentStyle
    let style = configuration.propertyCommentStyle
    guard style != .noComments                    else { return }
    guard let comment = comment, !comment.isEmpty else { return }
    
    let lines = comment.split(separator: "\n", omittingEmptySubsequences: false)
    
    let linePrefix : String
    switch style {
      case .stars, .doubleStars : linePrefix = " * "
      case .dashes              : linePrefix = "// "
      case .tripleDashes        : linePrefix = "/// "
      case .noComments          : linePrefix = ""
    }
    switch style { // start
      case .stars       : writeln("/*")
      case .doubleStars : writeln("/**")
      case .dashes, .tripleDashes, .noComments: break
    }

    for line in lines {
      writeln(linePrefix + line)
    }
    
    switch style { // end
      case .stars, .doubleStars: writeln(" */")
      case .dashes, .tripleDashes, .noComments: break
    }
  }
}

extension CodeGenerator.Configuration.CommentStyle: CustomStringConvertible {

  /// A string describing the comment style.
  public var description: String {
    switch self {
      case .dashes       : return "//"
      case .tripleDashes : return "///"
      case .stars        : return "/* */"
      case .doubleStars  : return "/****/"
      case .noComments   : return "-"
    }
  }
}
