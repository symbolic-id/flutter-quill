import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_editors/sym_editor_type.dart';

import 'default_sym_embed_builder.dart';

class SymEditorFace extends StatefulWidget {
  SymEditorFace({this.padding = EdgeInsets.zero});

  QuillController? _controller;

  final EdgeInsets padding;

  @override
  _SymEditorFaceState createState() => _SymEditorFaceState();
}

class _SymEditorFaceState extends State<SymEditorFace> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final doc = Document();
    widget._controller = QuillController(
        document: doc, selection: const TextSelection.collapsed(offset: 0));

    var quillEditor = QuillEditor(
      controller: widget._controller!,
      focusNode: _focusNode,
      scrollController: ScrollController(),
      scrollable: true,
      autoFocus: true,
      readOnly: false,
      placeholder: 'Ada kabar apa hari ini?',
      expands: false,
      embedBuilder: defaultSymEmbedBuilderWeb,
      padding: widget.padding,
      editorType: SymEditorTypeFace(),
    );

    return quillEditor;
  }
}
