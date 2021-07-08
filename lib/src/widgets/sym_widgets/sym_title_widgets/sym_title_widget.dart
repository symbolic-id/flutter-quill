import 'package:flutter/cupertino.dart';

abstract class SymTitleWidget extends StatefulWidget {
  const SymTitleWidget(
      this.focusNode, this.padding, this.onSubmitted, this.controller);

  final FocusNode focusNode;
  final EdgeInsetsGeometry padding;
  final Function onSubmitted;
  final TextEditingController controller;
}
