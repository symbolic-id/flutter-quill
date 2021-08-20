import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/src/utils/color.dart';

class SymToolbarIconButton extends StatelessWidget {
  const SymToolbarIconButton(
      {required this.onPressed,
      required this.icon,
      this.size = DEFAULT_BUTTON_SIZE,
      this.fillColor = SymColors.light_backgroundSurfaceOne,
      this.hoverElevation = 1,
      this.highlightElevation = 1,
      Key? key})
      : super(key: key);

  static const DEFAULT_BUTTON_SIZE = 48.0;
  static const DEFAULT_ICON_SIZE = 20.0;

  final VoidCallback? onPressed;
  final Widget icon;
  final double size;
  final Color fillColor;
  final double hoverElevation;
  final double highlightElevation;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: size, height: size),
      child: RawMaterialButton(
        visualDensity: VisualDensity.compact,
        shape: const CircleBorder(),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        fillColor: fillColor,
        elevation: 0,
        hoverElevation: hoverElevation,
        highlightElevation: highlightElevation,
        onPressed: onPressed,
        child: icon,
      ),
    );
  }
}
