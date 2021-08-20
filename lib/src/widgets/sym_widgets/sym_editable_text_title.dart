// import 'package:flutter/widgets.dart';
// import 'package:tuple/tuple.dart';
//
// import '../cursor.dart';
// import 'sym_title_widgets/sym_render_editable_text_title.dart';
// import 'sym_title_widgets/sym_text_title_element.dart';
// import 'sym_title_widgets/sym_title.dart';
// import 'sym_title_widgets/sym_title_button.dart';
//
// class SymEditableTextTitle extends RenderObjectWidget {
//   const SymEditableTextTitle(
//       Key key,
//       this.title,
//       this.buttonTag,
//       this.buttonCover,
//       this.buttonSticker,
//       this.body,
//       this.verticalSpacing,
//       this.textDirection,
//       this.textSelection,
//       this.color,
//       this.enableInteractiveSelection,
//       this.hasFocus,
//       this.devicePixelRatio,
//       this.cursorCont)
//       : super(key: key);
//
//   final SymTitle title;
//   final SymTitleButton buttonTag;
//   final SymTitleButton buttonCover;
//   final SymTitleButton buttonSticker;
//   final Widget body;
//   final Tuple2 verticalSpacing;
//   final TextDirection textDirection;
//   final TextSelection textSelection;
//   final Color color;
//   final bool enableInteractiveSelection;
//   final bool hasFocus;
//   final double devicePixelRatio;
//   final CursorCont cursorCont;
//
//   @override
//   RenderObjectElement createElement() {
//     return SymTextTitleElement(this);
//   }
//
//   @override
//   RenderObject createRenderObject(BuildContext context) {
//     return SymRenderEditableTextTitle(
//         title,
//         textDirection,
//         textSelection,
//         enableInteractiveSelection,
//         hasFocus,
//         devicePixelRatio,
//         _getPadding(),
//         SymTitleButton.buttonHeight,
//         color,
//         cursorCont);
//   }
//
//   @override
//   void updateRenderObject(
//       BuildContext context, SymRenderEditableTextTitle renderObject) {
//     renderObject
//       ..setTitle(title)
//       ..setPadding(_getPadding())
//       ..setTextDirection(textDirection)
//       ..setTextSelection(textSelection)
//       ..setColor(color)
//       ..setEnableInteractiveSelection(enableInteractiveSelection)
//       ..hasFocus = hasFocus
//       ..setDevicePixelRatio(devicePixelRatio)
//       ..setCursorCont(cursorCont);
//   }
//
//   EdgeInsetsGeometry _getPadding() {
//     return EdgeInsetsDirectional.only(
//         top: verticalSpacing.item1, bottom: verticalSpacing.item2);
//   }
// }
