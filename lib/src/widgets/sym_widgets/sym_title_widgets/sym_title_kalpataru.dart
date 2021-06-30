import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/src/widgets/common_widgets/gap.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_title_widgets/sym_title_button.dart';

import '../sym_text.dart';

class SymTitleKalpataru extends StatefulWidget {
  const SymTitleKalpataru(
      {required this.focusNode,
      required this.padding,
      required this.onSubmitted});

  final FocusNode focusNode;
  final EdgeInsetsGeometry padding;
  final Function onSubmitted;

  @override
  _SymTitleKalpataruState createState() => _SymTitleKalpataruState();
}

class _SymTitleKalpataruState extends State<SymTitleKalpataru> {
  var isHovered = false;

  var isExitedByArrow = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.requestFocus();
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (!isExitedByArrow) {
          if (
            event.logicalKey == LogicalKeyboardKey.arrowDown
          ) {
            isExitedByArrow = true;
            widget.onSubmitted();
          }
        }
      },
      child: MouseRegion(
        onHover: (_) {
          if (!isHovered) {
            setState(() {
              isHovered = true;
            });
          }
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: widget.padding,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isHovered ? 1 : 0,
                child: Row(
                  children: [
                    SymTitleButton.typeTag(),
                    GapH(7),
                    SymTitleButton.typeCover(),
                    GapH(7),
                    SymTitleButton.typeSticker(),
                  ],
                ),
              ),
            ),
            GapV(12),
            SymTextField(
              'Buat Judul',
              focusNode: widget.focusNode,
              size: 28,
              bold: true,
              padding: EdgeInsets.only(
                left: (widget.padding as EdgeInsets).left,
                right: (widget.padding as EdgeInsets).right
              ),
              onSubmitted: widget.onSubmitted,
            )
          ],
        ),
      ),
    );
  }

  void _onFocusChanged() {
    if (widget.focusNode.hasFocus) {
      isExitedByArrow = false;
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }
}
