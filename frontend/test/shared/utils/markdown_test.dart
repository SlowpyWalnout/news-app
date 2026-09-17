import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/utils/markdown.dart';

void main() {
  group('stripMarkdown', () {
    test('removes bold and italic markers', () {
      expect(stripMarkdown('a **bold** and *italic* word'), 'a bold and italic word');
    });

    test('removes heading markers', () {
      expect(stripMarkdown('## Title\n\n### Subtitle'), 'Title\n\nSubtitle');
    });

    test('removes quote and bullet markers', () {
      expect(stripMarkdown('> a quote'), 'a quote');
      expect(stripMarkdown('- item one'), 'item one');
      expect(stripMarkdown('* item two'), 'item two');
    });

    test('leaves plain text untouched', () {
      const plain = 'Just a normal paragraph with no syntax at all.';
      expect(stripMarkdown(plain), plain);
    });
  });

  group('parseMarkdown', () {
    test('classifies block types', () {
      final blocks = parseMarkdown('## Heading\n\n### Subheading\n\n> A quote\n\nA paragraph.');
      expect(blocks.map((b) => b.type), [
        MarkdownBlockType.heading2,
        MarkdownBlockType.heading3,
        MarkdownBlockType.quote,
        MarkdownBlockType.paragraph,
      ]);
    });

    test('groups consecutive bullet lines into separate bullet blocks', () {
      final blocks = parseMarkdown('- first\n- second');
      expect(blocks.map((b) => b.type), [MarkdownBlockType.bullet, MarkdownBlockType.bullet]);
      expect(blocks[0].spans.single.text, 'first');
      expect(blocks[1].spans.single.text, 'second');
    });

    test('resolves nested inline bold/italic spans', () {
      final blocks = parseMarkdown('plain **bold** and *italic* text');
      final spans = blocks.single.spans;
      expect(spans.map((s) => s.text), ['plain ', 'bold', ' and ', 'italic', ' text']);
      expect(spans[1].bold, isTrue);
      expect(spans[3].italic, isTrue);
    });

    test('renders an unclosed marker as literal text', () {
      final blocks = parseMarkdown('this has an **unclosed marker');
      final spans = blocks.single.spans;
      expect(spans.map((s) => s.text).join(), 'this has an **unclosed marker');
      expect(spans.every((s) => !s.bold), isTrue);
    });

    test('tolerates a heading with no space after the hashes', () {
      final blocks = parseMarkdown('##Title');
      expect(blocks.single.type, MarkdownBlockType.heading2);
      expect(blocks.single.spans.single.text, 'Title');
    });

    test('classifies each line by itself, even without blank lines between them', () {
      // Reproduces a real report: headings, bullets and a quote typed back
      // to back with single newlines used to render as one raw paragraph.
      final blocks = parseMarkdown(
        '## header 2\nheader3\n- item one\n- item two\n> a closing quote',
      );
      expect(blocks.map((b) => b.type), [
        MarkdownBlockType.heading2,
        MarkdownBlockType.paragraph,
        MarkdownBlockType.bullet,
        MarkdownBlockType.bullet,
        MarkdownBlockType.quote,
      ]);
    });

    test('merges consecutive plain lines into one paragraph, keeping line breaks', () {
      final blocks = parseMarkdown('line one\nline two');
      expect(blocks.single.type, MarkdownBlockType.paragraph);
      expect(blocks.single.spans.map((s) => s.text).join(), 'line one\nline two');
    });
  });

  group('tokenizeForEditing', () {
    void expectContiguous(String source) {
      final tokens = tokenizeForEditing(source);
      expect(tokens.map((t) => t.text).join(), source);
    }

    test('reconstructs plain text exactly', () {
      expectContiguous('Just a normal paragraph with no syntax at all.');
    });

    test('reconstructs a body mixing headings, bullets, quote and inline marks', () {
      expectContiguous(
        '## header 2\nheader3\n\n- item one\n- item two\n> a quote\n\ntext with **bold** and *italic*',
      );
    });

    test('reconstructs an empty string', () {
      expect(tokenizeForEditing(''), isEmpty);
    });

    test('reconstructs consecutive blank lines', () {
      expectContiguous('a\n\n\nb');
    });

    test('tags heading, marker and inline spans distinctly', () {
      final tokens = tokenizeForEditing('## Title with **bold**');
      expect(tokens.first.isMarker, isTrue);
      expect(tokens.first.blockType, MarkdownBlockType.heading2);
      final boldToken = tokens.firstWhere((t) => t.text == 'bold');
      expect(boldToken.bold, isTrue);
      expect(boldToken.isMarker, isFalse);
    });
  });
}
