import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';
import { onDocumentCreated, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { defineSecret } from 'firebase-functions/params';
import { logger } from 'firebase-functions';
import { thresholdFor, changedContent, isModerationOnlyChange } from './moderation_policy.mjs';
import { mapGuardianResponse } from './external_news/guardian_mapper.mjs';
import { mapGNewsResponse } from './external_news/gnews_mapper.mjs';

initializeApp();
const db = getFirestore();

const guardianApiKey = defineSecret('GUARDIAN_API_KEY');
const gnewsApiKey = defineSecret('GNEWS_API_KEY');

const EXTERNAL_NEWS_PURGE_BATCH_LIMIT = 200;
const FETCH_TIMEOUT_MS = 15000;

// El cliente solo puede crear el reporte (ver firestore.rules); contar y
// suspender es autoridad de servidor para que nadie pueda escribir
// reportCount/moderationState directamente.
export const onReportCreated = onDocumentCreated(
  'articles/{articleId}/reports/{reporterUid}',
  async (event) => {
    const { articleId } = event.params;
    const articleRef = db.doc(`articles/${articleId}`);

    await db.runTransaction(async (tx) => {
      const snapshot = await tx.get(articleRef);
      if (!snapshot.exists) return;
      const article = snapshot.data();

      const reportCount = (article.reportCount ?? 0) + 1;
      const update = { reportCount };

      const threshold = thresholdFor(article);
      if (article.status === 'published' && reportCount >= threshold) {
        update.status = 'draft';
        update.moderationState = 'suspended';
        update.suspendedAt = FieldValue.serverTimestamp();
        update.suspensionCount = (article.suspensionCount ?? 0) + 1;
        logger.info('article suspended', { articleId, reportCount, threshold });
      }

      tx.update(articleRef, update);
    });
  },
);

// La edición del autor es la apelación implícita: si cambió contenido real,
// el artículo vuelve a arrancar sin el historial de reportes de la versión
// anterior. suspensionCount no se toca a propósito — es memoria permanente
// de reincidencia (ver docs/DB_SCHEMA.md).
export const onArticleContentEdited = onDocumentUpdated('articles/{articleId}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();

  // Los artículos de noticias externas se reescriben en cada corrida del
  // cron (`syncGuardianNews`/`syncGnewsHeadlines`); sin esta guarda, cada
  // refresco dispararía este trigger decenas de veces por hora sin ningún
  // reporte real de por medio que resetear.
  if (after.source) return;
  if (isModerationOnlyChange(before, after)) return;
  if (!changedContent(before, after)) return;
  if (!after.moderationState && !(after.reportCount > 0)) return;

  const articleRef = event.data.after.ref;
  const reportsSnapshot = await articleRef.collection('reports').get();

  const batch = db.batch();
  batch.update(articleRef, {
    reportCount: 0,
    moderationState: FieldValue.delete(),
    suspendedAt: FieldValue.delete(),
  });
  for (const doc of reportsSnapshot.docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();

  logger.info('article moderation reset after content edit', {
    articleId: event.params.articleId,
    clearedReports: reportsSnapshot.size,
  });
});

async function fetchJson(url) {
  const res = await fetch(url, { signal: AbortSignal.timeout(FETCH_TIMEOUT_MS) });
  if (!res.ok) throw new Error(`request failed with status ${res.status}`);
  return res.json();
}

// Los mapeadores puros devuelven millis (no dependen del Admin SDK); aquí se
// convierten a Timestamp y se escriben con merge para no pisar los campos de
// moderación que un artículo externo pudiera acumular más adelante.
async function upsertExternalArticles(articles) {
  if (articles.length === 0) return;

  const batch = db.batch();
  for (const { id, publishedAtMillis, fetchedAtMillis, expiresAtMillis, ...rest } of articles) {
    batch.set(
      db.collection('articles').doc(id),
      {
        ...rest,
        // AuthoredArticleModel.fromFirestore requires both as non-null
        // Timestamps (they're normally server-fixed at author create time).
        // External articles have no such moment, so both track the latest
        // fetch — harmless here since the Feed sorts by publishedAt, never
        // by these two, for any article.
        createdAt: Timestamp.fromMillis(fetchedAtMillis),
        updatedAt: Timestamp.fromMillis(fetchedAtMillis),
        publishedAt: Timestamp.fromMillis(publishedAtMillis),
        fetchedAt: Timestamp.fromMillis(fetchedAtMillis),
        expiresAt: Timestamp.fromMillis(expiresAtMillis),
      },
      { merge: true },
    );
  }
  await batch.commit();
}

// Fuera de cualquier early-return de fetch: la retención de 24h de Guardian
// no puede depender de que la red funcione en esa corrida.
async function purgeExpiredExternalArticles() {
  try {
    const snapshot = await db
      .collection('articles')
      .where('expiresAt', '<', Timestamp.now())
      .limit(EXTERNAL_NEWS_PURGE_BATCH_LIMIT)
      .get();
    if (snapshot.empty) return;

    const batch = db.batch();
    for (const doc of snapshot.docs) batch.delete(doc.ref);
    await batch.commit();
    logger.info('external news purged', { count: snapshot.size });
  } catch (error) {
    logger.error('external news purge failed', { error: String(error) });
  }
}

// Cadencia más alta (30 min) porque también es quien purga — mantiene el
// cumplimiento de las 24h de Guardian aunque GNews vaya por su cuenta.
// retryCount: 0 a propósito: un reintento automático de Cloud Scheduler no
// debe quemar cuota de ninguna de las dos APIs.
export const syncGuardianNews = onSchedule(
  {
    schedule: 'every 30 minutes',
    region: 'us-central1',
    timeZone: 'UTC',
    secrets: [guardianApiKey],
    timeoutSeconds: 180,
    memory: '256MiB',
    retryCount: 0,
  },
  async () => {
    try {
      const url =
        'https://content.guardianapis.com/search' +
        '?show-fields=bodyText,thumbnail,trailText&page-size=20&order-by=newest' +
        `&api-key=${guardianApiKey.value()}`;
      const articles = mapGuardianResponse(await fetchJson(url));
      await upsertExternalArticles(articles);
      logger.info('guardian sync ok', { count: articles.length });
    } catch (error) {
      // Incluye 429 (cuota agotada): se loguea y no se toca Firestore en
      // absoluto para esta corrida, en vez de escribir a medias.
      logger.warn('guardian sync failed', { error: String(error) });
    }

    await purgeExpiredExternalArticles();
  },
);

// GNews free son 100 req/día; dos llamadas por corrida (es + en) a 1h dejan
// 48/día usadas y 52 de margen para reintentos o pruebas manuales.
export const syncGnewsHeadlines = onSchedule(
  {
    schedule: 'every 1 hours',
    region: 'us-central1',
    timeZone: 'UTC',
    secrets: [gnewsApiKey],
    timeoutSeconds: 180,
    memory: '256MiB',
    retryCount: 0,
  },
  async () => {
    for (const lang of ['es', 'en']) {
      try {
        const url = `https://gnews.io/api/v4/top-headlines?lang=${lang}&max=10&apikey=${gnewsApiKey.value()}`;
        const articles = mapGNewsResponse(await fetchJson(url), { lang });
        await upsertExternalArticles(articles);
        logger.info('gnews sync ok', { lang, count: articles.length });
      } catch (error) {
        // Un idioma fallando (incluida cuota agotada) no bloquea el otro.
        logger.warn('gnews sync failed', { lang, error: String(error) });
      }
    }
  },
);
