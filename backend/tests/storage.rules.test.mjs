import { afterAll, beforeAll, describe, it } from 'vitest';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { ref, uploadBytes, getBytes, deleteObject } from 'firebase/storage';
import { loadTestEnv } from './helpers.mjs';

let testEnv;

const SMALL_IMAGE = new Uint8Array(1024).fill(1);
const BIG_FILE = new Uint8Array(6 * 1024 * 1024).fill(1); // > 5 MB

beforeAll(async () => {
  testEnv = await loadTestEnv();
});

afterAll(async () => {
  await testEnv.cleanup();
});

describe('storage: media/articles/{uid}/{articleId}/{imageId}', () => {
  it('el dueño puede subir una imagen válida', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    const path = 'media/articles/author-1/article-1/thumb.jpg';
    await assertSucceeds(
      uploadBytes(ref(owner.storage(), path), SMALL_IMAGE, { contentType: 'image/jpeg' }),
    );
  });

  it('otro usuario no puede subir a la carpeta de otro uid', async () => {
    const attacker = testEnv.authenticatedContext('attacker');
    const path = 'media/articles/author-1/article-1/thumb.jpg';
    await assertFails(
      uploadBytes(ref(attacker.storage(), path), SMALL_IMAGE, { contentType: 'image/jpeg' }),
    );
  });

  it('rechaza archivos mayores a 5 MB', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    const path = 'media/articles/author-1/article-1/grande.jpg';
    await assertFails(
      uploadBytes(ref(owner.storage(), path), BIG_FILE, { contentType: 'image/jpeg' }),
    );
  });

  it('rechaza subir un PDF disfrazado de imagen', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    const path = 'media/articles/author-1/article-1/doc.jpg';
    await assertFails(
      uploadBytes(ref(owner.storage(), path), SMALL_IMAGE, { contentType: 'application/pdf' }),
    );
  });

  it('rechaza subir sin estar autenticado', async () => {
    const anon = testEnv.unauthenticatedContext();
    const path = 'media/articles/author-1/article-1/thumb.jpg';
    await assertFails(
      uploadBytes(ref(anon.storage(), path), SMALL_IMAGE, { contentType: 'image/jpeg' }),
    );
  });

  it('cualquiera puede leer una imagen (thumbnails públicos en el feed)', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    const path = 'media/articles/author-1/article-1/thumb.jpg';
    await uploadBytes(ref(owner.storage(), path), SMALL_IMAGE, { contentType: 'image/jpeg' });

    const anon = testEnv.unauthenticatedContext();
    await assertSucceeds(getBytes(ref(anon.storage(), path)));
  });

  it('el dueño puede borrar su imagen', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    const path = 'media/articles/author-1/article-1/thumb.jpg';
    await uploadBytes(ref(owner.storage(), path), SMALL_IMAGE, { contentType: 'image/jpeg' });
    await assertSucceeds(deleteObject(ref(owner.storage(), path)));
  });

  it('otro usuario no puede borrar una imagen ajena', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    const path = 'media/articles/author-1/article-1/thumb.jpg';
    await uploadBytes(ref(owner.storage(), path), SMALL_IMAGE, { contentType: 'image/jpeg' });

    const attacker = testEnv.authenticatedContext('attacker');
    await assertFails(deleteObject(ref(attacker.storage(), path)));
  });
});
