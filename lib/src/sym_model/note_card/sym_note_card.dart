import 'package:json_annotation/json_annotation.dart';

part 'sym_note_card.g.dart';

@JsonSerializable()
class SymNoteCard {
  String id;
  @JsonKey(name: _KeyString._adoptedAt)
  String? adoptedAt;
  @JsonKey(name: _KeyString._adoptedStatus)
  bool adoptedStatus;
  @JsonKey(name: _KeyString._blocksCount)
  int blocksCount;
  @JsonKey(name: _KeyString._backlinksCount)
  int backlinksCount;
  @JsonKey(name: _KeyString._forwardlinksCount)
  int forwardlinksCount;
  @JsonKey(name: _KeyString._createdAt)
  String createdAt;
  @JsonKey(name: _KeyString._currentOwnerId)
  int currentOwnerId;
  @JsonKey(name: _KeyString._deckId)
  String? deckId;
  @JsonKey(name: _KeyString._emoji)
  String? emoji;
  @JsonKey(name: _KeyString._isPremium)
  bool isPremium;
  @JsonKey(name: _KeyString._orderPosition)
  int orderPosition;
  @JsonKey(name: _KeyString._originalOwnerId)
  int originalOwnerId;
  @JsonKey(name: _KeyString._ownedStatus)
  bool ownedStatus;
  List<dynamic> tags; //dynamic => Tag
  String title;
  String type;
  @JsonKey(name: _KeyString._updatedAt)
  String? updatedAt;
  List<String> channels;
  String? image;

  SymNoteCard(
      {required this.id,
        required this.createdAt,
        required this.currentOwnerId,
        required this.originalOwnerId,
        required this.title,
        required this.channels,
        this.updatedAt = null,
        this.adoptedAt = null,
        this.adoptedStatus = false,
        this.blocksCount = 0,
        this.backlinksCount = 0,
        this.forwardlinksCount = 0,
        this.deckId = null,
        this.emoji = null,
        this.isPremium = false,
        this.orderPosition = 0,
        this.ownedStatus = true,
        this.tags = const [],
        this.type = objectAlias,
        this.image = null});

  factory SymNoteCard.fromJson(Map<String, dynamic> json) =>
      _$SymNoteCardFromJson(json);

  Map<String, dynamic> toJson() => _$SymNoteCardToJson(this);

  static const _KeyString keyString = const _KeyString();

  static const String objectAlias = 'card';
}

class _KeyString {
  const _KeyString();

  static const String _id = 'id';
  static const String _adoptedAt = 'adopted_at';
  static const String _adoptedStatus = 'adopted_status';
  static const String _blocksCount = 'blocks_count';
  static const String _backlinksCount = 'backlinks_count';
  static const String _forwardlinksCount = 'forwardlinks_count';
  static const String _createdAt = 'created_at';
  static const String _currentOwnerId = 'current_owner_id';
  static const String _deckId = 'deck_id';
  static const String _emoji = 'emoji';
  static const String _isPremium = 'is_premium';
  static const String _orderPosition = 'order_position';
  static const String _originalOwnerId = 'original_owner_id';
  static const String _ownedStatus = 'owned_status';
  static const String _tags = 'tags'; //dynamic => Tag
  static const String _title = 'title';
  static const String _type = 'type';
  static const String _updatedAt = 'updated_at';
  static const String _channels = 'channels';

  String get id => _id;
  String get adoptedAt => _adoptedAt;
  String get adoptedStatus => _adoptedStatus;
  String get channels => _channels;
  String get updatedAt => _updatedAt;
  String get type => _type;
  String get title => _title;
  String get tags => _tags;
  String get ownedStatus => _ownedStatus;
  String get originalOwnerId => _originalOwnerId;
  String get orderPosition => _orderPosition;
  String get isPremium => _isPremium;
  String get emoji => _emoji;
  String get deckId => _deckId;
  String get currentOwnerId => _currentOwnerId;
  String get createdAt => _createdAt;
  String get forwardlinksCount => _forwardlinksCount;
  String get backlinksCount => _backlinksCount;
  String get blocksCount => _blocksCount;
}
