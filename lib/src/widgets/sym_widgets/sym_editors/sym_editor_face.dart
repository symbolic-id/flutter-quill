import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/src/models/documents/document.dart';
import 'package:flutter_quill/src/utils/delta_markdown/delta_markdown.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_editors/sym_editor_type.dart';

import '../../controller.dart';
import '../../editor.dart';
import 'default_sym_embed_builder.dart';

class SymEditorFace extends StatefulWidget {
  SymEditorFace({this.padding = EdgeInsets.zero, this.onChangeListener});

  QuillController? _controller;

  Function(String)? onChangeListener;

  final EdgeInsets padding;

  @override
  _SymEditorFaceState createState() => _SymEditorFaceState();

  String getMarkdown() {
    final delta =
        _controller?.document.toDeltaWithLineId(postTypePrefix: 'face');

    final deltaJson = delta?.toJson();

    final deltaJsonString = deltaJson != null ? jsonEncode(deltaJson) : null;

    final md = deltaToMarkdown(deltaJsonString ?? '');

    return md;
  }
}

class _SymEditorFaceState extends State<SymEditorFace> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final doc = Document();
    widget._controller = QuillController(
        document: doc, selection: const TextSelection.collapsed(offset: 0))
      ..addListener(() {
        final plainText = widget._controller!.document.toPlainText().trim();

        widget.onChangeListener?.call(plainText);
      });

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
