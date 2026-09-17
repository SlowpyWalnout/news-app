import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { buildSearchKeywords, searchTokensFor } from './search-keywords.mjs';

const fixtures = JSON.parse(readFileSync(new URL('./tokenizer-fixtures.json', import.meta.url)));

describe('searchTokensFor', () => {
  it('folds accents to plain ASCII', () => {
    expect(searchTokensFor('Guía de Ñandú')).toEqual(['guia', 'nandu']);
  });

  it('drops es/en stopwords', () => {
    expect(searchTokensFor('de la the of Flutter')).toEqual(['flutter']);
  });

  it('keeps 2-letter tokens that are not stopwords', () => {
    expect(searchTokensFor('IA JS UX')).toEqual(['ia', 'js', 'ux']);
  });
});

describe('buildSearchKeywords — shared golden vectors', () => {
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
