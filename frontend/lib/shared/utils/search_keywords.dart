// Same normalization pipeline must run on write (buildSearchKeywords) and on
// read (searchTokensFor/primarySearchToken) — if they diverge, Firestore's
// array-contains silently returns nothing. See backend/scripts/search-keywords.mjs
// for the Node port used by the backfill script, and
// backend/scripts/tokenizer-fixtures.json for the golden vectors both sides
// assert against.

const Map<int, int> _accentFold = {
  0xE0: 0x61, 0xE1: 0x61, 0xE2: 0x61, 0xE3: 0x61, 0xE4: 0x61, 0xE5: 0x61, // a
  0xE8: 0x65, 0xE9: 0x65, 0xEA: 0x65, 0xEB: 0x65, // e
  0xEC: 0x69, 0xED: 0x69, 0xEE: 0x69, 0xEF: 0x69, // i
  0xF2: 0x6F, 0xF3: 0x6F, 0xF4: 0x6F, 0xF5: 0x6F, 0xF6: 0x6F, // o
  0xF9: 0x75, 0xFA: 0x75, 0xFB: 0x75, 0xFC: 0x75, // u
  0xF1: 0x6E, // ñ
  0xE7: 0x63, // ç
  0xFD: 0x79, 0xFF: 0x79, // y
};

const Set<String> _stopwords = {
  // es
  'de', 'la', 'el', 'los', 'las', 'un', 'una', 'unos', 'unas', 'y', 'o', 'u',
  'que', 'en', 'con', 'por', 'para', 'del', 'al', 'se', 'no', 'lo', 'su',
  'sus', 'es', 'son', 'fue', 'fueron', 'era', 'eran', 'como', 'mas', 'pero',
  'si', 'ya', 'sin', 'sobre', 'entre', 'este', 'esta', 'esto', 'estos',
  'estas', 'ese', 'esa', 'eso', 'esas', 'esos', 'aquel', 'aquella', 'muy',
  'tambien', 'cuando', 'donde', 'quien', 'quienes', 'cual', 'cuales',
  'desde', 'hasta', 'le', 'les', 'mi', 'mis', 'tu', 'tus', 'nos', 'ellos',
  'ellas', 'ser', 'estar', 'hay', 'habia', 'han', 'ha', 'he', 'has',
  'hemos', 'sera', 'seran', 'seremos', 'mismo', 'misma', 'mismos',
  'mismas', 'otro', 'otra', 'otros', 'otras', 'todo', 'toda', 'todos',
  'todas', 'nada', 'algo', 'alguna', 'alguno', 'algunos', 'algunas',
  'cada', 'porque', 'pues', 'aunque',
  // en
  'the', 'a', 'an', 'and', 'or', 'of', 'to', 'in', 'on', 'for', 'with',
  'from', 'at', 'by', 'is', 'are', 'was', 'were', 'be', 'this', 'that',
  'it', 'as', 'not', 'but', 'if', 'then', 'than', 'so', 'such', 'your',
  'you', 'our', 'their', 'his', 'her', 'its', 'what', 'which', 'who',
  'whom', 'these', 'those', 'there', 'here', 'about', 'into', 'over',
  'under', 'again', 'further', 'once', 'more', 'most', 'other', 'some',
  'nor', 'only', 'own', 'same', 'too', 'very', 'can', 'will', 'just',
  'don', 'should', 'now',
};

const int _minTokenLength = 2;
const int _maxKeywords = 30;
const int _maxAuthorTokens = 4;

String _foldAccents(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    buffer.writeCharCode(_accentFold[rune] ?? rune);
  }
  return buffer.toString();
}

List<String> _rawTokens(String input) {
  final folded = _foldAccents(input.toLowerCase());
  final cleaned = folded.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  return cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
}

/// Normalized, deduped tokens for [raw] — no cap. Used both to search the
/// residual (non-primary) tokens client-side and to tokenize a query string.
List<String> searchTokensFor(String raw) {
  final seen = <String>{};
  final result = <String>[];
  for (final token in _rawTokens(raw)) {
    if (token.length < _minTokenLength) continue;
    if (_stopwords.contains(token)) continue;
    if (seen.add(token)) result.add(token);
  }
  return result;
}

/// The `searchKeywords` array stored on an article. Priority order —
/// category, then up to [_maxAuthorTokens] author tokens, then title tokens
/// in document order — so a long title can't crowd out the author/category
/// slots before the 30-token cap (firestore.rules denies writes above it).
List<String> buildSearchKeywords({
  required String title,
  required String authorName,
  required String categoryName,
}) {
  final seen = <String>{};
  final result = <String>[];

  void addAll(Iterable<String> tokens, {int? limit}) {
    var added = 0;
    for (final token in tokens) {
      if (limit != null && added >= limit) break;
      if (seen.add(token)) {
        result.add(token);
        added++;
      }
    }
  }

  addAll(searchTokensFor(categoryName));
  addAll(searchTokensFor(authorName), limit: _maxAuthorTokens);
  addAll(searchTokensFor(title));

  return result.take(_maxKeywords).toList();
}

/// The single token sent as Firestore's `array-contains` clause (only one is
/// allowed per query) — the longest token in [raw], since longer tokens tend
/// to be the most selective. Remaining tokens are matched client-side
/// against the returned page's `searchKeywords`. `null` when [raw] has no
/// usable token (empty, or only stopwords/short words).
String? primarySearchToken(String raw) {
  final tokens = searchTokensFor(raw);
  if (tokens.isEmpty) return null;
  var best = tokens.first;
  for (final token in tokens.skip(1)) {
    if (token.length > best.length) best = token;
  }
  return best;
}
