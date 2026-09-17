import 'package:flutter/widgets.dart';

/// Pure text-transform helpers behind the editor's formatting toolbar.
/// Kept free of any widget so they can be unit-tested directly.

/// Wraps the current selection in [marker] (`**` for bold, `*` for italic),
/// toggling it off if the selection is already wrapped. With an empty
/// selection, inserts [placeholder] wrapped in the marker and selects the
/// placeholder, so the author types over it instead of landing between two
/// bare markers with no visible cue.
TextEditingValue applyInlineMarker(TextEditingValue value, String marker, {required String placeholder}) {
  final text = value.text;
  final selection = value.selection;
  if (!selection.isValid) return value;

  final start = selection.start;
  final end = selection.end;
  final markerLen = marker.length;

  final alreadyWrapped = start >= markerLen &&
      end + markerLen <= text.length &&
      text.substring(start - markerLen, start) == marker &&
      text.substring(end, end + markerLen) == marker;

  if (alreadyWrapped) {
    final newText = text.substring(0, start - markerLen) +
        text.substring(start, end) +
        text.substring(end + markerLen);
    return TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start - markerLen,
        extentOffset: end - markerLen,
      ),
    );
  }

  final selected = text.substring(start, end);
  final inserted = selected.isEmpty ? placeholder : selected;
  final newText = text.substring(0, start) + marker + inserted + marker + text.substring(end);
  final newSelection = TextSelection(
    baseOffset: start + markerLen,
    extentOffset: start + markerLen + inserted.length,
  );
  return TextEditingValue(text: newText, selection: newSelection);
}

/// Adds [prefix] (e.g. `"## "`, `"> "`, `"- "`) to the start of the line the
/// cursor is on, or removes it if already present (toggle).
TextEditingValue applyLinePrefix(TextEditingValue value, String prefix) {
  final text = value.text;
  final selection = value.selection;
  if (!selection.isValid) return value;

  final lineStart = selection.start == 0 ? 0 : text.lastIndexOf('\n', selection.start - 1) + 1;
  var lineEnd = text.indexOf('\n', selection.start);
  if (lineEnd == -1) lineEnd = text.length;

  final line = text.substring(lineStart, lineEnd);
  final cursorOffsetInLine = selection.start - lineStart;

  String newLine;
  int delta;
  if (line.startsWith(prefix)) {
    newLine = line.substring(prefix.length);
    delta = -prefix.length;
  } else {
    newLine = prefix + line;
    delta = prefix.length;
  }

  final newText = text.substring(0, lineStart) + newLine + text.substring(lineEnd);
  final newOffset = (lineStart + cursorOffsetInLine + delta).clamp(lineStart, lineStart + newLine.length);
  return TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: newOffset));
}
