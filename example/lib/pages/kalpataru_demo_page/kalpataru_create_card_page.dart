import 'package:app/pages/kalpataru_demo_page/kalpataru_create_card/kalpataru_create_card_desktop.dart';
import 'package:app/pages/kalpataru_demo_page/kalpataru_create_card/kalpataru_create_card_mobile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/utils/adaptive_layout_builder.dart';

class KalpataruCreateCardPage {
  static void open(BuildContext context) {
    final editor = SymEditorKalpataru();
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

// class _KalpataruCreateCardPageState extends State<KalpataruCreateCardPage> {
//
//   late SymEditorKalpataru editor;
//
//   @override
//   void initState() {
//     super.initState();
//     editor = SymEditorKalpataru();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding:
//       EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
//       clipBehavior: Clip.antiAlias,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(topLeft: Radius.circular(37))),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.topRight,
//             child: IconButton(
//               onPressed: () {
//                 debugPrint('LL:: title : ${editor.getTitle()}');
//                 debugPrint('LL:: content : ${editor.getContent()}');
//               },
//               icon: Icon(Icons.save),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               height: double.infinity,
//               width: MediaQuery.of(context).size.width,
//               color: Colors.white,
//               child: editor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
