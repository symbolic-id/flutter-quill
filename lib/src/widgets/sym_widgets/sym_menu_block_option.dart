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
      int textLength;

      /*
            Applying linebreak length (+ 1) on the text length
            but embeddable (image) considered only contain
            a linebreak
          */
      if (!widget.isEmbeddable) {
        textLength = widget.controller.document
                .getTextInLineFromTextIndex(textIndex)
                .length +
            1;
      } else {
        textLength = 1;
      }

      if (textLength != widget.controller.document.length) {
        widget.controller.document.delete(textIndex, textLength);

        final lastCursorIndex = widget.controller.selection.baseOffset;

        if (lastCursorIndex > textIndex) {
          var newCursorIndex = lastCursorIndex - textLength;

          if (newCursorIndex < 0) {
            newCursorIndex = 0;
          }

          widget.controller.updateSelection(
              TextSelection(
                  baseOffset: newCursorIndex, extentOffset: newCursorIndex),
              ChangeSource.LOCAL);
        }
      } else {
        widget.controller.replaceText(
            0,
            widget.controller.document
                .getTextInLineFromTextIndex(textIndex)
                .length,
            '\n',
            const TextSelection(baseOffset: 0, extentOffset: 0));
      }
    }, onCopy: () async {
      final text =
          widget.controller.document.getTextInLineFromTextIndex(textIndex);
      await Clipboard.setData(ClipboardData(text: text));
    }, onDuplicate: () {
      final selectedLine = widget.renderEditableTextLine.line;

      final selectedBlock =
          selectedLine.parent is Block ? selectedLine.parent as Block : null;
      var newLineIndex = selectedLine.documentOffset + selectedLine.length;

      if (selectedLine.nextLine == null) {
        newLineIndex--;
      }

      widget.controller.document.duplicateLine(newLineIndex, selectedLine,
          selectedBlock?.style.attributes.entries.first.value);
    });

    turnIntoListener = MenuBlockOptionTurnIntoListener(
      turnInto: (attribute) {
        for (final attr in Attribute.blockKeysExceptIndent) {
          if (attr != attribute) {
            widget.controller.document
                .format(textIndex, 0, Attribute.clone(attr, null));
          }
        }

        widget.controller.document.format(textIndex, 0, attribute);
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
        _itemMenuContent(Assets.INDENT_LEFT_ACTIVE, 'Indent kiri', maxMenuWidth,
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
