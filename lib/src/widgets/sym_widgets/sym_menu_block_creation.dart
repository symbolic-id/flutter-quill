import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../src/utils/iterator_ext.dart';
import '../../../utils/assets.dart';
import '../../models/documents/attribute.dart';
import '../../utils/color.dart';
import '../common_widgets/gap.dart';
import '../controller.dart';
import '../editor.dart';
import 'sym_asset_image.dart';
import 'sym_block_button.dart';
import 'sym_text.dart';

class MenuBlockCreationItem {
  MenuBlockCreationItem({
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
  final Attribute? attr;
  final String title;
  final double titleSize;
  final String iconAssetName;
  String? descAssetName;
  String? desc;
  String? shortcutChar;
  int index = 0;

  void setIndex(int index) {
    this.index = index;
  }
}

class MenuBlockCreationSection {
  MenuBlockCreationSection(this.blockType,
      {required List<MenuBlockCreationItem> defaultItems})
      : defaultItems = defaultItems;

  final String blockType;
  final List<MenuBlockCreationItem> defaultItems;

  bool itemsContainKeyword(String? keyword) {
    if (keyword == null) {
      return true;
    }
    for (final item in defaultItems) {
      if (item.title.toLowerCase().contains(keyword.toLowerCase()) ||
          item.desc?.toLowerCase().contains(keyword.toLowerCase()) == true) {
        return true;
      }
    }
    return false;
  }

  List<MenuBlockCreationItem> getItemsContainKeyword(String? keyword) {
    if (keyword == null) {
      return defaultItems;
    }
    final itemsMatch = <MenuBlockCreationItem>[];

    for (final item in defaultItems) {
      if (item.title.toLowerCase().contains(keyword.toLowerCase()) ||
          item.desc?.toLowerCase().contains(keyword.toLowerCase()) == true) {
        itemsMatch.add(item);
      }
    }

    return itemsMatch;
  }
}

class SymMenuBlockCreation extends StatefulWidget {
  SymMenuBlockCreation(this.controller, this.renderObject,
      {required this.toolbarLayerLink,
      required this.onDismiss,
      required this.onSelected,
      required this.selectionIndex});

  final QuillController controller;
  final RenderEditor renderObject;
  final Function() onDismiss;
  final Function(Attribute?) onSelected;
  final LayerLink toolbarLayerLink;
  int? selectionIndex;

  @override
  State<StatefulWidget> createState() => _SymMenuBlockCreationState();
}

class _SymMenuBlockCreationState extends State<SymMenuBlockCreation> {
  final double MAX_HEIGHT = 350;
  final double MAX_WIDTH = 320;
  final scrollController = ScrollController();

  int? selectedIndex;

  bool onScroll = false;

  final filteredSections = <MenuBlockCreationSection>[];
  final filteredItems = <MenuBlockCreationItem>[];

  void _setSelectedIndex(int index) {
    if (filteredItems.isNotEmpty) {
      if (index < 0) {
        selectedIndex = filteredItems.length - 1;
      } else if (index >= filteredItems.length) {
        selectedIndex = 0;
      } else {
        selectedIndex = index;
      }

      setState(() {
        Scrollable.ensureVisible(
            filteredItems[selectedIndex!].key.currentContext!,
            alignment: 0.5,
            duration: const Duration(milliseconds: 500));
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          onScroll = false;
        });
      });
    }
  }

  var keyword = '';
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final selectionIndex = widget.selectionIndex != null
        ? TextSelection(
            baseOffset: widget.selectionIndex!,
            extentOffset: widget.selectionIndex!)
        : widget.controller.selection;
    filteredSections.clear();
    filteredItems.clear();
    final endpoints =
        widget.renderObject.getEndpointsForSelection(selectionIndex);

    final editingRegion = Rect.fromPoints(
      widget.renderObject.localToGlobal(Offset.zero),
      widget.renderObject
          .localToGlobal(widget.renderObject.size.bottomRight(Offset.zero)),
    );

    final baseLineHeight =
        widget.renderObject.preferredLineHeight(selectionIndex.base);

    var offsetX = endpoints.first.point.dx + editingRegion.left;
    var offsetY = endpoints[0].point.dy + editingRegion.top;

    final screenSize = MediaQuery.of(context).size;

    const safeMargin = 20.0;

    var isUpward = false;

    if (offsetY + MAX_HEIGHT > screenSize.height - safeMargin) {
      isUpward = true;
      offsetY = screenSize.height - offsetY + baseLineHeight;
    }
    if (offsetX + MAX_WIDTH > editingRegion.right - safeMargin) {
      offsetX = editingRegion.right - safeMargin - MAX_WIDTH;
    }

    /* menu trigerred by buttonAdd instead of slash */
    if (widget.selectionIndex != null) {
      offsetX -= SymBlockButton.buttonWidth;
      if (isUpward) {
        offsetY -= baseLineHeight;
      } else {
        offsetY += baseLineHeight;
      }
    }

    final offset = Offset(
      offsetX,
      offsetY,
    );

    FocusScope.of(context).requestFocus(focusNode);

    var itemCount = 0;

    for (final section in defaultMenuBlockCreationSections) {
      if (section.itemsContainKeyword(keyword)) {
        filteredSections.add(section);
        filteredItems.addAll(section.getItemsContainKeyword(keyword));
      }
    }

    return CompositedTransformFollower(
      link: widget.toolbarLayerLink,
      offset: -editingRegion.topLeft,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AbsorbPointer(),
          RawKeyboardListener(
            focusNode: focusNode,
            onKey: _handleRawKeyEvent,
            child: GestureDetector(
              onTap: dismiss,
            ),
          ),
          _positionedMenu(
            isUpward: isUpward,
            offset: offset,
            child: Material(
              color: SymColors.light_bgWhite,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  side: BorderSide(color: SymColors.light_line)),
              elevation: 5,
              clipBehavior: Clip.hardEdge,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxHeight: MAX_HEIGHT, maxWidth: MAX_WIDTH),
                child: Stack(
                  children: [
                    Scrollbar(
                      controller: scrollController,
                      isAlwaysShown: true,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: filteredSections.isNotEmpty
                                ? filteredSections.mapIndexed((e, i) {
                                    final itemStartIndex = itemCount;
                                    itemCount += e
                                        .getItemsContainKeyword(keyword)
                                        .length;

                                    return _buildSection(
                                        e.blockType,
                                        e.getItemsContainKeyword(keyword),
                                        i != filteredSections.length - 1,
                                        itemStartIndex);
                                  }).toList()
                                : [_noResult()]),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Opacity(
                        opacity: keyword.isNotEmpty ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16, top: 8),
                          child: IntrinsicWidth(
                            child: TextField(
                              showCursor: false,
                              focusNode: focusNode,
                              style: GoogleFonts.ibmPlexSans().merge(
                                  const TextStyle(
                                      fontSize: 12,
                                      color: SymColors.light_textTertiary)),
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 12,
                                    color: SymColors.light_textTertiary,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                      maxWidth: 12, maxHeight: 12),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none),
                              onChanged: (text) {
                                setState(() {
                                  keyword = text;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _positionedMenu(
      {required bool isUpward, required Offset offset, required Widget child}) {
    if (!isUpward) {
      return Positioned(
        top: offset.dy,
        left: offset.dx,
        child: child,
      );
    } else {
      return Positioned(
        bottom: offset.dy,
        left: offset.dx,
        child: child,
      );
    }
  }

  Widget _buildSection(String blockType, List<MenuBlockCreationItem> items,
      bool withDivider, int itemStartIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerBlockType(blockType),
        ...items
            .mapIndexed((e, i) => _buildItem(e, itemStartIndex + i))
            .toList(),
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

  Widget _buildItem(MenuBlockCreationItem item, int index) {
    final key = item.key;
    final title = item.title;
    final titleSize = item.titleSize;
    final iconAssetName = item.iconAssetName;
    final desc = item.desc;
    final descAssetName = item.descAssetName;
    final shortcutChar = item.shortcutChar;

    return Material(
      child: InkWell(
        key: key,
        hoverColor: SymColors.hoverColor,
        onTap: () {
          _setSelectedIndex(index);
          onEnter();
        },
        child: Ink(
          color: index == selectedIndex
              ? SymColors.hoverColor
              : SymColors.light_bgWhite,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                ClipOval(
                  child: Container(
                    padding: EdgeInsets.zero,
                    width: 40,
                    height: 40,
                    color: SymColors.light_bgWhite,
                    child: SymAssetImage(
                      iconAssetName,
                      size: const Size(48, 48),
                    ),
                  ),
                ),
                GapH(12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SymText(
                      title,
                      size: titleSize,
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
                            color: SymColors.light_textTertiary,
                          )
                        ],
                      ),
                  ],
                )),
                if (shortcutChar != null)
                  SymText(
                    shortcutChar,
                    color: SymColors.light_bluePrimary,
                    bold: true,
                  )
              ],
            ),
          ),
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

  Widget _noResult() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const SymText(
          'No Result',
          size: 14,
          color: SymColors.light_textTertiary,
        ),
      ),
    );
  }

  void onDown() {
    _setSelectedIndex((selectedIndex ?? -1) + 1);
  }

  void onUp() {
    _setSelectedIndex((selectedIndex ?? 0) - 1);
  }

  void onEnter() {
    if (selectedIndex != null) {
      widget.onSelected(filteredItems[selectedIndex!].attr);
    } else {
      dismiss();
    }
  }

  void dismiss() {
    widget.onDismiss();
  }

  void _handleRawKeyEvent(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      onEnter();
    } else if (event is RawKeyDownEvent) {
      onScroll = true;
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        onDown();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        onUp();
      } else if (event.logicalKey == LogicalKeyboardKey.abort ||
          event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        dismiss();
      } else if (event.logicalKey == LogicalKeyboardKey.backspace &&
          keyword.isEmpty) {
        dismiss();
      } else {
        onScroll = false;
      }
    }
  }
}

/* DEFAULT MENU ITEM */

final List<MenuBlockCreationSection> defaultMenuBlockCreationSections = [
  MenuBlockCreationSection(
    'Format Teks',
    defaultItems: [
      MenuBlockCreationItem(
          key: GlobalKey(),
          attr: null,
          title: 'Teks Biasa',
          iconAssetName: Assets.CIRCLE_FORMAT_NORMAL_TEXT,
          desc: 'Format teks standar dalam paragraf')
    ],
  ),
  MenuBlockCreationSection(
    'Format Judul',
    defaultItems: [
      MenuBlockCreationItem(
          key: GlobalKey(),
          attr: Attribute.h1,
          title: 'Judul Besar',
          titleSize: 20,
          iconAssetName: Assets.CIRCLE_FORMAT_H1,
          shortcutChar: '#'),
      MenuBlockCreationItem(
          key: GlobalKey(),
          attr: Attribute.h2,
          title: 'Judul Sedang',
          titleSize: 16,
          iconAssetName: Assets.CIRCLE_FORMAT_H2,
          shortcutChar: '##'),
      MenuBlockCreationItem(
          key: GlobalKey(),
          attr: Attribute.h3,
          title: 'Judul Kecil',
          iconAssetName: Assets.CIRCLE_FORMAT_H3,
          shortcutChar: '###'),
    ],
  ),
  MenuBlockCreationSection(
    'Format Daftar',
    defaultItems: [
      MenuBlockCreationItem(
          key: GlobalKey(),
          attr: Attribute.ul,
          title: 'Bullet List',
          iconAssetName: Assets.CIRCLE_FORMAT_BULLET_LIST,
          desc: '• Buat daftar dengan pointer lingkaran',
          shortcutChar: '*'),
      MenuBlockCreationItem(
          key: GlobalKey(),
          attr: Attribute.ol,
          title: 'Number List',
          iconAssetName: Assets.CIRCLE_FORMAT_NUMBER_LIST,
          desc: '1. Buat daftar dengan urutan angka',
          shortcutChar: '1.'),
      MenuBlockCreationItem(
          key: GlobalKey(),
          attr: Attribute.unchecked,
          title: 'To do List',
          iconAssetName: Assets.CIRCLE_FORMAT_TODO_LIST,
          desc: 'Buat daftar dengan checkbox',
          descAssetName: Assets.CHECK_12PX),
    ],
  ),
  MenuBlockCreationSection(
    'Hashtag',
    defaultItems: [
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Tag Section',
        iconAssetName: Assets.CIRCLE_FORMAT_TAG,
        desc: 'Menambahkan tag di suatu section',
      ),
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Tag Card',
        iconAssetName: Assets.CIRCLE_FORMAT_TAG,
        desc: 'Menambahkan tag di card',
      ),
    ],
  ),
  MenuBlockCreationSection(
    'Referensi',
    defaultItems: [
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Card Reference',
        iconAssetName: Assets.CIRCLE_FORMAT_REFERENCE,
        desc: 'Menambahkan card lain',
      ),
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Block Embed',
        iconAssetName: Assets.CIRCLE_FORMAT_TAG,
        desc: 'Menambahkan section card lain',
      ),
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Block Reference',
        iconAssetName: Assets.CIRCLE_FORMAT_TAG,
        desc: 'Menambahkan section card lain',
      ),
    ],
  ),
  MenuBlockCreationSection(
    'Referensi #2',
    defaultItems: [
      MenuBlockCreationItem(
          key: GlobalKey(),
          attr: Attribute.blockQuote,
          title: 'Quote',
          iconAssetName: Assets.CIRCLE_FORMAT_QUOTE,
          desc: 'Buat tulisan quote',
          shortcutChar: '>'),
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.codeBlock,
        title: 'Code',
        iconAssetName: Assets.CIRCLE_FORMAT_CODE,
        desc: 'Buat tulisan code snippet',
      ),
    ],
  ),
  MenuBlockCreationSection(
    'Referensi #3',
    defaultItems: [
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Tanggal Sekarang',
        iconAssetName: Assets.CIRCLE_DATE,
        desc: 'Menambahkan tanggal sekarang',
      ),
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Jam Sekarang',
        iconAssetName: Assets.CIRCLE_CLOCK,
        desc: 'Menambahkan jam sekarang',
      ),
    ],
  ),
  MenuBlockCreationSection(
    'Format Sisipan',
    defaultItems: [
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Gambar',
        iconAssetName: Assets.CIRCLE_IMAGE,
        desc: 'Menambahkan file gambar',
      ),
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'GIF',
        iconAssetName: Assets.INSERT_GIF,
        desc: 'Menambahkan GIF',
      ),
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Embed Link',
        iconAssetName: Assets.INSERT_GIF,
        desc: 'Menambahkan rangkuman tautan',
      ),
      MenuBlockCreationItem(
        key: GlobalKey(),
        attr: Attribute.header,
        title: 'Divider',
        iconAssetName: Assets.CIRCLE_DIVIDER,
        desc: 'Menambahkan garis pemisah',
      ),
    ],
  ),
];
