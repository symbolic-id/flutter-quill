import 'dart:convert';

import 'package:flutter_quill/src/utils/sym_regex.dart';

import '../../models/quill_delta.dart';

import 'delta_markdown_src/md_delta_markdown_decorder.dart';
import 'delta_markdown_src/md_delta_markdown_encoder.dart';

/// Codec used to convert between Markdown and Quill deltas.
const DeltaMarkdownCodec _kCodec = DeltaMarkdownCodec();

String markdownToDeltaString(String markdown) {
  return _kCodec.decode(markdown);
}

String deltaToMarkdown(String delta) {
  return _kCodec.encode(delta);
}

Delta markdownToDelta(String markdown) {
  final deltaString = _kCodec.decode(markdown);
  return Delta.fromJson(jsonDecode(deltaString));
}

class DeltaMarkdownCodec extends Codec<String, String> {
  const DeltaMarkdownCodec();

  @override
  Converter<String, String> get decoder => DeltaMarkdownDecoder();

  @override
  Converter<String, String> get encoder => DeltaMarkdownEncoder();
}
