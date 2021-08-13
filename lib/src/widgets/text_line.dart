import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/src/utils/sym_regex.dart';
import 'package:tuple/tuple.dart';

import '../models/documents/attribute.dart';
import '../models/documents/nodes/container.dart' as container;
import '../models/documents/nodes/leaf.dart' as leaf;
import '../models/documents/nodes/leaf.dart';
import '../models/documents/nodes/line.dart';
import '../models/documents/nodes/node.dart';
import '../utils/color.dart';
import 'box.dart';
import 'cursor.dart';
import 'default_styles.dart';
import 'delegate.dart';
import 'proxy.dart';
import 'sym_widgets/sym_block_button.dart';
import 'text_selection.dart';

class TextLine extends StatelessWidget {
  const TextLine({
    required this.line,
    required this.embedBuilder,
    required this.styles,
    required this.readOnly,
    this.textDirection,
    Key? key,
  }) : super(key: key);

  final Line line;
  final TextDirection? textDirection;
  final EmbedBuilder embedBuilder;
  final DefaultStyles styles;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    if (line.hasEmbed && line.childCount == 1) {
      // For video, it is always single child
      final embed = line.children.single as Embed;
      return EmbedProxy(embedBuilder(context, embed, readOnly));
    }
    final textSpan = _getTextSpanForWholeLine(context);
    final strutStyle = StrutStyle.fromTextStyle(textSpan.style!);
    final textAlign = _getTextAlign();
    final child = RichText(
      text: textSpan,
      textAlign: textAlign,
      textDirection: textDirection,
      strutStyle: strutStyle,
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
    );
    return RichTextProxy(
        child,
        textSpan.style!,
        textAlign,
        textDirection!,
        1,
        Localizations.localeOf(context),
        strutStyle,
        TextWidthBasis.parent,
        null);
  }

  InlineSpan _getTextSpanForWholeLine(BuildContext context) {
    final lineStyle = _getLineStyle(styles);
    if (!line.hasEmbed) {
      return _buildTextSpan(styles, line.children, lineStyle);
    }

    // The line could contain more than one Embed & more than one Text
    final textSpanChildren = <InlineSpan>[];
    var textNodes = LinkedList<Node>();
    for (final child in line.children) {
      if (child is Embed) {
        if (textNodes.isNotEmpty) {
          textSpanChildren.add(_buildTextSpan(styles, textNodes, lineStyle));
          textNodes = LinkedList<Node>();
        }
        // Here it should be image
        final embed = WidgetSpan(
            child: EmbedProxy(embedBuilder(context, child, readOnly)));
        textSpanChildren.add(embed);
        continue;
      }

      // here child is Text node and its value is cloned
      textNodes.add(child.clone());
    }

    if (textNodes.isNotEmpty) {
      textSpanChildren.add(_buildTextSpan(styles, textNodes, lineStyle));
    }

    return TextSpan(style: lineStyle, children: textSpanChildren);
  }

  TextAlign _getTextAlign() {
    final alignment = line.style.attributes[Attribute.align.key];
    if (alignment == Attribute.leftAlignment) {
      return TextAlign.left;
    } else if (alignment == Attribute.centerAlignment) {
      return TextAlign.center;
    } else if (alignment == Attribute.rightAlignment) {
      return TextAlign.right;
    } else if (alignment == Attribute.justifyAlignment) {
      return TextAlign.justify;
    }
    return TextAlign.start;
  }

  TextSpan _buildTextSpan(DefaultStyles defaultStyles, LinkedList<Node> nodes,
      TextStyle lineStyle) {
    final children = nodes
        .map((node) => _getTextSpanFromNode(defaultStyles, node))
        .toList(growable: false);

    return TextSpan(children: children, style: lineStyle);
  }

  TextStyle _getLineStyle(DefaultStyles defaultStyles) {
    var textStyle = const TextStyle();

    if (line.style.containsKey(Attribute.placeholder.key)) {
      return defaultStyles.placeHolder!.style;
    }

    final header = line.style.attributes[Attribute.header.key];
    final m = <Attribute, TextStyle>{
      Attribute.h1: defaultStyles.h1!.style,
      Attribute.h2: defaultStyles.h2!.style,
      Attribute.h3: defaultStyles.h3!.style,
    };

    textStyle = textStyle.merge(m[header] ?? defaultStyles.paragraph!.style);

    final block = line.style.getBlockExceptHeader();
    TextStyle? toMerge;
    if (block?.key == Attribute.indent.key) {
      toMerge = null;
    } else if (block == Attribute.blockQuote) {
      toMerge = defaultStyles.quote!.style;
    } else if (block == Attribute.codeBlock) {
      toMerge = defaultStyles.code!.style;
    } else if (block != null) {
      toMerge = defaultStyles.lists!.style;
    }

    textStyle = textStyle.merge(toMerge);

    return textStyle;
  }

  TextSpan _getTextSpanFromNode(DefaultStyles defaultStyles, Node node) {
    final textNode = node as leaf.Text;
    final style = textNode.style;
    var res = const TextStyle(); // This is inline text style
    final color = textNode.style.attributes[Attribute.color.key];

    <String, TextStyle?>{
      Attribute.bold.key: defaultStyles.bold,
      Attribute.italic.key: defaultStyles.italic,
      Attribute.link.key: defaultStyles.link,
      Attribute.underline.key: defaultStyles.underline,
      Attribute.strikeThrough.key: defaultStyles.strikeThrough,
    }.forEach((k, s) {
      if (style.values.any((v) => v.key == k)) {
        if (k == Attribute.underline.key || k == Attribute.strikeThrough.key) {
          var textColor = defaultStyles.color;
          if (color?.value is String) {
            textColor = stringToColor(color?.value);
          }
          res = _merge(res.copyWith(decorationColor: textColor),
              s!.copyWith(decorationColor: textColor));
        } else {
          res = _merge(res, s!);
        }
      }
    });

    final font = textNode.style.attributes[Attribute.font.key];
    if (font != null && font.value != null) {
      res = res.merge(TextStyle(fontFamily: font.value));
    }

    final size = textNode.style.attributes[Attribute.size.key];
    if (size != null && size.value != null) {
      switch (size.value) {
        case 'small':
          res = res.merge(defaultStyles.sizeSmall);
          break;
        case 'large':
          res = res.merge(defaultStyles.sizeLarge);
          break;
        case 'huge':
          res = res.merge(defaultStyles.sizeHuge);
          break;
        default:
          final fontSize = double.tryParse(size.value);
          if (fontSize != null) {
            res = res.merge(TextStyle(fontSize: fontSize));
          } else {
            throw 'Invalid size ${size.value}';
          }
      }
    }

    if (color != null && color.value != null) {
      var textColor = defaultStyles.color;
      if (color.value is String) {
        textColor = stringToColor(color.value);
      }
      if (textColor != null) {
        res = res.merge(TextStyle(color: textColor));
      }
    }

    final background = textNode.style.attributes[Attribute.background.key];
    if (background != null && background.value != null) {
      final backgroundColor = stringToColor(background.value);
      res = res.merge(TextStyle(backgroundColor: backgroundColor));
    }

    return TextSpan(
        text: textNode.value.replaceAll(
            SymRegex.BLOCK_IDENTIFIER_INSIDE_DOUBLE_SQR_BRACKET, ''),
        style: res);
  }

  TextStyle _merge(TextStyle a, TextStyle b) {
    final decorations = <TextDecoration?>[];
    if (a.decoration != null) {
      decorations.add(a.decoration);
    }
    if (b.decoration != null) {
      decorations.add(b.decoration);
    }
    return a.merge(b).apply(
        decoration: TextDecoration.combine(
            List.castFrom<dynamic, TextDecoration>(decorations)));
  }
}

class EditableTextLine extends RenderObjectWidget {
  EditableTextLine(
    Key key,
    this.line,
    this.buttonAdd,
    this.buttonOption,
    this.leading,
    this.body,
    this.indentWidth,
    this.verticalSpacing,
    this.textDirection,
    this.textSelection,
    this.color,
    this.enableInteractiveSelection,
    this.hasFocus,
    this.devicePixelRatio,
    this.cursorCont, {
    this.isLineSelected = false,
    this.hoveredCallback,
  }) : super(key: key);

  final Line line;
  final SymBlockButton? buttonAdd;
  final SymBlockButton? buttonOption;
  final Widget? leading;
  final Widget body;
  final double indentWidth;
  final Tuple2 verticalSpacing;
  final TextDirection textDirection;
  final TextSelection textSelection;
  final Color color;
  final bool enableInteractiveSelection;
  final bool hasFocus;
  final double devicePixelRatio;
  final CursorCont cursorCont;
  final bool isLineSelected;
  Function(bool, RenderEditableTextLine)? hoveredCallback;

  @override
  RenderObjectElement createElement() {
    return _TextLineElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderEditableTextLine(
        line,
        textDirection,
        textSelection,
        enableInteractiveSelection,
        hasFocus,
        devicePixelRatio,
        _getPadding(),
        buttonAdd?.width ?? 0,
        color,
        cursorCont,
        isLineSelected: isLineSelected,
        hoveredCallback: hoveredCallback);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderEditableTextLine renderObject) {
    renderObject
      ..setLine(line)
      ..setPadding(_getPadding())
      ..setTextDirection(textDirection)
      ..setTextSelection(textSelection)
      ..setColor(color)
      ..setEnableInteractiveSelection(enableInteractiveSelection)
      ..hasFocus = hasFocus
      ..setDevicePixelRatio(devicePixelRatio)
      ..setCursorCont(cursorCont)
      ..setLineSelected(isLineSelected);
  }

  EdgeInsetsGeometry _getPadding() {
    return EdgeInsetsDirectional.only(
        start: indentWidth,
        top: verticalSpacing.item1,
        bottom: verticalSpacing.item2);
  }
}

enum TextLineSlot { BUTTON_ADD, BUTTON_OPTION, LEADING, BODY }

class RenderEditableTextLine extends RenderEditableBox
    implements MouseTrackerAnnotation {
  RenderEditableTextLine(
      this.line,
      this.textDirection,
      this.textSelection,
      this.enableInteractiveSelection,
      this.hasFocus,
      this.devicePixelRatio,
      this.padding,
      this.buttonWidth,
      this.color,
      this.cursorCont,
      {this.isLineSelected = false,
      this.hoveredCallback});

  RenderBox? _buttonAdd;
  RenderBox? _buttonOption;
  RenderBox? _leading;
  RenderContentProxyBox? body;
  Line line;
  TextDirection textDirection;
  TextSelection textSelection;
  Color color;
  bool enableInteractiveSelection;
  bool hasFocus = false;
  double devicePixelRatio;
  EdgeInsetsGeometry padding;
  double buttonWidth;
  CursorCont cursorCont;
  EdgeInsets? _resolvedPadding;
  bool? _containsCursor;
  List<TextBox>? _selectedRects;
  Rect? _caretPrototype;
  final Map<TextLineSlot, RenderBox> children = <TextLineSlot, RenderBox>{};
  Function(bool, RenderEditableTextLine)? hoveredCallback;

  final buttonRightMargin = 8;

  bool _onHover = false;

  bool get onHover => _onHover;

  void setHovered(bool isHovered) {
    hoveredCallback?.call(isHovered, this);
    if (_onHover != isHovered) {
      _onHover = isHovered;
      markNeedsPaint();
    }
  }

  Color _lineSelectColor = SymColors.light_bgSurface2;
  bool isLineSelected = false;

  void setLineSelected(bool isSelected,
      {Color color = SymColors.light_bgSurface2}) {
    if (isLineSelected != isSelected) {
      isLineSelected = isSelected;
      _lineSelectColor = color;
      markNeedsPaint();
    }
  }

  Iterable<RenderBox> get _children sync* {
    if (_buttonAdd != null) {
      yield _buttonAdd!;
    }
    if (_buttonOption != null) {
      yield _buttonOption!;
    }
    if (_leading != null) {
      yield _leading!;
    }
    if (body != null) {
      yield body!;
    }
  }

  void setCursorCont(CursorCont c) {
    if (cursorCont == c) {
      return;
    }
    cursorCont = c;
    markNeedsLayout();
  }

  void setDevicePixelRatio(double d) {
    if (devicePixelRatio == d) {
      return;
    }
    devicePixelRatio = d;
    markNeedsLayout();
  }

  void setEnableInteractiveSelection(bool val) {
    if (enableInteractiveSelection == val) {
      return;
    }

    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  void setColor(Color c) {
    if (color == c) {
      return;
    }

    color = c;
    if (containsTextSelection()) {
      markNeedsPaint();
    }
  }

  void setTextSelection(TextSelection t) {
    if (textSelection == t) {
      return;
    }

    final containsSelection = containsTextSelection();
    if (attached && containsCursor()) {
      cursorCont.removeListener(markNeedsLayout);
      cursorCont.color.removeListener(markNeedsPaint);
    }

    textSelection = t;
    _selectedRects = null;
    _containsCursor = null;
    if (attached && containsCursor()) {
      cursorCont.addListener(markNeedsLayout);
      cursorCont.color.addListener(markNeedsPaint);
    }

    if (containsSelection || containsTextSelection()) {
      markNeedsPaint();
    }
  }

  void setTextDirection(TextDirection t) {
    if (textDirection == t) {
      return;
    }
    textDirection = t;
    _resolvedPadding = null;
    markNeedsLayout();
  }

  void setLine(Line l) {
    if (line == l) {
      return;
    }
    line = l;
    _containsCursor = null;
    markNeedsLayout();
  }

  void setPadding(EdgeInsetsGeometry p) {
    assert(p.isNonNegative);
    if (padding == p) {
      return;
    }
    padding = p;
    _resolvedPadding = null;
    markNeedsLayout();
  }

  void setButtonAdd(RenderBox? btn) {
    _buttonAdd = _updateChild(_buttonAdd, btn, TextLineSlot.BUTTON_ADD);
  }

  void setButtonOption(RenderBox? btn) {
    _buttonOption =
        _updateChild(_buttonOption, btn, TextLineSlot.BUTTON_OPTION);
  }

  void setLeading(RenderBox? l) {
    _leading = _updateChild(_leading, l, TextLineSlot.LEADING);
  }

  void setBody(RenderContentProxyBox? b) {
    body = _updateChild(body, b, TextLineSlot.BODY) as RenderContentProxyBox?;
  }

  bool containsTextSelection() {
    return line.documentOffset <= textSelection.end &&
        textSelection.start <= line.documentOffset + line.length - 1;
  }

  bool containsCursor() {
    return _containsCursor ??= textSelection.isCollapsed &&
        line.containsOffset(textSelection.baseOffset);
  }

  RenderBox? _updateChild(
      RenderBox? old, RenderBox? newChild, TextLineSlot slot) {
    if (old != null) {
      dropChild(old);
      children.remove(slot);
    }
    if (newChild != null) {
      children[slot] = newChild;
      adoptChild(newChild);
    }
    return newChild;
  }

  List<TextBox> _getBoxes(TextSelection textSelection) {
    final parentData = body!.parentData as BoxParentData?;
    return body!.getBoxesForSelection(textSelection).map((box) {
      return TextBox.fromLTRBD(
        box.left + parentData!.offset.dx,
        box.top + parentData.offset.dy,
        box.right + parentData.offset.dx,
        box.bottom + parentData.offset.dy,
        box.direction,
      );
    }).toList(growable: false);
  }

  void _resolvePadding() {
    if (_resolvedPadding != null) {
      return;
    }

    _resolvedPadding = padding.resolve(textDirection);

    if (_buttonAdd != null) {
      _resolvedPadding = _resolvedPadding!
          .add(EdgeInsets.only(left: buttonWidth)) as EdgeInsets?;
    }

    if (_buttonOption != null) {
      _resolvedPadding = _resolvedPadding!
          .add(EdgeInsets.only(left: buttonWidth)) as EdgeInsets?;
    }

    assert(_resolvedPadding!.isNonNegative);
  }

  @override
  TextSelectionPoint getBaseEndpointForSelection(TextSelection textSelection) {
    return _getEndpointForSelection(textSelection, true);
  }

  @override
  TextSelectionPoint getExtentEndpointForSelection(
      TextSelection textSelection) {
    return _getEndpointForSelection(textSelection, false);
  }

  TextSelectionPoint _getEndpointForSelection(
      TextSelection textSelection, bool first) {
    if (textSelection.isCollapsed) {
      return TextSelectionPoint(
          Offset(0, preferredLineHeight(textSelection.extent)) +
              getOffsetForCaret(textSelection.extent),
          null);
    }
    final boxes = _getBoxes(textSelection);
    assert(boxes.isNotEmpty);
    final targetBox = first ? boxes.first : boxes.last;
    return TextSelectionPoint(
        Offset(first ? targetBox.start : targetBox.end, targetBox.bottom),
        targetBox.direction);
  }

  @override
  TextRange getLineBoundary(TextPosition position) {
    final lineDy = getOffsetForCaret(position)
        .translate(0, 0.5 * preferredLineHeight(position))
        .dy;
    final lineBoxes =
        _getBoxes(TextSelection(baseOffset: 0, extentOffset: line.length - 1))
            .where((element) => element.top < lineDy && element.bottom > lineDy)
            .toList(growable: false);
    return TextRange(
        start:
            getPositionForOffset(Offset(lineBoxes.first.left, lineDy)).offset,
        end: getPositionForOffset(Offset(lineBoxes.last.right, lineDy)).offset);
  }

  @override
  Offset getOffsetForCaret(TextPosition position) {
    return body!.getOffsetForCaret(position, _caretPrototype) +
        (body!.parentData as BoxParentData).offset;
  }

  @override
  TextPosition? getPositionAbove(TextPosition position) {
    return _getPosition(position, -0.5);
  }

  @override
  TextPosition? getPositionBelow(TextPosition position) {
    return _getPosition(position, 1.5);
  }

  TextPosition? _getPosition(TextPosition textPosition, double dyScale) {
    assert(textPosition.offset < line.length);
    final offset = getOffsetForCaret(textPosition)
        .translate(0, dyScale * preferredLineHeight(textPosition));
    if (body!.size
        .contains(offset - (body!.parentData as BoxParentData).offset)) {
      return getPositionForOffset(offset);
    }
    return null;
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    return body!.getPositionForOffset(
        offset - (body!.parentData as BoxParentData).offset);
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    return body!.getWordBoundary(position);
  }

  @override
  double preferredLineHeight(TextPosition position) {
    return body!.getPreferredLineHeight();
  }

  @override
  container.Container getContainer() {
    return line;
  }

  double get cursorWidth => cursorCont.style.width;

  double get cursorHeight =>
      cursorCont.style.height ??
      preferredLineHeight(const TextPosition(offset: 0));

  void _computeCaretPrototype() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _caretPrototype = Rect.fromLTWH(0, 0, cursorWidth, cursorHeight + 2);
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _caretPrototype = Rect.fromLTWH(0, 2, cursorWidth, cursorHeight - 4.0);
        break;
      default:
        throw 'Invalid platform';
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    for (final child in _children) {
      child.attach(owner);
    }
    if (containsCursor()) {
      cursorCont.addListener(markNeedsLayout);
      cursorCont.color.addListener(markNeedsPaint);
    }
  }

  @override
  void detach() {
    super.detach();
    for (final child in _children) {
      child.detach();
    }
    if (containsCursor()) {
      cursorCont.removeListener(markNeedsLayout);
      cursorCont.color.removeListener(markNeedsPaint);
    }
  }

  @override
  void redepthChildren() {
    _children.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _children.forEach(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final value = <DiagnosticsNode>[];
    void add(RenderBox? child, String name) {
      if (child != null) {
        value.add(child.toDiagnosticsNode(name: name));
      }
    }

    add(_buttonAdd, 'buttonAdd');
    add(_buttonOption, 'buttonOption');
    add(_leading, 'leading');
    add(body, 'body');
    return value;
  }

  @override
  bool get sizedByParent => false;

  @override
  double computeMinIntrinsicWidth(double height) {
    _resolvePadding();
    final horizontalPadding = _resolvedPadding!.left + _resolvedPadding!.right;
    final verticalPadding = _resolvedPadding!.top + _resolvedPadding!.bottom;
    final buttonAddWidth = _buttonAdd == null
        ? 0
        : _buttonAdd!.getMinIntrinsicWidth(height - verticalPadding).ceil();
    final buttonOptionWidth = _buttonOption == null
        ? 0
        : _buttonOption!.getMinIntrinsicWidth(height - verticalPadding).ceil();
    final leadingWidth = _leading == null
        ? 0
        : _leading!.getMinIntrinsicWidth(height - verticalPadding).ceil();
    final bodyWidth = body == null
        ? 0
        : body!
            .getMinIntrinsicWidth(math.max(0, height - verticalPadding))
            .ceil();
    return horizontalPadding +
        buttonAddWidth +
        buttonOptionWidth +
        leadingWidth +
        bodyWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolvePadding();
    final horizontalPadding = _resolvedPadding!.left + _resolvedPadding!.right;
    final verticalPadding = _resolvedPadding!.top + _resolvedPadding!.bottom;
    final buttonAddWidth = _buttonAdd == null
        ? 0
        : _buttonAdd!.getMinIntrinsicWidth(height - verticalPadding).ceil();
    final buttonOptionWidth = _buttonOption == null
        ? 0
        : _buttonOption!.getMinIntrinsicWidth(height - verticalPadding).ceil();
    final leadingWidth = _leading == null
        ? 0
        : _leading!.getMaxIntrinsicWidth(height - verticalPadding).ceil();
    final bodyWidth = body == null
        ? 0
        : body!
            .getMaxIntrinsicWidth(math.max(0, height - verticalPadding))
            .ceil();
    return horizontalPadding +
        buttonAddWidth +
        buttonOptionWidth +
        leadingWidth +
        bodyWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _resolvePadding();
    final horizontalPadding = _resolvedPadding!.left + _resolvedPadding!.right;
    final verticalPadding = _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (body != null) {
      return body!
              .getMinIntrinsicHeight(math.max(0, width - horizontalPadding)) +
          verticalPadding;
    }
    return verticalPadding;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _resolvePadding();
    final horizontalPadding = _resolvedPadding!.left + _resolvedPadding!.right;
    final verticalPadding = _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (body != null) {
      return body!
              .getMaxIntrinsicHeight(math.max(0, width - horizontalPadding)) +
          verticalPadding;
    }
    return verticalPadding;
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    _resolvePadding();
    return body!.getDistanceToActualBaseline(baseline)! + _resolvedPadding!.top;
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    _selectedRects = null;

    _resolvePadding();
    assert(_resolvedPadding != null);

    if (body == null && _leading == null) {
      size = constraints.constrain(Size(
        _resolvedPadding!.left + _resolvedPadding!.right,
        _resolvedPadding!.top + _resolvedPadding!.bottom,
      ));
      return;
    }
    final innerConstraints = constraints.deflate(_resolvedPadding!);

    final indentWidth = textDirection == TextDirection.ltr
        ? _resolvedPadding!.left
        : _resolvedPadding!.right;

    body!.layout(innerConstraints, parentUsesSize: true);
    (body!.parentData as BoxParentData).offset =
        Offset(_resolvedPadding!.left, _resolvedPadding!.top);

    if (_buttonAdd != null) {
      final buttonConstraints = innerConstraints.copyWith(
          minWidth: 0, maxWidth: buttonWidth, maxHeight: body!.size.height);
      _buttonAdd!.layout(buttonConstraints, parentUsesSize: true);

      var buttonMargin = 5;
      void resolveMargin() {
        if (_buttonAdd!.size.height + buttonMargin + buttonMargin >
                body!.size.height &&
            buttonMargin != 0) {
          buttonMargin--;
          resolveMargin();
        }
      }

      resolveMargin();

      (_buttonAdd!.parentData as BoxParentData).offset =
          Offset(0, _resolvedPadding!.top + buttonMargin);
    }

    if (_buttonOption != null) {
      final buttonConstraints = innerConstraints.copyWith(
          minWidth: 0, maxWidth: buttonWidth, maxHeight: body!.size.height);
      _buttonOption!.layout(buttonConstraints, parentUsesSize: true);

      var buttonMargin = 5;
      void resolveMargin() {
        if (_buttonOption!.size.height + buttonMargin + buttonMargin >
                body!.size.height &&
            buttonMargin != 0) {
          buttonMargin--;
          resolveMargin();
        }
      }

      resolveMargin();

      (_buttonOption!.parentData as BoxParentData).offset =
          Offset(buttonWidth, _resolvedPadding!.top + buttonMargin);
    }

    if (_leading != null) {
      final double buttonOffset = _buttonOption != null
          ? _buttonOption!.size.width * 2 + buttonRightMargin
          : 0;
      final leadingConstraints = innerConstraints.copyWith(
          minWidth: indentWidth - buttonWidth * 2 - buttonRightMargin,
          maxWidth: indentWidth,
          maxHeight: body!.size.height);
      _leading!.layout(leadingConstraints, parentUsesSize: true);
      (_leading!.parentData as BoxParentData).offset =
          Offset(buttonOffset, _resolvedPadding!.top);
    }

    size = constraints.constrain(Size(
      _resolvedPadding!.left + body!.size.width + _resolvedPadding!.right,
      _resolvedPadding!.top + body!.size.height + _resolvedPadding!.bottom,
    ));

    _computeCaretPrototype();
  }

  CursorPainter get _cursorPainter => CursorPainter(
        body,
        cursorCont.style,
        _caretPrototype!,
        cursorCont.color.value,
        devicePixelRatio,
      );

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_buttonAdd != null && (onHover || isLineSelected)) {
      final parentData = _buttonAdd!.parentData as BoxParentData;
      final effectiveOffset = offset + parentData.offset;
      context.paintChild(_buttonAdd!, effectiveOffset);
    }

    if (_buttonOption != null && (onHover || isLineSelected)) {
      final parentData = _buttonOption!.parentData as BoxParentData;
      final effectiveOffset = offset + parentData.offset;
      context.paintChild(_buttonOption!, effectiveOffset);
    }

    if (_leading != null) {
      final parentData = _leading!.parentData as BoxParentData;
      final effectiveOffset = offset + parentData.offset;

      context.paintChild(_leading!, effectiveOffset);
    }

    if (body != null) {
      final parentData = body!.parentData as BoxParentData;
      final effectiveOffset = offset + parentData.offset;
      if (enableInteractiveSelection &&
          line.documentOffset <= textSelection.end &&
          textSelection.start <= line.documentOffset + line.length - 1) {
        final local = localSelection(line, textSelection, false);
        _selectedRects ??= body!.getBoxesForSelection(
          local,
        );
        _paintSelection(context, effectiveOffset);
      }

      if (isLineSelected) {
        _paintLineBody(context, effectiveOffset, _lineSelectColor);
      }

      if (hasFocus &&
          cursorCont.show.value &&
          containsCursor() &&
          !cursorCont.style.paintAboveText) {
        _paintCursor(context, effectiveOffset);
      }

      context.paintChild(body!, effectiveOffset);

      if (hasFocus &&
          cursorCont.show.value &&
          containsCursor() &&
          cursorCont.style.paintAboveText) {
        _paintCursor(context, effectiveOffset);
      }
    }
  }

  void _paintSelection(PaintingContext context, Offset effectiveOffset) {
    assert(_selectedRects != null);
    final paint = Paint()..color = color;
    for (final box in _selectedRects!) {
      context.canvas.drawRect(box.toRect().shift(effectiveOffset), paint);
    }
  }

  void _paintLineBody(
      PaintingContext context, Offset effectiveOffset, Color color) {
    final paint = Paint()..color = color;
    final box = Rect.fromLTRB(
        effectiveOffset.dx,
        effectiveOffset.dy,
        effectiveOffset.dx + body!.size.width,
        effectiveOffset.dy + body!.size.height);
    context.canvas.drawRect(box, paint);
  }

  void _paintCursor(PaintingContext context, Offset effectiveOffset) {
    final position = TextPosition(
      offset: textSelection.extentOffset - line.documentOffset,
      affinity: textSelection.base.affinity,
    );
    _cursorPainter.paint(context.canvas, effectiveOffset, position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_buttonOption != null || hoveredCallback != null) {
      for (RenderBox? child in [_buttonAdd, _buttonOption, _leading, body]) {
        if (child != null) {
          final parentData = child.parentData as BoxParentData;
          var isHit = result.addWithPaintOffset(
              offset: parentData.offset,
              position: position,
              hitTest: (BoxHitTestResult result, Offset tranformed) {
                assert(tranformed == position - parentData.offset);
                return child.hitTest(result, position: tranformed);
              });
          if (child == body && !isHit) {
            isHit = result.addWithPaintOffset(
                offset: parentData.offset,
                position: position,
                hitTest: (BoxHitTestResult result, Offset tranformed) {
                  assert(tranformed == position - parentData.offset);
                  return child.hitTest(result,
                      position: tranformed + Offset(_resolvedPadding!.left, 0));
                });
          }
          if (isHit) {
            setHovered(true);
            return true;
          }
        }
      }
    }

    return false;
  }

  @override
  Rect getLocalRectForCaret(TextPosition position) {
    final caretOffset = getOffsetForCaret(position);
    var rect =
        Rect.fromLTWH(0, 0, cursorWidth, cursorHeight).shift(caretOffset);
    final cursorOffset = cursorCont.style.offset;
    // Add additional cursor offset (generally only if on iOS).
    if (cursorOffset != null) rect = rect.shift(cursorOffset);
    return rect;
  }

  @override
  TextPosition globalToLocalPosition(TextPosition position) {
    assert(getContainer().containsOffset(position.offset),
        'The provided text position is not in the current node');
    return TextPosition(
      offset: position.offset - getContainer().documentOffset,
      affinity: position.affinity,
    );
  }

  @override
  MouseCursor get cursor => MouseCursor.defer;

  @override
  PointerEnterEventListener? get onEnter => (event) {
        // do nothing : hover handled on hitTestChildren
      };

  @override
  PointerExitEventListener? get onExit => (event) {
        if (_buttonOption != null || hoveredCallback != null) {
          setHovered(false);
        }
      };

  @override
  bool get validForMouseTracker => true;
}

class _TextLineElement extends RenderObjectElement {
  _TextLineElement(EditableTextLine line) : super(line);

  final Map<TextLineSlot, Element> _slotToChildren = <TextLineSlot, Element>{};

  @override
  EditableTextLine get widget => super.widget as EditableTextLine;

  @override
  RenderEditableTextLine get renderObject =>
      super.renderObject as RenderEditableTextLine;

  @override
  void visitChildren(ElementVisitor visitor) {
    _slotToChildren.values.forEach(visitor);
  }

  @override
  void forgetChild(Element child) {
    assert(_slotToChildren.containsValue(child));
    assert(child.slot is TextLineSlot);
    assert(_slotToChildren.containsKey(child.slot));
    _slotToChildren.remove(child.slot);
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _mountChild(widget.buttonAdd, TextLineSlot.BUTTON_ADD);
    _mountChild(widget.buttonOption, TextLineSlot.BUTTON_OPTION);
    _mountChild(widget.leading, TextLineSlot.LEADING);
    _mountChild(widget.body, TextLineSlot.BODY);
  }

  @override
  void update(EditableTextLine newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _updateChild(widget.buttonAdd, TextLineSlot.BUTTON_ADD);
    _updateChild(widget.buttonOption, TextLineSlot.BUTTON_OPTION);
    _updateChild(widget.leading, TextLineSlot.LEADING);
    _updateChild(widget.body, TextLineSlot.BODY);
  }

  @override
  void insertRenderObjectChild(RenderBox child, TextLineSlot? slot) {
    // assert(child is RenderBox);
    _updateRenderObject(child, slot);
    assert(renderObject.children.keys.contains(slot));
  }

  @override
  void removeRenderObjectChild(RenderObject child, TextLineSlot? slot) {
    assert(child is RenderBox);
    assert(renderObject.children[slot!] == child);
    _updateRenderObject(null, slot);
    assert(!renderObject.children.keys.contains(slot));
  }

  @override
  void moveRenderObjectChild(
      RenderObject child, dynamic oldSlot, dynamic newSlot) {
    throw UnimplementedError();
  }

  void _mountChild(Widget? widget, TextLineSlot slot) {
    final oldChild = _slotToChildren[slot];
    final newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      _slotToChildren.remove(slot);
    }
    if (newChild != null) {
      _slotToChildren[slot] = newChild;
    }
  }

  void _updateRenderObject(RenderBox? child, TextLineSlot? slot) {
    switch (slot) {
      case TextLineSlot.BUTTON_ADD:
        renderObject.setButtonAdd(child);
        break;
      case TextLineSlot.BUTTON_OPTION:
        renderObject.setButtonOption(child);
        break;
      case TextLineSlot.LEADING:
        renderObject.setLeading(child);
        break;
      case TextLineSlot.BODY:
        renderObject.setBody(child as RenderContentProxyBox?);
        break;
      default:
        throw UnimplementedError();
    }
  }

  void _updateChild(Widget? widget, TextLineSlot slot) {
    final oldChild = _slotToChildren[slot];
    final newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      _slotToChildren.remove(slot);
    }
    if (newChild != null) {
      _slotToChildren[slot] = newChild;
    }
  }
}
