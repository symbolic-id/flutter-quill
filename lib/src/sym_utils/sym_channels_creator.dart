class SymChannelsCreator {
  SymChannelsCreator._internal();

  static final SymChannelsCreator instance = SymChannelsCreator._internal();

  void init({required int userId, required String? deckId}) {
    instance._userId = userId;
    instance._deckId = deckId;
  }

  int? _userId;
  String? _deckId;

  List<String> getChannels() {
    if (_userId == null) {
      throw StateError(
          'SymChannelsCreator not yet initialized! Please initialize it by using SymChannelsCreator.instance.init(userId, deckId)'
      );
    }

    return _deckId != null
        ? ['kalpataru_${_userId}_$_deckId']
        : ['kalpataru_$_userId'];
  }
}
