import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:flutter_quill/src/widgets/common_widgets/gap.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_asset_image.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_text.dart';
import 'package:flutter_quill/utils/assets.dart';

enum _ButtonType { TAG, COVER, STICKER }

class SymTitleButton extends StatefulWidget {
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
          child: Ink(
            color: ,
            child: Row(
              children: [
                SymAssetImage(
                  assetName,
                ),
                const GapH(4),
                SymText(label, size: 14, color: SymColors.light_textQuaternary,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
