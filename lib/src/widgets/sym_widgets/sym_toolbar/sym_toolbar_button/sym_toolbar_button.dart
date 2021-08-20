import 'package:flutter/cupertino.dart';
import '../../sym_asset_image.dart';
import 'sym_toolbar_icon_button.dart';

class SymToolbarButton extends StatelessWidget {
  const SymToolbarButton({
    required this.iconAssetName,
    required this.onPressed
  });

  final String iconAssetName;
  final VoidCallback onPressed;
  // final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return SymToolbarIconButton(
      onPressed: onPressed,
      icon: SymAssetImage(
        iconAssetName,
        size: const Size(SymToolbarIconButton.DEFAULT_ICON_SIZE,
            SymToolbarIconButton.DEFAULT_ICON_SIZE),
      ),
      highlightElevation: 0,
      hoverElevation: 0,
    );
  }
}
