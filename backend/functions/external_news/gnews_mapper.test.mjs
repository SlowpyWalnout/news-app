import { describe, expect, it } from 'vitest';
import { mapGNewsArticle, mapGNewsResponse, EXPIRY_MS } from './gnews_mapper.mjs';

function rawArticle(overrides = {}) {
  return {
    title: 'Un titular de prueba',
    description: 'Resumen breve de la noticia.',
    url: 'https://example-news.com/nota-1',
    image: 'https://example-news.com/img.jpg',
    publishedAt: '2026-01-01T10:00:00Z',
    source: { name: 'Example News' },
    ...overrides,
  };
}

describe('mapGNewsArticle', () => {
  it('mapea un artículo válido, siempre con hasFullBody en false', () => {
    const article = mapGNewsArticle(rawArticle(), { lang: 'es', topic: 'technology' });
    expect(article).toMatchObject({
      title: 'Un titular de prueba',
      body: 'Resumen breve de la noticia.',
      source: 'gnews',
      sourceName: 'Example News',
      authorId: 'external:gnews',
      hasFullBody: false,
      lang: 'es',
      category: 'technology',
      status: 'published',
    });
    expect(article.expiresAtMillis - article.fetchedAtMillis).toBe(EXPIRY_MS);
  });

  it('propaga el lang de la llamada, no del artículo', () => {
    const article = mapGNewsArticle(rawArticle(), { lang: 'en' });
    expect(article.lang).toBe('en');
  });

  it('descarta el artículo si falta url', () => {
    expect(mapGNewsArticle(rawArticle({ url: undefined }), { lang: 'es' })).toBeNull();
  });

  it('descarta el artículo si falta título', () => {
    expect(mapGNewsArticle(rawArticle({ title: '' }), { lang: 'es' })).toBeNull();
  });

  it('descarta el artículo si la fecha de publicación es inválida', () => {
    expect(mapGNewsArticle(rawArticle({ publishedAt: 'not-a-date' }), { lang: 'es' })).toBeNull();
  });

  it('topic desconocido cae en general', () => {
    const article = mapGNewsArticle(rawArticle(), { lang: 'es', topic: 'crossword' });
    expect(article.category).toBe('general');
  });

  it('sin description/image/source usa defaults, nunca undefined', () => {
    const article = mapGNewsArticle(rawArticle({ description: undefined, image: undefined, source: undefined }), { lang: 'es' });
    expect(article.body).toBe('');
    expect(article.thumbnailURL).toBeNull();
    expect(article.sourceName).toBe('GNews');
    expect(Object.values(article)).not.toContain(undefined);
  });

  it('mismo título con URLs distintas produce ids distintos (dedupe es por URL)', () => {
    const a = mapGNewsArticle(rawArticle({ url: 'https://example-news.com/nota-1' }), { lang: 'es' });
    const b = mapGNewsArticle(rawArticle({ url: 'https://example-news.com/nota-2' }), { lang: 'es' });
    expect(a.id).not.toBe(b.id);
  });
});

describe('mapGNewsResponse', () => {
  it('filtra inválidos y deduplica por id', () => {
    const payload = { articles: [rawArticle(), rawArticle(), rawArticle({ url: undefined })] };
    const mapped = mapGNewsResponse(payload, { lang: 'es' });
    expect(mapped).toHaveLength(1);
  });

  it('devuelve [] si el payload es null, string, o sin campo articles', () => {
    expect(mapGNewsResponse(null)).toEqual([]);
    expect(mapGNewsResponse('oops')).toEqual([]);
    expect(mapGNewsResponse({})).toEqual([]);
  });
});
