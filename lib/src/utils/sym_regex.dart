class SymRegex {
  SymRegex._();

  static final BLOCK_IDENTIFIER_INSIDE_DOUBLE_SQR_BRACKET_BEFORE_LINEBREAK = RegExp(r'\[\[\^.{36,43}\]\](?=\\n)'); // match '[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]]' inside '**Markdown**[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]]\\n'
  static final BLOCK_IDENTIFIER_INSIDE_DOUBLE_SQR_BRACKET = RegExp(r'\[\[\^.{36,43}\]\]'); // match '[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]]' inside '**Markdown**[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]]' (without linebreak)
  static final BLOCK_REFERENCE = RegExp(r'!\[\[.+[\^|\#].+\]\]'); // UNTESTED

  static final IMAGE_MD_BEFORE_BLOCK_IDENTIFIER_INSIDE_DOUBLE_SQR_BRACKET_BEFORE_LINEBREAK = RegExp(r'!\[[^\]]*\]\((.*?)\s*("(?:.*[^"])")?\s*\)(\[\[\^.{36,43}\]\]\\\\n)'); // match '![desc](image_url.com)[[^space-52aa7567-9e89-4d68-92d9-754d75e7680f]]\\n' inside '**Markdown ![desc](image_url.com)[[^space-52aa7567-9e89-4d68-92d9-754d75e7680f]]\\n'
  static final IMAGE_MD = RegExp(r'!\[[^\]]*\]\((.*?)\s*("(?:.*[^"])")?\s*\)');  // match '![desc](image_url.com)' inside '**Markdown ![desc](image_url.com) **Markdown'

  static final TEXTS_INSIDE_BRACKET = RegExp(r'(?<=\().+?(?=\))'); // match 'image_url.com' inside '**Markdown ![desc](image_url.com) **Markdown'
  static final TEXTS_INSIDE_DOUBLE_SQUARE_BRACKET = RegExp(r'(?<=\[\[\^).{36,43}(?=\]\])'); // match 'space-52aa7567-9e89-4d68-92d9-754d75e7680f' inside '**Markdown**[[^space-52aa7567-9e89-4d68-92d9-754d75e7680f]]'
}