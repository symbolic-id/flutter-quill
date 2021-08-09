import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common_widgets/gap.dart';
import 'sym_title_button.dart';

import '../sym_text.dart';
import 'sym_title_widget.dart';

class SymTitleKalpataru extends SymTitleWidget {
  SymTitleKalpataru(
      {required FocusNode focusNode,
      required EdgeInsetsGeometry padding,
      required Function onSubmitted,
      required TextEditingController controller})
      : super(focusNode, padding, onSubmitted, controller);

  @override
  _SymTitleKalpataruState createState() => _SymTitleKalpataruState();
}

class _SymTitleKalpataruState extends State<SymTitleKalpataru> {
  var isHovered = false;

  @override
  void initState() {
    super.initState();
    widget.init();
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (!widget.isExitedByArrow) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            widget.isExitedByArrow = true;
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
                  right: (widget.padding as EdgeInsets).right),
              onSubmitted: widget.onSubmitted,
              controller: widget.controller,
            )
          ],
        ),
      ),
    );
  }
}
