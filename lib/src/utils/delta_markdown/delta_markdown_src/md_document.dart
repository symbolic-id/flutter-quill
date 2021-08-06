// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'md_ast.dart';
import 'md_block_parser.dart';
import 'md_extension_set.dart';
import 'md_inline_parser.dart';

/// Maintains the context needed to parse a Markdown document.
class MDDocument {
  MDDocument({
    Iterable<MDBlockSyntax>? blockSyntaxes,
    Iterable<MDInlineSyntax>? inlineSyntaxes,
    MDExtensionSet? extensionSet,
    this.linkResolver,
    this.imageLinkResolver,
  }) : extensionSet = extensionSet ?? MDExtensionSet.commonMark {
    _blockSyntaxes
      ..addAll(blockSyntaxes ?? [])
      ..addAll(this.extensionSet.blockSyntaxes);
    _inlineSyntaxes
      ..addAll(inlineSyntaxes ?? [])
      ..addAll(this.extensionSet.inlineSyntaxes);
  }

  final Map<String, MDLinkReference> linkReferences = <String, MDLinkReference>{};
  final MDExtensionSet extensionSet;
  final Resolver? linkResolver;
  final Resolver? imageLinkResolver;
  final _blockSyntaxes = <MDBlockSyntax>{};
  final _inlineSyntaxes = <MDInlineSyntax>{};

  Iterable<MDBlockSyntax> get blockSyntaxes => _blockSyntaxes;
  Iterable<MDInlineSyntax> get inlineSyntaxes => _inlineSyntaxes;

  /// Parses the given [lines] of Markdown to a series of AST nodes.
  List<MDNode> parseLines(List<String> lines) {
    final nodes = MDBlockParser(lines, this).parseLines();
    // Make sure to mark the top level nodes as such.
    for (final n in nodes) {
      n.isToplevel = true;
    }
    _parseInlineContent(nodes);
    return nodes;
  }

  /// Parses the given inline Markdown [text] to a series of AST nodes.
  List<MDNode>? parseInline(String text) => MDInlineParser(text, this).parse();

  void _parseInlineContent(List<MDNode> nodes) {
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node is UnparsedContent) {
        final inlineNodes = parseInline(node.textContent)!;
        nodes
          ..removeAt(i)
          ..insertAll(i, inlineNodes);
        i += inlineNodes.length - 1;
      } else if (node is MDElement && node.children != null) {
        _parseInlineContent(node.children!);
      }
    }
  }
}

/// A [link reference
/// definition](http://spec.commonmark.org/0.28/#link-reference-definitions).
class MDLinkReference {
  /// Construct a [MDLinkReference], with all necessary fields.
  ///
  /// If the parsed link reference definition does not include a title, use
  /// `null` for the [title] parameter.
  MDLinkReference(this.label, this.destination, this.title);

  /// The [link label](http://spec.commonmark.org/0.28/#link-label).
  ///
  /// Temporarily, this class is also being used to represent the link data for
  /// an inline link (the destination and title), but this should change before
  /// the package is released.
  final String label;

  /// The [link destination](http://spec.commonmark.org/0.28/#link-destination).
  final String destination;

  /// The [link title](http://spec.commonmark.org/0.28/#link-title).
  final String title;
}
