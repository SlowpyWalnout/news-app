import { describe, expect, it } from 'vitest';
import { mapGuardianArticle, mapGuardianResponse, EXPIRY_MS } from './guardian_mapper.mjs';

function rawArticle(overrides = {}) {
  return {
    webUrl: 'https://www.theguardian.com/technology/2026/jan/01/some-article',
    webTitle: 'Some article title',
    webPublicationDate: '2026-01-01T10:00:00Z',
    sectionId: 'technology',
    fields: {
      bodyText: 'Full body text of the article, quite long in real life.',
      trailText: 'Short trail.',
      thumbnail: 'https://media.guardian.com/thumb.jpg',
    },
    ...overrides,
  };
}

describe('mapGuardianArticle', () => {
  it('mapea un artículo válido con cuerpo completo', () => {
    const article = mapGuardianArticle(rawArticle());
    expect(article).toMatchObject({
      title: 'Some article title',
      body: 'Full body text of the article, quite long in real life.',
      source: 'guardian',
      sourceName: 'The Guardian',
      authorId: 'external:guardian',
      hasFullBody: true,
      lang: 'en',
      category: 'technology',
      status: 'published',
    });
    expect(article.thumbnailURL).toBe('https://media.guardian.com/thumb.jpg');
    expect(article.expiresAtMillis - article.fetchedAtMillis).toBe(EXPIRY_MS);
  });

  it('descarta el artículo si falta url', () => {
    expect(mapGuardianArticle(rawArticle({ webUrl: undefined }))).toBeNull();
  });

  it('descarta el artículo si falta título', () => {
    expect(mapGuardianArticle(rawArticle({ webTitle: '' }))).toBeNull();
  });

  it('descarta el artículo si la fecha de publicación es inválida', () => {
    expect(mapGuardianArticle(rawArticle({ webPublicationDate: 'not-a-date' }))).toBeNull();
  });

  it('sectionId desconocido cae en la categoría general', () => {
    const article = mapGuardianArticle(rawArticle({ sectionId: 'crossword' }));
    expect(article.category).toBe('general');
  });

  it('sin bodyText usa trailText y hasFullBody queda en false', () => {
    const article = mapGuardianArticle(rawArticle({ fields: { trailText: 'Solo el resumen.' } }));
    expect(article.hasFullBody).toBe(false);
    expect(article.body).toBe('Solo el resumen.');
    expect(article.thumbnailURL).toBeNull();
  });

  it('sin fields en absoluto no revienta y usa defaults, nunca undefined', () => {
    const article = mapGuardianArticle(rawArticle({ fields: undefined }));
    expect(article.body).toBe('');
    expect(article.thumbnailURL).toBeNull();
    expect(article.hasFullBody).toBe(false);
    expect(Object.values(article)).not.toContain(undefined);
  });

  it('genera searchKeywords con al menos el título tokenizado, máx 30', () => {
    const article = mapGuardianArticle(rawArticle());
    expect(article.searchKeywords.length).toBeGreaterThan(0);
    expect(article.searchKeywords.length).toBeLessThanOrEqual(30);
    expect(article.searchKeywords).toContain('article');
  });
});

describe('mapGuardianResponse', () => {
  it('filtra inválidos y deduplica por id', () => {
    const payload = {
      response: {
        results: [rawArticle(), rawArticle(), rawArticle({ webUrl: undefined })],
      },
    };
    const mapped = mapGuardianResponse(payload);
    expect(mapped).toHaveLength(1);
  });

  it('devuelve [] si el payload no tiene forma de respuesta de Guardian', () => {
    expect(mapGuardianResponse(null)).toEqual([]);
    expect(mapGuardianResponse({})).toEqual([]);
    expect(mapGuardianResponse('oops')).toEqual([]);
  });
});
