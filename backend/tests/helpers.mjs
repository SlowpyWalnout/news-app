import { readFileSync } from 'node:fs';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

export function loadTestEnv() {
  return initializeTestEnvironment({
    projectId: 'news-app-f979a',
    firestore: {
      rules: readFileSync('../firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
    storage: {
      rules: readFileSync('../storage.rules', 'utf8'),
      host: '127.0.0.1',
      port: 9199,
    },
  });
}

export function validArticle(overrides = {}) {
  return {
    authorId: 'author-1',
    authorName: 'José',
    authorPhotoURL: null,
    title: 'Título de prueba',
    body: 'Cuerpo de prueba con contenido suficiente.',
    status: 'published',
    category: 'technology',
    thumbnailURL: 'https://example.com/thumb.jpg',
    thumbnailPath: 'media/articles/author-1/article-1/thumb.jpg',
    searchKeywords: ['titulo', 'prueba'],
    ...overrides,
  };
}
