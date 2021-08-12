import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/src/utils/app_constant.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_asset_image.dart';
import 'package:flutter_quill/utils/assets.dart';

enum _ButtonType { ADD, OPTION }

class SymBlockButton extends StatefulWidget {
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
  _SymBlockButtonState createState() => _SymBlockButtonState();
}

class _SymBlockButtonState extends State<SymBlockButton> {
  var _onHover = false;

  @override
  Widget build(BuildContext context) {
    return ButtonClipper(
        child: Material(
          color: SymColors.light_bgWhite,
      child: InkWell(
        onTap: () {
          widget.onTap(widget.offset, widget.editableTextLineKey);
        },
        onHover: (hovered) {
          setState(() {
            _onHover = hovered;
          });
        },
        splashColor: SymColors.hoverColor,
        child: Ink(
          child: SymAssetImage(
            widget.type == _ButtonType.ADD ? Assets.CIRCLE_ADD : Assets.MORE,
            size: const Size(22, 22),
            fit: BoxFit.fill,
            color: _onHover
                ? SymColors.light_bluePrimary
                : SymColors.light_textQuaternary,
          ),
        ),
      ),
    ));
  }

  Widget ButtonClipper({required Widget child}) {
    if (widget.type == _ButtonType.ADD) {
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
