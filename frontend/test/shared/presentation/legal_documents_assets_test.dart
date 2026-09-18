import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/utils/markdown.dart';

// Reads the asset files directly off disk (not via rootBundle) so this stays
// a plain unit test, same style as markdown_test.dart — no widget pump
// needed just to check the legal docs parse cleanly.
void main() {
  for (final doc in ['privacy', 'terms']) {
    for (final locale in ['es', 'en']) {
      group('${doc}_$locale.md', () {
        late String content;

        setUpAll(() {
          content = File('assets/legal/${doc}_$locale.md').readAsStringSync();
        });

        test('is not empty', () {
          expect(content.trim(), isNotEmpty);
        });

        test('parses without leaving raw syntax as literal paragraph text', () {
          final blocks = parseMarkdown(content);
          expect(blocks, isNotEmpty);
          for (final block in blocks) {
            for (final span in block.spans) {
              expect(span.text, isNot(contains('##')));
              expect(span.text, isNot(contains('**')));
            }
          }
        });

        test('has no links or tables — outside the supported subset', () {
          expect(content, isNot(contains('](')));
          expect(content, isNot(contains('|---')));
        });
      });
    }
  }
}
