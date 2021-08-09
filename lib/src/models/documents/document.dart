import 'dart:async';

import 'package:flutter_quill/src/utils/delta_markdown/markdown_converter.dart';
import 'package:tuple/tuple.dart';

import '../quill_delta.dart';
import '../rules/rule.dart';
import 'attribute.dart';
import 'history.dart';
import 'nodes/block.dart';
import 'nodes/container.dart';
import 'nodes/embed.dart';
import 'nodes/line.dart';
import 'nodes/node.dart';
import 'style.dart';

/// The rich text document
class Document {
  Document() : _delta = Delta()..insert('\n') {
    _loadDocument(_delta);
  }

  Document.fromJson(List data) : _delta = _transform(Delta.fromJson(data)) {
    _loadDocument(_delta);
  }

  Document.fromDelta(Delta delta) : _delta = delta {
    _loadDocument(delta);
  }

  Document.fromMarkdown(String data, {bool removeImage = false})
      : _delta = _transform(
            MarkdownConverter.fromMarkdown(data, removeImage: removeImage)) {
    _loadDocument(_delta);
  }

  /// The root node of the document tree
  final Root _root = Root();

  Root get root => _root;

  int get length => _root.length;

  Delta _delta;

  Delta toDelta() => Delta.from(_delta);

  final Rules _rules = Rules.getInstance();

  void setCustomRules(List<Rule> customRules) {
    _rules.setCustomRules(customRules);
  }

  final StreamController<Tuple3<Delta, Delta, ChangeSource>> _observer =
      StreamController.broadcast();

  final History _history = History();

  Stream<Tuple3<Delta, Delta, ChangeSource>> get changes => _observer.stream;

  Delta insert(int index, Object? data,
      {int replaceLength = 0, bool autoAppendNewlineAfterImage = true}) {
    assert(index >= 0);
    assert(data is String || data is Embeddable);
    if (data is Embeddable) {
      data = data.toJson();
    } else if ((data as String).isEmpty) {
      return Delta();
    }

    final delta = _rules.apply(RuleType.INSERT, this, index,
        data: data, len: replaceLength);
    compose(delta, ChangeSource.LOCAL,
        autoAppendNewlineAfterImage: autoAppendNewlineAfterImage);
    return delta;
  }

  void duplicateLine(int index, Line line, Attribute? blockAttr) {
    var _index = index;

    if (line.nextLine == null) {
      insert(_index, '\n');
      _index++;
    }

    final delta = line.toDelta();
    for (final op in delta.toList()) {
      final style =
          op.attributes != null ? Style.fromJson(op.attributes) : null;

      final data = _normalize(op.data);
      _root.insert(_index, data, style);
      _index += op.length!;
      _delta = _root.toDelta();
    }
  }

  int insertLine(Line fromLine, Attribute? blockAttr) {
    var index = fromLine.documentOffset + fromLine.length;

    if (fromLine.nextLine == null) {
      index--;
      insert(index, '\n');
      index++;
    }
    final newLine = Line();

    Block? newBlock;
    if (blockAttr?.isBlock == true) {
      newBlock = Block()
        ..add(newLine)
        ..applyAttribute(blockAttr!);
    }

    final delta = newBlock?.toDelta() ?? newLine.toDelta();
    for (final op in delta.toList()) {
      final style =
          op.attributes != null ? Style.fromJson(op.attributes) : null;

      final data = _normalize(op.data);
      _root.insert(index, data, style);
      index += op.length!;
      _delta = _root.toDelta();
    }

    return index - 1;
  }

  Delta delete(int index, int len) {
    assert(index >= 0 && len > 0);
    final delta = _rules.apply(RuleType.DELETE, this, index, len: len);
    if (delta.isNotEmpty) {
      compose(delta, ChangeSource.LOCAL);
    }
    return delta;
  }

  Delta replace(int index, int len, Object? data,
      {bool autoAppendNewlineAfterImage = true}) {
    assert(index >= 0);
    assert(data is String || data is Embeddable);

    final dataIsNotEmpty = (data is String) ? data.isNotEmpty : true;

    assert(dataIsNotEmpty || len > 0);

    var delta = Delta();

    // We have to insert before applying delete rules
    // Otherwise delete would be operating on stale document snapshot.
    if (dataIsNotEmpty) {
      delta = insert(index, data,
          replaceLength: len,
          autoAppendNewlineAfterImage: autoAppendNewlineAfterImage);
    }

    if (len > 0) {
      final deleteDelta = delete(index, len);
      delta = delta.compose(deleteDelta);
    }

    return delta;
  }

  Delta format(int index, int len, Attribute? attribute) {
    assert(index >= 0 && len >= 0 && attribute != null);

    var delta = Delta();

    final formatDelta = _rules.apply(RuleType.FORMAT, this, index,
        len: len, attribute: attribute);
    if (formatDelta.isNotEmpty) {
      compose(formatDelta, ChangeSource.LOCAL);
      delta = delta.compose(formatDelta);
    }

    return delta;
  }

  /* Get string from entire line by text index */
  String getTextInLineFromTextIndex(int index) {
    var delta = Delta()..retain(index);
    final itr = DeltaIterator(toDelta())..skip(index);

    Operation op;

    var text = '';

    while (itr.hasNext) {
      op = itr.next();

      final _text = op.data is String ? (op.data as String?)! : '';
      final lineBreak = _text.indexOf('\n');
      if (lineBreak < 0) {
        delta.retain(op.length!);
        text = '$text${op.data}';
        continue;
      }
      text = '$text${(op.data as String).substring(0, _text.indexOf('\n'))}';
      break;
    }
    return text;
  }

  /// Only attributes applied to all characters within this range are
  /// included in the result.
  Style collectStyle(int index, int len) {
    final res = queryChild(index);
    return (res.node as Line).collectStyle(res.offset, len);
  }

  /// Returns all styles for any character within the specified text range.
  List<Style> collectAllStyles(int index, int len) {
    final res = queryChild(index);
    return (res.node as Line).collectAllStyles(res.offset, len);
  }

  ChildQuery queryChild(int offset) {
    final res = _root.queryChild(offset, true);
    if (res.node is Line) {
      return res;
    }
    final block = res.node as Block;
    return block.queryChild(res.offset, true);
  }

  Line getLineFromTextIndex(int textIndex) {
    final res = _root.queryChild(textIndex, true);
    if (res.node is Line) {
      return res.node as Line;
    }
    final block = res.node as Block;
    return block.queryChild(res.offset, true).node as Line;
  }

  void compose(Delta delta, ChangeSource changeSource,
      {bool autoAppendNewlineAfterImage = true,
      bool autoAppendNewlineAfterVideo = true}) {
    assert(!_observer.isClosed);
    delta.trim();
    assert(delta.isNotEmpty);

    var offset = 0;
    delta = _transform(delta,
        autoAppendNewlineAfterImage: autoAppendNewlineAfterImage,
        autoAppendNewlineAfterVideo: autoAppendNewlineAfterVideo);
    final originalDelta = toDelta();
    for (final op in delta.toList()) {
      final style =
          op.attributes != null ? Style.fromJson(op.attributes) : null;

      if (op.isInsert) {
        _root.insert(offset, _normalize(op.data), style);
      } else if (op.isDelete) {
        _root.delete(offset, op.length);
      } else if (op.attributes != null) {
        _root.retain(offset, op.length, style);
      }

      if (!op.isDelete) {
        offset += op.length!;
      }
    }
    try {
      _delta = _delta.compose(delta);
    } catch (e) {
      throw '_delta compose failed';
    }

    if (_delta != _root.toDelta()) {
      throw 'Compose failed';
    }
    final change = Tuple3(originalDelta, delta, changeSource);
    _observer.add(change);
    _history.handleDocChange(change);
  }

  Tuple2 undo() {
    return _history.undo(this);
  }

  Tuple2 redo() {
    return _history.redo(this);
  }

  bool get hasUndo => _history.hasUndo;

  bool get hasRedo => _history.hasRedo;

  static Delta _transform(Delta delta,
      {bool autoAppendNewlineAfterImage = true,
      bool autoAppendNewlineAfterVideo = true}) {
    final res = Delta();
    final ops = delta.toList();
    for (var i = 0; i < ops.length; i++) {
      final op = ops[i];
      res.push(op);
      if (autoAppendNewlineAfterImage) {
        _autoAppendNewlineAfterEmbeddable(i, ops, op, res, 'image');
      }
      if (autoAppendNewlineAfterVideo) {
        _autoAppendNewlineAfterEmbeddable(i, ops, op, res, 'video');
      }
    }
    return res;
  }

  static void _autoAppendNewlineAfterEmbeddable(
      int i, List<Operation> ops, Operation op, Delta res, String type) {
    final nextOpIsImage = i + 1 < ops.length &&
        ops[i + 1].isInsert &&
        ops[i + 1].data is Map &&
        (ops[i + 1].data as Map).containsKey(type);
    if (nextOpIsImage &&
        op.data is String &&
        (op.data as String).isNotEmpty &&
        !(op.data as String).endsWith('\n')) {
      res.push(Operation.insert('\n'));
    }
    // embed could be image or video
    final opInsertImage =
        op.isInsert && op.data is Map && (op.data as Map).containsKey(type);
    final nextOpIsLineBreak = i + 1 < ops.length &&
        ops[i + 1].isInsert &&
        ops[i + 1].data is String &&
        (ops[i + 1].data as String).startsWith('\n');
    if (opInsertImage && (i + 1 == ops.length - 1 || !nextOpIsLineBreak)) {
      // automatically append '\n' for embeddable
      res.push(Operation.insert('\n'));
    }
  }

  Object _normalize(Object? data) {
    if (data is String) {
      return data;
    }

    if (data is Embeddable) {
      return data;
    }
    return Embeddable.fromJson(data as Map<String, dynamic>);
  }

  void close() {
    _observer.close();
    _history.clear();
  }

  String toPlainText() => _root.children.map((e) => e.toPlainText()).join();

  void _loadDocument(Delta doc) {
    if (doc.isEmpty) {
      throw ArgumentError.value(doc, 'Document Delta cannot be empty.');
    }

    assert((doc.last.data as String).endsWith('\n'));

    var offset = 0;
    for (final op in doc.toList()) {
      if (!op.isInsert) {
        throw ArgumentError.value(doc,
            'Document can only contain insert operations but ${op.key} found.');
      }
      final style =
          op.attributes != null ? Style.fromJson(op.attributes) : null;
      final data = _normalize(op.data);
      _root.insert(offset, data, style);
      offset += op.length!;
    }
    final node = _root.last;
    if (node is Line &&
        node.parent is! Block &&
        node.style.isEmpty &&
        _root.childCount > 1) {
      _root.remove(node);
    }
  }

  bool isEmpty() {
    if (root.children.length != 1) {
      return false;
    }

    final node = root.children.first;
    if (!node.isLast) {
      return false;
    }

    final delta = node.toDelta();
    return delta.length == 1 &&
        delta.first.data == '\n' &&
        delta.first.key == 'insert';
  }
}

enum ChangeSource {
  LOCAL,
  REMOTE,
}
