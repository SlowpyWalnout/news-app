/// Estimated reading time in whole minutes (minimum 1), at 200 words/min —
/// the article body has no stored read-time, so this derives one for display.
int estimateReadingMinutes(String body) {
  final wordCount = body.trim().isEmpty ? 0 : body.trim().split(RegExp(r'\s+')).length;
  return (wordCount / 200).ceil().clamp(1, 999);
}
