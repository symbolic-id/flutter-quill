import 'package:flutter/cupertino.dart';

class GapV extends StatelessWidget {
  const GapV(this.height);

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height,);
  }
}

class GapH extends StatelessWidget {
  const GapH(this.width);

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width,);
  }
}