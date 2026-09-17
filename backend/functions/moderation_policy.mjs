// Lógica pura, sin Admin SDK ni Firestore, para poder testearla sin
// emulador. Ver "Moderación: umbral de suspensión" en
// backend/docs/DB_SCHEMA.md para la justificación completa.

export const REPORT_THRESHOLD_DEFAULT = 2;
export const REPORT_THRESHOLD_APPROVED = 10;

const MODERATION_FIELDS = [
  'reportCount',
  'moderationState',
  'suspendedAt',
  'approvedAt',
  'approvedBy',
  'suspensionCount',
];

// `status` no es un campo de moderación en sí (el autor también lo cambia al
// publicar/guardar borrador), pero tanto el trigger de suspensión como la
// rama de staff lo tocan junto con los campos de arriba. Sin incluirlo aquí,
// `isModerationOnlyChange` no reconocería su propia escritura y
// `onArticleContentEdited` volvería a dispararse sobre ella.
const RECURSION_GUARD_FIELDS = [...MODERATION_FIELDS, 'status'];

const CONTENT_FIELDS = ['title', 'body', 'category', 'thumbnailURL'];

/**
 * Umbral de reportes necesario para (re)suspender un artículo.
 *
 * Sin aprobación de staff, o si el artículo se editó después de la última
 * aprobación (`updatedAt` adelantó a `approvedAt`), el umbral es el bajo.
 * Una aprobación vale solo para la versión revisada en ese momento — no
 * hace falta contar ediciones por separado.
 */
export function thresholdFor({ approvedAt, updatedAt }) {
  if (approvedAt && updatedAt && toMillis(approvedAt) >= toMillis(updatedAt)) {
    return REPORT_THRESHOLD_APPROVED;
  }
  return REPORT_THRESHOLD_DEFAULT;
}

function toMillis(value) {
  if (value == null) return null;
  if (typeof value.toMillis === 'function') return value.toMillis();
  if (value instanceof Date) return value.getTime();
  return Number(value);
}

/** True si el diff de un update de `articles/{id}` toca contenido real. */
export function changedContent(beforeData, afterData) {
  return CONTENT_FIELDS.some((field) => !sameValue(beforeData[field], afterData[field]));
}

/** True si el diff de un update de `articles/{id}` es solo campos de moderación. */
export function isModerationOnlyChange(beforeData, afterData) {
  const keys = new Set([...Object.keys(beforeData), ...Object.keys(afterData)]);
  for (const key of keys) {
    if (RECURSION_GUARD_FIELDS.includes(key)) continue;
    if (!sameValue(beforeData[key], afterData[key])) return false;
  }
  return true;
}

function sameValue(a, b) {
  if (a === b) return true;
  const aMillis = toMillis(a);
  const bMillis = toMillis(b);
  if (aMillis != null && bMillis != null) return aMillis === bMillis;
  return JSON.stringify(a ?? null) === JSON.stringify(b ?? null);
}
