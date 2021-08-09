import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/src/models/documents/nodes/leaf.dart';

Widget defaultSymEmbedBuilderWeb(
    BuildContext context, Embed node, bool readOnly) {
  switch (node.value.type) {
    case 'image':
      final String imageUrl = node.value.data;
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Image.network(imageUrl));

    default:
      throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by default '
            'embed builder of QuillEditor. You must pass your own builder function '
            'to embedBuilder property of QuillEditor or QuillField widgets.',
      );
  }
}