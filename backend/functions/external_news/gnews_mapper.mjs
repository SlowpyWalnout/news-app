// Mapea la respuesta de GNews.io a un documento de `articles`. El free tier
// trunca `content` (~200 chars), así que aquí `body` guarda el resumen
// (`description`) y nunca se presenta como cuerpo completo — `hasFullBody`
// queda en false para que la UI muestre el aviso y el CTA a la fuente.

import { canonicalizeUrl, externalArticleIdFor } from './shared.mjs';
import { buildSearchKeywords } from './search_keywords.mjs';

export const EXPIRY_MS = 7 * 24 * 60 * 60 * 1000;

const ALLOWED_CATEGORIES = new Set(['general', 'business', 'entertainment', 'health', 'science', 'sports', 'technology', 'politics']);

function normalizeCategory(topic) {
  return ALLOWED_CATEGORIES.has(topic) ? topic : 'general';
}

/**
 * Mapea un único artículo de GNews. `lang` viene de la llamada que lo trajo
 * (GNews no lo repite por artículo). Devuelve `null` si falta url, título o
 * la fecha de publicación es inválida.
 */
export function mapGNewsArticle(raw, { lang, topic } = {}) {
  if (!raw || typeof raw !== 'object') return null;

  const sourceUrl = raw.url;
  const title = raw.title;
  if (typeof sourceUrl !== 'string' || sourceUrl.length === 0) return null;
  if (typeof title !== 'string' || title.length === 0) return null;

  const publishedAtMillis = Date.parse(raw.publishedAt ?? '');
  if (Number.isNaN(publishedAtMillis)) return null;

  const canonicalUrl = canonicalizeUrl(sourceUrl);
  const category = normalizeCategory(topic);
  const sourceName = raw.source?.name ?? 'GNews';
  const summary = raw.description ?? '';

  return {
    id: externalArticleIdFor(sourceUrl),
    authorId: 'external:gnews',
    authorName: sourceName,
    authorPhotoURL: null,
    title,
    body: summary,
    status: 'published',
    category,
    thumbnailURL: typeof raw.image === 'string' ? raw.image : null,
    thumbnailPath: null,
    searchKeywords: buildSearchKeywords({ title, authorName: sourceName, categoryName: category }),
    source: 'gnews',
    sourceName,
    sourceUrl: canonicalUrl,
    hasFullBody: false,
    lang: lang ?? 'en',
    publishedAtMillis,
    fetchedAtMillis: Date.now(),
    expiresAtMillis: Date.now() + EXPIRY_MS,
  };
}

/** Mapea una página de resultados de GNews, filtrando y deduplicando por id. */
export function mapGNewsResponse(payload, options = {}) {
  const articles = payload?.articles;
  if (!Array.isArray(articles)) return [];

  const seen = new Set();
  const mapped = [];
  for (const raw of articles) {
    const article = mapGNewsArticle(raw, options);
    if (!article) continue;
    if (seen.has(article.id)) continue;
    seen.add(article.id);
    mapped.push(article);
  }
  return mapped;
}
