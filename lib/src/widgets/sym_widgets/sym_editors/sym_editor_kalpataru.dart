import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../flutter_quill.dart';
import '../../../../src/utils/iterator_ext.dart';
import '../../../../utils/adaptive_layout_builder.dart';
import '../../../sym_model/note_card/sym_note_card.dart';
import '../../../sym_model/note_card/sym_note_card_entity.dart';
import '../../../sym_model/sym_block/sym_block.dart';
import '../../../sym_utils/sym_timestamp_creator.dart';
import '../../../sym_utils/sym_uuid_creator.dart';
import '../../../utils/delta_markdown/markdown_converter.dart';
import '../../../utils/sym_regex.dart';
import '../sym_toolbar/sym_toolbar.dart';
import 'default_sym_embed_builder.dart';
import 'sym_editor_type.dart';

class SymEditorKalpataru extends StatefulWidget {
  SymEditorKalpataru(Map<String, dynamic> noteCardEntityJson) {
    noteCard = SymNoteCard.fromJson(noteCardEntityJson);
    SymUUIDCreator.instance.userId = noteCard.currentOwnerId;
    SymChannelsCreator.instance
        .init(userId: noteCard.currentOwnerId, deckId: noteCard.deckId);
  }

  QuillController? _controller;

  late SymNoteCard noteCard;

  @override
  _SymEditorKalpataruState createState() => _SymEditorKalpataruState();

  String _getTitle() {
    return _controller?.titleKalpataru?.controller.text ?? '';
  }

  Future<Map<String, dynamic>> getNoteCardEntity() async {
    final lines = _controller?.document.getAllLine() ?? [];

    final originalOwnerId = noteCard.originalOwnerId;
    final currentOwnerId = noteCard.currentOwnerId;

    final channels = noteCard.channels;

    final currentTime = SymTimestampCreator.now();

    final blocks = lines.mapIndexed((line, index) {
      final md = MarkdownConverter.toMarkdown(line.toDelta());
      return SymBlock(
          id: line.lineId,
          blocktype: 'text',
          cardId: noteCard.id,
          content: md.replaceAll(SymRegex.LAST_LINE_BREAK, ''),
          deckId: null,
          orderPosition: index,
          potentialWords: [],
          tags: [],
          createdAt: currentTime,
          updatedAt: currentTime,
          originalOwnerId: originalOwnerId,
          currentOwnerId: currentOwnerId,
          type: SymBlock.objectAlias,
          channels: channels,
          forwardlinksCount: 0);
    }).toList();

    final updatedNotedCard = SymNoteCard(
        id: noteCard.id,
        createdAt: noteCard.createdAt,
        currentOwnerId: noteCard.currentOwnerId,
        originalOwnerId: noteCard.originalOwnerId,
        title: _getTitle(),
        channels: channels,
        updatedAt: currentTime,
        adoptedAt: noteCard.adoptedAt,
        adoptedStatus: noteCard.adoptedStatus,
        blocksCount: blocks.length,
        backlinksCount: noteCard.backlinksCount,
        forwardlinksCount: noteCard.forwardlinksCount,
        deckId: noteCard.deckId,
        emoji: noteCard.emoji,
        isPremium: noteCard.isPremium,
        orderPosition: noteCard.orderPosition,
        ownedStatus: noteCard.ownedStatus,
        tags: noteCard.tags,
        type: noteCard.type,
        image: noteCard.image);

    return SymNoteCardEntity.fromNoteCard(updatedNotedCard, blocks).toJson();
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
