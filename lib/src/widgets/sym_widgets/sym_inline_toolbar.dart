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
  );

  final TextSelection selection;
  final RenderEditor renderObject;
  final TextSelectionDelegate selectionDelegate;
  final QuillController controller;

  @override
  _SymInlineToolbarState createState() => _SymInlineToolbarState();
}

class _SymInlineToolbarState extends State<SymInlineToolbar> {
  @override
  Widget build(BuildContext context) {
    final endpoints = widget.renderObject
        .getEndpointsForSelection(widget.selection);

    final editingRegion = Rect.fromPoints(
      widget.renderObject.localToGlobal(Offset.zero),
      widget.renderObject.localToGlobal(
          widget.renderObject.size.bottomRight(Offset.zero)),
    );

    final baseLineHeight = widget.renderObject
        .preferredLineHeight(widget.selection.base);
    final extentLineHeight =
    widget.renderObject.preferredLineHeight(widget.selection.extent);
    final smallestLineHeight = math.min(baseLineHeight, extentLineHeight);
    final isMultiline = endpoints.last.point.dy - endpoints.first.point.dy >
        smallestLineHeight / 2;

    final midX = isMultiline
        ? editingRegion.width / 2
        : (endpoints.first.point.dx + endpoints.last.point.dx) / 2;

    final midpoint = Offset(
      midX,
      endpoints[0].point.dy - baseLineHeight,
    );

    return Visibility(
      visible: widget.selection.baseOffset != widget.selection.extentOffset,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
                left: midpoint.dx -
                    ((2) * _toggledButtonSize / 2),
                top: midpoint.dy + baseLineHeight / 2,
                child: FractionalTranslation(
                    translation: const Offset(0, -0.2),
                    child: Material(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(color: SymColors.light_line
                          )
                      ),
                      elevation: 5,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        height: _toggledButtonSize,
                        width: _toggledButtonSize * 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _symToggleStyleButton(
                                assetName: Assets.FORMAT_BOLD,
                                onAfterPressed: () { setState(() {}); },
                                tooltipLabel: 'Bold',
                                controller: widget.controller,
                                attribute: Attribute.bold
                            ),
                            _symToggleStyleButton(
                                assetName: Assets.FORMAT_ITALIC,
                                onAfterPressed: () { setState(() {}); },
                                tooltipLabel: 'Italic',
                                controller: widget.controller,
                                attribute: Attribute.italic
                            ),
                            _symToggleStyleButton(
                                assetName: Assets.FORMAT_STRIKETHROUGH,
                                onAfterPressed: () { setState(() {}); },
                                tooltipLabel: 'Strikethrough',
                                controller: widget.controller,
                                attribute: Attribute.strikeThrough
                            ),
                            _symToggleStyleButton(
                                assetName: Assets.FORMAT_INLINECODE,
                                onAfterPressed: () { setState(() {}); },
                                tooltipLabel: 'Code',
                                controller: widget.controller,
                                attribute: Attribute.underline
                            ),
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
                    )
                )
            )
          ],
        ),
      ),
    );
  }
}

Widget _symToggleStyleButton({
  required String assetName,
  required Function onAfterPressed,
  required String tooltipLabel,
  required QuillController controller,
  required Attribute attribute
}) {
  final selectionStyle = controller.getSelectionStyle();
  final isToggled = selectionStyle.containsKey(attribute.key);

  return Tooltip(
    message: tooltipLabel,
    child: TextButton(
      onPressed: () {
          if (isToggled) {
            controller.formatSelection(
                Attribute.clone(attribute, null));
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