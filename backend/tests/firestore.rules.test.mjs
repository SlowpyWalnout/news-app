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

async function seedStaff(uid) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'users', uid), {
      displayName: 'Staff',
      photoURL: null,
      createdAt: new Date(),
      role: 'staff',
    });
  });
}

describe('articles: campos de moderación', () => {
  it('el autor no puede escribir reportCount al editar contenido', async () => {
    await seedArticle('a1', { authorId: 'author-1' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      updateDoc(doc(owner.firestore(), 'articles', 'a1'), {
        title: 'Editado',
        updatedAt: serverTimestamp(),
        reportCount: 0,
      }),
    );
  });

  it('el autor no puede limpiar moderationState al editar', async () => {
    await seedArticle('a1', { authorId: 'author-1' });
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'articles', 'a1'), { moderationState: 'suspended', reportCount: 2 });
    });
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      updateDoc(doc(owner.firestore(), 'articles', 'a1'), {
        title: 'Editado',
        updatedAt: serverTimestamp(),
        moderationState: 'approved',
      }),
    );
  });

  it('un usuario normal no puede usar la rama de staff', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'draft', publishedAt: null });
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'articles', 'a1'), { moderationState: 'suspended', reportCount: 2 });
    });
    const other = testEnv.authenticatedContext('author-2');
    await assertFails(
      updateDoc(doc(other.firestore(), 'articles', 'a1'), {
        status: 'published',
        moderationState: 'approved',
        approvedAt: serverTimestamp(),
        approvedBy: 'author-2',
      }),
    );
  });

  it('staff puede aprobar un artículo suspendido', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'draft', publishedAt: null });
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'articles', 'a1'), { moderationState: 'suspended', reportCount: 2 });
    });
    await seedStaff('staff-1');
    const staff = testEnv.authenticatedContext('staff-1');
    await assertSucceeds(
      updateDoc(doc(staff.firestore(), 'articles', 'a1'), {
        status: 'published',
        moderationState: 'approved',
        approvedAt: serverTimestamp(),
        approvedBy: 'staff-1',
      }),
    );
  });

  it('staff no puede tocar título al aprobar', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'draft', publishedAt: null });
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'articles', 'a1'), { moderationState: 'suspended', reportCount: 2 });
    });
    await seedStaff('staff-1');
    const staff = testEnv.authenticatedContext('staff-1');
    await assertFails(
      updateDoc(doc(staff.firestore(), 'articles', 'a1'), {
        status: 'published',
        moderationState: 'approved',
        approvedAt: serverTimestamp(),
        approvedBy: 'staff-1',
        title: 'Título retocado por staff',
      }),
    );
  });

  it('staff no puede suplantar approvedBy con otro uid', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'draft', publishedAt: null });
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'articles', 'a1'), { moderationState: 'suspended', reportCount: 2 });
    });
    await seedStaff('staff-1');
    const staff = testEnv.authenticatedContext('staff-1');
    await assertFails(
      updateDoc(doc(staff.firestore(), 'articles', 'a1'), {
        status: 'published',
        moderationState: 'approved',
        approvedAt: serverTimestamp(),
        approvedBy: 'otro-uid',
      }),
    );
  });

  it('staff sí puede leer un artículo suspendido (draft)', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'draft', publishedAt: null });
    await seedStaff('staff-1');
    const staff = testEnv.authenticatedContext('staff-1');
    await assertSucceeds(getDoc(doc(staff.firestore(), 'articles', 'a1')));
  });
});

describe('articles/{id}/reports', () => {
  it('un usuario puede reportar un artículo publicado de otro', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'published' });
    const reporter = testEnv.authenticatedContext('reporter-1');
    await assertSucceeds(
      setDoc(doc(reporter.firestore(), 'articles', 'a1', 'reports', 'reporter-1'), {
        reason: 'sexual',
        createdAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza reportar el propio artículo', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'published' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      setDoc(doc(owner.firestore(), 'articles', 'a1', 'reports', 'author-1'), {
        reason: 'spam',
        createdAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza un segundo reporte del mismo usuario (mismo doc-id ya existe)', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'published' });
    const reporter = testEnv.authenticatedContext('reporter-1');
    await assertSucceeds(
      setDoc(doc(reporter.firestore(), 'articles', 'a1', 'reports', 'reporter-1'), {
        reason: 'spam',
        createdAt: serverTimestamp(),
      }),
    );
    await assertFails(
      updateDoc(doc(reporter.firestore(), 'articles', 'a1', 'reports', 'reporter-1'), {
        reason: 'hate',
      }),
    );
  });

  it('rechaza motivo fuera del enum', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'published' });
    const reporter = testEnv.authenticatedContext('reporter-1');
    await assertFails(
      setDoc(doc(reporter.firestore(), 'articles', 'a1', 'reports', 'reporter-1'), {
        reason: 'me-cae-mal',
        createdAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza reportar sin sesión', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'published' });
    const anon = testEnv.unauthenticatedContext();
    await assertFails(
      setDoc(doc(anon.firestore(), 'articles', 'a1', 'reports', 'anon'), {
        reason: 'spam',
        createdAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza reportar un borrador', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'draft', publishedAt: null });
    const reporter = testEnv.authenticatedContext('reporter-1');
    await assertFails(
      setDoc(doc(reporter.firestore(), 'articles', 'a1', 'reports', 'reporter-1'), {
        reason: 'spam',
        createdAt: serverTimestamp(),
      }),
    );
  });

  it('un usuario normal no puede leer los reportes', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'published' });
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'articles', 'a1', 'reports', 'reporter-1'), {
        reason: 'spam',
        createdAt: new Date(),
      });
    });
    const other = testEnv.authenticatedContext('reporter-2');
    await assertFails(getDoc(doc(other.firestore(), 'articles', 'a1', 'reports', 'reporter-1')));
  });

  it('staff sí puede leer los reportes', async () => {
    await seedArticle('a1', { authorId: 'author-1', status: 'published' });
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'articles', 'a1', 'reports', 'reporter-1'), {
        reason: 'spam',
        createdAt: new Date(),
      });
    });
    await seedStaff('staff-1');
    const staff = testEnv.authenticatedContext('staff-1');
    await assertSucceeds(getDoc(doc(staff.firestore(), 'articles', 'a1', 'reports', 'reporter-1')));
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

// Los artículos de noticias externas (Guardian/GNews) los escribe solo el
// Admin SDK (syncGuardianNews/syncGnewsHeadlines), que bypasa estas rules.
// Estos tests fijan que un cliente normal NO puede fabricar uno: el badge de
// "Titular" debe ser estructuralmente infalsificable, no solo por convención.
describe('articles: noticias externas', () => {
  it('rechaza que un cliente cree un artículo con el campo source', async () => {
    const attacker = testEnv.authenticatedContext('attacker');
    await assertFails(
      setDoc(doc(attacker.firestore(), 'articles', 'fake-headline'), {
        ...validArticle({ authorId: 'attacker' }),
        source: 'guardian',
        sourceName: 'The Guardian',
        sourceUrl: 'https://www.theguardian.com/fake',
        hasFullBody: true,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('rechaza que un cliente añada source a un artículo propio ya existente', async () => {
    await seedArticle('a1', { status: 'published', authorId: 'author-1' });
    const owner = testEnv.authenticatedContext('author-1');
    await assertFails(
      updateDoc(doc(owner.firestore(), 'articles', 'a1'), {
        source: 'gnews',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('nadie puede editar un artículo externo (authorId sintético, sin dueño real)', async () => {
    await seedArticle('headline-1', {
      status: 'published',
      authorId: 'external:guardian',
      authorName: 'The Guardian',
    });
    const someone = testEnv.authenticatedContext('author-1');
    await assertFails(
      updateDoc(doc(someone.firestore(), 'articles', 'headline-1'), {
        title: 'Título alterado',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('nadie puede borrar un artículo externo', async () => {
    await seedArticle('headline-1', {
      status: 'published',
      authorId: 'external:gnews',
      authorName: 'Example News',
    });
    const someone = testEnv.authenticatedContext('author-1');
    await assertFails(deleteDoc(doc(someone.firestore(), 'articles', 'headline-1')));
  });

  it('cualquier autenticado puede leer un artículo externo publicado', async () => {
    await seedArticle('headline-1', {
      status: 'published',
      authorId: 'external:guardian',
      authorName: 'The Guardian',
    });
    const someone = testEnv.authenticatedContext('author-1');
    await assertSucceeds(getDoc(doc(someone.firestore(), 'articles', 'headline-1')));
  });

  it('un anónimo también puede leer un artículo externo publicado', async () => {
    await seedArticle('headline-1', {
      status: 'published',
      authorId: 'external:gnews',
      authorName: 'Example News',
    });
    const anon = testEnv.unauthenticatedContext();
    await assertSucceeds(getDoc(doc(anon.firestore(), 'articles', 'headline-1')));
  });
});
