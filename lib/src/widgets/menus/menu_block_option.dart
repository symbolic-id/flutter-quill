import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/src/utils/app_constant.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:flutter_quill/src/widgets/common_widgets/gap.dart';
import 'package:flutter_quill/src/widgets/common_widgets/sym_text.dart';
import 'package:flutter_quill/utils/assets.dart';

import '../../../flutter_quill.dart';

class MenuBlockOption extends StatefulWidget {
  final RenderBox buttonRenderBox;
  final MenuBlockOptionActionListener actionListener;
  final MenuBlockOptionTurnIntoListener? turnIntoListener;

  const MenuBlockOption({
    required this.buttonRenderBox,
    required this.actionListener,
    this.turnIntoListener
  });

  @override
  _MenuBlockOptionState createState() => _MenuBlockOptionState();
}

class _MenuBlockOptionState extends State<MenuBlockOption> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    bool maxBottom = false;

    final childOffset = widget.buttonRenderBox.localToGlobal(Offset.zero);
    final childSize = widget.buttonRenderBox.size;

    const preferredMenuWidth = 207.0;
    final preferredMenuHeight = widget.turnIntoListener != null ? 650.0 : 260.0;
    final maxMenuWidth = size.width * 0.3;
    final maxMenuHeight = size.height;

    final menuSize = Size(
        preferredMenuWidth > maxMenuWidth
        ? maxMenuWidth : preferredMenuWidth,
        preferredMenuHeight > maxMenuHeight
        ? maxMenuHeight : preferredMenuHeight
    );
    const menuMargin = 10;
    final leftOffset = childOffset.dx - menuSize.width - menuMargin;
    var topOffset = childOffset.dy - (menuSize.height / 2) + childSize.height;

    // 100 - 50 + 25 = 75
    // 100 - 25

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
                duration: Duration(milliseconds: 200),
                builder: (BuildContext context, double value, child) {
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
          if (widget.turnIntoListener != null) ..._submenuTurnInto(maxMenuWidth)
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
      String assetName, String text, double maxMenuWidth, {Function()? onTap}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: SymColors.hoverColor,
        onTap: onTap,
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
      _itemMenuContent(Assets.TRASH, 'Delete Section', maxMenuWidth),
      _itemMenuContent(Assets.COPY, 'Copy Text', maxMenuWidth),
      _itemMenuContent(Assets.DUPLICATE ,'Duplicate Section', maxMenuWidth),
      _itemMenuContent(Assets.INDENT_LEFT_ACTIVE ,'Indent Left', maxMenuWidth),
      _itemMenuContent(Assets.INDENT_RIGHT_ACTIVE ,'Indent Right', maxMenuWidth),
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
      _itemMenuContent(Assets.TEXT_NORMAL, 'Text Biasa', maxMenuWidth),
      _itemMenuContent(
          Assets.H1, 'Judul Besar 1', maxMenuWidth,
          onTap: () {
            // Navigator.pop(context, onTap);
            widget.turnIntoListener!.turnInto(Attribute.h1);
          }),
      _itemMenuContent(Assets.H2, 'Judul Besar 2', maxMenuWidth),
      _itemMenuContent(Assets.H3, 'Judul Besar 3', maxMenuWidth),
      _itemMenuContent(Assets.BULLET_LIST, 'Bullet List', maxMenuWidth),
      _itemMenuContent(Assets.NUMBERING_LIST, 'Numbering List', maxMenuWidth),
      _itemMenuContent(
        Assets.TODO_LIST, 'To-Do List', maxMenuWidth,
        onTap: () {
          widget.turnIntoListener!.turnInto(Attribute.checked);
        }
      ),
      _itemMenuContent(Assets.COPY, 'Code', maxMenuWidth),
      _itemMenuContent(Assets.COPY, 'Blockquote', maxMenuWidth),
    ];
  } 
  
}

class MenuBlockOptionActionListener {
  const MenuBlockOptionActionListener({
    required this.onCopy,
    required this.onDelete,
    required this.onDismiss,
  });
  
  final Function onCopy;
  final Function onDelete;
  final Function onDismiss;
}

class MenuBlockOptionTurnIntoListener {
  const MenuBlockOptionTurnIntoListener({
    required this.turnInto,
    required this.onDismiss,
  });

  final Function(Attribute) turnInto;
  final Function onDismiss;
}