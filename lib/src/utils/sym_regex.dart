class SymRegex {
  SymRegex._();

  static final LINEBREAK_BLOCK_IDENTIFIER = RegExp(r'\[\[\^.{40,43}\]\](?=\\n)'); // match [[^space-22b480bd-440b-4805-84c8-e38cc3275c87]] inside **Markdown**[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]]\\n
  static final BLOCK_IDENTIFIER = RegExp(r'\[\[\^.{40,43}\]\]'); // match [[^space-22b480bd-440b-4805-84c8-e38cc3275c87]] inside **Markdown**[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]] (without linebreak)
  static final BLOCK_REFERENCE = RegExp(r'!\[\[.+[\^|\#].+\]\]');

  static final REMOVE_IMAGE_BLOCK_IDENTIFIER = RegExp(r'!\[[^\]]*\]\((.*?)\s*("(?:.*[^"])")?\s*\)(\[\[\^.{40,43}\]\]\\\\n)');
  static final REMOVE_IMAGE = RegExp(r'!\[[^\]]*\]\((.*?)\s*("(?:.*[^"])")?\s*\)');

  static final TEXTS_INSIDE_BRACKET = RegExp(r'(?<=\().+?(?=\))');
}