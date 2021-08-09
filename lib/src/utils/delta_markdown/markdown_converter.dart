import 'package:flutter_quill/src/utils/delta_markdown/delta_markdown.dart';
import 'package:flutter_quill/src/utils/sym_regex.dart';

import '../../models/quill_delta.dart';

class MarkdownConverter {
  MarkdownConverter._();

  static Delta fromMarkdown(String data) {
    return markdownToDelta(data
        .replaceAll('\\n', '\n'));
  }
}
