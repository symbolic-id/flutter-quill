// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sym_note_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymNoteCard _$SymNoteCardFromJson(Map<String, dynamic> json) {
  return SymNoteCard(
    id: json['id'] as String,
    createdAt: json['created_at'] as String,
    currentOwnerId: json['current_owner_id'] as int,
    originalOwnerId: json['original_owner_id'] as int,
    title: json['title'] as String,
    channels:
        (json['channels'] as List<dynamic>).map((e) => e as String).toList(),
    updatedAt: json['updated_at'] as String?,
    adoptedAt: json['adopted_at'] as String?,
    adoptedStatus: json['adopted_status'] as bool,
    blocksCount: json['blocks_count'] as int,
    backlinksCount: json['backlinks_count'] as int,
    forwardlinksCount: json['forwardlinks_count'] as int,
    deckId: json['deck_id'] as String?,
    emoji: json['emoji'] as String?,
    isPremium: json['is_premium'] as bool,
    orderPosition: json['order_position'] as int,
    ownedStatus: json['owned_status'] as bool,
    tags: json['tags'] as List<dynamic>,
    type: json['type'] as String,
    image: json['image'] as String?,
  );
}

Map<String, dynamic> _$SymNoteCardToJson(SymNoteCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adopted_at': instance.adoptedAt,
      'adopted_status': instance.adoptedStatus,
      'blocks_count': instance.blocksCount,
      'backlinks_count': instance.backlinksCount,
      'forwardlinks_count': instance.forwardlinksCount,
      'created_at': instance.createdAt,
      'current_owner_id': instance.currentOwnerId,
      'deck_id': instance.deckId,
      'emoji': instance.emoji,
      'is_premium': instance.isPremium,
      'order_position': instance.orderPosition,
      'original_owner_id': instance.originalOwnerId,
      'owned_status': instance.ownedStatus,
      'tags': instance.tags,
      'title': instance.title,
      'type': instance.type,
      'updated_at': instance.updatedAt,
      'channels': instance.channels,
      'image': instance.image,
    };
