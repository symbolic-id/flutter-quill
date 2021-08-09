import 'package:flutter/services.dart';
import 'package:flutter/src/painting/edge_insets.dart';
import 'package:flutter/src/widgets/editable_text.dart';
import 'package:flutter/src/widgets/focus_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_text.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_title_widgets/sym_title_widget.dart';
import '../sym_text.dart';

class SymTitleFace extends SymTitleWidget {
  SymTitleFace(FocusNode focusNode, EdgeInsetsGeometry padding,
      Function onSubmitted, TextEditingController controller)
      : super(focusNode, padding, onSubmitted, controller);

  @override
  _SymTitleFaceState createState() => _SymTitleFaceState();
}

class _SymTitleFaceState extends State<SymTitleFace> {
  var isExitedByArrow = false;

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
          if (!isExitedByArrow) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              isExitedByArrow = true;
              widget.onSubmitted();
            }
          }
        },
        child: SymTextField(
          'Apa kabar hari ini?',
          focusNode: widget.focusNode,
          size: 16,
          bold: true,
          padding: EdgeInsets.only(
            left: (widget.padding as EdgeInsets).left,
            right: (widget.padding as EdgeInsets).right
          ),
          onSubmitted: widget.onSubmitted,
          controller: widget.controller,
        )
    );
  }



}
