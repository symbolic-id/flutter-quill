import 'package:flutter/widgets.dart';
import '../../box.dart';
import '../sym_editable_text_title.dart';
import 'sym_render_editable_text_title.dart';

enum SymTextTitleSlot { BUTTON_TAG, BUTTON_COVER, BUTTON_STICKER, BODY }

@Deprecated("Not used yet")
class SymTextTitleElement extends RenderObjectElement {
  SymTextTitleElement(SymEditableTextTitle title) : super(title);

  final Map<SymTextTitleSlot, Element> _slotToChildren =
      <SymTextTitleSlot, Element>{};

  @override
  SymEditableTextTitle get widget => super.widget as SymEditableTextTitle;

  @override
  SymRenderEditableTextTitle get renderObject =>
      super.renderObject as SymRenderEditableTextTitle;
  
  @override
  void visitChildren(ElementVisitor visitor) {
    _slotToChildren.values.forEach(visitor);
  }
  
  @override
  void forgetChild(Element child) {
    assert(_slotToChildren.containsValue(child));
    assert(child.slot is SymTextTitleSlot);
    assert(_slotToChildren.containsKey(child.slot));
    _slotToChildren.remove(child.slot);
    super.forgetChild(child);
  }
  
  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _mountChild(widget.buttonTag, SymTextTitleSlot.BUTTON_TAG);
    _mountChild(widget.buttonCover, SymTextTitleSlot.BUTTON_COVER);
    _mountChild(widget.buttonSticker, SymTextTitleSlot.BUTTON_STICKER);
    _mountChild(widget.body, SymTextTitleSlot.BODY);
  }
  
  @override
  void update(covariant RenderObjectWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _updateChild(widget.buttonTag, SymTextTitleSlot.BUTTON_TAG);
    _updateChild(widget.buttonCover, SymTextTitleSlot.BUTTON_COVER);
    _updateChild(widget.buttonSticker, SymTextTitleSlot.BUTTON_STICKER);
    _updateChild(widget.body, SymTextTitleSlot.BODY);
  }

  @override
  void insertRenderObjectChild(RenderBox child, SymTextTitleSlot? slot) {
    _updateRenderObject(child, slot);
    assert(renderObject.children.keys.contains(slot));
  }

  @override
  void removeRenderObjectChild(RenderObject child, SymTextTitleSlot? slot) {
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
  
  void _mountChild(Widget? widget, SymTextTitleSlot slot) {
    final oldChild = _slotToChildren[slot];
    final newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      _slotToChildren.remove(slot);
    }
    if (newChild != null) {
      _slotToChildren[slot] = newChild;
    }
  }
  
  void _updateRenderObject(RenderBox? child, SymTextTitleSlot? slot) {
    switch (slot) {
      case SymTextTitleSlot.BUTTON_TAG:
        renderObject.setButtonTag(child);
        break;
      case SymTextTitleSlot.BUTTON_COVER:
        renderObject.setButtonCover(child);
        break;
      case SymTextTitleSlot.BUTTON_STICKER:
        renderObject.setButtonSticker(child);
        break;
      case SymTextTitleSlot.BODY:
        renderObject.setBody(child as RenderContentProxyBox?);
        break;
      default:
        throw UnimplementedError();
    }
  }

  void _updateChild(Widget? widget, SymTextTitleSlot slot) {
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
