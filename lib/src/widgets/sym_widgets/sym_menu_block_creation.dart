import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

import '../../../utils/assets.dart';
import '../../models/documents/attribute.dart';
import '../../utils/color.dart';
import '../common_widgets/gap.dart';
import '../controller.dart';
import '../editor.dart';
import 'sym_asset_image.dart';
import 'sym_text.dart';

class _MenuBlockItem {
  _MenuBlockItem({
    required this.key,
    required this.attr,
    required this.title,
    required this.iconAssetName,
    this.titleSize = 14,
    this.desc,
    this.descAssetName,
    this.shortcutChar,
  });

  final GlobalKey key;
  final Attribute attr;
  final String title;
  final double titleSize;
  final String iconAssetName;
  String? descAssetName;
  String? desc;
  String? shortcutChar;
}

class _MenuBlockSection {
  _MenuBlockSection(this.blockType, {this.items, this.withDivider = true});

  final String blockType;
  final List<_MenuBlockItem>? items;
  final bool withDivider;
}

class SymMenuBlockCreation extends StatefulWidget {
  const SymMenuBlockCreation(this.controller, this.renderObject,
      this.selectionDelegate, this.onDismiss);

  final QuillController controller;
  final RenderEditor renderObject;
  final TextSelectionDelegate selectionDelegate;
  final Function() onDismiss;

  @override
  State<StatefulWidget> createState() => _SymMenuBlockCreationState();
}

class _SymMenuBlockCreationState extends State<SymMenuBlockCreation> {
  final List<_MenuBlockSection> menuSections = [
    _MenuBlockSection(
      'Format Teks',
      items: [
        _MenuBlockItem(
            key: GlobalKey(),
            attr: Attribute.clone(Attribute.header, null),
            title: 'Teks Biasa',
            iconAssetName: Assets.CIRCLE_FORMAT_NORMAL_TEXT,
            desc: 'Format teks standar dalam paragraf')
      ],
    ),
    _MenuBlockSection(
      'Format Judul',
      items: [
        _MenuBlockItem(
            key: GlobalKey(),
            attr: Attribute.h1,
            title: 'Judul Besar',
            titleSize: 20,
            iconAssetName: Assets.CIRCLE_FORMAT_H1,
            shortcutChar: '#'),
        _MenuBlockItem(
            key: GlobalKey(),
            attr: Attribute.h2,
            title: 'Judul Sedang',
            titleSize: 16,
            iconAssetName: Assets.CIRCLE_FORMAT_H2,
            shortcutChar: '##'),
        _MenuBlockItem(
            key: GlobalKey(),
            attr: Attribute.h3,
            title: 'Judul Kecil',
            iconAssetName: Assets.CIRCLE_FORMAT_H3,
            shortcutChar: '###'),
      ],
    ),
    _MenuBlockSection(
      'Format Daftar',
      items: [
        _MenuBlockItem(
            key: GlobalKey(),
            attr: Attribute.ul,
            title: 'Bullet List',
            iconAssetName: Assets.CIRCLE_FORMAT_BULLET_LIST,
            desc: '• Buat daftar dengan pointer lingkaran',
            shortcutChar: '*'),
        _MenuBlockItem(
            key: GlobalKey(),
            attr: Attribute.ol,
            title: 'Number List',
            iconAssetName: Assets.CIRCLE_FORMAT_NUMBER_LIST,
            desc: '1. Buat daftar dengan urutan angka',
            shortcutChar: '1.'),
        _MenuBlockItem(
            key: GlobalKey(),
            attr: Attribute.unchecked,
            title: 'To do List',
            iconAssetName: Assets.CIRCLE_FORMAT_TODO_LIST,
            desc: 'Buat daftar dengan checkbox',
            descAssetName: Assets.CHECK_12PX),
      ],
    ),
    _MenuBlockSection(
      'Hashtag',
      items: [
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Tag Section',
          iconAssetName: Assets.CIRCLE_FORMAT_TAG,
          desc: 'Menambahkan tag di suatu section',
        ),
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Tag Card',
          iconAssetName: Assets.CIRCLE_FORMAT_TAG,
          desc: 'Menambahkan tag di card',
        ),
      ],
    ),
    _MenuBlockSection(
      'Referensi',
      items: [
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Card Reference',
          iconAssetName: Assets.CIRCLE_FORMAT_REFERENCE,
          desc: 'Menambahkan card lain',
        ),
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Block Embed',
          iconAssetName: Assets.CIRCLE_FORMAT_TAG,
          desc: 'Menambahkan section card lain',
        ),
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Block Reference',
          iconAssetName: Assets.CIRCLE_FORMAT_TAG,
          desc: 'Menambahkan section card lain',
        ),
      ],
    ),
    _MenuBlockSection(
      'Referensi',
      items: [
        _MenuBlockItem(
            key: GlobalKey(),
            attr: Attribute.blockQuote,
            title: 'Quote',
            iconAssetName: Assets.CIRCLE_FORMAT_QUOTE,
            desc: 'Buat tulisan quote',
            shortcutChar: '>'),
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.codeBlock,
          title: 'Code',
          iconAssetName: Assets.CIRCLE_FORMAT_CODE,
          desc: 'Buat tulisan code snippet',
        ),
      ],
    ),
    _MenuBlockSection(
      'Referensi',
      items: [
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Tanggal Sekarang',
          iconAssetName: Assets.CIRCLE_DATE,
          desc: 'Menambahkan tanggal sekarang',
        ),
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Jam Sekarang',
          iconAssetName: Assets.CIRCLE_CLOCK,
          desc: 'Menambahkan jam sekarang',
        ),
      ],
    ),
    _MenuBlockSection(
      'Format Sisipan',
      withDivider: false,
      items: [
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Gambar',
          iconAssetName: Assets.CIRCLE_IMAGE,
          desc: 'Menambahkan file gambar',
        ),
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'GIF',
          iconAssetName: Assets.CIRCLE_GIF,
          desc: 'Menambahkan GIF',
        ),
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Embed Link',
          iconAssetName: Assets.CIRCLE_GIF,
          desc: 'Menambahkan rangkuman tautan',
        ),
        _MenuBlockItem(
          key: GlobalKey(),
          attr: Attribute.header,
          title: 'Divider',
          iconAssetName: Assets.CIRCLE_DIVIDER,
          desc: 'Menambahkan garis pemisah',
        ),
      ],
    ),
  ];

  final List<Tuple2<GlobalKey, String>> menus = [
    Tuple2(GlobalKey(), '1'),
    Tuple2(GlobalKey(), '2'),
    Tuple2(GlobalKey(), '3'),
    Tuple2(GlobalKey(), '4'),
    Tuple2(GlobalKey(), '5'),
    Tuple2(GlobalKey(), '6'),
    Tuple2(GlobalKey(), '7'),
    Tuple2(GlobalKey(), '8'),
    Tuple2(GlobalKey(), '9'),
    Tuple2(GlobalKey(), '10'),
    Tuple2(GlobalKey(), '11'),
    Tuple2(GlobalKey(), '12'),
    Tuple2(GlobalKey(), '13'),
    Tuple2(GlobalKey(), '14'),
    Tuple2(GlobalKey(), '15'),
  ];

  final scrollController = ScrollController();

  GlobalKey? selectedIndex;

  bool onScroll = false;

  void _setSelectedIndex(int index) {
    // print('LL:: _setSelectedIndex $index');
    // if (index < 0) {
    //   selectedIndex = menus.length - 1;
    // } else if (index >= menus.length) {
    //   selectedIndex = 0;
    // } else {
    //   selectedIndex = index;
    // }
    //
    // print(
    //     'LL:: selectedIndex $selectedIndex | menus[selectedIndex!] : ${menus[selectedIndex!]} | currentContext : ${menus[selectedIndex!].item1.currentContext}');
    // setState(() {
    //   Scrollable.ensureVisible(menus[selectedIndex!].item1.currentContext!);
    //   WidgetsBinding.instance!.addPostFrameCallback((_) {
    //     onScroll = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    final endpoints = widget.renderObject
        .getEndpointsForSelection(widget.controller.selection);

    final midX = (endpoints.first.point.dx + endpoints.last.point.dx) / 2;

    final offset = Offset(
      midX,
      widget.renderObject.localToGlobal(Offset(0, endpoints.first.point.dy)).dy,
    );

    final focusNode = FocusNode();

    FocusScope.of(context).requestFocus(focusNode);

    return Stack(
      fit: StackFit.expand,
      children: [
        RawKeyboardListener(
          focusNode: focusNode,
          onKey: (event) {
            if (!onScroll && event is RawKeyDownEvent) {
              onScroll = true;
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                print('SymMenuBlockCreation arrowDown');

                // _setSelectedIndex((selectedIndex ?? -1) + 1);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                // _setSelectedIndex((selectedIndex ?? menus.length + 1) - 1);
              } else if (event.logicalKey == LogicalKeyboardKey.abort ||
                  event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                  event.logicalKey == LogicalKeyboardKey.arrowRight) {
                widget.onDismiss();
              } else {
                onScroll = false;
              }
            }
          },
          child: GestureDetector(
            onTap: () {
              widget.onDismiss();
            },
          ),
        ),
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Material(
            color: SymColors.light_bgWhite,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                side: BorderSide(color: SymColors.light_line)),
            elevation: 5,
            clipBehavior: Clip.hardEdge,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350, maxWidth: 320),
              child: Scrollbar(
                controller: scrollController,
                isAlwaysShown: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: menuSections
                          .map((e) => _buildSection(
                              e.blockType, e.items!, e.withDivider))
                          .toList()),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSection(
      String blockType, List<_MenuBlockItem> items, bool withDivider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerBlockType(blockType),
        ...items.map(_menuItem).toList(),
        if (withDivider) _divider()
      ],
    );
  }

  Widget _headerBlockType(String blockType) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      child: SymText(
        blockType,
      ),
    );
  }

  Widget _menuItem(_MenuBlockItem item) {
    final key = item.key;
    final attr = item.attr;
    final title = item.title;
    final titleSize = item.titleSize;
    final iconAssetName = item.iconAssetName;
    final desc = item.desc;
    final descAssetName = item.descAssetName;
    final shortcutChar = item.shortcutChar;

    return InkWell(
      key: key,
      hoverColor: SymColors.hoverColor,
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            SymAssetImage(
              iconAssetName,
              size: const Size(48, 48),
            ),
            GapH(12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SymText(
                  title,
                  textSize: titleSize,
                  bold: true,
                ),
                if (desc != null)
                  Row(
                    children: [
                      if (descAssetName != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 4, top: 2),
                          child: SymAssetImage(
                            descAssetName,
                            size: const Size(12, 12),
                          ),
                        ),
                      SymText(
                        desc,
                        textColor: SymColors.light_textTertiary,
                      )
                    ],
                  ),
              ],
            )),
            if (shortcutChar != null)
              SymText(
                shortcutChar,
                textColor: SymColors.light_bluePrimary,
                bold: true,
              )
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 16, left: 16, right: 16),
      color: SymColors.light_line,
      height: 1,
    );
  }
}
