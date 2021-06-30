import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/utils/color.dart';

class ButtonMenu extends StatefulWidget {

  const ButtonMenu({required this.onSelectEmptyDoc});

  final Function onSelectEmptyDoc;

  @override
  _ButtonMenuState createState() => _ButtonMenuState();
}

class _ButtonMenuState extends State<ButtonMenu>
    with SingleTickerProviderStateMixin {
  var isOpened = false;

  late AnimationController controller;
  late Animation<double> openAnimation;

  final buttonSize = 40.0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);

    openAnimation = CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.easeOutQuad);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              if (isOpened) {
                _toggle();
              }
            },
          ),
          _buildMenus(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 45 / 360).animate(controller),
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _toggle,
          child: Ink(
            color: SymColors.light_bluePrimary,
            child: SizedBox.fromSize(
              size: Size(buttonSize, buttonSize),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenus() {
    return AnimatedBuilder(
        animation: openAnimation,
        builder: (context, child) {
          final actualOffset = buttonSize + 13;

          return Positioned(
              top: openAnimation.value * actualOffset,
              child: Visibility(
                visible: openAnimation.value > 0,
                  child: child!
              )
          );
        },
      child: FadeTransition(
        opacity: openAnimation,
        child: Material(
          borderRadius: BorderRadius.circular(8),
          elevation: 5,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding:
                EdgeInsets.only(left: 17, right: 17, top: 17, bottom: 7),
                child: Text(
                  'BUAT',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: () {
                  _toggle();
                  widget.onSelectEmptyDoc();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 17),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 35,
                          height: 35,
                          color: SymColors.light_bluePrimary,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Catatan Kosong',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      isOpened = !isOpened;
      if (isOpened) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }
}
