import 'dart:math' as math;

import '../../models/documents/attribute.dart';
import '../../models/documents/nodes/container.dart';
import '../../models/documents/nodes/embed.dart';
import '../../models/documents/nodes/leaf.dart';
import '../../models/documents/nodes/line.dart';
import '../../models/documents/nodes/node.dart';
import '../../models/documents/style.dart';
import '../../models/quill_delta.dart';

class SymTitle extends Container<Leaf?> {
  @override
  Leaf? get defaultChild => Text('Buat Judul');

  @override
  int get length => super.length + 1;

  Line? get nextLine {
    return null;
    // if (!isLast) {
    //   return next is Block ? (next as Block).first as Line? : next as Line?;
    // }
    //
    // if (parent!.isLast) {
    //   return null;
    // }
    // return parent!.next is Block
    //     ? (parent!.next as Block).first as Line?
    //     : parent!.next as Line?;
  }

  @override
  Node newInstance() => SymTitle();

  @override
  Delta toDelta() {
    final delta = children
        .map((child) => child.toDelta())
        .fold(Delta(), (dynamic a, b) => a.concat(b));

    var attributes = style;

    attributes = attributes/*.merge(Attribute.h1).merge(Attribute.bold)*/;
    delta.insert('\n');
    return delta;
  }

  @override
  String toPlainText() => '${super.toPlainText()}\n';

  @override
  String toString() {
    final body = children.join(' → ');
    final styleString = style.isNotEmpty ? ' $style' : '';
    return '¶ $body ⏎$styleString';
  }

  @override
  void insert(int index, Object data, Style? style) {
    if (data is Embeddable) {
      return;
    }

    final text = data as String;
    final lineBreak = text.indexOf('\n');
    if (lineBreak < 0) {
      _insertSafe(index, text, style);
      return;
    }

    final prefix = text.substring(0, lineBreak);
    _insertSafe(index, prefix, style);
    if (prefix.isNotEmpty) {
      index += prefix.length;
    }

    // Next line inherits our format.
    final nextLine = _getNextLine(index);

    // Reset our format and unwrap from a block if needed.
    clearStyle();

    // Now we can apply new format and re-layout.
    _format(style);

    // Continue with remaining part.
    final remain = text.substring(lineBreak + 1);
    nextLine.insert(0, remain, style);
  }

  @override
  void retain(int index, int? len, Style? style) {
    if (style == null) {
      return;
    }
    final thisLength = length;

    final local = math.min(thisLength - index, len!);
    // If index is at newline character then this is a line/block style update.
    final isLineFormat = (index + local == thisLength) && local == 1;

    if (isLineFormat) {
      assert(style.values.every((attr) => attr.scope == AttributeScope.BLOCK),
      'It is not allowed to apply inline attributes to line itself.');
      _format(style);
    } else {
      // Otherwise forward to children as it's an inline format update.
      assert(style.values.every((attr) => attr.scope == AttributeScope.INLINE));
      assert(index + local != thisLength);
      super.retain(index, local, style);
    }

    final remain = len - local;
    if (remain > 0) {
      assert(nextLine != null);
      nextLine!.retain(0, remain, style);
    }
  }

  @override
  void delete(int index, int? len) {
    final local = math.min(length - index, len!);
    final isLFDeleted = index + local == length; // Line feed
    if (isLFDeleted) {
      // Our newline character deleted with all style information.
      clearStyle();
      if (local > 1) {
        // Exclude newline character from delete range for children.
        super.delete(index, local - 1);
      }
    } else {
      super.delete(index, local);
    }

    final remaining = len - local;
    if (remaining > 0) {
      assert(nextLine != null);
      nextLine!.delete(0, remaining);
    }

    if (isLFDeleted && isNotEmpty) {
      // Since we lost our line-break and still have child text nodes those must
      // migrate to the next line.

      // nextLine might have been unmounted since last assert so we need to
      // check again we still have a line after us.
      assert(nextLine != null);

      // Move remaining children in this line to the next line so that all
      // attributes of nextLine are preserved.
      nextLine!.moveChildToNewParent(this);
      moveChildToNewParent(nextLine);
    }

    if (isLFDeleted) {
      // Now we can remove this line.
      final block = parent!; // remember reference before un-linking.
      unlink();
      block.adjust();
    }
  }

  /// Formats this line.
  void _format(Style? newStyle) {
    if (newStyle == null || newStyle.isEmpty) {
      return;
    }

    applyStyle(newStyle);
    final blockStyle = newStyle.getBlockExceptHeader();
    if (blockStyle == null) {
      return;
    } // No block-level changes
  }

  Line _getNextLine(int index) {
    assert(index == 0 || (index > 0 && index < length));

    final line = Line();
    insertAfter(line);
    if (index == length - 1) {
      return line;
    }

    final query = queryChild(index, false);
    while (!query.node!.isLast) {
      final next = (last as Leaf)..unlink();
      line.addFirst(next);
    }
    final child = query.node as Leaf;
    final cut = child.splitAt(query.offset);
    cut?.unlink();
    line.addFirst(cut);
    return line;
  }

  void _insertSafe(int index, Object data, Style? style) {
    assert(index == 0 || (index > 0 && index < length));

    if (data is String) {
      assert(!data.contains('\n'));
      if (data.isEmpty) {
        return;
      }
    }

    if (isEmpty) {
      final child = Leaf(data);
      add(child);
      child.format(style);
    } else {
      final result = queryChild(index, true);
      result.node!.insert(result.offset, data, style);
    }
  }



  /// Returns style for specified text range.
  ///
  /// Only attributes applied to all characters within this range are
  /// included in the result. Inline and line level attributes are
  /// handled separately, e.g.:
  ///
  /// - line attribute X is included in the result only if it exists for
  ///   every line within this range (partially included lines are counted).
  /// - inline attribute X is included in the result only if it exists
  ///   for every character within this range (line-break characters excluded).
  Style collectStyle(int offset, int len) {
    final local = math.min(length - offset, len);
    var result = Style();
    final excluded = <Attribute>{};

    void _handle(Style style) {
      if (result.isEmpty) {
        excluded.addAll(style.values);
      } else {
        for (final attr in result.values) {
          if (!style.containsKey(attr.key)) {
            excluded.add(attr);
          }
        }
      }
      final remaining = style.removeAll(excluded);
      result = result.removeAll(excluded);
      result = result.mergeAll(remaining);
    }

    final data = queryChild(offset, true);
    var node = data.node as Leaf?;
    if (node != null) {
      result = result.mergeAll(node.style);
      var pos = node.length - data.offset;
      while (!node!.isLast && pos < local) {
        node = node.next as Leaf?;
        _handle(node!.style);
        pos += node.length;
      }
    }

    result = result.mergeAll(style);

    final remaining = len - local;
    if (remaining > 0) {
      final rest = nextLine!.collectStyle(0, remaining);
      _handle(rest);
    }

    return result;
  }

}