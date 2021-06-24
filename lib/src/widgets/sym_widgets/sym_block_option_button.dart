import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/src/utils/app_constant.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_asset_image.dart';
import 'package:flutter_quill/utils/assets.dart';

enum _ButtonType { ADD, OPTION }

class SymBlockButton extends StatelessWidget {
  const SymBlockButton({
    required this.width,
    required this.onTap,
    required this.offset,
    required this.editableTextLineKey,
    required this.type,
  });

  factory SymBlockButton.typeAdd(GlobalKey editableTextLineKey, int offset,
      Function(int, GlobalKey) onTap) {
    return SymBlockButton(
      editableTextLineKey: editableTextLineKey,
      width: buttonWidth,
      offset: offset,
      onTap: onTap,
      type: _ButtonType.ADD,
    );
  }

  factory SymBlockButton.typeOption(GlobalKey editableTextLineKey, int offset,
      Function(int, GlobalKey) onTap) {
    return SymBlockButton(
      editableTextLineKey: editableTextLineKey,
      width: buttonWidth,
      offset: offset,
      onTap: onTap,
      type: _ButtonType.OPTION,
    );
  }

  static const buttonWidth = 32.0;

  final GlobalKey editableTextLineKey;
  final double width;
  final Function(int, GlobalKey) onTap;
  final int offset;
  final _ButtonType type;

  @override
  Widget build(BuildContext context) {
    return ButtonClipper(
        child: Material(
          child: InkWell(
            onTap: () {
              onTap(offset, editableTextLineKey);
            },
            splashColor: SymColors.hoverColor,
            child: SymAssetImage(
              type == _ButtonType.ADD ? Assets.CIRCLE_ADD : Assets.MORE,
              size: const Size(22, 22),
            ),
          ),
        )
    );
  }

  Widget ButtonClipper({required Widget child}) {
    if (type == _ButtonType.ADD) {
      return ClipOval(
        child: child,
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: child,
      );
    }
  }
}
