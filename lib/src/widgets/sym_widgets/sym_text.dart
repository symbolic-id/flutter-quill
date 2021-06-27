import 'package:flutter/widgets.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:google_fonts/google_fonts.dart';

class SymText extends StatelessWidget {
  const SymText(
      this.text,
      {
        this.size = 12,
        this.color = SymColors.light_textPrimary,
        this.bold = false,
        this.align,
        Key? key
      }): super(key: key);

  final String text;
  final double size;
  final Color color;
  final bool bold;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.ibmPlexSans()
      .merge(
        TextStyle(
          fontSize: size,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        )
      ),
      textAlign: align,
    );
  }
}