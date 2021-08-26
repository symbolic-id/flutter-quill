// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sym_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymBlock _$SymBlockFromJson(Map<String, dynamic> json) {
  return SymBlock(
    id: json['id'] as String,
    blocktype: json['block_type'] as String,
    cardId: json['card_id'] as String,
    content: json['content'] as String,
    createdAt: json['created_at'] as String,
    deckId: json['deck_id'] as String?,
    orderPosition: json['order_position'] as int,
    potentialWords: (json['potential_words'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    tags: json['tags'] as List<dynamic>,
    forwardlinksCount: json['forwardlinks_count'] as int,
    updatedAt: json['updated_at'] as String?,
    currentOwnerId: json['current_owner_id'] as int,
    originalOwnerId: json['original_owner_id'] as int,
    type: json['type'] as String,
    channels:
        (json['channels'] as List<dynamic>).map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$SymBlockToJson(SymBlock instance) => <String, dynamic>{
      'id': instance.id,
      'block_type': instance.blocktype,
      'card_id': instance.cardId,
      'content': instance.content,
      'type': instance.type,
      'created_at': instance.createdAt,
      'deck_id': instance.deckId,
      'order_position': instance.orderPosition,
      'potential_words': instance.potentialWords,
      'tags': instance.tags,
      'forwardlinks_count': instance.forwardlinksCount,
      'updated_at': instance.updatedAt,
      'current_owner_id': instance.currentOwnerId,
      'original_owner_id': instance.originalOwnerId,
      'channels': instance.channels,
    };
