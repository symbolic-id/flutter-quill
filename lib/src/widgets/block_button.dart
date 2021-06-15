import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/utils/assets.dart';

class BlockButton extends StatelessWidget {
  const BlockButton({
    required this.width,
    required this.onTap,
    required this.offset,
    Key? key,
}): super(key: key);

  factory BlockButton.basic(int offset) {
    return BlockButton(
      key: UniqueKey(),
      width: 32,
      offset: offset,
      onTap: (offset) { print('LL:: Tap Button : offset : $offset'); },
    );
  }

  final double width;
  final Function(int) onTap;
  final int offset;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () { onTap(offset); },
        splashColor: Colors.deepOrange,
        child: const Image(
            image: AssetImage(Assets.ADD_BLOCK, package: 'flutter_quill'),
            width: 22,
            height: 22
        ),
      ),
    );
  }
}