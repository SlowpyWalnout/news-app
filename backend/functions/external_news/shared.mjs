// Utilidades puras compartidas por los mapeadores de noticias externas
// (Guardian, GNews). Sin Admin SDK, testeables sin emulador — mismo patrón
// que moderation_policy.mjs.

import { createHash } from 'node:crypto';

const TRACKING_PARAMS_PREFIXES = ['utm_'];
const TRACKING_PARAMS_EXACT = new Set(['fbclid', 'gclid', 'ref', 'ref_src']);

/**
 * Normaliza una URL para que la misma noticia, vista con o sin parámetros de
 * tracking, produzca el mismo id de documento. Host en minúsculas, sin
 * parámetros de tracking, sin fragment, sin slash final.
 */
export function canonicalizeUrl(rawUrl) {
  const url = new URL(rawUrl);
  url.hostname = url.hostname.toLowerCase();
  url.hash = '';

  const keptParams = [...url.searchParams.entries()].filter(
    ([key]) => !TRACKING_PARAMS_EXACT.has(key.toLowerCase()) && !TRACKING_PARAMS_PREFIXES.some((prefix) => key.toLowerCase().startsWith(prefix)),
  );
  url.search = '';
  for (const [key, value] of keptParams) {
    url.searchParams.append(key, value);
  }

  let normalized = url.toString();
  if (normalized.endsWith('/') && url.pathname !== '/') {
    normalized = normalized.slice(0, -1);
  }
  return normalized;
}

/**
 * Doc id determinista para `articles/{id}` a partir de la URL canónica. Hace
 * que el cron sea idempotente entre corridas (`set(..., {merge:true})` sobre
 * el mismo id nunca duplica) sin necesitar una tabla de "ya visto".
 */
export function externalArticleIdFor(rawUrl) {
  const canonical = canonicalizeUrl(rawUrl);
  return createHash('sha256').update(canonical).digest('hex').slice(0, 32);
}
