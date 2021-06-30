import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_block_button.dart';

import '../../../models/documents/nodes/container.dart' as container;
import '../../box.dart';
import '../../cursor.dart';
import '../../text_selection.dart';
import 'sym_text_title_element.dart';
import 'sym_title.dart';

@Deprecated("Not used yet")
class SymRenderEditableTextTitle extends RenderEditableBox
    implements MouseTrackerAnnotation {
  SymRenderEditableTextTitle(this.title,
      this.textDirection,
      this.textSelection,
      this.enableInteractiveSelection,
      this.hasFocus,
      this.devicePixelRatio,
      this.padding,
      this.buttonHeight,
      this.color,
      this.cursorCont,);

  RenderBox? _buttonTag;
  RenderBox? _buttonCover;
  RenderBox? _buttonSticker;
  RenderContentProxyBox? body;
  SymTitle title;
  TextDirection textDirection;
  TextSelection textSelection;
  Color color;
  bool enableInteractiveSelection;
  bool hasFocus = false;
  double devicePixelRatio;
  EdgeInsetsGeometry padding;
  double buttonHeight;
  CursorCont cursorCont;
  EdgeInsets? _resolvedPadding;
  bool? _containsCursor;
  List<TextBox>? _selectedRects;
  Rect? _caretPrototype;
  final Map<SymTextTitleSlot, RenderBox> children =
  <SymTextTitleSlot, RenderBox>{};

  final buttonBottomMargin = 12;

  bool _onHover = false;

  bool get onHover => _onHover;

  void setHovered(bool isHovered) {
    if (_onHover != isHovered) {
      _onHover = isHovered;
      markNeedsPaint();
    }
  }

  Iterable<RenderBox> get _children sync* {
    if (_buttonTag != null) {
      yield _buttonTag!;
    }
    if (_buttonCover != null) {
      yield _buttonCover!;
    }
    if (_buttonSticker != null) {
      yield _buttonSticker!;
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
    _resolvedPadding == null;
    markNeedsLayout();
  }

  void setTitle(SymTitle t) {
    if (title == t) {
      return;
    }
    title = t;
    _containsCursor == null;
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

  void setButtonTag(RenderBox? btn) {
    _buttonTag = _updateChild(_buttonTag, btn, SymTextTitleSlot.BUTTON_TAG);
  }

  void setButtonCover(RenderBox? btn) {
    _buttonCover =
        _updateChild(_buttonCover, btn, SymTextTitleSlot.BUTTON_COVER);
  }

  void setButtonSticker(RenderBox? btn) {
    _buttonSticker =
        _updateChild(_buttonSticker, btn, SymTextTitleSlot.BUTTON_STICKER);
  }

  void setBody(RenderContentProxyBox? b) {
    body =
    _updateChild(body, b, SymTextTitleSlot.BODY) as RenderContentProxyBox?;
  }

  bool containsTextSelection() {
    return title.documentOffset <= textSelection.end &&
        textSelection.start <= title.documentOffset + title.length - 1;
  }

  bool containsCursor() {
    return _containsCursor ??= textSelection.isCollapsed &&
        title.containsOffset(textSelection.baseOffset);
  }

  RenderBox? _updateChild(RenderBox? old, RenderBox? newChild,
      SymTextTitleSlot slot) {
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

    if (_buttonCover != null) {
      _resolvedPadding = _resolvedPadding!
          .add(EdgeInsets.only(top: buttonHeight + buttonBottomMargin))
      as EdgeInsets?;
    }

    _resolvedPadding = _resolvedPadding!
        .add(EdgeInsets.only(left: SymBlockButton.buttonWidth * 2)) as EdgeInsets?;

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

  TextSelectionPoint _getEndpointForSelection(TextSelection textSelection,
      bool first) {
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
    final titleDy = getOffsetForCaret(position)
        .translate(0, 0.5 * preferredLineHeight(position))
        .dy;
    final titleBoxes = _getBoxes(
        TextSelection(baseOffset: 0, extentOffset: title.length - 1))
        .where((element) => element.top < titleDy && element.bottom > titleDy)
        .toList(growable: false);
    return TextRange(
        start:
        getPositionForOffset(Offset(titleBoxes.first.left, titleDy)).offset,
        end: getPositionForOffset(Offset(titleBoxes.last.right, titleDy))
            .offset);
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
    assert(textPosition.offset < title.length);
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
    return title;
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

    add(_buttonTag, 'buttonTag');
    add(_buttonCover, 'buttonCover');
    add(_buttonSticker, 'buttonSticker');
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
    final bodyWidth = body == null
        ? 0
        : body!.getMinIntrinsicWidth(height - verticalPadding).ceil();
    return horizontalPadding + bodyWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolvePadding();
    final horizontalPadding = _resolvedPadding!.left + _resolvedPadding!.right;
    final verticalPadding = _resolvedPadding!.top + _resolvedPadding!.bottom;
    final bodyWidth = body == null
        ? 0
        : body!.getMinIntrinsicWidth(height - verticalPadding).ceil();
    return horizontalPadding + bodyWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _resolvePadding();
    final horizontalPadding = _resolvedPadding!.left + _resolvedPadding!.right;
    final verticalPadding = _resolvedPadding!.top + _resolvedPadding!.bottom;

    final buttonHeight = _buttonTag == null
        ? 0
        : _buttonCover!.getMinIntrinsicHeight(width - horizontalPadding).ceil();

    return verticalPadding + buttonHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _resolvePadding();
    final horizontalPadding = _resolvedPadding!.left + _resolvedPadding!.right;
    final verticalPadding = _resolvedPadding!.top + _resolvedPadding!.bottom;

    final buttonHeight = _buttonTag == null
        ? 0
        : _buttonCover!.getMinIntrinsicHeight(width - horizontalPadding).ceil();

    return verticalPadding + buttonHeight;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    _resolvePadding();
    return body!.getDistanceToActualBaseline(baseline)! + _resolvedPadding!.top;
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    _selectedRects = null;

    _resolvePadding();
    assert(_resolvedPadding != null);

    if (body == null) {
      size = constraints.constrain(Size(
          _resolvedPadding!.left + _resolvedPadding!.right,
          _resolvedPadding!.top + _resolvedPadding!.bottom));
      return;
    }
    final innerConstrains = constraints.deflate(_resolvedPadding!);

    final indentWidth = textDirection == TextDirection.ltr
        ? _resolvedPadding!.left
        : _resolvedPadding!.right;

    assert(_buttonTag != null);

    const buttonMarginBetween = 4.0;

    final buttonConstrains = innerConstrains.copyWith(
        minWidth: 0, maxWidth: 150, maxHeight: buttonHeight);

    /* _buttonTag layout */
    _buttonTag!.layout(buttonConstrains, parentUsesSize: true);
    (_buttonTag!.parentData as BoxParentData).offset =
        Offset(0, _resolvedPadding!.top);

    /* _buttonCover layout */
    _buttonCover!.layout(buttonConstrains, parentUsesSize: true);
    (_buttonCover!.parentData as BoxParentData).offset = Offset(
        _buttonTag!.size.width + buttonMarginBetween, _resolvedPadding!.top);

    /* _buttonSticker layout */
    _buttonSticker!.layout(buttonConstrains, parentUsesSize: true);
    (_buttonSticker!.parentData as BoxParentData).offset = Offset(
        _buttonTag!.size.width +
            buttonMarginBetween +
            _buttonCover!.size.width +
            buttonMarginBetween,
        _resolvedPadding!.top);

    body!.layout(innerConstrains, parentUsesSize: true);
    (body!.parentData as BoxParentData).offset = Offset(_resolvedPadding!.left,
        _resolvedPadding!.top + _buttonCover!.size.height + buttonBottomMargin);

    size = constraints.constrain(Size(
        _resolvedPadding!.left + body!.size.width + _resolvedPadding!.right,
        _resolvedPadding!.top + body!.size.height + _resolvedPadding!.bottom
    ));

    _computeCaretPrototype();
  }

  CursorPainter get _cursorPainter =>
      CursorPainter(
          body,
          cursorCont.style,
          _caretPrototype!,
          cursorCont.color.value,
          devicePixelRatio
      );

  @override
  void paint(PaintingContext context, Offset offset) {
    if (onHover) {
      /* paint buttons */
      if (_buttonTag != null) {
        final parentData = _buttonTag!.parentData as BoxParentData;
        final effectiveOffset = offset + parentData.offset;
        context.paintChild(_buttonTag!, effectiveOffset);
      }

      if (_buttonCover != null) {
        final parentData = _buttonTag!.parentData as BoxParentData;
        final effectiveOffset = offset + parentData.offset;
        context.paintChild(_buttonTag!, effectiveOffset);
      }

      if (_buttonSticker != null) {
        final parentData = _buttonTag!.parentData as BoxParentData;
        final effectiveOffset = offset + parentData.offset;
        context.paintChild(_buttonTag!, effectiveOffset);
      }
    }

    if (body != null) {
      final parentData = body!.parentData as BoxParentData;
      final effectiveOffset = offset + parentData.offset;
      if (enableInteractiveSelection &&
          title.documentOffset <= textSelection.end &&
          textSelection.start <= title.documentOffset + title.length - 1) {
        final local = localSelection(title, textSelection, false);
        _selectedRects ??= body!.getBoxesForSelection(local);
        _paintSelection(context, effectiveOffset);
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

  void _paintCursor(PaintingContext context, Offset effectiveOffset) {
    final position = TextPosition(
      offset: textSelection.extentOffset - title.documentOffset,
      affinity: textSelection.base.affinity,
    );
    _cursorPainter.paint(context.canvas, effectiveOffset, position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (RenderBox? child in [_buttonSticker, _buttonCover, _buttonTag, body]) {
      if (child != null) {
        final parentData = child.parentData as BoxParentData;
        var isHit = result.addWithPaintOffset(
            offset: parentData.offset,
            position: position,
            hitTest: (BoxHitTestResult result, Offset tranformed) {
              assert(tranformed == position - parentData.offset);
              return child.hitTest(result, position: tranformed);
            });
        // if (child == body && !isHit) {
        //   isHit = result.addWithPaintOffset(
        //       offset: parentData.offset,
        //       position: position,
        //       hitTest: (BoxHitTestResult result, Offset tranformed) {
        //         assert(tranformed == position - parentData.offset);
        //         return child.hitTest(result,
        //             position: tranformed + Offset(0, _resolvedPadding!.top));
        //       });
        // }
        if (isHit) {
          setHovered(true);
          return true;
        }
      }
    }

    return false;
  }

  @override
  MouseCursor get cursor => MouseCursor.defer;

  @override
  PointerEnterEventListener? get onEnter => (event) {
    // do nothing : hover handled on hitTestChildren
  };

  @override
  PointerExitEventListener? get onExit => (event) {
    if (_buttonCover != null) {
      setHovered(false);
    }
  };

  @override
  bool get validForMouseTracker => true;
}
