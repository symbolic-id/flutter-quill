import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/models/documents/nodes/leaf.dart';
import 'package:flutter_quill/src/models/documents/nodes/block.dart';
import 'package:flutter_quill/src/models/documents/nodes/line.dart';
import 'package:flutter_quill/src/widgets/sym_widgets/sym_title_widgets/sym_title_kalpataru.dart';
import 'package:tuple/tuple.dart';

import '../models/documents/attribute.dart';
import '../models/documents/document.dart';
import '../models/documents/nodes/embed.dart';
import '../models/documents/style.dart';
import '../models/quill_delta.dart';
import '../utils/diff_delta.dart';
import 'sym_widgets/sym_title_widgets/sym_title_widget.dart';

class QuillController extends ChangeNotifier {
  QuillController({
    required this.document,
    required TextSelection selection,
  }) : _selection = selection;

  factory QuillController.basic() {
    return QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  /// Document managed by this controller.
  final Document document;

  /// Currently selected text within the [document].
  TextSelection get selection => _selection;
  TextSelection _selection;

  /// Store any styles attribute that got toggled by the tap of a button
  /// and that has not been applied yet.
  /// It gets reset after each format action within the [document].
  Style toggledStyle = Style();

  bool ignoreFocusOnTextChange = false;

  /// True when this [QuillController] instance has been disposed.
  ///
  /// A safety mechanism to ensure that listeners don't crash when adding,
  /// removing or listeners to this instance.
  bool _isDisposed = false;

  SymTitleWidget? titleKalpataru;

  // item1: Document state before [change].
  //
  // item2: Change delta applied to the document.
  //
  // item3: The source of this change.
  Stream<Tuple3<Delta, Delta, ChangeSource>> get changes => document.changes;

  TextEditingValue get plainTextEditingValue => TextEditingValue(
        text: document.toPlainText(),
        selection: selection,
      );

  /// Only attributes applied to all characters within this range are
  /// included in the result.
  Style getSelectionStyle() {
    return document
        .collectStyle(selection.start, selection.end - selection.start)
        .mergeAll(toggledStyle);
  }

  /// Returns all styles for any character within the specified text range.
  List<Style> getAllSelectionStyles() {
    final styles = document.collectAllStyles(
        selection.start, selection.end - selection.start)
      ..add(toggledStyle);
    return styles;
  }

  void undo() {
    final tup = document.undo();
    if (tup.item1) {
      _handleHistoryChange(tup.item2);
    }
  }

  void _handleHistoryChange(int? len) {
    if (len! > 0) {
      // if (this.selection.extentOffset >= document.length) {
      // // cursor exceeds the length of document, position it in the end
      // updateSelection(
      // TextSelection.collapsed(offset: document.length), ChangeSource.LOCAL);
      updateSelection(
          TextSelection.collapsed(offset: selection.baseOffset + len),
          ChangeSource.LOCAL);
    } else {
      // no need to move cursor
      notifyListeners();
    }
  }

  void redo() {
    final tup = document.redo();
    if (tup.item1) {
      _handleHistoryChange(tup.item2);
    }
  }

  bool get hasUndo => document.hasUndo;

  bool get hasRedo => document.hasRedo;

  void replaceText(
      int index, int len, Object? data, TextSelection? textSelection,
      {bool ignoreFocus = false}) {
    assert(data is String || data is Embeddable);

    Delta? delta;
    if (len > 0 || data is! String || data.isNotEmpty) {
      delta = document.replace(index, len, data);
      var shouldRetainDelta = toggledStyle.isNotEmpty &&
          delta.isNotEmpty &&
          delta.length <= 2 &&
          delta.last.isInsert;
      if (shouldRetainDelta &&
          toggledStyle.isNotEmpty &&
          delta.length == 2 &&
          delta.last.data == '\n') {
        // if all attributes are inline, shouldRetainDelta should be false
        final anyAttributeNotInline =
            toggledStyle.values.any((attr) => !attr.isInline);
        if (!anyAttributeNotInline) {
          shouldRetainDelta = false;
        }
      }
      if (shouldRetainDelta) {
        final retainDelta = Delta()
          ..retain(index)
          ..retain(data is String ? data.length : 1, toggledStyle.toJson());
        document.compose(retainDelta, ChangeSource.LOCAL);
      }
    }

    toggledStyle = Style();
    if (textSelection != null) {
      if (delta == null || delta.isEmpty) {
        _updateSelection(textSelection, ChangeSource.LOCAL);
      } else {
        final user = Delta()
          ..retain(index)
          ..insert(data)
          ..delete(len);
        final positionDelta = getPositionDelta(user, delta);
        _updateSelection(
          textSelection.copyWith(
            baseOffset: textSelection.baseOffset + positionDelta,
            extentOffset: textSelection.extentOffset + positionDelta,
          ),
          ChangeSource.LOCAL,
        );
      }
    }

    if (ignoreFocus) {
      ignoreFocusOnTextChange = true;
    }
    notifyListeners();
    ignoreFocusOnTextChange = false;
  }

  void formatText(int index, int len, Attribute? attribute) {
    if (len == 0 &&
        attribute!.isInline &&
        attribute.key != Attribute.link.key) {
      toggledStyle = toggledStyle.put(attribute);
    }

    final change = document.format(index, len, attribute);
    final adjustedSelection = selection.copyWith(
        baseOffset: change.transformPosition(selection.baseOffset),
        extentOffset: change.transformPosition(selection.extentOffset));
    if (selection != adjustedSelection) {
      _updateSelection(adjustedSelection, ChangeSource.LOCAL);
    }
    notifyListeners();
  }

  void formatSelection(Attribute? attribute) {
    formatText(selection.start, selection.end - selection.start, attribute);
  }

  void updateSelection(TextSelection textSelection, ChangeSource source) {
    _updateSelection(textSelection, source);
    notifyListeners();
  }

  void formatLine(Line line, Attribute attribute) {
    document.format(line.documentOffset, line.length - 1, attribute);
  }

  void insertLine(Line fromLine, Attribute? attribute,
      {bool fromSlashCommand = false}) {
    if (fromSlashCommand) {
      final currentSelection = selection.extentOffset;
      document.delete(currentSelection - 1, 1);
      _updateSelection(
          TextSelection(
              baseOffset: currentSelection - 1,
              extentOffset: currentSelection - 1),
          ChangeSource.LOCAL);
    }
    final result = document.insertLine(fromLine, attribute);
    _updateSelection(TextSelection(baseOffset: result, extentOffset: result),
        ChangeSource.LOCAL);
    notifyListeners();
  }

  void compose(Delta delta, TextSelection textSelection, ChangeSource source) {
    if (delta.isNotEmpty) {
      document.compose(delta, source);
    }

    textSelection = selection.copyWith(
        baseOffset: delta.transformPosition(selection.baseOffset, force: false),
        extentOffset:
            delta.transformPosition(selection.extentOffset, force: false));
    if (selection != textSelection) {
      _updateSelection(textSelection, source);
    }

    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    // By using `_isDisposed`, make sure that `addListener` won't be called on a
    // disposed `ChangeListener`
    if (!_isDisposed) {
      super.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    // By using `_isDisposed`, make sure that `removeListener` won't be called
    // on a disposed `ChangeListener`
    if (!_isDisposed) {
      super.removeListener(listener);
    }
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      document.close();
    }

    _isDisposed = true;
    super.dispose();
  }

  void _updateSelection(TextSelection textSelection, ChangeSource source) {
    _selection = textSelection;
    final end = document.length - 1;
    _selection = selection.copyWith(
        baseOffset: math.min(selection.baseOffset, end),
        extentOffset: math.min(selection.extentOffset, end));
  }

  void deleteSelectedLine([int? selectedTextIndex]) {
    final line = document
        .getLineFromTextIndex(selectedTextIndex ?? selection.baseOffset);

    final isEmbed = line.children.isNotEmpty
        ? (line.children.first as Leaf).value is Embeddable
        : false;
    final textIndex = selectedTextIndex ?? line.offset;
    int textLength;
    if (!isEmbed) {
      textLength = line.length + 1;
    } else {
      textLength = 1;
    }

    if (textLength < document.length) {
      document.delete(textIndex, line.length);

      final lastCursorIndex = selection.baseOffset;

      if (lastCursorIndex > textIndex) {
        var newCursorIndex = lastCursorIndex - textLength;

        if (newCursorIndex < 0) {
          newCursorIndex = 0;
        }

        updateSelection(
            TextSelection(
                baseOffset: newCursorIndex, extentOffset: newCursorIndex),
            ChangeSource.LOCAL);
      }
    } else {
      replaceText(
          0, line.length - 1, '\n', const TextSelection.collapsed(offset: 0));
    }
  }

  Future<void> copyPlainTextSelectedLine([int? selectedTextIndex]) async {
    final text = document
        .getTextInLineFromTextIndex(selectedTextIndex ?? selection.baseOffset);
    await Clipboard.setData(ClipboardData(text: text));
  }

  void duplicateSelectedLine([int? selectedTextIndex]) {
    final line = document
        .getLineFromTextIndex(selectedTextIndex ?? selection.baseOffset);

    final selectedBlock = line.parent is Block ? line.parent as Block : null;
    var newLineIndex = line.documentOffset + line.length;

    if (line.nextLine == null) {
      newLineIndex--;
    }

    document.duplicateLine(newLineIndex, line,
        selectedBlock?.style.attributes.entries.first.value);
  }

  void turnSelectedLineInto(Attribute? attribute, [int? selectedTextIndex]) {
    final textIndex = selectedTextIndex ?? selection.baseOffset;
    for (final attr in Attribute.blockKeysExceptIndent) {
      if (attr != attribute) {
        document.format(textIndex, 0, Attribute.clone(attr, null));
      }
    }
    document.format(textIndex, 0, attribute);
  }
}
