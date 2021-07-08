import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:google_fonts/google_fonts.dart';

class SymText extends StatelessWidget {
  const SymText(this.text,
      {this.size = 12,
      this.color = SymColors.light_textPrimary,
      this.bold = false,
      this.align,
      Key? key})
      : super(key: key);

  final String text;
  final double size;
  final Color color;
  final bool bold;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _symTextStyle(size, color, bold),
      textAlign: align,
    );
  }
}

class SymTextField extends StatefulWidget {
  const SymTextField(this.hint,
      {required this.focusNode,
      required this.padding,
      this.size = 12,
      this.color = SymColors.light_textPrimary,
      this.bold = false,
      this.align,
      this.onSubmitted,
      this.controller,
      Key? key})
      : super(key: key);

  final String hint;
  final double size;
  final Color color;
  final bool bold;
  final TextAlign? align;
  final EdgeInsetsGeometry padding;
  final TextEditingController? controller;

  final FocusNode? focusNode;
  final Function? onSubmitted;

  @override
  _SymTextFieldState createState() => _SymTextFieldState();
}

class _SymTextFieldState extends State<SymTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: widget.padding,
          hintText: widget.hint,
          hintStyle: _symTextStyle(
              widget.size, SymColors.light_textQuaternary, widget.bold)),
      style: _symTextStyle(widget.size, widget.color, widget.bold),
      textAlign: widget.align ?? TextAlign.start,
      maxLines: null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onChanged: (text) {
        // widget.controller?.text = text;
        // widget.controller?.selection = widget.controller?.selection ??
        //     const TextSelection.collapsed(offset: 0);
      },
      onSubmitted: (value) {
        widget.onSubmitted?.call();
      },
    );
  }
}

TextStyle _symTextStyle(double size, Color color, bool bold) {
  return GoogleFonts.ibmPlexSans().merge(TextStyle(
    fontSize: size,
    color: color,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
  ));
}
