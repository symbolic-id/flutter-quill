import 'package:app/pages/kalpataru_demo_page/kalpataru_create_card/kalpataru_create_card_desktop.dart';
import 'package:app/pages/kalpataru_demo_page/kalpataru_create_card/kalpataru_create_card_mobile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/utils/adaptive_layout_builder.dart';

Map<String, dynamic> _dummyEmptyNoteCardEntityJson() {
  final currentTime = SymTimestampCreator.now();

  SymUUIDCreator.instance.userId = 1;
  SymChannelsCreator.instance.init(userId: 1, deckId: null);
  return {
    'id': SymUUIDCreator.instance.create(),
    'created_at': currentTime,
    'current_owner_id': 1,
    'original_owner_id': 1,
    'title': 'Test Yoo',
    'channels': SymChannelsCreator.instance.getChannels(),
    'updated_at': currentTime,
    'adopted_at': null,
    'adopted_status': false,
    'blocks_count': 0,
    'backlinks_count': 0,
    'forwardlinks_count': 0,
    'deck_id': null,
    'emoji': null,
    'is_premium': false,
    'order_position': 0,
    'owned_status': false,
    'tags': [],
    'type': 'card',
    'image': null,
    'blocks' : [{
      'id': SymUUIDCreator.instance.create(),
      'blocktype': SymBlockType.basic,
      'card_id': 'card-Test',
      'content': '',
      'created_at': currentTime,
      'deck_id': null,
      'order_position': 0,
      'potentialWords': [],
      'tags': [],
      'forwardlinks_count': 0,
      'updated_at': currentTime,
      'current_owner_id': 1,
      'original_owner_id': 1,
      'type': 'block',
      'channels': SymChannelsCreator.instance.getChannels(),
    }]
  };
}

class KalpataruCreateCardPage {
  static void open(BuildContext context) {
    final editor = SymEditorKalpataru(_dummyEmptyNoteCardEntityJson());
    ScreenAdaptor.onScreen(context,
        onMobile: () => _openMobile(context, editor),
        onDesktop: () => _showDialog(context, editor));
  }

  static void _openMobile(BuildContext context, SymEditorKalpataru editor) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => KalpataruCreateCardMobile(editor)));
  }

  static void _showDialog(BuildContext context, SymEditorKalpataru editor) {
    showGeneralDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = 1 - Curves.easeOutQuad.transform(a1.value);
          return Transform(
            transform: Matrix4.translationValues(
                curvedValue * MediaQuery.of(context).size.width, 0, 0),
            child: KalpataruCreateCardDesktop(editor),
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
