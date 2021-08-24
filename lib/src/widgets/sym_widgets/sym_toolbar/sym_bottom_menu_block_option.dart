import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:flutter_quill/src/widgets/common_widgets/gap.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_asset_image.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_menu_block_option.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_text.dart';
import 'package:flutter_quill/utils/assets.dart';
import '../../../../src/utils/iterator_ext.dart';

class SymBottomMenuBlockOption {
  SymBottomMenuBlockOption._(this.context, this.controller) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _layout
    );
  }

  factory SymBottomMenuBlockOption.show(
      BuildContext context, QuillController controller) {
    return SymBottomMenuBlockOption._(context, controller);
  }

  final BuildContext context;
  final QuillController controller;

  Widget get _layout {
    final sections = defaultMenuBlockOptionSections(false);
    final children = Container(
      color: SymColors.light_bgWhite,
      child: Column(
        children: [
          _headerMenu(() => Navigator.pop(context)),
          const GapV(21),
          ...sections.mapIndexed((e, i) {
            return _buildSection(e, i != sections.length - 1);
          }).toList()
        ],
      ),
    );
    return DraggableScrollableSheet(
        initialChildSize: 0.6,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: children,
          );
        }
    );
  }

  Widget _headerMenu(VoidCallback onClose) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: Row(
            children: [
              InkWell(
                onTap: onClose,
                child: const SymAssetImage(
                  Assets.CIRCLE_CLOSE,
                  size: Size(40, 40),
                ),
              ),
              const GapH(16),
              const SymText(
                'Opsi format lainnya',
                size: 16,
                bold: true,
              ),
              Container(
                color: SymColors.light_line,
                height: 1,
              ),
            ],
          ),
        ),
        GapV(12),
        Container(
          color: SymColors.light_line,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildSection(MenuBlockOptionSection section, bool widthDivider) {
    final title = section.title;
    final items = section.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: SymColors.light_bgWhite,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 20),
              child: SymText(
                title,
              )),
        ),
        ...items.map(_buildItem).toList(),
        if (widthDivider) _divider()
      ],
    );
  }

  Widget _buildItem(MenuBlockOptionItem item) {
    final title = item.title;
    final type = item.type;
    final iconAssetName = item.iconAssetName;

    return Material(
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            if (type is BlockOptionTypeAction) {
              switch (type.type) {
                case BlockActionItem.DELETE:
                  controller.deleteCurrentLine();
                  break;
                case BlockActionItem.COPY:
                // TODO: Handle this case.
                  break;
                case BlockActionItem.DUPLICATE:
                // TODO: Handle this case.
                  break;
                case BlockActionItem.INDENT_LEFT:
                // TODO: Handle this case.
                  break;
                case BlockActionItem.INDENT_RIGHT:
                // TODO: Handle this case.
                  break;
              }
            }
          });
        },
        child: Ink(
          color: SymColors.light_bgWhite,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 20),
            child: Row(
              children: [
                SymAssetImage(
                  iconAssetName,
                  size: const Size(17, 17),
                ),
                const GapH(17),
                SymText(
                  title,
                  size: 14,
                  bold: true,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 16, left: 16, right: 16),
      color: SymColors.light_line,
      height: 1,
    );
  }
}
