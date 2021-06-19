import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/src/models/documents/nodes/block.dart';
import 'package:flutter_quill/src/models/documents/nodes/line.dart';
import 'package:flutter_quill/src/widgets/text_block.dart';
import 'package:flutter_quill/src/widgets/text_line.dart';

import '../../../flutter_quill.dart';
import '../../../utils/assets.dart';
import '../../utils/app_constant.dart';
import '../../utils/color.dart';
import '../block_option_button.dart';
import '../common_widgets/gap.dart';
import '../common_widgets/sym_text.dart';

class MenuBlockOption extends StatefulWidget {

  const MenuBlockOption({
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
  _MenuBlockOptionState createState() => _MenuBlockOptionState();
}

class _MenuBlockOptionState extends State<MenuBlockOption> {

  late MenuBlockOptionActionListener actionListener;
  MenuBlockOptionTurnIntoListener? turnIntoListener;

  @override
  void initState() {
    super.initState();
    widget.renderEditableTextLine.setLineSelected(true);
    final textIndex = widget.textIndex;
    actionListener = MenuBlockOptionActionListener(
        onDelete: () {
          int textLength;

          /*
            Applying linebreak length (+ 1) on the text length
            but embeddable (image) considered only contain
            a linebreak
          */
          if (!widget.isEmbeddable) {
            textLength = widget.controller
                .document
                .getTextInLineFromTextIndex(textIndex)
                .length
                + 1;
          } else {
            textLength = 1;
          }

          if (textLength != widget.controller.document.length) {
            widget.controller.document
                .delete(textIndex, textLength);

            final lastCursorIndex = widget.controller
                .selection.baseOffset;

            if (lastCursorIndex > textIndex) {
              var newCursorIndex = lastCursorIndex
                  - textLength;

              if (newCursorIndex < 0) {
                newCursorIndex = 0;
              }

              widget.controller.updateSelection(
                  TextSelection(
                      baseOffset: newCursorIndex,
                      extentOffset: newCursorIndex
                  ), ChangeSource.LOCAL);
            }
          } else {
            widget.controller
                .replaceText(
                0,
                widget.controller
                    .document
                    .getTextInLineFromTextIndex(textIndex)
                    .length,
                '\n',
                const TextSelection(
                    baseOffset: 0,
                    extentOffset: 0
                )
            );
          }
        },
        onCopy: () async {
          final text = widget
              .controller
              .document
              .getTextInLineFromTextIndex(textIndex);
          await Clipboard.setData(ClipboardData(text: text));
        },
        onDuplicate: () {
          final selectedLine = widget.renderEditableTextLine.line;

          final selectedBlock =
          selectedLine.parent is Block
              ? selectedLine.parent as Block : null;
          var newLineIndex = selectedLine.documentOffset
              + selectedLine.length;

          if (selectedLine.nextLine == null) {
            newLineIndex--;
          }

          widget.controller.document.duplicateLine(
              newLineIndex,
              selectedLine,
              selectedBlock?.style
                  .attributes.entries.first.value);
        }
    );

    turnIntoListener = MenuBlockOptionTurnIntoListener(
      turnInto: (attribute) {
        for (final attr in Attribute.blockKeysExceptIndent) {
          if (attr != attribute) {
            widget.controller.document.format(
                textIndex, 0, Attribute.clone(attr, null));
          }
        }

        widget.controller.document.format(
            textIndex, 0, attribute);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    var maxBottom = false;

    final childOffset = widget.renderEditableTextLine
        .localToGlobal(Offset.zero);

    const menuMargin = 10;

    const preferredMenuWidth = 207.0;
    final preferredMenuHeight = !widget.isEmbeddable ? 650.0 : 260.0;
    final maxMenuWidth = size.width * 0.3;
    final maxMenuHeight = size.height + 2 * menuMargin;

    final menuSize = Size(
        preferredMenuWidth > maxMenuWidth
        ? maxMenuWidth : preferredMenuWidth,
        preferredMenuHeight > maxMenuHeight
        ? maxMenuHeight : preferredMenuHeight
    );
    final leftOffset = childOffset.dx - menuSize.width - menuMargin;
    var topOffset = childOffset.dy - (menuSize.height / 2)
        + BlockOptionButton.buttonWidth;

    if (topOffset + menuSize.height + menuMargin > size.height) {
      maxBottom = true;
      topOffset = size.height - menuSize.height - menuMargin;
    } else if (topOffset < 0) {
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
                  child: Stack(
                    children: [
                      Positioned(
                        top: maxBottom ? null : 0,
                        bottom: maxBottom ? 0 : null,
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                              boxShadow: [
                                const BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 4),
                                    blurRadius: 6,
                                    spreadRadius: 0.5)
                              ]),
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          child: _menuContent(menuSize.width),
                        ),
                      ),
                    ],
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

  Widget _itemMenuContent(
      String assetName, String text, double maxMenuWidth, {Function? onTap}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: SymColors.hoverColor,
        onTap: () {
          onTap?.call();
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            widget.controller.notifyListeners();
          });
        },
        child: Container(
          width: maxMenuWidth,
          padding: const EdgeInsets.all(8)
              + const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Image(
                  image: AssetImage(assetName, package: PACKAGES_NAME),
                  width: 18,
                  height: 18
              ),
              const GapH(19),
              SymText(text)
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _submenuAction(double maxMenuWidth) {
    return [
      _titleSubMenu('Action'),
      GapV(8),
      _itemMenuContent(
          Assets.TRASH, 'Delete Section', maxMenuWidth,
          onTap: () {
            actionListener.onDelete();
          }
      ),
      _itemMenuContent(
          Assets.COPY, 'Copy Text', maxMenuWidth,
          onTap: () {
            actionListener.onCopy();
          }
      ),
      _itemMenuContent(
          Assets.DUPLICATE ,'Duplicate Section', maxMenuWidth,
          onTap: () {
            actionListener.onDuplicate();
          }
      ),
      _itemMenuContent(Assets.INDENT_LEFT_ACTIVE ,'Indent Left', maxMenuWidth),
      _itemMenuContent(
          Assets.INDENT_RIGHT_ACTIVE ,'Indent Right', maxMenuWidth),
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
          color: SymColors.light_Line,
        ),
      ),
      GapV(16),
      _titleSubMenu('Change Section Into'),
      GapV(8),
      _itemMenuContent(
          Assets.TEXT_NORMAL, 'Text Biasa', maxMenuWidth,
          onTap: () {
              turnIntoListener!.turnInto(Attribute.header);
          }
      ),
      _itemMenuContent(
          Assets.H1, 'Judul Besar 1', maxMenuWidth,
          onTap: () {
            turnIntoListener!.turnInto(Attribute.h1);
          }
      ),
      _itemMenuContent(
          Assets.H2, 'Judul Besar 2', maxMenuWidth,
          onTap: () {
            turnIntoListener!.turnInto(Attribute.h2);
          }
      ),
      _itemMenuContent(
          Assets.H3, 'Judul Besar 3', maxMenuWidth,
          onTap: () {
            turnIntoListener!.turnInto(Attribute.h3);
          }
      ),
      _itemMenuContent(
          Assets.BULLET_LIST, 'Bullet List', maxMenuWidth,
          onTap: () {
            turnIntoListener!.turnInto(Attribute.ul);
          }
      ),
      _itemMenuContent(
          Assets.NUMBERING_LIST, 'Numbering List', maxMenuWidth,
          onTap: () {
            turnIntoListener!.turnInto(Attribute.ol);
          }
      ),
      _itemMenuContent(
          Assets.TODO_LIST, 'To-Do List', maxMenuWidth,
          onTap: () {
            turnIntoListener!.turnInto(Attribute.checked);
          }
      ),
      _itemMenuContent(
          Assets.COPY, 'Code', maxMenuWidth,
          onTap: () {
            turnIntoListener!.turnInto(Attribute.codeBlock);
          }
      ),
      _itemMenuContent(
          Assets.COPY, 'Blockquote', maxMenuWidth,
          onTap: () {
            turnIntoListener!.turnInto(Attribute.blockQuote);
          }
      ),
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