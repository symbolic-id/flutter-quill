import 'package:flutter/cupertino.dart';

abstract class SymTitleWidget extends StatefulWidget {
  SymTitleWidget(
      this.focusNode, this.padding, this.onSubmitted, this.controller);

  final FocusNode focusNode;
  final EdgeInsetsGeometry padding;
  final Function onSubmitted;
  final TextEditingController controller;

  var isExitedByArrow = false;

  void _onFocusChanged() {
    if (focusNode.hasFocus) {
      isExitedByArrow = false;
    }
  }

  void init() {
    focusNode
      ..requestFocus()
      ..addListener(_onFocusChanged);
  }

  void dispose() {
    focusNode.removeListener(_onFocusChanged);
  }
}
