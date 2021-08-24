import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/src/utils/app_constant.dart';

class SymAssetImage extends StatelessWidget {
  const SymAssetImage(
    this.assetName, {
    this.size,
    this.color,
    this.fit = BoxFit.scaleDown,
    Key? key,
  }) : super(key: key);

  final String assetName;
  final Size? size;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetName,
      package: PACKAGE_NAME,
      width: size?.width,
      height: size?.height,
      color: color,
      fit: fit,
    );
  }
}
