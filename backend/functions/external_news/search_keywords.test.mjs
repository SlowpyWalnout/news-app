// Asserts the vendored copy (search_keywords.mjs, deployed with functions/)
// stays byte-for-byte in sync with backend/scripts/search-keywords.mjs
// against the same golden vectors both the Dart client and the backfill
// script already use — a divergence here fails a test instead of silently
// producing tokens the Feed's `array-contains` query never matches.

import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { buildSearchKeywords, searchTokensFor } from './search_keywords.mjs';

const fixtures = JSON.parse(
  readFileSync(new URL('../../scripts/tokenizer-fixtures.json', import.meta.url)),
);

describe('searchTokensFor (vendored)', () => {
  it('folds accents to plain ASCII', () => {
    expect(searchTokensFor('Guía de Ñandú')).toEqual(['guia', 'nandu']);
  });

  it('drops es/en stopwords', () => {
    expect(searchTokensFor('de la the of Flutter')).toEqual(['flutter']);
  });
});

describe('buildSearchKeywords (vendored) — shared golden vectors', () => {
  it('has at least one fixture', () => {
    expect(fixtures.length).toBeGreaterThan(0);
  });

  for (const vector of fixtures) {
    it(`matches the Dart tokenizer: ${vector.name}`, () => {
      const result = buildSearchKeywords({
        title: vector.title,
        authorName: vector.authorName,
        categoryName: vector.category,
      });
      expect(result).toEqual(vector.expected);
    });
  }
});
