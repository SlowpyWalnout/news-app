// Vendored copy of backend/scripts/search-keywords.mjs. `firebase deploy`
// only packages backend/functions/ (see firebase.json `functions.source`) —
// a relative import reaching outside that directory resolves fine locally
// but is absent from the uploaded bundle, crashing the Cloud Run container
// before it can bind its health-check port (silent "Container Healthcheck
// failed" with no application log). Kept in sync via the same golden
// vectors as the original: see search_keywords.test.mjs in this folder,
// which asserts against ../../scripts/tokenizer-fixtures.json (a test file
// never gets deployed, so reaching outside functions/ there is safe).
//
// Node port of frontend/lib/shared/utils/search_keywords.dart.

const ACCENT_FOLD = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ñ': 'n',
  'ç': 'c',
  'ý': 'y', 'ÿ': 'y',
};

const STOPWORDS = new Set([
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
]);

const MIN_TOKEN_LENGTH = 2;
const MAX_KEYWORDS = 30;
const MAX_AUTHOR_TOKENS = 4;

function foldAccents(input) {
  let out = '';
  for (const ch of input) {
    out += ACCENT_FOLD[ch] ?? ch;
  }
  return out;
}

function rawTokens(input) {
  const folded = foldAccents(input.toLowerCase());
  const cleaned = folded.replace(/[^a-z0-9]+/g, ' ');
  return cleaned.split(/\s+/).filter((t) => t.length > 0);
}

/** Normalized, deduped tokens for `raw` — no cap. */
export function searchTokensFor(raw) {
  const seen = new Set();
  const result = [];
  for (const token of rawTokens(raw)) {
    if (token.length < MIN_TOKEN_LENGTH) continue;
    if (STOPWORDS.has(token)) continue;
    if (!seen.has(token)) {
      seen.add(token);
      result.push(token);
    }
  }
  return result;
}

/**
 * The `searchKeywords` array stored on an article. Priority order —
 * category, then up to MAX_AUTHOR_TOKENS author tokens, then title tokens
 * in document order — so a long title can't crowd out the author/category
 * slots before the 30-token cap (firestore.rules denies writes above it).
 */
export function buildSearchKeywords({ title, authorName, categoryName }) {
  const seen = new Set();
  const result = [];

  function addAll(tokens, limit) {
    let added = 0;
    for (const token of tokens) {
      if (limit !== undefined && added >= limit) break;
      if (!seen.has(token)) {
        seen.add(token);
        result.push(token);
        added++;
      }
    }
  }

  addAll(searchTokensFor(categoryName));
  addAll(searchTokensFor(authorName), MAX_AUTHOR_TOKENS);
  addAll(searchTokensFor(title));

  return result.slice(0, MAX_KEYWORDS);
}
