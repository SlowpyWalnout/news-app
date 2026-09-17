import { describe, expect, it } from 'vitest';
import {
  thresholdFor,
  changedContent,
  isModerationOnlyChange,
  REPORT_THRESHOLD_DEFAULT,
  REPORT_THRESHOLD_APPROVED,
} from './moderation_policy.mjs';

function ts(millis) {
  return { toMillis: () => millis };
}

describe('thresholdFor', () => {
  it('es el umbral bajo cuando nunca fue aprobado', () => {
    expect(thresholdFor({ approvedAt: null, updatedAt: ts(100) })).toBe(REPORT_THRESHOLD_DEFAULT);
  });

  it('es el umbral alto cuando la aprobación es posterior a la última edición', () => {
    expect(thresholdFor({ approvedAt: ts(200), updatedAt: ts(100) })).toBe(REPORT_THRESHOLD_APPROVED);
  });

  it('vuelve al umbral bajo si se editó después de la aprobación', () => {
    expect(thresholdFor({ approvedAt: ts(100), updatedAt: ts(200) })).toBe(REPORT_THRESHOLD_DEFAULT);
  });

  it('trata approvedAt == updatedAt como todavía vigente', () => {
    expect(thresholdFor({ approvedAt: ts(100), updatedAt: ts(100) })).toBe(REPORT_THRESHOLD_APPROVED);
  });
});

describe('changedContent', () => {
  it('detecta cambio de título', () => {
    expect(changedContent({ title: 'A', body: 'x', category: 'c', thumbnailURL: null }, { title: 'B', body: 'x', category: 'c', thumbnailURL: null })).toBe(true);
  });

  it('no marca cambio si solo cambian campos de moderación', () => {
    expect(
      changedContent(
        { title: 'A', body: 'x', category: 'c', thumbnailURL: null },
        { title: 'A', body: 'x', category: 'c', thumbnailURL: null, reportCount: 1 },
      ),
    ).toBe(false);
  });
});

describe('isModerationOnlyChange', () => {
  it('es true cuando el trigger suspende el artículo', () => {
    const before = { title: 'A', status: 'published' };
    const after = { title: 'A', status: 'draft', moderationState: 'suspended', reportCount: 2 };
    expect(isModerationOnlyChange(before, after)).toBe(true);
  });

  it('es false cuando además cambia contenido', () => {
    const before = { title: 'A', status: 'published' };
    const after = { title: 'B', status: 'draft', moderationState: 'suspended', reportCount: 2 };
    expect(isModerationOnlyChange(before, after)).toBe(false);
  });
});
