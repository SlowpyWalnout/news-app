/// Minimal Markdown subset for article bodies: only what the editor's
/// toolbar can insert (bold, italic, H2/H3, quote, bullet). No tables,
/// links or images — nothing the toolbar can't produce doesn't need a
/// parser, so anything else is emitted as literal text.
library;

enum MarkdownBlockType { paragraph, heading2, heading3, quote, bullet }

class MarkdownSpan {
  const MarkdownSpan(this.text, {this.bold = false, this.italic = false});

  final String text;
  final bool bold;
  final bool italic;
}

class MarkdownBlock {
  const MarkdownBlock(this.type, this.spans);

  final MarkdownBlockType type;
  final List<MarkdownSpan> spans;
}

final _headingPattern = RegExp(r'^(#{2,3})\s*(.*)$');
final _quotePattern = RegExp(r'^>\s?(.*)$');
final _bulletPattern = RegExp(r'^[-*]\s+(.*)$');
final _inlinePattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');

/// Strips Markdown syntax back to plain text — used wherever the body is
/// shown without a renderer (feed card descriptions, reading-time estimate).
String stripMarkdown(String source) {
  final buffer = StringBuffer();
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    line = line.replaceFirst(RegExp(r'^#{2,3}\s*'), '');
    line = line.replaceFirst(RegExp(r'^>\s?'), '');
    line = line.replaceFirst(RegExp(r'^[-*]\s+'), '');
    line = _stripInline(line);
    buffer.write(line);
    if (i != lines.length - 1) buffer.write('\n');
  }
  return buffer.toString();
}

String _stripInline(String text) {
  return text
      .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m[1]!)
      .replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m[1]!);
}

/// Parses [source] into display blocks, one line at a time — a block type
/// (heading/quote/bullet) only ever applies to the single line it starts on,
/// never to a whole run of text separated by blank lines. Consecutive plain
/// lines are merged into one paragraph, keeping their line breaks.
List<MarkdownBlock> parseMarkdown(String source) {
  final blocks = <MarkdownBlock>[];
  final paragraphLines = <String>[];

  void flushParagraph() {
    if (paragraphLines.isEmpty) return;
    blocks.add(MarkdownBlock(MarkdownBlockType.paragraph, _parseInline(paragraphLines.join('\n'))));
    paragraphLines.clear();
  }

  for (final rawLine in source.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      flushParagraph();
      continue;
    }

    final heading = _headingPattern.firstMatch(line);
    if (heading != null) {
      flushParagraph();
      final type = heading[1]!.length == 2 ? MarkdownBlockType.heading2 : MarkdownBlockType.heading3;
      blocks.add(MarkdownBlock(type, _parseInline(heading[2]!)));
      continue;
    }

    final quote = _quotePattern.firstMatch(line);
    if (quote != null) {
      flushParagraph();
      blocks.add(MarkdownBlock(MarkdownBlockType.quote, _parseInline(quote[1]!)));
      continue;
    }

    final bullet = _bulletPattern.firstMatch(line);
    if (bullet != null) {
      flushParagraph();
      blocks.add(MarkdownBlock(MarkdownBlockType.bullet, _parseInline(bullet[1]!)));
      continue;
    }

    paragraphLines.add(line);
  }
  flushParagraph();

  return blocks;
}

/// Parses `**bold**` and `*italic*` within a single block of text. Unclosed
/// markers fall through as literal text via the final unmatched segment.
List<MarkdownSpan> _parseInline(String text) {
  final spans = <MarkdownSpan>[];
  var last = 0;

  for (final match in _inlinePattern.allMatches(text)) {
    if (match.start > last) {
      spans.add(MarkdownSpan(text.substring(last, match.start)));
    }
    if (match[1] != null) {
      spans.add(MarkdownSpan(match[1]!, bold: true));
    } else {
      spans.add(MarkdownSpan(match[2]!, italic: true));
    }
    last = match.end;
  }
  if (last < text.length) {
    spans.add(MarkdownSpan(text.substring(last)));
  }
  if (spans.isEmpty) spans.add(const MarkdownSpan(''));
  return spans;
}

/// A slice of the raw editor text, tagged with the block/inline styling it
/// should render with while the author is still typing, and whether it's
/// syntax (`**`, `##`, `>`, `-`) rather than content — syntax renders dimmed
/// instead of being hidden, since hiding it would desync the cursor from
/// what's on screen.
class MarkdownEditToken {
  const MarkdownEditToken({
    required this.text,
    required this.blockType,
    required this.isMarker,
    this.bold = false,
    this.italic = false,
  });

  final String text;
  final MarkdownBlockType blockType;
  final bool isMarker;
  final bool bold;
  final bool italic;
}

/// Tokenizes [source] for live-formatting the write tab. The returned tokens
/// are contiguous and gap-free: concatenating every token's `text` in order
/// reproduces [source] exactly (newlines included), which is what keeps the
/// `TextField` cursor/selection — computed against that same string — in
/// sync with what's drawn on screen.
List<MarkdownEditToken> tokenizeForEditing(String source) {
  if (source.isEmpty) return const [];
  final tokens = <MarkdownEditToken>[];
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    tokens.addAll(_tokenizeLineForEditing(lines[i]));
    if (i != lines.length - 1) {
      tokens.add(const MarkdownEditToken(text: '\n', blockType: MarkdownBlockType.paragraph, isMarker: false));
    }
  }
  return tokens;
}

final _headingMarkerPattern = RegExp(r'^(#{2,3}\s*)(.*)$');
final _quoteMarkerPattern = RegExp(r'^(>\s?)(.*)$');
final _bulletMarkerPattern = RegExp(r'^([-*]\s+)(.*)$');

List<MarkdownEditToken> _tokenizeLineForEditing(String line) {
  final heading = _headingMarkerPattern.firstMatch(line);
  if (heading != null) {
    final type = heading[1]!.trim().length == 2 ? MarkdownBlockType.heading2 : MarkdownBlockType.heading3;
    return [
      MarkdownEditToken(text: heading[1]!, blockType: type, isMarker: true),
      ..._tokenizeInlineForEditing(heading[2]!, type),
    ];
  }

  final quote = _quoteMarkerPattern.firstMatch(line);
  if (quote != null) {
    return [
      MarkdownEditToken(text: quote[1]!, blockType: MarkdownBlockType.quote, isMarker: true),
      ..._tokenizeInlineForEditing(quote[2]!, MarkdownBlockType.quote),
    ];
  }

  final bullet = _bulletMarkerPattern.firstMatch(line);
  if (bullet != null) {
    return [
      MarkdownEditToken(text: bullet[1]!, blockType: MarkdownBlockType.bullet, isMarker: true),
      ..._tokenizeInlineForEditing(bullet[2]!, MarkdownBlockType.bullet),
    ];
  }

  return _tokenizeInlineForEditing(line, MarkdownBlockType.paragraph);
}

List<MarkdownEditToken> _tokenizeInlineForEditing(String text, MarkdownBlockType blockType) {
  if (text.isEmpty) return const [];
  final tokens = <MarkdownEditToken>[];
  var last = 0;

  for (final match in _inlinePattern.allMatches(text)) {
    if (match.start > last) {
      tokens.add(MarkdownEditToken(text: text.substring(last, match.start), blockType: blockType, isMarker: false));
    }
    final isBold = match[1] != null;
    final marker = isBold ? '**' : '*';
    final inner = isBold ? match[1]! : match[2]!;
    tokens.add(MarkdownEditToken(text: marker, blockType: blockType, isMarker: true, bold: isBold, italic: !isBold));
    tokens.add(MarkdownEditToken(text: inner, blockType: blockType, isMarker: false, bold: isBold, italic: !isBold));
    tokens.add(MarkdownEditToken(text: marker, blockType: blockType, isMarker: true, bold: isBold, italic: !isBold));
    last = match.end;
  }
  if (last < text.length) {
    tokens.add(MarkdownEditToken(text: text.substring(last), blockType: blockType, isMarker: false));
  }
  return tokens;
}
