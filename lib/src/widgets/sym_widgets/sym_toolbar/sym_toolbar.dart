import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_toolbar/sym_toolbar_button/sym_toolbar_button.dart';
import 'package:flutter_quill/utils/assets.dart';
import '../../../../flutter_quill.dart';
import '../../../utils/color.dart';
import '../../toolbar/arrow_indicated_button_list.dart';

class SymToolbar extends StatelessWidget implements PreferredSizeWidget {

  SymToolbar({required this.children, Key? key}): super(key: key);

  static const toolbarHeight = 48.0;

  factory SymToolbar.basic({
    required QuillController controller,
    Key? key,
}) {
    return SymToolbar(children: [
      SymToolbarButton(iconAssetName: Assets.CIRCLE_ADD, onPressed: () {}),
      const VerticalDivider(
        indent: 8,
        endIndent: 8,
        color: SymColors.light_line,
      ),
      SymToolbarButton(iconAssetName: Assets.MORE_HORIZ, onPressed: () {}),
      const VerticalDivider(
        indent: 8,
        endIndent: 8,
        width: 1,
        color: SymColors.light_line,
      ),
      SymToolbarButton(iconAssetName: Assets.FORMAT_BOLD_INACTIVE, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.FORMAT_ITALIC_INACTIVE, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.FORMAT_BOLD_INACTIVE, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.FORMAT_BOLD_INACTIVE, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.FORMAT_BOLD_INACTIVE, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.FORMAT_BOLD_INACTIVE, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.FORMAT_BOLD_INACTIVE, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.FORMAT_BOLD_INACTIVE, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.FORMAT_BOLD_INACTIVE, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.FORMAT_BOLD_INACTIVE, onPressed: () {}),
    ]);
}

  final List<Widget> children;
  final bool multiRowsDisplay = false;

  final Color bgColor = SymColors.light_backgroundSurfaceOne;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (multiRowsDisplay) {
      return Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 4,
        spacing: 4,
        children: children,
      );
    }
    return Container(
      constraints: BoxConstraints.tightFor(height: preferredSize.height),
      color: bgColor,
      child: ArrowIndicatedButtonList(buttons: children,),
    );
  }
}