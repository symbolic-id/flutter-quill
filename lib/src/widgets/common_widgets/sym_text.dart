import 'package:flutter/widgets.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:google_fonts/google_fonts.dart';

class SymText extends StatelessWidget {
  const SymText(
      this.text,
      {
        this.textSize = 12,
        this.textColor = SymColors.light_textPrimary,
        this.bold = false,
        Key? key
      }): super(key: key);

  final String text;
  final double textSize;
  final Color textColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.ibmPlexSans()
      .merge(
        TextStyle(
          fontSize: textSize,
          color: textColor,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal
        )
      ),
    );
  }
}