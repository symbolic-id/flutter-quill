import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../utils/assets.dart';
import '../../models/documents/attribute.dart';
import '../../utils/color.dart';
import '../controller.dart';
import '../editor.dart';
import 'sym_asset_image.dart';

const double _toggledButtonSize = 48;

class SymInlineToolbar extends StatefulWidget {
  const SymInlineToolbar(
    this.selection,
    this.renderObject,
    this.selectionDelegate,
    this.controller,
    this.toolbarLayerLink,
  );

  final TextSelection selection;
  final RenderEditor renderObject;
  final TextSelectionDelegate selectionDelegate;
  final QuillController controller;
  final LayerLink toolbarLayerLink;

  @override
  _SymInlineToolbarState createState() => _SymInlineToolbarState();
}

class _SymInlineToolbarState extends State<SymInlineToolbar> {
  @override
  Widget build(BuildContext context) {
    const buttonCount = 4;
    const containerWidth = _toggledButtonSize * (buttonCount + 1);

    final endpoints =
        widget.renderObject.getEndpointsForSelection(widget.selection);

    final editingRegion = Rect.fromPoints(
      widget.renderObject.localToGlobal(Offset.zero),
      widget.renderObject
          .localToGlobal(widget.renderObject.size.bottomRight(Offset.zero)),
    );

    final baseLineHeight =
        widget.renderObject.preferredLineHeight(widget.selection.base);
    final extentLineHeight =
        widget.renderObject.preferredLineHeight(widget.selection.extent);
    final smallestLineHeight = math.min(baseLineHeight, extentLineHeight);
    final isMultiline = endpoints.last.point.dy - endpoints.first.point.dy >
        smallestLineHeight / 2;

    var midX = /*isMultiline
        ? editingRegion.left + editingRegion.width / 2
        :*/ editingRegion.left +
            (endpoints.first.point.dx + endpoints.last.point.dx) / 2;

    final midpoint = Offset(
      midX,
      endpoints[0].point.dy - baseLineHeight,
    );

    const paddingToolbar = 40;

    final topOffset = midpoint.dy + editingRegion.top - paddingToolbar;

    var leftOffset = midpoint.dx - (containerWidth / 2);

    if (leftOffset + containerWidth > editingRegion.right) {
      leftOffset = editingRegion.right - containerWidth;
    }

    return CompositedTransformFollower(
      link: widget.toolbarLayerLink,
      offset: -editingRegion.topLeft,
      child: Visibility(
        visible: widget.selection.baseOffset != widget.selection.extentOffset &&
            topOffset > 0,
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                  left: leftOffset,
                  top: topOffset,
                  child: FractionalTranslation(
                      translation: const Offset(0, -0.2),
                      child: Material(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            side: BorderSide(color: SymColors.light_line)),
                        elevation: 5,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          height: _toggledButtonSize,
                          width: containerWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SymToggleStyleButton(
                                  assetName: Assets.FORMAT_BOLD,
                                  onAfterPressed: () {
                                    setState(() {});
                                  },
                                  tooltipLabel: 'Bold',
                                  controller: widget.controller,
                                  attribute: Attribute.bold),
                              SymToggleStyleButton(
                                  assetName: Assets.FORMAT_ITALIC,
                                  onAfterPressed: () {
                                    setState(() {});
                                  },
                                  tooltipLabel: 'Italic',
                                  controller: widget.controller,
                                  attribute: Attribute.italic),
                              SymToggleStyleButton(
                                  assetName: Assets.FORMAT_STRIKETHROUGH,
                                  onAfterPressed: () {
                                    setState(() {});
                                  },
                                  tooltipLabel: 'Strikethrough',
                                  controller: widget.controller,
                                  attribute: Attribute.strikeThrough),
                              SymToggleStyleButton(
                                  assetName: Assets.FORMAT_INLINECODE,
                                  onAfterPressed: () {
                                    setState(() {});
                                  },
                                  tooltipLabel: 'Code',
                                  controller: widget.controller,
                                  attribute: Attribute.underline),
                              // Container(
                              //   width: 1,
                              //   color: SymColors.light_line,
                              //   margin: const EdgeInsets.symmetric(vertical: 8),
                              // ),
                              // TextButton(
                              //   onPressed: () {
                              //     widget.selectionDelegate.hideToolbar();
                              //   },
                              //   child: const SymAssetImage(
                              //     Assets.MORE,
                              //     size: Size(20, 20),
                              //     color: SymColors.light_textPrimary,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}

Widget SymToggleStyleButton(
    {required String assetName,
    required Function onAfterPressed,
    required String tooltipLabel,
    required QuillController controller,
    required Attribute attribute}) {
  final selectionStyle = controller.getSelectionStyle();
  final isToggled = selectionStyle.containsKey(attribute.key);

  return Tooltip(
    message: tooltipLabel,
    child: TextButton(
      onPressed: () {
        if (isToggled) {
          controller.formatSelection(Attribute.clone(attribute, null));
        } else {
          controller.formatSelection(attribute);
        }
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          onAfterPressed();
        });
      },
      child: SymAssetImage(
        assetName,
        size: const Size(20, 20),
        color: isToggled ? SymColors.light_textPrimary : null,
      ),
    ),
  );
}

class InlineToolbarDelegate extends SingleChildLayoutDelegate {
  final Size anchorSize;

  // ignore: sort_constructors_first
  InlineToolbarDelegate(this.anchorSize);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // we allow our child to be smaller than parent's constraint:
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0, 0);
  }

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return true;
  }
}
