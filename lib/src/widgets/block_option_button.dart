import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/src/utils/app_constant.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:flutter_quill/utils/assets.dart';

class BlockOptionButton extends StatelessWidget {

  static const buttonWidth = 32.0;

  const BlockOptionButton({
    required this.width,
    required this.onTap,
    required this.offset,
    required this.editableTextLineKey,
});

  factory BlockOptionButton.basic(
      GlobalKey editableTextLineKey,
      int offset,
      Function(int, GlobalKey) onTap
  ) {
    return BlockOptionButton(
      editableTextLineKey: editableTextLineKey,
      width: buttonWidth,
      offset: offset,
      onTap: onTap,
    );
  }

  final GlobalKey editableTextLineKey;
  final double width;
  final Function(int, GlobalKey) onTap;
  final int offset;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () { onTap(offset, editableTextLineKey); },
        splashColor: SymColors.hoverColor,
        child: const Image(
            image: AssetImage(Assets.MORE, package: PACKAGE_NAME),
            width: 22,
            height: 22
        ),
      ),
    );
  }
}