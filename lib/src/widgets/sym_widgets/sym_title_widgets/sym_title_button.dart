import 'package:flutter/material.dart';

import '../../../../utils/assets.dart';
import '../../../utils/color.dart';
import '../../common_widgets/gap.dart';
import '../sym_asset_image.dart';
import '../sym_text.dart';

enum _ButtonType { TAG, COVER, STICKER }

class SymTitleButton extends StatefulWidget {
  const SymTitleButton(this.type);

  factory SymTitleButton.typeTag() => const SymTitleButton(_ButtonType.TAG);

  factory SymTitleButton.typeCover() => const SymTitleButton(_ButtonType.COVER);

  factory SymTitleButton.typeSticker() =>
      const SymTitleButton(_ButtonType.STICKER);

  static const buttonHeight = 26.0;

  final _ButtonType type;

  @override
  _SymTitleButton createState() => _SymTitleButton();
}

class _SymTitleButton extends State<SymTitleButton> {
  var _onHover = false;

  @override
  Widget build(BuildContext context) {
    final buttonRRadius = BorderRadius.circular(32);

    final String assetName;
    final String label;
    if (widget.type == _ButtonType.TAG) {
      assetName = Assets.HASHTAG_14PX;
      label = 'tambah tag';
    } else if (widget.type == _ButtonType.COVER) {
      assetName = Assets.IMAGE_14PX;
      label = 'tambah cover';
    } else {
      assetName = Assets.STICKER_HAPPY_14PX;
      label = 'tambah stiker';
    }
    final activeColor = SymColors.light_bluePrimary;
    final inactiveColor = SymColors.light_textQuaternary;

    return ClipRRect(
      borderRadius: buttonRRadius,
      child: Material(
        child: InkWell(
          onTap: () {},
          onHover: (hovered) {
            setState(() {
              _onHover = hovered;
            });
          },
          splashColor: SymColors.hoverColor,
          hoverColor: SymColors.hoverColor,
          child: Ink(
            color: SymColors.light_bgSurface1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  minHeight: SymTitleButton.buttonHeight,
                  maxHeight: SymTitleButton.buttonHeight),
              child: Row(
                children: [
                  SymAssetImage(
                    assetName,
                    size: const Size(14, 14),
                    color: _onHover ? activeColor : inactiveColor,
                  ),
                  const GapH(4),
                  SymText(label,
                      size: 14, color: _onHover ? activeColor : inactiveColor)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
