#!/usr/bin/env node
// Semilla reproducible para desarrollo local y demo — no para los tests de
// rules (esos crean sus propios datos y unos ids preexistentes voltearían
// assertFails/assertSucceeds, ver ROADMAP.md / plan de Fase 8).
//
// Uso: levantar el emulador y correr esto en una segunda terminal, luego
// Ctrl-C en la primera (--export-on-exit hace el export) o, sin parar nada:
//
//   cd backend && firebase emulators:start --project=news-app-f979a \
//     --only auth,firestore,storage --export-on-exit=./seed
//   # en otra terminal:
//   cd backend/scripts && \
//     FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
//     FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 \
//     FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9199 \
//     npm run seed
//
// Se niega a arrancar si falta cualquiera de esas tres variables — así no
// puede tocar el proyecto real ni por error de entorno.

import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { buildSearchKeywords } from './search-keywords.mjs';

const PROJECT_ID = 'news-app-f979a';
const STORAGE_BUCKET = 'news-app-f979a.firebasestorage.app';

const REQUIRED_EMULATOR_VARS = [
  'FIREBASE_AUTH_EMULATOR_HOST',
  'FIRESTORE_EMULATOR_HOST',
  'FIREBASE_STORAGE_EMULATOR_HOST',
];

function assertRunningAgainstEmulators() {
  const missing = REQUIRED_EMULATOR_VARS.filter((name) => !process.env[name]);
  if (missing.length > 0) {
    console.error(
      `Faltan variables de emulador: ${missing.join(', ')}.\n` +
        'Este script se niega a arrancar sin las tres — nunca debe poder tocar el proyecto real.',
    );
    process.exitCode = 1;
    throw new Error('missing emulator env vars');
  }
}

const AUTHOR = { uid: 'seed-author', email: 'author@demo.test', password: 'demodemo', displayName: 'Autora Demo' };
const STAFF = { uid: 'seed-staff', email: 'staff@demo.test', password: 'demodemo', displayName: 'Staff Demo' };

async function ensureUser(auth, user) {
  try {
    await auth.getUser(user.uid);
  } catch {
    await auth.createUser({
      uid: user.uid,
      email: user.email,
      password: user.password,
      displayName: user.displayName,
      emailVerified: true,
    });
  }
}

function article({ id, authorId, authorName, title, body, category, status, publishedAt, moderation }) {
  const now = Timestamp.now();
  return {
    id,
    data: {
      authorId,
      authorName,
      title,
      body,
      status,
      category,
      thumbnailURL: null,
      thumbnailPath: null,
      searchKeywords: buildSearchKeywords({ title, authorName, categoryName: category }),
      createdAt: now,
      updatedAt: now,
      publishedAt: publishedAt ? Timestamp.fromDate(publishedAt) : null,
      reportCount: moderation?.reportCount ?? 0,
      moderationState: moderation?.state ?? null,
      suspendedAt: moderation?.state === 'suspended' ? now : null,
    },
  };
}

const ARTICLES = [
  article({
    id: 'seed-article-1',
    authorId: AUTHOR.uid,
    authorName: AUTHOR.displayName,
    title: 'Guía rápida de Flutter',
    body: 'Un repaso de lo esencial para empezar con Flutter.',
    category: 'technology',
    status: 'published',
    publishedAt: new Date('2026-01-05'),
  }),
  article({
    id: 'seed-article-2',
    authorId: AUTHOR.uid,
    authorName: AUTHOR.displayName,
    title: 'Resultados de la jornada deportiva',
    body: 'Resumen de los partidos más destacados de la semana.',
    category: 'sports',
    status: 'published',
    publishedAt: new Date('2026-01-06'),
  }),
  article({
    id: 'seed-article-3',
    authorId: AUTHOR.uid,
    authorName: AUTHOR.displayName,
    title: 'Avances en salud pública',
    body: 'Novedades sobre políticas de salud en la región.',
    category: 'health',
    status: 'published',
    publishedAt: new Date('2026-01-07'),
  }),
  article({
    id: 'seed-article-4',
    authorId: AUTHOR.uid,
    authorName: AUTHOR.displayName,
    title: 'Panorama económico del mes',
    body: 'Análisis de los principales indicadores económicos.',
    category: 'business',
    status: 'published',
    publishedAt: new Date('2026-01-08'),
  }),
  article({
    id: 'seed-article-draft',
    authorId: AUTHOR.uid,
    authorName: AUTHOR.displayName,
    title: 'Borrador sin publicar',
    body: 'Todavía en preparación.',
    category: 'general',
    status: 'draft',
    publishedAt: null,
  }),
  article({
    id: 'seed-article-suspended',
    authorId: AUTHOR.uid,
    authorName: AUTHOR.displayName,
    title: 'Artículo reportado varias veces',
    body: 'Contenido señalado por la comunidad, en revisión de staff.',
    category: 'other',
    status: 'published',
    publishedAt: new Date('2026-01-04'),
    moderation: { state: 'suspended', reportCount: 3 },
  }),
];

async function main() {
  assertRunningAgainstEmulators();

  initializeApp({ projectId: PROJECT_ID, storageBucket: STORAGE_BUCKET });
  const auth = getAuth();
  const db = getFirestore();
  const storage = getStorage();

  await ensureUser(auth, AUTHOR);
  await ensureUser(auth, STAFF);

  const batch = db.batch();
  batch.set(db.collection('users').doc(AUTHOR.uid), {
    displayName: AUTHOR.displayName,
    photoURL: null,
    createdAt: Timestamp.now(),
  });
  batch.set(db.collection('users').doc(STAFF.uid), {
    displayName: STAFF.displayName,
    photoURL: null,
    createdAt: Timestamp.now(),
    role: 'staff',
  });
  for (const { id, data } of ARTICLES) {
    batch.set(db.collection('articles').doc(id), data);
  }
  batch.set(db.collection('articles').doc('seed-article-suspended').collection('reports').doc(STAFF.uid), {
    reason: 'spam',
    note: 'Contenido de ejemplo para la cola de revisión.',
    createdAt: Timestamp.now(),
  });
  await batch.commit();

  const thumbnailPath = `media/articles/${AUTHOR.uid}/seed-article-1/seed-thumbnail.jpg`;
  await storage
    .bucket()
    .file(thumbnailPath)
    .save(Buffer.from('semilla de miniatura de ejemplo, no es una imagen real'), {
      contentType: 'image/jpeg',
    });
  await db.collection('articles').doc('seed-article-1').update({
    thumbnailURL: `https://storage.example/${thumbnailPath}`,
    thumbnailPath,
  });

  console.log('Semilla cargada: 2 usuarios, 6 artículos, 1 reporte, 1 objeto de Storage.');
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
