import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/src/models/documents/style.dart';

import '../../../../models/documents/attribute.dart';
import '../../../../utils/color.dart';
import '../../sym_asset_image.dart';
import 'sym_toolbar_icon_button.dart';

typedef SymToggleStyleButtonBuilder = Widget Function(
    BuildContext context,
    Attribute attribute,
    String iconAssetName,
    Color fillColor,
    bool? isToggled,
    VoidCallback? onPressed,
    [double iconSize]);

class SymToggleStyleButton extends StatefulWidget {
  const SymToggleStyleButton(
      {required this.attribute,
      required this.iconAssetName,
      required this.controller,
      this.fillColor = SymColors.light_backgroundSurfaceOne,
      this.childBuilder = defaultToggleStyleButtonBuilder,
      Key? key})
      : super(key: key);

  final Attribute attribute;

  final String iconAssetName;
  final Color fillColor;

  final QuillController controller;

  final SymToggleStyleButtonBuilder childBuilder;

  @override
  State<StatefulWidget> createState() => _SymToggleStyleButtonState();
}

class _SymToggleStyleButtonState extends State<SymToggleStyleButton> {
  bool? _isToggled;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    _isToggled = _getIsToggled(_selectionStyle.attributes);
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  Widget build(BuildContext context) {
    final isInCodeBlock =
        _selectionStyle.attributes.containsKey(Attribute.codeBlock.key);

    final isEnabled =
        !isInCodeBlock || widget.attribute.key == Attribute.codeBlock.key;

    return widget.childBuilder(
      context,
      widget.attribute,
      widget.iconAssetName,
      widget.fillColor,
      _isToggled,
      isEnabled ? _toggleAttribute : null,
    );
  }

  void _didChangeEditingValue() {
    setState(() {
      _isToggled = _getIsToggled(_selectionStyle.attributes);
    });
  }

  bool _getIsToggled(Map<String, Attribute> attrs) {
    if (widget.attribute.key == Attribute.list.key) {
      final attribute = attrs[widget.attribute.key];
      if (attribute == null) {
        return false;
      }
      return attribute.value == widget.attribute.value;
    }
    return attrs.containsKey(widget.attribute.key);
  }

  void _toggleAttribute() {
    widget.controller.formatSelection(_isToggled!
        ? Attribute.clone(widget.attribute, null)
        : widget.attribute);
  }
}

Widget defaultToggleStyleButtonBuilder(
    BuildContext context,
    Attribute attribute,
    String iconAssetName,
    Color fillColor,
    bool? isToggled,
    VoidCallback? onPressed,
    [double iconSize = SymToolbarIconButton.DEFAULT_ICON_SIZE]) {
  final isEnabled = onPressed != null;
  final iconColor = isEnabled
      ? isToggled == true
          ? SymColors.light_textQuaternary
          : SymColors.light_iconPrimary
      : SymColors.light_line;

  return SymToolbarIconButton(
    highlightElevation: 0,
    hoverElevation: 0,
    icon: SymAssetImage(
      iconAssetName,
      size: Size(iconSize, iconSize),
      color: iconColor,
    ),
    fillColor: fillColor,
    onPressed: onPressed,
  );
}
