import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/src/widgets/common_widgets/gap.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_title_widgets/sym_title_button.dart';

import '../sym_text.dart';
import 'sym_title_widget.dart';

class SymTitleKalpataruMobile extends SymTitleWidget {
  SymTitleKalpataruMobile(
      {required FocusNode focusNode,
      required EdgeInsetsGeometry padding,
      required Function onSubmitted,
      required TextEditingController controller})
      : super(focusNode, padding, onSubmitted, controller);

  @override
  _SymTitleKalpataruMobileState createState() =>
      _SymTitleKalpataruMobileState();
}

class _SymTitleKalpataruMobileState extends State<SymTitleKalpataruMobile> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}
