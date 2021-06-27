import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../../models/documents/attribute.dart';
import '../../../models/documents/nodes/leaf.dart' as leaf;
import '../../../models/documents/nodes/node.dart';
import '../../../models/documents/style.dart';
import '../../../utils/color.dart';
import '../../default_styles.dart';
import '../../proxy.dart';
import 'sym_title.dart';

class SymTextTitle extends StatelessWidget {
  const SymTextTitle({
    required this.title,
    required this.styles,
    required this.textDirection,
    Key? key,
  }) : super(key: key);

  final SymTitle title;
  final TextDirection textDirection;
  final DefaultStyles styles;

  @override
  Widget build(BuildContext context) {
    final textSpan = _buildTextSpan(context);
    final strutStyle = StrutStyle.fromTextStyle(textSpan.style!);
    const textAlign = TextAlign.start;
    final child = RichText(
      text: textSpan,
      textDirection: textDirection,
      strutStyle: strutStyle,
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
    );
    return RichTextProxy(
        child,
        textSpan.style!,
        textAlign,
        textDirection,
        1,
        Localizations.localeOf(context),
        strutStyle,
        TextWidthBasis.parent,
        null);
  }

  TextSpan _buildTextSpan(BuildContext context) {
    final defaultStyles = styles;
    final children = title.children
        .map((node) => _getTextSpanFromNode(defaultStyles, node))
        .toList(growable: false);

    var textStyle = const TextStyle();

    if (title.style.containsKey(Attribute.placeholder.key)) {
      textStyle = defaultStyles.placeHolder!.style;
      return TextSpan(children: children, style: textStyle);
    }

    final header = title.style.attributes[Attribute.header.key];
    final m = <Attribute, TextStyle>{
      Attribute.h1: defaultStyles.h1!.style,
    };

    textStyle = textStyle.merge(m[header] ?? defaultStyles.paragraph!.style);
    // textStyle = textStyle.merge(const TextStyle(color: SymColors.light_bluePrimary));

    return TextSpan(children: children, style: textStyle);
  }

  TextSpan _getTextSpanFromNode(DefaultStyles defaultStyles, Node node) {
    final textNode = node as leaf.Text;
    final style = Style()
      ..merge(Attribute.bold);
    var res = const TextStyle();
    final color = textNode.style.attributes[Attribute.color.key];

    <String, TextStyle?>{
      Attribute.bold.key: defaultStyles.bold,
    }.forEach((k, s) {
      if (style.values.any((v) => v.key == k)) {
        if (k == Attribute.underline.key || k == Attribute.strikeThrough.key) {
          var textColor = defaultStyles.color;
          if (color?.value is String) {
            textColor = stringToColor(color?.value);
          }
          res = _merge(res.copyWith(decorationColor: textColor),
              s!.copyWith(decorationColor: textColor));
        } else {
          res = _merge(res, s!);
        }
      }
    });

    final font = textNode.style.attributes[Attribute.font.key];
    if (font != null && font.value != null) {
      res = res.merge(TextStyle(fontFamily: font.value));
    }

    if (color != null && color.value != null) {
      var textColor = defaultStyles.color;
      if (color.value is String) {
        textColor = stringToColor(color.value);
      }
      if (textColor != null) {
        res = res.merge(TextStyle(color: textColor));
      }
    }

    final background = textNode.style.attributes[Attribute.background.key];
    if (background != null && background.value != null) {
      final backgroundColor = stringToColor(background.value);
      res = res.merge(TextStyle(backgroundColor: backgroundColor));
    }

    return TextSpan(text: textNode.value, style: res);
  }


  TextStyle _merge(TextStyle a, TextStyle b) {
    final decorations = <TextDecoration?>[];
    if (a.decoration != null) {
      decorations.add(a.decoration);
    }
    if (b.decoration != null) {
      decorations.add(b.decoration);
    }
    return a.merge(b).apply(
        decoration: TextDecoration.combine(
            List.castFrom<dynamic, TextDecoration>(decorations)));
  }
}