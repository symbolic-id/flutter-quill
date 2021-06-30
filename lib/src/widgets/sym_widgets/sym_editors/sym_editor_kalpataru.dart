import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_text.dart';

class SymEditorKalpataru extends StatefulWidget {
  @override
  _SymEditorKalpataruState createState() => _SymEditorKalpataruState();
}

class _SymEditorKalpataruState extends State<SymEditorKalpataru> {

  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    final doc = Document();
    _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0)
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) { // in case loading an existing document
      return const Scaffold(body: Center(child: SymText('Loading...'),),);
    }
    var quillEditor = QuillEditor(
      controller: _controller!,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: _focusNode,
      autoFocus: false,
      readOnly: false,
      placeholder: 'Add content',
      expands: false,
      embedBuilder: _defaultEmbedBuilderWeb,);
    return quillEditor;
  }
}

Widget _defaultEmbedBuilderWeb(BuildContext context, Embed node) {
  switch (node.value.type) {
    case 'image':
      final String imageUrl = node.value.data;
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Image.network(imageUrl)
      );

    default:
      throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by default '
            'embed builder of QuillEditor. You must pass your own builder function '
            'to embedBuilder property of QuillEditor or QuillField widgets.',
      );
  }
}