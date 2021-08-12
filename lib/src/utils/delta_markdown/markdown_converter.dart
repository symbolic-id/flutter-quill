import 'package:flutter_quill/src/utils/delta_markdown/delta_markdown.dart';

import '../../models/quill_delta.dart';


/* original library from https://github.com/friebetill/delta_markdown */
class MarkdownConverter {
  MarkdownConverter._();

  static Delta fromMarkdown(String data) {
    return markdownToDelta(data
        .replaceAll('\\n', '\n'));
  }
}
