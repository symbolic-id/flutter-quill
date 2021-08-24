import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/src/utils/color.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_toolbar/sym_toolbar.dart';
import 'package:flutter_quill/utils/adaptive_layout_builder.dart';
import '../../../../flutter_quill.dart';
import 'default_sym_embed_builder.dart';
import 'sym_editor_type.dart';

class SymEditorKalpataru extends StatefulWidget {
  SymEditorKalpataru();

  QuillController? _controller;

  @override
  _SymEditorKalpataruState createState() => _SymEditorKalpataruState();

  String getTitle() {
    return _controller?.titleKalpataru?.controller.text ?? '';
  }

  String getContent() {
    return _controller?.document.toPlainText() ?? '';
  }
}

class _SymEditorKalpataruState extends State<SymEditorKalpataru> {
  final FocusNode _focusNode = FocusNode();
  final _titleController = TextEditingController();

  ValueNotifier<bool> contentFocused = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final doc = Document();
    widget._controller = QuillController(
        document: doc, selection: const TextSelection.collapsed(offset: 0));

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget._controller == null) { // in case loading an existing document
    //   return const Scaffold(body: Center(child: SymText('Loading...'),),);
    // }
    return AdaptiveLayoutBuilder(
        onMobile: _buildEditor(true), onDesktop: _buildEditor(false));
  }

  Widget _buildEditor(bool isMobile) {
    return Column(
      children: [
        Expanded(
          child: QuillEditor(
            controller: widget._controller!,
            scrollController: ScrollController(),
            scrollable: true,
            focusNode: _focusNode,
            autoFocus: false,
            readOnly: false,
            placeholder: 'Add content',
            expands: false,
            embedBuilder: defaultSymEmbedBuilderWeb,
            padding: isMobile ? const EdgeInsets.only(left: 24) : null,
            editorType: SymEditorTypeKalpataru(_titleController, isMobile),
          ),
        ),
        if (isMobile)
          ValueListenableBuilder(
            valueListenable: contentFocused,
            builder: (context, bool isContentFocused, child) {
              return Visibility(
                visible: isContentFocused,
                child: child!,
              );
            },
            child: SymToolbar.basic(
              context: context,
              controller: widget._controller!,
            ),
          )
      ],
    );
  }

  void _onFocusChanged() {
    contentFocused.value = _focusNode.hasFocus;
  }
}
