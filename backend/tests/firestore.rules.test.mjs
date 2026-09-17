import { afterAll, afterEach, beforeAll, describe, it } from 'vitest';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { serverTimestamp, doc, getDoc, setDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { loadTestEnv, validArticle } from './helpers.mjs';

let testEnv;

beforeAll(async () => {
  testEnv = await loadTestEnv();
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

afterAll(async () => {
  await testEnv.cleanup();
});

async function seedArticle(articleId, overrides = {}) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'articles', articleId), {
      ...validArticle(overrides),
      createdAt: overrides.createdAt ?? new Date(),
      updatedAt: overrides.updatedAt ?? new Date(),
      publishedAt: overrides.status === 'draft' ? null : (overrides.publishedAt ?? new Date()),
    });
  });
}

describe('articles: lectura', () => {
  it('cualquiera puede leer un artículo publicado', async () => {
    await seedArticle('a1', { status: 'published' });
    const anon = testEnv.unauthenticatedContext();
    await assertSucceeds(getDoc(doc(anon.firestore(), 'articles', 'a1')));
  });

  it('un usuario no puede leer el borrador de otro', async () => {
    await seedArticle('a1', { status: 'draft', authorId: 'author-1' });
    const other = testEnv.authenticatedContext('author-2');
    await assertFails(getDoc(doc(other.firestore(), 'articles', 'a1')));
  });

  it('el dueño sí puede leer su propio borrador', async () => {
    await seedArticle('a1', { status: 'draft', authorId: 'author-1' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertSucceeds(getDoc(doc(owner.firestore(), 'articles', 'a1')));
  });
});

describe('articles: creación', () => {
  it('permite crear un artículo válido como propio autor', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    await assertSucceeds(
      setDoc(doc(owner.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'author-1' }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza suplantar authorId de otro usuario', async () => {
    const attacker = testEnv.authenticatedContext('attacker');
    await assertFails(
      setDoc(doc(attacker.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'victim' }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza campos fuera del esquema', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      setDoc(doc(owner.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'author-1' }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
        isPromoted: true,
      }),
    );
  });

  it('rechaza categoría fuera del enum', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      setDoc(doc(owner.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'author-1', category: 'chismes' }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza borrador con publishedAt distinto de null', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      setDoc(doc(owner.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'author-1', status: 'draft' }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza título vacío', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      setDoc(doc(owner.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'author-1', title: '' }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza usuario no autenticado', async () => {
    const anon = testEnv.unauthenticatedContext();
    await assertFails(
      setDoc(doc(anon.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'author-1' }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });
});

describe('articles: edición', () => {
  it('el dueño puede editar contenido y updatedAt avanza', async () => {
    await seedArticle('a1', { authorId: 'author-1' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertSucceeds(
      updateDoc(doc(owner.firestore(), 'articles', 'a1'), {
        title: 'Título editado',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('otro usuario no puede editar un artículo ajeno', async () => {
    await seedArticle('a1', { authorId: 'author-1' });
    const other = testEnv.authenticatedContext('author-2');
    await assertFails(
      updateDoc(doc(other.firestore(), 'articles', 'a1'), {
        title: 'Hackeado',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza cambiar authorId en una edición', async () => {
    await seedArticle('a1', { authorId: 'author-1' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      updateDoc(doc(owner.firestore(), 'articles', 'a1'), {
        authorId: 'author-2',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('permite el fan-out de rename sin tocar updatedAt', async () => {
    await seedArticle('a1', { authorId: 'author-1', authorName: 'Nombre viejo' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertSucceeds(
      updateDoc(doc(owner.firestore(), 'articles', 'a1'), {
        authorName: 'Nombre nuevo',
      }),
    );
  });

  it('rechaza el fan-out de rename si además cambia otro campo', async () => {
    await seedArticle('a1', { authorId: 'author-1' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      updateDoc(doc(owner.firestore(), 'articles', 'a1'), {
        authorName: 'Nombre nuevo',
        title: 'Cambio colado',
      }),
    );
  });
});

describe('articles: borrado', () => {
  it('el dueño puede borrar su artículo', async () => {
    await seedArticle('a1', { authorId: 'author-1' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertSucceeds(deleteDoc(doc(owner.firestore(), 'articles', 'a1')));
  });

  it('otro usuario no puede borrar un artículo ajeno', async () => {
    await seedArticle('a1', { authorId: 'author-1' });
    const other = testEnv.authenticatedContext('author-2');
    await assertFails(deleteDoc(doc(other.firestore(), 'articles', 'a1')));
  });
});

describe('articles: searchKeywords', () => {
  it('permite hasta 30 tokens', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    const keywords = Array.from({ length: 30 }, (_, i) => `token${i}`);
    await assertSucceeds(
      setDoc(doc(owner.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'author-1', searchKeywords: keywords }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza más de 30 tokens', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    const keywords = Array.from({ length: 31 }, (_, i) => `token${i}`);
    await assertFails(
      setDoc(doc(owner.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'author-1', searchKeywords: keywords }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza searchKeywords como string en vez de lista', async () => {
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      setDoc(doc(owner.firestore(), 'articles', 'a1'), {
        ...validArticle({ authorId: 'author-1', searchKeywords: 'flutter' }),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza el fan-out de rename si además toca searchKeywords', async () => {
    await seedArticle('a1', { authorId: 'author-1', authorName: 'Nombre viejo' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      updateDoc(doc(owner.firestore(), 'articles', 'a1'), {
        authorName: 'Nombre nuevo',
        searchKeywords: ['nombre', 'nuevo'],
      }),
    );
  });
});

describe('users', () => {
  it('cualquiera puede leer un perfil', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users', 'author-1'), {
        displayName: 'José',
        photoURL: null,
        createdAt: new Date(),
      });
    });
    const anon = testEnv.unauthenticatedContext();
    await assertSucceeds(getDoc(doc(anon.firestore(), 'users', 'author-1')));
  });

  it('un usuario no puede crear el perfil de otro', async () => {
    const attacker = testEnv.authenticatedContext('attacker');
    await assertFails(
      setDoc(doc(attacker.firestore(), 'users', 'victim'), {
        displayName: 'Suplantado',
        photoURL: null,
        createdAt: serverTimestamp(),
      }),
    );
  });
});
