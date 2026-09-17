import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/article_composer/presentation/screens/article_editor/markdown_editing.dart';

TextEditingValue _value(String text, int start, int end) {
  return TextEditingValue(text: text, selection: TextSelection(baseOffset: start, extentOffset: end));
}

void main() {
  group('applyInlineMarker', () {
    test('wraps a non-empty selection', () {
      final result = applyInlineMarker(_value('hello world', 6, 11), '**', placeholder: 'text');
      expect(result.text, 'hello **world**');
      expect(result.selection, const TextSelection(baseOffset: 8, extentOffset: 13));
    });

    test('inserts the placeholder already selected for an empty selection', () {
      final result = applyInlineMarker(_value('hello ', 6, 6), '*', placeholder: 'text');
      expect(result.text, 'hello *text*');
      expect(result.selection, const TextSelection(baseOffset: 7, extentOffset: 11));
    });

    test('toggles an already-wrapped selection off', () {
      final result = applyInlineMarker(_value('hello **world**', 8, 13), '**', placeholder: 'text');
      expect(result.text, 'hello world');
      expect(result.selection, const TextSelection(baseOffset: 6, extentOffset: 11));
    });
  });

  group('applyLinePrefix', () {
    test('adds prefix to an empty line', () {
      final result = applyLinePrefix(_value('', 0, 0), '## ');
      expect(result.text, '## ');
      expect(result.selection, const TextSelection.collapsed(offset: 3));
    });

    test('adds prefix at cursor mid-line, preserving cursor offset within the line', () {
      final result = applyLinePrefix(_value('hello world', 5, 5), '> ');
      expect(result.text, '> hello world');
      expect(result.selection, const TextSelection.collapsed(offset: 7));
    });

    test('toggles an existing prefix off', () {
      final result = applyLinePrefix(_value('- item', 2, 2), '- ');
      expect(result.text, 'item');
      expect(result.selection, const TextSelection.collapsed(offset: 0));
    });

    test('only affects the current line in a multi-line body', () {
      final result = applyLinePrefix(_value('first\nsecond\nthird', 8, 8), '### ');
      expect(result.text, 'first\n### second\nthird');
    });
  });
}
