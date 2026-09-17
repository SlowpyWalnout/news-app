import 'markdown.dart';

/// Estimated reading time in whole minutes (minimum 1), at 200 words/min —
/// the article body has no stored read-time, so this derives one for display.
/// Strips Markdown syntax first so `**`/`##`/`>` don't count as words.
int estimateReadingMinutes(String body) {
  final plain = stripMarkdown(body).trim();
  final wordCount = plain.isEmpty ? 0 : plain.split(RegExp(r'\s+')).length;
  return (wordCount / 200).ceil().clamp(1, 999);
}
