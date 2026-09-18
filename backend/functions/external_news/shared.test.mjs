import { describe, expect, it } from 'vitest';
import { canonicalizeUrl, externalArticleIdFor } from './shared.mjs';

describe('canonicalizeUrl', () => {
  it('quita parámetros de tracking', () => {
    expect(canonicalizeUrl('https://example.com/a?utm_source=x&utm_medium=y')).toBe('https://example.com/a');
  });

  it('quita fbclid/gclid/ref', () => {
    expect(canonicalizeUrl('https://example.com/a?fbclid=123&gclid=456&ref=twitter')).toBe('https://example.com/a');
  });

  it('conserva parámetros de contenido real', () => {
    expect(canonicalizeUrl('https://example.com/a?id=42&utm_source=x')).toBe('https://example.com/a?id=42');
  });

  it('quita el fragment', () => {
    expect(canonicalizeUrl('https://example.com/a#section-2')).toBe('https://example.com/a');
  });

  it('normaliza el host a minúsculas', () => {
    expect(canonicalizeUrl('https://Example.COM/a')).toBe('https://example.com/a');
  });

  it('quita el slash final salvo en la raíz', () => {
    expect(canonicalizeUrl('https://example.com/a/')).toBe('https://example.com/a');
    expect(canonicalizeUrl('https://example.com/')).toBe('https://example.com/');
  });
});

describe('externalArticleIdFor', () => {
  it('produce el mismo id para la misma URL con distinto tracking', () => {
    const a = externalArticleIdFor('https://example.com/noticia?utm_source=twitter');
    const b = externalArticleIdFor('https://example.com/noticia?utm_source=facebook');
    expect(a).toBe(b);
  });

  it('produce ids distintos para URLs distintas', () => {
    const a = externalArticleIdFor('https://example.com/noticia-1');
    const b = externalArticleIdFor('https://example.com/noticia-2');
    expect(a).not.toBe(b);
  });

  it('es estable entre llamadas', () => {
    const url = 'https://example.com/noticia?id=42';
    expect(externalArticleIdFor(url)).toBe(externalArticleIdFor(url));
  });

  it('produce un hex de 32 caracteres', () => {
    expect(externalArticleIdFor('https://example.com/noticia')).toMatch(/^[0-9a-f]{32}$/);
  });
});
