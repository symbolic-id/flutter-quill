import 'md_block_parser.dart';
import 'md_inline_parser.dart';

/// ExtensionSets provide a simple grouping mechanism for common Markdown
/// flavors.
///
/// For example, the [gitHubFlavored] set of syntax extensions allows users to
/// output HTML from their Markdown in a similar fashion to GitHub's parsing.
class MDExtensionSet {
  MDExtensionSet(this.blockSyntaxes, this.inlineSyntaxes);

  /// The [MDExtensionSet.none] extension set renders Markdown similar to
  /// [Markdown.pl].
  ///
  /// However, this set does not render _exactly_ the same as Markdown.pl;
  /// rather it is more-or-less the CommonMark standard of Markdown, without
  /// fenced code blocks, or inline HTML.
  ///
  /// [Markdown.pl]: http://daringfireball.net/projects/markdown/syntax
  static final MDExtensionSet none = MDExtensionSet([], []);

  /// The [commonMark] extension set is close to compliance with [CommonMark].
  ///
  /// [CommonMark]: http://commonmark.org/
  static final MDExtensionSet commonMark =
  MDExtensionSet([const MDFencedCodeBlockSyntax()], [MDInlineHtmlSyntax()]);

  /// The [gitHubWeb] extension set renders Markdown similarly to GitHub.
  ///
  /// This is different from the [gitHubFlavored] extension set in that GitHub
  /// actually renders HTML different from straight [GitHub flavored Markdown].
  ///
  /// (The only difference currently is that [gitHubWeb] renders headers with
  /// linkable IDs.)
  ///
  /// [GitHub flavored Markdown]: https://github.github.com/gfm/
  static final MDExtensionSet gitHubWeb = MDExtensionSet([
    const MDFencedCodeBlockSyntax(),
    const MDHeaderWithIdSyntax(),
    const SetextHeaderWithIdSyntax(),
    const MDTableSyntax()
  ], [
    MDInlineHtmlSyntax(),
    MDStrikethroughSyntax(),
    MDEmojiSyntax(),
    MDAutolinkExtensionSyntax(),
  ]);

  /// The [gitHubFlavored] extension set is close to compliance with the [GitHub
  /// flavored Markdown spec].
  ///
  /// [GitHub flavored Markdown]: https://github.github.com/gfm/
  static final MDExtensionSet gitHubFlavored = MDExtensionSet([
    const MDFencedCodeBlockSyntax(),
    const MDTableSyntax()
  ], [
    MDInlineHtmlSyntax(),
    MDStrikethroughSyntax(),
    MDAutolinkExtensionSyntax(),
  ]);

  final List<MDBlockSyntax> blockSyntaxes;
  final List<MDInlineSyntax> inlineSyntaxes;
}
