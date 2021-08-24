import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../src/utils/iterator_ext.dart';
import '../../../../utils/assets.dart';
import '../../../utils/color.dart';
import '../../common_widgets/gap.dart';
import '../sym_asset_image.dart';
import '../sym_menu_block_creation.dart';
import '../sym_text.dart';

class SymBottomMenuBlockCreation {
  SymBottomMenuBlockCreation._(this.context, this.controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _layout,
    );
  }

  factory SymBottomMenuBlockCreation.show(
      BuildContext context, QuillController controller) {
    return SymBottomMenuBlockCreation._(context, controller);
  }

  final BuildContext context;
  final QuillController controller;

  Widget get _layout {
    final children = Container(
      color: SymColors.light_bgWhite,
      child: Column(
        children: [
          _headerMenu(() {
            Navigator.pop(context);
          }),
          const GapV(21),
          ...defaultMenuBlockCreationSections.mapIndexed((e, i) {
            return _buildSection(
              e.blockType,
              e.defaultItems,
              i != defaultMenuBlockCreationSections.length - 1,
            );
          }).toList(),
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
        });
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
                'Format konten blok',
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

  Widget _buildSection(
      String blockType, List<MenuBlockCreationItem> items, bool withDivider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerBlockType(blockType),
        ...items.mapIndexed((e, i) => _buildItem(e)).toList(),
        if (withDivider) _divider()
      ],
    );
  }

  Widget _headerBlockType(String blockType) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      child: SymText(
        blockType,
      ),
    );
  }

  Widget _buildItem(MenuBlockCreationItem item) {
    final key = item.key;
    final title = item.title;
    final titleSize = item.titleSize;
    final iconAssetName = item.iconAssetName;
    final desc = item.desc;
    final descAssetName = item.descAssetName;
    final shortcutChar = item.shortcutChar;

    return Material(
        child: InkWell(
      key: key,
      onTap: () {
        Navigator.pop(context);
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          final fromLine = controller.document
              .getLineFromTextIndex(controller.selection.extentOffset);
          controller.insertLine(fromLine, item.attr);
        });
      },
      child: Ink(
        color: SymColors.light_bgWhite,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SymColors.light_line)),
                padding: const EdgeInsets.all(9.5),
                child: SymAssetImage(
                  iconAssetName,
                  size: const Size(17, 17),
                ),
              ),
              const GapH(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SymText(
                      title,
                      bold: true,
                      size: titleSize,
                    ),
                    if (desc != null)
                      Row(
                        children: [
                          if (descAssetName != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 4, top: 2),
                              child: SymAssetImage(
                                descAssetName,
                                size: const Size(12, 12),
                              ),
                            ),
                          SymText(
                            desc,
                            color: SymColors.light_textTertiary,
                          )
                        ],
                      ),
                  ],
                ),
              ),
              if (shortcutChar != null)
                SymText(
                  shortcutChar,
                  color: SymColors.light_bluePrimary,
                  bold: true,
                )
            ],
          ),
        ),
      ),
    ));
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 16, left: 16, right: 16),
      color: SymColors.light_line,
      height: 1,
    );
  }
}
