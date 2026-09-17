#!/usr/bin/env node
// One-off backfill: recomputes searchKeywords on every article using the
// same rules as AuthoredArticleFirestoreDataSource._upsert (frontend), so
// articles written before Fase 6b become findable by search.
//
// Uses the Admin SDK on purpose — it bypasses firestore.rules, so it never
// has to satisfy `updatedAt == request.time` (a client-side backfill would
// be forced to bump updatedAt on every article, reordering everyone's "Mis
// artículos" — see ROADMAP.md, Fase 6b).
//
// Usage:
//   node backfill-search-keywords.mjs --project=news-app-f979a            # dry run (default)
//   node backfill-search-keywords.mjs --project=news-app-f979a --apply    # writes
//
// Against the emulator first:
//   FIRESTORE_EMULATOR_HOST=localhost:8080 node backfill-search-keywords.mjs --project=news-app-f979a --apply
//
// Deploy the two new composite indexes (firestore.indexes.json) BEFORE
// running this with --apply against prod, so search works the moment the
// tokens land.

import { initializeApp, applicationDefault, cert } from 'firebase-admin/app';
import { getFirestore, FieldPath } from 'firebase-admin/firestore';
import { buildSearchKeywords } from './search-keywords.mjs';

const PAGE_SIZE = 300;
const BATCH_LIMIT = 400; // under Firestore's 500 ops/batch limit

function parseArgs(argv) {
  const args = { apply: false, project: undefined };
  for (const arg of argv) {
    if (arg === '--apply') args.apply = true;
    else if (arg.startsWith('--project=')) args.project = arg.slice('--project='.length);
  }
  return args;
}

function sameKeywords(a, b) {
  const arrA = Array.isArray(a) ? a : [];
  return JSON.stringify(arrA) === JSON.stringify(b);
}

async function main() {
  const { apply, project } = parseArgs(process.argv.slice(2));
  const credential = process.env.GOOGLE_APPLICATION_CREDENTIALS
    ? applicationDefault()
    : (process.env.FIRESTORE_EMULATOR_HOST ? undefined : applicationDefault());

  initializeApp(credential ? { credential, projectId: project } : { projectId: project });
  const db = getFirestore();

  let scanned = 0;
  let wouldChange = 0;
  let changed = 0;
  const sampleDiffs = [];

  let lastId = null;
  let batch = db.batch();
  let opsInBatch = 0;

  const flush = async () => {
    if (opsInBatch === 0) return;
    if (apply) await batch.commit();
    batch = db.batch();
    opsInBatch = 0;
  };

  for (;;) {
    let query = db.collection('articles').orderBy(FieldPath.documentId()).limit(PAGE_SIZE);
    if (lastId) query = query.startAfter(lastId);
    const snapshot = await query.get();
    if (snapshot.empty) break;

    for (const doc of snapshot.docs) {
      scanned++;
      const data = doc.data();
      const next = buildSearchKeywords({
        title: data.title ?? '',
        authorName: data.authorName ?? '',
        categoryName: data.category ?? '',
      });

      if (!sameKeywords(data.searchKeywords, next)) {
        wouldChange++;
        if (sampleDiffs.length < 10) {
          sampleDiffs.push({ id: doc.id, before: data.searchKeywords ?? [], after: next });
        }
        if (apply) {
          batch.update(doc.ref, { searchKeywords: next });
          opsInBatch++;
          changed++;
          if (opsInBatch >= BATCH_LIMIT) await flush();
        }
      }
    }

    lastId = snapshot.docs[snapshot.docs.length - 1].id;
    if (snapshot.docs.length < PAGE_SIZE) break;
  }

  await flush();

  console.log(`Escaneados: ${scanned}`);
  console.log(`${apply ? 'Cambiados' : 'Cambiarían'}: ${apply ? changed : wouldChange}`);
  console.log(`Sin cambios: ${scanned - wouldChange}`);
  if (sampleDiffs.length > 0) {
    console.log(`\nPrimeros ${sampleDiffs.length} diffs:`);
    for (const d of sampleDiffs) {
      console.log(`  ${d.id}: ${JSON.stringify(d.before)} -> ${JSON.stringify(d.after)}`);
    }
  }
  if (!apply) {
    console.log('\nDry run (por defecto). Corré con --apply para escribir.');
  }
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
