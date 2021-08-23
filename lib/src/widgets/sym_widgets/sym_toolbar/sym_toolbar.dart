import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_toolbar/sym_bottom_menu_block_creation.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_toolbar/sym_toolbar_button/sym_toggle_style_button.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_toolbar/sym_toolbar_button/sym_toolbar_button.dart';
import 'package:flutter_quill/utils/assets.dart';
import '../../../../flutter_quill.dart';
import '../../../utils/color.dart';
import '../../toolbar/arrow_indicated_button_list.dart';

class SymToolbar extends StatelessWidget implements PreferredSizeWidget {
  SymToolbar({required this.context, required this.children, Key? key})
      : super(key: key);

  static const toolbarHeight = 48.0;
  final BuildContext context;

  factory SymToolbar.basic({
    required BuildContext context,
    required QuillController controller,
    Key? key,
  }) {
    const divider = VerticalDivider(
      indent: 8,
      endIndent: 8,
      width: 1,
      color: SymColors.light_line,
    );

    return SymToolbar(context: context, children: [
      SymToolbarButton(
          iconAssetName: Assets.CIRCLE_ADD,
          onPressed: () {
            SymBottomMenuBlockCreation.show(context);
          }),
      divider,
      SymToolbarButton(iconAssetName: Assets.MORE_VERT, onPressed: () {}),
      divider,
      SymToggleStyleButton(
          attribute: Attribute.bold,
          iconAssetName: Assets.FORMAT_BOLD_INACTIVE,
          controller: controller),
      SymToggleStyleButton(
          attribute: Attribute.italic,
          iconAssetName: Assets.FORMAT_ITALIC_INACTIVE,
          controller: controller),
      SymToggleStyleButton(
          attribute: Attribute.strikeThrough,
          iconAssetName: Assets.FORMAT_STRIKETHROUGH_INACTIVE,
          controller: controller),
      SymToolbarButton(iconAssetName: Assets.INSERT_GIF, onPressed: () {}),
      SymToolbarButton(iconAssetName: Assets.INSERT_IMAGE, onPressed: () {}),
      SymToolbarButton(
          iconAssetName: Assets.INDENT_LEFT_INACTIVE, onPressed: () {}),
      SymToolbarButton(
          iconAssetName: Assets.INDENT_RIGHT_ACTIVE, onPressed: () {}),
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
      child: ArrowIndicatedButtonList(
        buttons: children,
      ),
    );
  }
}
