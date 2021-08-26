import 'sym_block.dart';
import '../note_card/sym_note_card.dart';

class SymNoteCardSingleBlockEntity extends SymNoteCard {
  final SymBlock block;
  SymNoteCardSingleBlockEntity({
    required String id,
    required String? adoptedAt,
    required bool adoptedStatus,
    required int blocksCount,
    required int backlinksCount,
    required int forwardlinksCount,
    required String createdAt,
    required int currentOwnerId,
    required String? deckId,
    required String? emoji,
    required bool isPremium,
    required int orderPosition,
    required int originalOwnerId,
    required bool ownedStatus,
    required List<dynamic> tags, //dynamic => Tag
    required String title,
    required String type,
    required String? updatedAt,
    required List<String> channels,
    required String? image,
    required this.block,
  }) : super(
    id: id,
    adoptedAt: adoptedAt,
    adoptedStatus: adoptedStatus,
    channels: channels,
    updatedAt: updatedAt,
    type: type,
    title: title,
    tags: tags,
    ownedStatus: ownedStatus,
    originalOwnerId: originalOwnerId,
    orderPosition: orderPosition,
    isPremium: isPremium,
    emoji: emoji,
    deckId: deckId,
    currentOwnerId: currentOwnerId,
    createdAt: createdAt,
    forwardlinksCount: forwardlinksCount,
    backlinksCount: backlinksCount,
    blocksCount: blocksCount,
  );

  factory SymNoteCardSingleBlockEntity.fromJson(Map<String, dynamic> json) {
    final block = SymBlock.fromJson(json['card']);

    return fromNoteCard(SymNoteCard.fromJson(json), block);
  }

  static SymNoteCardSingleBlockEntity fromNoteCard(SymNoteCard card, SymBlock block) {
    return SymNoteCardSingleBlockEntity(
        id: card.id,
        adoptedAt: card.adoptedAt,
        adoptedStatus: card.adoptedStatus,
        blocksCount: card.blocksCount,
        backlinksCount: card.backlinksCount,
        forwardlinksCount: card.forwardlinksCount,
        createdAt: card.createdAt,
        currentOwnerId: card.currentOwnerId,
        deckId: card.deckId,
        emoji: card.emoji,
        isPremium: card.isPremium,
        orderPosition: card.orderPosition,
        originalOwnerId: card.originalOwnerId,
        ownedStatus: card.ownedStatus,
        tags: card.tags,
        title: card.title,
        type: card.type,
        updatedAt: card.updatedAt,
        channels: card.channels,
        image: card.image,
        block: block);
  }
}
