import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class KalpataruCreateCardMobile extends StatelessWidget {
  KalpataruCreateCardMobile(this.editor);

  final SymEditorKalpataru editor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buat Catatan')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: editor)
          ],
        ),
      ),
    );
  }
}
