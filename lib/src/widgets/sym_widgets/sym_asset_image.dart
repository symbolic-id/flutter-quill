import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/src/utils/app_constant.dart';

class SymAssetImage extends StatelessWidget {
  const SymAssetImage(
    this.assetName, {
    this.size = _defaultImageSize,
    this.color,
    Key? key,
  }) : super(key: key);

  static const Size _defaultImageSize = Size(40, 40);

  final String assetName;
  final Size size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetName,
      package: PACKAGE_NAME,
      width: size.width,
      height: size.width,
      color: color,
    );
  }
}
