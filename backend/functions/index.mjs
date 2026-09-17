import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { onDocumentCreated, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { logger } from 'firebase-functions';
import { thresholdFor, changedContent, isModerationOnlyChange } from './moderation_policy.mjs';

initializeApp();
const db = getFirestore();

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
