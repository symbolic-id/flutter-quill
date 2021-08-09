import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../../../../flutter_quill.dart';
import '../../../models/documents/nodes/block.dart';
import '../../../models/documents/nodes/line.dart';
import '../../../utils/color.dart';
import '../../../utils/sym_regex.dart';
import '../../cursor.dart';
import '../../delegate.dart';
import '../../text_block.dart';
import '../../text_line.dart';
import '../sym_editors/default_sym_embed_builder.dart';
import '../sym_text.dart';

class SymTextViewer extends StatefulWidget {
  SymTextViewer(this.markdownData,
      {this.scrollController, this.maxHeight, this.darkMode = false});

  final bool darkMode;
  final String markdownData;
  final ScrollController? scrollController;
  final double? maxHeight;

  late QuillController _controller;

  @override
  _SymTextViewerState createState() => _SymTextViewerState();
}

class _SymTextViewerState extends State<SymTextViewer>
    with SingleTickerProviderStateMixin {
  late DefaultStyles _styles;
  final LayerLink _toolbarLayerLink = LayerLink();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();
  late CursorCont _cursorCont;

  bool _isExceededMaxHeight = false;

  bool get showPreviewImage => widget.maxHeight != null;

  @override
  void initState() {
    super.initState();

    _cursorCont = CursorCont(
      show: ValueNotifier<bool>(false),
      style: const CursorStyle(
        color: Colors.black,
        backgroundColor: Colors.grey,
        width: 2,
        radius: Radius.zero,
        offset: Offset.zero,
      ),
      tickerProvider: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final textColor = widget.darkMode
        ? SymColors.dark_textPrimary
        : SymColors.light_textPrimary;
    final defaultStyles =
        DefaultStyles.getInstance(context, baseTextColor: textColor);
    _styles = defaultStyles;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.darkMode ? SymColors.dark_bgSurface2 : SymColors.light_bgWhite;

    var markdownToDecode = widget.markdownData;
    if (widget.maxHeight != null) {
      markdownToDecode = widget.markdownData
          .replaceAll(SymRegex.REMOVE_IMAGE_BLOCK_IDENTIFIER, '')
          .replaceAll(SymRegex.REMOVE_IMAGE, '');
    }
    final doc = Document.fromMarkdown(markdownToDecode);
    widget._controller = QuillController(
        document: doc, selection: const TextSelection.collapsed(offset: 0));

    Widget child = CompositedTransformTarget(
      link: _toolbarLayerLink,
      child: Semantics(
        child: _SymTextViewer(
          document: doc,
          textDirection: _textDirection,
          startHandleLayerLink: _startHandleLayerLink,
          endHandleLayerLink: _endHandleLayerLink,
          onSelectionChanged: _nullSelectionChanged,
          scrollBottomInset: 0,
          children: _buildChildren(doc, context),
        ),
      ),
    );

    if (widget.maxHeight != null) {
      final _key = GlobalKey();

      if (!_isExceededMaxHeight) {
        child = ConstrainedBox(
            key: _key,
            constraints: BoxConstraints(maxHeight: widget.maxHeight!),
            child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), child: child));
      } else {
        final readMore = Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                bgColor.withOpacity(0),
                bgColor.withOpacity(0.8),
                bgColor,
                bgColor
              ],
                  stops: [
                0.0,
                0.2,
                0.3,
                1.0
              ])),
          child: const Padding(
            padding: EdgeInsets.only(
              top: 2,
            ),
            child: SymText(
              '...Lihat selengkapnya',
              size: 16,
              color: SymColors.light_textQuaternary,
            ),
          ),
        );

        child = Stack(children: [
          ConstrainedBox(
              key: _key,
              constraints: BoxConstraints(maxHeight: widget.maxHeight!),
              child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(), child: child)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: readMore,
          )
        ]);
      }

      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        final height = _key.currentContext?.size?.height;
        if (height != null) {
          if (height >= widget.maxHeight! && !_isExceededMaxHeight) {
            setState(() {
              _isExceededMaxHeight = true;
            });
          }
        }
      });
    }

    // final textViewer = QuillStyles(data: _styles, child: child);
    final textViewer = QuillStyles(data: _styles, child: child);

    if (widget.maxHeight != null) {
      final images = SymRegex.REMOVE_IMAGE.allMatches(widget.markdownData);

      if (images.isNotEmpty) {
        final image = images.first.group(0);
        if (image != null) {
          final imageUrls = SymRegex.TEXTS_INSIDE_BRACKET.allMatches(image);
          final imageUrl = imageUrls.last.group(0);

          if (imageUrl != null) {
            return Column(
              children: [
                if (images.isNotEmpty && image != null)
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Image.network(imageUrl)),
                textViewer
              ],
            );
          } else {
            return textViewer;
          }
        } else {
          return textViewer;
        }
      } else {
        return textViewer;
      }
    } else {
      return textViewer;
    }
  }

  List<Widget> _buildChildren(Document doc, BuildContext context) {
    final result = <Widget>[];
    final indentLevelCounts = <int, int>{};
    for (final node in doc.root.children) {
      if (node is Line) {
        final editableTextLine = _getEditableTextLineFromNode(node, context);
        result.add(editableTextLine);
      } else if (node is Block) {
        final attrs = node.style.attributes;
        final editableTextBlock = EditableTextBlock(
          node,
          _textDirection,
          0,
          _getVerticalSpacingForBlock(node, _styles),
          widget._controller.selection,
          Colors.black,
          // selectionColor,
          _styles,
          false,
          // enableInteractiveSelection,
          false,
          // hasFocus,
          attrs.containsKey(Attribute.codeBlock.key)
              ? const EdgeInsets.all(16)
              : null,
          embedBuilder,
          _cursorCont,
          indentLevelCounts,
          _handleCheckboxTap,
          true,
          onBlockButtonAddTap: (_) {},
          onBlockButtonOptionTap: (_, __, ___) {},
        );
        result.add(editableTextBlock);
      } else {
        throw StateError('Unreachable.');
      }
    }
    return result;
  }

  /// Updates the checkbox positioned at [offset] in document
  /// by changing its attribute according to [value].
  void _handleCheckboxTap(int offset, bool value) {
    // readonly - do nothing
  }

  TextDirection get _textDirection {
    final result = Directionality.of(context);
    return result;
  }

  EditableTextLine _getEditableTextLineFromNode(
      Line node, BuildContext context) {
    final textLine = TextLine(
      line: node,
      textDirection: _textDirection,
      embedBuilder: embedBuilder,
      styles: _styles,
      readOnly: true,
    );
    final editableTextLine = EditableTextLine(
        GlobalKey(),
        node,
        null,
        null,
        null,
        textLine,
        0,
        _getVerticalSpacingForLine(node, _styles),
        _textDirection,
        widget._controller.selection,
        Colors.black,
        //widget.selectionColor,
        false,
        //enableInteractiveSelection,
        false,
        //_hasFocus,
        MediaQuery.of(context).devicePixelRatio,
        _cursorCont);
    return editableTextLine;
  }

  Tuple2<double, double> _getVerticalSpacingForLine(
      Line line, DefaultStyles? defaultStyles) {
    final attrs = line.style.attributes;
    if (attrs.containsKey(Attribute.header.key)) {
      final int? level = attrs[Attribute.header.key]!.value;
      switch (level) {
        case 1:
          return defaultStyles!.h1!.verticalSpacing;
        case 2:
          return defaultStyles!.h2!.verticalSpacing;
        case 3:
          return defaultStyles!.h3!.verticalSpacing;
        default:
          throw 'Invalid level $level';
      }
    }

    return defaultStyles!.paragraph!.verticalSpacing;
  }

  Tuple2<double, double> _getVerticalSpacingForBlock(
      Block node, DefaultStyles? defaultStyles) {
    final attrs = node.style.attributes;
    if (attrs.containsKey(Attribute.blockQuote.key)) {
      return defaultStyles!.quote!.verticalSpacing;
    } else if (attrs.containsKey(Attribute.codeBlock.key)) {
      return defaultStyles!.code!.verticalSpacing;
    } else if (attrs.containsKey(Attribute.indent.key)) {
      return defaultStyles!.indent!.verticalSpacing;
    }
    return defaultStyles!.lists!.verticalSpacing;
  }

  void _nullSelectionChanged(
      TextSelection selection, SelectionChangedCause cause) {}

  EmbedBuilder get embedBuilder => defaultSymEmbedBuilderWeb;
}

class _SymTextViewer extends MultiChildRenderObjectWidget {
  _SymTextViewer({
    required List<Widget> children,
    required this.document,
    required this.textDirection,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    required this.onSelectionChanged,
    required this.scrollBottomInset,
    this.padding = EdgeInsets.zero,
    Key? key,
  }) : super(key: key, children: children);

  final Document document;
  final TextDirection textDirection;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final TextSelectionChangedHandler onSelectionChanged;
  final double scrollBottomInset;
  final EdgeInsetsGeometry padding;

  @override
  RenderEditor createRenderObject(BuildContext context) {
    return RenderEditor(
      null,
      textDirection,
      scrollBottomInset,
      padding,
      document,
      const TextSelection(baseOffset: 0, extentOffset: 0),
      false,
      // hasFocus,
      onSelectionChanged,
      startHandleLayerLink,
      endHandleLayerLink,
      const EdgeInsets.fromLTRB(4, 4, 4, 5),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderEditor renderObject) {
    renderObject
      ..document = document
      ..setContainer(document.root)
      ..textDirection = textDirection
      ..setStartHandleLayerLink(startHandleLayerLink)
      ..setEndHandleLayerLink(endHandleLayerLink)
      ..onSelectionChanged = onSelectionChanged
      ..setScrollBottomInset(scrollBottomInset)
      ..setPadding(padding);
  }
}
