import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets/button_menu.dart';
import 'widgets/kalpataru_create_card_page.dart';

class KalpataruPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
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
                width: 79,
              ),
              Expanded(
                child: ButtonMenu(
                  onSelectEmptyDoc: () {
                    _openEmptyDoc(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEmptyDoc(BuildContext context) {
    showGeneralDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = 1 - Curves.easeOutQuad.transform(a1.value);
          return Transform(
              transform: Matrix4.translationValues(
                  curvedValue * MediaQuery.of(context).size.width,
                  0, 0),
            child: KalpataruCreateCardPage(),
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
