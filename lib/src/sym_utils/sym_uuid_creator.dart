import 'package:flutter/foundation.dart' show debugPrint;
import 'package:uuid/uuid.dart';

class SymUUIDCreator {
  SymUUIDCreator._internal();

  static final SymUUIDCreator instance = SymUUIDCreator._internal();

  final Uuid _uuid = const Uuid();

  int? userId;

  String create() {
    if (userId == null) {
      debugPrint(
          "WARNING: UUID created without userId name-based. Please provide userId by using 'SymUUIDCreator.instance.userId = <user_id>");
    }

    final uuidTimeBased = _uuid.v1();

    // higher random chance of UUID by combining time-based and namespace-based
    final uuidNamespaceBased = _uuid.v5(Uuid.NAMESPACE_NIL,
        userId != null ? '${userId}_$uuidTimeBased' : uuidTimeBased);

    return uuidNamespaceBased;
  }
}
