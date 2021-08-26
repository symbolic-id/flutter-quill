import 'package:intl/intl.dart';

class SymTimestampCreator {
  SymTimestampCreator._();

  static String now() {
    final now = DateTime.now();
    final timeZoneOffset = now.timeZoneOffset;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(timeZoneOffset.inMinutes.remainder(60));

    final timeZone = '${twoDigits(timeZoneOffset.inHours)}:$twoDigitMinutes';
    final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
    return '${formatter.format(now)}+$timeZone';
  }
}