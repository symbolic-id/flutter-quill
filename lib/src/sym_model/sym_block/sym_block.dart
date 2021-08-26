import 'package:json_annotation/json_annotation.dart';
import '../note_card/sym_note_card.dart';

part 'sym_block.g.dart';

@JsonSerializable()
class SymBlock {
  String id;
  @JsonKey(name: 'block_type')
  String blocktype;
  @JsonKey(name: 'card_id')
  String cardId;
  String content;
  String type;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'deck_id')
  String? deckId;
  @JsonKey(name: 'order_position')
  int orderPosition;
  @JsonKey(name: 'potential_words')
  List<String> potentialWords;
  List<dynamic> tags; //dynamic => Tag
  @JsonKey(name: 'forwardlinks_count')
  int forwardlinksCount;
  @JsonKey(name: 'updated_at')
  String? updatedAt;
  @JsonKey(name: 'current_owner_id')
  int currentOwnerId;
  @JsonKey(name: 'original_owner_id')
  int originalOwnerId;
  List<String> channels;

  SymBlock(
      {required this.id,
      required this.blocktype,
      required this.cardId,
      required this.content,
      required this.createdAt,
      required this.deckId,
      required this.orderPosition,
      required this.potentialWords,
      required this.tags,
      required this.forwardlinksCount,
      required this.updatedAt,
      required this.currentOwnerId,
      required this.originalOwnerId,
      required this.type,
      required this.channels});

  factory SymBlock.fromJson(Map<String, dynamic> json) =>
      _$SymBlockFromJson(json);

  factory SymBlock.emptyBlock(String id, SymNoteCard card) {
    return SymBlock(
      id: id,
      blocktype: "content",
      cardId: card.id,
      content: "",
      createdAt: card.createdAt,
      deckId: null,
      orderPosition: 0,
      potentialWords: [],
      tags: [],
      forwardlinksCount: 0,
      updatedAt: null,
      currentOwnerId: card.originalOwnerId,
      originalOwnerId: card.originalOwnerId,
      type: objectAlias,
      channels: card.channels,
    );
  }

  Map<String, dynamic> toJson() => _$SymBlockToJson(this);

  static const _KeyString keyString = const _KeyString();

  static const String objectAlias = 'block';
}

class _KeyString {
  const _KeyString();

  static const String _id = 'id';
  static const String _blockType = 'block_type';
  static const String _cardId = 'card_id';
  static const String _content = 'content';
  static const String _createdAt = 'created_at';
  static const String _deckId = 'deck_id';
  static const String _order_position = 'order_position';
  static const String _potentialWords = 'potential_words';
  static const String _tags = 'tags';
  static const String _forwardlinksCount = 'forwardlinks_count';
  static const String _inline_tag = 'inline_tag';
  static const String _title = 'title';
  static const String _type = 'type';
  static const String _updated_at = 'updated_at';
  static const String _currentOwnerId = 'current_owner_id';
  static const String _originalOwnerId = 'original_owner_id';
  static const String _channels = 'channels';

  String get id => _id;

  String get blockType => _blockType;

  String get cardId => _cardId;

  String get content => _content;

  String get createdAt => _createdAt;

  String get deckId => _deckId;

  String get order_position => _order_position;

  String get potentialWords => _potentialWords;

  String get tags => _tags;

  String get forwardlinksCount => _forwardlinksCount;

  String get inline_tag => _inline_tag;

  String get title => _title;

  String get type => _type;

  String get updated_at => _updated_at;

  String get currentOwnerId => _currentOwnerId;

  String get originalOwnerId => _originalOwnerId;

  String get channels => _channels;
}
