import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../flutter_quill.dart';
import '../../../utils/assets.dart';
import '../../models/documents/nodes/block.dart';
import '../../utils/app_constant.dart';
import '../../utils/color.dart';
import 'sym_block_button.dart';
import '../common_widgets/gap.dart';
import 'sym_text.dart';
import '../text_line.dart';

class MenuBlockOptionItem {
  MenuBlockOptionItem({
    required this.title,
    required this.iconAssetName,
    required this.type,
  });

  final _BlockOptionType type;
  final String title;
  final String iconAssetName;
}

class MenuBlockOptionSection {
  MenuBlockOptionSection(this.title, this.items);

  final String title;
  final List<MenuBlockOptionItem> items;
}

abstract class _BlockOptionType {}

class BlockOptionTypeAction extends _BlockOptionType {
  BlockOptionTypeAction(this.type);

  final BlockActionItem type;
}

enum BlockActionItem { DELETE, COPY, DUPLICATE, INDENT_LEFT, INDENT_RIGHT }

class BlockOptionTypeAttribute extends _BlockOptionType {
  BlockOptionTypeAttribute(this.attr);

  final Attribute attr;
}

class SymMenuBlockOption extends StatefulWidget {
  const SymMenuBlockOption({
    required this.renderEditableTextLine,
    required this.controller,
    required this.isEmbeddable,
    required this.textIndex,
  });

  final RenderEditableTextLine renderEditableTextLine;
  final bool isEmbeddable;
  final QuillController controller;
  final int textIndex;

  @override
  _SymMenuBlockOptionState createState() => _SymMenuBlockOptionState();
}

class _SymMenuBlockOptionState extends State<SymMenuBlockOption> {
  late MenuBlockOptionActionListener actionListener;
  MenuBlockOptionTurnIntoListener? turnIntoListener;

  @override
  void initState() {
    super.initState();
    widget.renderEditableTextLine.setLineSelected(true);
    final textIndex = widget.textIndex;
    actionListener = MenuBlockOptionActionListener(onDelete: () {
      widget.controller.deleteSelectedLine(textIndex);
    }, onCopy: () async {
      await widget.controller.copyPlainTextSelectedLine(textIndex);
    }, onDuplicate: () {
      widget.controller.duplicateSelectedLine(textIndex);
    });

    turnIntoListener = MenuBlockOptionTurnIntoListener(
      turnInto: (attribute) {
        widget.controller.turnSelectedLineInto(attribute, textIndex);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    bool? maxBottom;

    final childOffset =
        widget.renderEditableTextLine.localToGlobal(Offset.zero);

    const menuMargin = 10;

    const preferredMenuWidth = 207.0;
    final preferredMenuHeight = !widget.isEmbeddable ? 650.0 : 260.0;
    final maxMenuWidth = size.width * 0.3;
    final maxMenuHeight = size.height + 2 * menuMargin;

    final menuSize = Size(
        preferredMenuWidth > maxMenuWidth ? maxMenuWidth : preferredMenuWidth,
        preferredMenuHeight > maxMenuHeight
            ? maxMenuHeight
            : preferredMenuHeight);
    final leftOffset = childOffset.dx -
        menuSize.width -
        menuMargin +
        SymBlockButton.buttonWidth;
    var topOffset =
        childOffset.dy - (menuSize.height / 2) + SymBlockButton.buttonWidth;

    if (topOffset + menuSize.height + menuMargin > size.height) {
      maxBottom = true;
      topOffset = size.height - menuSize.height - menuMargin;
    } else if (topOffset < 0) {
      maxBottom = false;
      topOffset = menuMargin.toDouble();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  widget.controller.notifyListeners();
                });
              },
            ),
            Positioned(
              top: topOffset,
              left: leftOffset,
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 200),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                tween: Tween(begin: 0.0, end: 1.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: menuSize.width,
                    maxHeight: menuSize.height,
                  ),
                  child: Align(
                    alignment: maxBottom != null
                        ? maxBottom
                            ? Alignment.bottomCenter
                            : Alignment.topCenter
                        : Alignment.center,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 4),
                                blurRadius: 6,
                                spreadRadius: 0.5)
                          ]),
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      child: _menuContent(menuSize.width),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuContent(double maxMenuWidth) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._submenuAction(maxMenuWidth),
          if (!widget.isEmbeddable) ..._submenuTurnInto(maxMenuWidth)
        ],
      ),
    );
  }

  Widget _titleSubMenu(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SymText(text),
    );
  }

  Widget _itemMenuContent(String assetName, String text, double maxMenuWidth,
      {Function? onTap, bool enabled = true}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: SymColors.hoverColor,
        onTap: enabled
            ? () {
                onTap?.call();
                Navigator.pop(context);
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  widget.controller.notifyListeners();
                });
              }
            : null,
        child: Container(
          width: maxMenuWidth,
          padding: const EdgeInsets.all(8) +
              const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Image(
                image: AssetImage(assetName, package: PACKAGE_NAME),
                width: 18,
                height: 18,
                color: !enabled ? SymColors.light_line : null,
              ),
              const GapH(19),
              SymText(text,
                  color: enabled
                      ? SymColors.light_textPrimary
                      : SymColors.light_line)
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _submenuAction(double maxMenuWidth) {
    final selectedLine = widget.renderEditableTextLine.line;

    final int? indentLevel =
        selectedLine.style.attributes[Attribute.indent.key]?.value;

    return [
      _titleSubMenu('Aksi'),
      GapV(8),
      _itemMenuContent(Assets.TRASH, 'Hapus blok', maxMenuWidth, onTap: () {
        actionListener.onDelete();
      }),
      _itemMenuContent(Assets.COPY, 'Salin Teks', maxMenuWidth, onTap: () {
        actionListener.onCopy();
      }),
      _itemMenuContent(Assets.DUPLICATE, 'Duplikat blok', maxMenuWidth,
          onTap: () {
        actionListener.onDuplicate();
      }),
      if (!widget.isEmbeddable)
        _itemMenuContent(
            Assets.INDENT_LEFT_INACTIVE, 'Indent kiri', maxMenuWidth,
            enabled: (indentLevel ?? 0) > 0, onTap: () {
          if (indentLevel == 1) {
            widget.controller.formatLine(
                selectedLine, Attribute.clone(Attribute.indentL1, null));
            return;
          }
          widget.controller.formatLine(
              selectedLine, Attribute.getIndentLevel(indentLevel! - 1));
        }),
      if (!widget.isEmbeddable)
        _itemMenuContent(
            Assets.INDENT_RIGHT_ACTIVE, 'Indent kanan', maxMenuWidth,
            enabled: true, onTap: () {
          if (indentLevel == null) {
            widget.controller.formatLine(selectedLine, Attribute.indentL1);
            return;
          }
          widget.controller.formatLine(
              selectedLine, Attribute.getIndentLevel(indentLevel + 1));
        }),
    ];
  }

  List<Widget> _submenuTurnInto(double maxMenuWidth) {
    return [
      GapV(8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          height: 1,
          width: maxMenuWidth - 15 - 15,
          color: SymColors.light_line,
        ),
      ),
      GapV(16),
      _titleSubMenu('Change Section Into'),
      GapV(8),
      _itemMenuContent(Assets.TEXT_NORMAL, 'Text Biasa', maxMenuWidth,
          onTap: () {
        turnIntoListener!.turnInto(Attribute.header);
      }),
      _itemMenuContent(Assets.H1, 'Judul Besar', maxMenuWidth, onTap: () {
        turnIntoListener!.turnInto(Attribute.h1);
      }),
      _itemMenuContent(Assets.H2, 'Judul Sedang', maxMenuWidth, onTap: () {
        turnIntoListener!.turnInto(Attribute.h2);
      }),
      _itemMenuContent(Assets.H3, 'Judul Kecil', maxMenuWidth, onTap: () {
        turnIntoListener!.turnInto(Attribute.h3);
      }),
      _itemMenuContent(Assets.BULLET_LIST, 'Bullet List', maxMenuWidth,
          onTap: () {
        turnIntoListener!.turnInto(Attribute.ul);
      }),
      _itemMenuContent(Assets.NUMBERING_LIST, 'Numbering List', maxMenuWidth,
          onTap: () {
        turnIntoListener!.turnInto(Attribute.ol);
      }),
      _itemMenuContent(Assets.TODO_LIST, 'To-Do List', maxMenuWidth, onTap: () {
        turnIntoListener!.turnInto(Attribute.checked);
      }),
      _itemMenuContent(Assets.COPY, 'Code', maxMenuWidth, onTap: () {
        turnIntoListener!.turnInto(Attribute.codeBlock);
      }),
      _itemMenuContent(Assets.COPY, 'Blockquote', maxMenuWidth, onTap: () {
        turnIntoListener!.turnInto(Attribute.blockQuote);
      }),
    ];
  }
}

class MenuBlockOptionActionListener {
  const MenuBlockOptionActionListener({
    required this.onCopy,
    required this.onDelete,
    required this.onDuplicate,
  });

  final Function onCopy;
  final Function onDelete;
  final Function onDuplicate;
}

class MenuBlockOptionTurnIntoListener {
  const MenuBlockOptionTurnIntoListener({
    required this.turnInto,
  });

  final Function(Attribute) turnInto;
}

/* DEFAULT MENU ITEM */

List<MenuBlockOptionSection> defaultMenuBlockOptionSections(bool isEmbed) {
  return [
    MenuBlockOptionSection('Aksi', [
      MenuBlockOptionItem(
          title: 'Hapus blok',
          iconAssetName: Assets.TRASH,
          type: BlockOptionTypeAction(BlockActionItem.DELETE)),
      MenuBlockOptionItem(
          title: 'Salin teks',
          iconAssetName: Assets.COPY,
          type: BlockOptionTypeAction(BlockActionItem.COPY)),
      MenuBlockOptionItem(
          title: 'Duplikat blok',
          iconAssetName: Assets.DUPLICATE,
          type: BlockOptionTypeAction(BlockActionItem.DUPLICATE)),
      if (!isEmbed)
        MenuBlockOptionItem(
            title: 'Indent kiri',
            iconAssetName: Assets.INDENT_LEFT_INACTIVE,
            type: BlockOptionTypeAction(BlockActionItem.INDENT_LEFT)),
      if (!isEmbed)
        MenuBlockOptionItem(
            title: 'Indent kanan',
            iconAssetName: Assets.INDENT_RIGHT_ACTIVE,
            type: BlockOptionTypeAction(BlockActionItem.INDENT_RIGHT)),
    ]),
    if (!isEmbed)
      MenuBlockOptionSection('Change Section Into', [
        MenuBlockOptionItem(
            title: 'Text Biasa',
            iconAssetName: Assets.H1,
            type: BlockOptionTypeAttribute(Attribute.h1)),
        MenuBlockOptionItem(
            title: 'Judul Sedang',
            iconAssetName: Assets.H2,
            type: BlockOptionTypeAttribute(Attribute.h2)),
        MenuBlockOptionItem(
            title: 'Judul Kecil',
            iconAssetName: Assets.H3,
            type: BlockOptionTypeAttribute(Attribute.h3)),
        MenuBlockOptionItem(
            title: 'Bullet List',
            iconAssetName: Assets.BULLET_LIST,
            type: BlockOptionTypeAttribute(Attribute.ul)),
        MenuBlockOptionItem(
            title: 'Numbering List',
            iconAssetName: Assets.NUMBERING_LIST,
            type: BlockOptionTypeAttribute(Attribute.ol)),
        MenuBlockOptionItem(
            title: 'To-Do List',
            iconAssetName: Assets.TODO_LIST,
            type: BlockOptionTypeAttribute(Attribute.checked)),
        MenuBlockOptionItem(
            title: 'Block Code',
            iconAssetName: Assets.FORMAT_INLINECODE_INACTIVE,
            type: BlockOptionTypeAttribute(Attribute.codeBlock)),
        MenuBlockOptionItem(
            title: 'Blockquote',
            iconAssetName: Assets.FORMAT_INLINECODE_INACTIVE,
            type: BlockOptionTypeAttribute(Attribute.blockQuote)),
      ]),
  ];
}
