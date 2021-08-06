class SymRegex {
  SymRegex._();

  static final LINEBREAK_BLOCK_IDENTIFIER = RegExp(r'\[\[\^.{40,43}\]\](?=\\n)');
  static final BLOCK_REFERENCE = RegExp(r'!\[\[.+[\^|\#].+\]\]');
}