import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class KalpataruCreateCardPage extends StatefulWidget {
  @override
  _KalpataruCreateCardPageState createState() =>
      _KalpataruCreateCardPageState();
}

class _KalpataruCreateCardPageState extends State<KalpataruCreateCardPage> {

  late SymEditorKalpataru editor;

  @override
  void initState() {
    super.initState();
    editor = SymEditorKalpataru();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
      EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(37))),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                debugPrint('LL:: title : ${editor.getTitle()}');
                debugPrint('LL:: content : ${editor.getContent()}');
              },
              icon: Icon(Icons.save),
            ),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: editor,
            ),
          ),
        ],
      ),
    );
  }
}
