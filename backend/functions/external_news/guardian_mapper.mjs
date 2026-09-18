// Mapea la respuesta de The Guardian Open Platform
// (content?show-fields=bodyText,thumbnail,trailText) a un documento de
// `articles`. Sin Admin SDK: los timestamps se devuelven como epoch millis,
// el cableado en index.mjs los convierte a Timestamp de Firestore.
//
// Guardian permite cuerpo completo real (a diferencia de GNews, que lo
// trunca en el free tier) pero sus términos prohíben conservar el contenido
// más de 24h — de ahí EXPIRY_MS más corto que el de GNews.

import { canonicalizeUrl, externalArticleIdFor } from './shared.mjs';
import { buildSearchKeywords } from './search_keywords.mjs';

export const EXPIRY_MS = 24 * 60 * 60 * 1000;

const SECTION_TO_CATEGORY = {
  business: 'business',
  culture: 'entertainment',
  film: 'entertainment',
  music: 'entertainment',
  stage: 'entertainment',
  lifeandstyle: 'entertainment',
  society: 'health',
  environment: 'science',
  science: 'science',
  sport: 'sports',
  football: 'sports',
  technology: 'technology',
  politics: 'politics',
  world: 'general',
  uk: 'general',
  us: 'general',
};

function categoryFromSection(sectionId) {
  return SECTION_TO_CATEGORY[sectionId] ?? 'general';
}

/**
 * Mapea un único artículo de la respuesta de Guardian. Devuelve `null` si
 * falta algo indispensable (url, título o fecha de publicación válida) en
 * vez de escribir un documento incompleto.
 */
export function mapGuardianArticle(raw) {
  if (!raw || typeof raw !== 'object') return null;

  const sourceUrl = raw.webUrl;
  const title = raw.webTitle;
  if (typeof sourceUrl !== 'string' || sourceUrl.length === 0) return null;
  if (typeof title !== 'string' || title.length === 0) return null;

  const publishedAtMillis = Date.parse(raw.webPublicationDate ?? '');
  if (Number.isNaN(publishedAtMillis)) return null;

  const fields = raw.fields ?? {};
  const canonicalUrl = canonicalizeUrl(sourceUrl);
  const category = categoryFromSection(raw.sectionId ?? '');

  return {
    id: externalArticleIdFor(sourceUrl),
    authorId: 'external:guardian',
    authorName: 'The Guardian',
    authorPhotoURL: null,
    title,
    body: typeof fields.bodyText === 'string' && fields.bodyText.length > 0 ? fields.bodyText : (fields.trailText ?? ''),
    status: 'published',
    category,
    thumbnailURL: typeof fields.thumbnail === 'string' ? fields.thumbnail : null,
    thumbnailPath: null,
    searchKeywords: buildSearchKeywords({ title, authorName: 'The Guardian', categoryName: category }),
    source: 'guardian',
    sourceName: 'The Guardian',
    sourceUrl: canonicalUrl,
    hasFullBody: typeof fields.bodyText === 'string' && fields.bodyText.length > 0,
    lang: 'en',
    publishedAtMillis,
    fetchedAtMillis: Date.now(),
    expiresAtMillis: Date.now() + EXPIRY_MS,
  };
}

/** Mapea una página de resultados de Guardian, filtrando y deduplicando por id. */
export function mapGuardianResponse(payload) {
  const results = payload?.response?.results;
  if (!Array.isArray(results)) return [];

  const seen = new Set();
  const mapped = [];
  for (const raw of results) {
    const article = mapGuardianArticle(raw);
    if (!article) continue;
    if (seen.has(article.id)) continue;
    seen.add(article.id);
    mapped.push(article);
  }
  return mapped;
}
