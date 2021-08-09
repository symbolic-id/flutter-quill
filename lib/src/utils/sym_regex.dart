class SymRegex {
  SymRegex._();

  static final LINEBREAK_BLOCK_IDENTIFIER = RegExp(r'\[\[\^.{40,43}\]\](?=\\n)');
  static final VALID_BLOCK_REFERENCE = RegExp(r'!\[\[.+[\^|\#].+\]\]');

  static final REMOVE_IMAGE_BLOCK_IDENTIFIER = RegExp(r'!\[[^\]]*\]\((.*?)\s*("(?:.*[^"])")?\s*\)(\[\[\^.{40,43}\]\]\\\\n)');
  static final REMOVE_IMAGE = RegExp(r'!\[[^\]]*\]\((.*?)\s*("(?:.*[^"])")?\s*\)');
}