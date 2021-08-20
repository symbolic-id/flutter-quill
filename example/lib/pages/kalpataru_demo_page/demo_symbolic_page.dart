import 'package:app/pages/kalpataru_demo_page/demo_load_from_markdown_page.dart';
import 'package:app/pages/kalpataru_demo_page/face_create_post_page.dart';
import 'package:app/pages/kalpataru_demo_page/space_create_post_page.dart';
import 'package:app/pages/kalpataru_demo_page/widgets/space_detail_post_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/utils/color.dart';

import 'widgets/button_menu.dart';
import 'kalpataru_create_card_page.dart';

class DemoSymbolicPage extends StatelessWidget {
  final buttonSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'MARKDOWN VIEWER',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 22,
                  ),
                  Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openMarkdownViewer(context),
                      child: Ink(
                        color: SymColors.light_bluePrimary,
                        child: SizedBox.fromSize(
                          size: Size(buttonSize, buttonSize),
                          child: const Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text(
                    'PUBLIC-SPACE',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 22,
                  ),
                  Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openCreatePublicSpace(context),
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
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text(
                    'PUBLIC-SPACE DETAIL',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 22,
                  ),
                  Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openDetailPublicSpace(context),
                      child: Ink(
                        color: SymColors.light_bluePrimary,
                        child: SizedBox.fromSize(
                          size: Size(buttonSize, buttonSize),
                          child: const Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text(
                    'INTER-FACE',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 22,
                  ),
                  Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openCreateInterFace(context),
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
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KALPATARU',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      width: 22,
                    ),
                    ButtonMenu(
                      onSelectEmptyDoc: () {
                        _openEmptyKalpataru(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEmptyKalpataru(BuildContext context) {
    KalpataruCreateCardPage.open(context);
    // _showDialog(context, KalpataruCreateCardPage());
  }

  void _openCreateInterFace(BuildContext context) {
    _showDialog(context, FaceCreatePostPage());
  }

  void _openCreatePublicSpace(BuildContext context) {
    _showDialog(context, SpaceCreatePostPage());
  }

  void _openDetailPublicSpace(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SpaceDetailPostPage()));
  }

  void _openMarkdownViewer(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DemoLoadFromMarkdownPage()));
  }

  void _showDialog(BuildContext context, Widget page) {
    showGeneralDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = 1 - Curves.easeOutQuad.transform(a1.value);
          return Transform(
            transform: Matrix4.translationValues(
                curvedValue * MediaQuery.of(context).size.width, 0, 0),
            child: page,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
        barrierDismissible: true,
        barrierLabel: '',
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }
}
