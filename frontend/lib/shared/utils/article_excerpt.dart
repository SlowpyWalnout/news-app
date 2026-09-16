/// First ~[maxLength] characters of [body], cut on a word boundary — used
/// as the feed card excerpt since the entity has no stored summary.
String articleExcerpt(String body, {int maxLength = 140}) {
  final trimmed = body.trim();
  if (trimmed.length <= maxLength) return trimmed;
  final cut = trimmed.substring(0, maxLength);
  final lastSpace = cut.lastIndexOf(' ');
  final safeCut = lastSpace > 0 ? cut.substring(0, lastSpace) : cut;
  return '$safeCut…';
}
