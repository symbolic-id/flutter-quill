import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/src/utils/app_constant.dart';
import 'package:flutter_quill/src/widgets/common_widgets/gap.dart';
import 'package:flutter_quill/utils/assets.dart';
import 'dart:math' as math;
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
  SymTextViewer(
    this.markdownData, {
    this.maxHeight,
    this.darkMode = false,
    this.padding = EdgeInsets.zero,
  });

  SymTextViewer.blockSelector(
    this.markdownData, {
    required this.selectedBlock,
    this.maxHeight,
    this.darkMode = false,
    this.padding = EdgeInsets.zero,
  });

  final bool darkMode;
  final String markdownData;
  final double? maxHeight;
  final EdgeInsetsGeometry padding;

  late QuillController _controller;

  void Function(String rawMarkdown)? selectedBlock;

  @override
  _SymTextViewerState createState() => _SymTextViewerState();
}

class _SymTextViewerState extends State<SymTextViewer>
    with TickerProviderStateMixin {
  final _widgetKey = GlobalKey();
  late DefaultStyles _styles;
  final LayerLink _toolbarLayerLink = LayerLink();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();
  late CursorCont _cursorCont;

  bool _isExceededMaxHeight = false;

  bool get showPreviewImage => widget.maxHeight != null;

  void Function(bool, RenderEditableTextLine) hoverCallback = (_, __) {};

  final Map<String, Tuple3<RenderEditableTextLine, GlobalKey, OverlayEntry>>
      _hoveredLines = {};

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
    if (widget.selectedBlock != null) {
      hoverCallback = (isHovered, renderBox) {
        if (isHovered) {
          _addHoveredLine(renderBox);
        } else {
          _removeHoveredLine(renderBox);
        }
      };
    }
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

  void _addHoveredLine(RenderEditableTextLine box) {
    if (!_hoveredLines.containsKey(box.line.lineId) &&
        box.line.toPlainTextWithoutLineId().trim().isNotEmpty) {
      const preferredButtonWidth = 17.0;
      final lineBodyOffset = box.body!.localToGlobal(Offset.zero);

      final viewerRegionBox =
          _widgetKey.currentContext!.findRenderObject() as RenderBox;
      final viewerRegionBoxOffset = viewerRegionBox.localToGlobal(Offset.zero);
      final optionOffsetX = viewerRegionBox.size.width -
          math.max((widget.padding as EdgeInsets).right, preferredButtonWidth);
      final optionOffsetY = lineBodyOffset.dy - viewerRegionBoxOffset.dy;

      final _optionButtonKey = GlobalKey();

      _hoveredLines.addAll({
        box.line.lineId:
            Tuple3(box, _optionButtonKey, OverlayEntry(builder: (context) {
          return Positioned(
              top: 0,
              left: 0,
              child: CompositedTransformFollower(
                offset: Offset(optionOffsetX, optionOffsetY),
                link: _toolbarLayerLink,
                child: MouseRegion(
                  onEnter: (event) {
                    _addHoveredLine(box);
                  },
                  onExit: (_) => _removeHoveredLine(box),
                  child: Material(
                    key: _optionButtonKey,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    child: InkWell(
                      onTap: () {
                        print('LL:: line id: ${box.line.lineId}');
                        _showMenuOptionOverlay(box);
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 4, bottom: 4, right: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.more_vert,
                              size: preferredButtonWidth,
                            ),
                            const GapH(4),
                            const SymText(
                              'Lihat opsi block',
                              size: 12,
                              bold: true,
                              color: SymColors.light_textQuaternary,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ));
        }))
      });
      Overlay.of(context)!.insert(_hoveredLines[box.line.lineId]!.item3);
    }
  }

  void _removeHoveredLine(RenderEditableTextLine box) {
    _hoveredLines[box.line.lineId]?.item3.remove();
    _hoveredLines.removeWhere((key, value) => key == box.line.lineId);
  }

  void _showMenuOptionOverlay(RenderEditableTextLine box) {
    OverlayEntry? menuOverlay;
    final buttonKey = _hoveredLines[box.line.lineId]?.item2;
    final buttonBox =
        buttonKey?.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox != null) {
      box.setLineSelected(true);
      final buttonOffset = buttonBox.localToGlobal(Offset.zero);
      final controller = AnimationController(
          duration: const Duration(milliseconds: 100),
          vsync: this,
          reverseDuration: const Duration(milliseconds: 100));

      final menuOffset = Offset(buttonOffset.dx + buttonBox.size.width,
          buttonOffset.dy + buttonBox.size.height);

      menuOverlay = OverlayEntry(
          builder: (context) => Stack(
                fit: StackFit.expand,
                children: [
                  const AbsorbPointer(),
                  GestureDetector(
                    onTap: () =>
                        _hideMenuOptionOverlay(box, controller, menuOverlay),
                  ),
                  _buildMenuOption(
                      buttonBox.size.height,
                      menuOffset,
                      controller,
                      () =>
                          _hideMenuOptionOverlay(box, controller, menuOverlay))
                ],
              ));

      controller.forward();
      Overlay.of(context)!.insert(menuOverlay);
    }
  }

  void _hideMenuOptionOverlay(RenderEditableTextLine box,
      AnimationController controller, OverlayEntry? menuOverlay) {
    if (menuOverlay != null) {
      box.setLineSelected(false);
      controller.reverse();
      late AnimationStatusListener statusListener;
      statusListener = (status) {
        if (status == AnimationStatus.dismissed) {
          menuOverlay?.remove();
          menuOverlay = null;
          controller.removeStatusListener(statusListener);
        }
      };
      controller.addStatusListener(statusListener);
    }
  }

  Widget _buildMenuOption(double buttonBoxHeight, Offset offset,
      AnimationController controller, Function onHide) {
    final openAnimation = CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.easeOutQuad);

    const MENU_SIZE = Size(220, 96);

    return AnimatedBuilder(
      animation: openAnimation,
      builder: (context, child) {
        return Positioned(
          left: offset.dx - MENU_SIZE.width,
          top: offset.dy -
              buttonBoxHeight +
              openAnimation.value * buttonBoxHeight,
          child: Visibility(
            visible: openAnimation.value > 0,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: openAnimation,
        child: Material(
            borderRadius: BorderRadius.circular(8),
            elevation: 5,
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: MENU_SIZE.width,
              height: MENU_SIZE.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: _itemMenuOption(
                          'Kutip ke komentar', Assets.QUOTE_BLOCK, () {
                    onHide();
                  })),
                  Expanded(
                      child: _itemMenuOption(
                          'Jadikan catatan', Assets.CREATE_NOTE, () {
                    onHide();
                  })),
                ],
              ),
            )),
      ),
    );
  }

  Widget _itemMenuOption(String label, String assetName, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Image(
              image: AssetImage(assetName, package: PACKAGE_NAME),
              width: 21,
              height: 21,
            ),
            GapH(8),
            SymText(
              label,
              size: 15,
              bold: true,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.darkMode ? SymColors.dark_bgSurface2 : SymColors.light_bgWhite;

    var markdownToDecode = widget.markdownData;
    if (widget.maxHeight != null) {
      markdownToDecode = widget.markdownData
          .replaceAll(
              SymRegex
                  .IMAGE_MD_BEFORE_BLOCK_IDENTIFIER_INSIDE_DOUBLE_SQR_BRACKET_BEFORE_LINEBREAK,
              '')
          .replaceAll(SymRegex.IMAGE_MD, '');
    }
    final doc = Document.fromMarkdown(markdownToDecode);
    widget._controller = QuillController(
        document: doc, selection: const TextSelection.collapsed(offset: 0));

    Widget child = CompositedTransformTarget(
      link: _toolbarLayerLink,
      child: Semantics(
        child: _SymTextViewer(
          key: _widgetKey,
          document: doc,
          textDirection: _textDirection,
          startHandleLayerLink: _startHandleLayerLink,
          endHandleLayerLink: _endHandleLayerLink,
          onSelectionChanged: _nullSelectionChanged,
          scrollBottomInset: 0,
          padding: widget.padding,
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
      final images = SymRegex.IMAGE_MD.allMatches(widget.markdownData);

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
          lineHoveredCallback: hoverCallback,
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
      _cursorCont,
      hoveredCallback: hoverCallback,
    );
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
