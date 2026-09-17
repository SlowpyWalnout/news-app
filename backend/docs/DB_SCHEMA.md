# Esquema de datos

Fuente de las decisiones: `ROADMAP.md` (raíz), sección "Schema — decisiones".
Este documento describe el esquema tal y como lo aplican `firestore.rules` y
`storage.rules`; cualquier cambio a uno debe reflejarse en el otro.

## Colecciones

### `users/{uid}`

| Campo | Tipo | Notas |
|---|---|---|
| `displayName` | `string` (1–60) | Nombre público del autor. |
| `photoURL` | `string \| null` | Foto de perfil. |
| `createdAt` | `timestamp` | Fijado por el servidor (`request.time`), inmutable. |

El documento existe para el perfil propio del usuario. Los artículos **no**
leen este documento en cada render del feed: guardan una copia de
`displayName`/`photoURL` (ver más abajo) para no pagar una lectura extra por
artículo.

### `articles/{articleId}` (colección raíz)

| Campo | Tipo | Notas |
|---|---|---|
| `authorId` | `string` | UID del autor. Inmutable tras crear. |
| `authorName` | `string` (1–60) | Denormalizado desde `users/{uid}.displayName`. |
| `authorPhotoURL` | `string \| null` | Denormalizado desde `users/{uid}.photoURL`. |
| `title` | `string` (1–120) | |
| `body` | `string` (1–20000) | Markdown (Fase 6b): subconjunto cerrado — negrita/cursiva (`**`/`*`), `##`/`###`, cita (`> `), lista (`- `). Sin campo de formato: texto plano ya es Markdown válido, así que artículos previos a Fase 6b se renderizan igual. El límite de 20000 cuenta los caracteres de sintaxis (`size()` corre sobre el string crudo). |
| `status` | `'draft' \| 'published'` | Controla visibilidad. |
| `category` | enum, ver abajo | Para filtros del feed. |
| `thumbnailURL` | `string \| null` | URL de descarga pública de Storage, para pintar. |
| `thumbnailPath` | `string \| null` | Path del objeto en Storage, para poder borrarlo. |
| `searchKeywords` | `array<string>` (≤30) | Generado en cliente: minúsculas, sin tildes, sin stopwords. Consultado con `array-contains`. |
| `createdAt` | `timestamp` | Fijado por el servidor al crear, inmutable. |
| `updatedAt` | `timestamp` | Fijado por el servidor en cada edición de contenido. Ver excepción de rename. |
| `publishedAt` | `timestamp \| null` | `null` mientras `status == 'draft'`. Se fija al publicar y no vuelve a tocarse. |

**Categorías permitidas:** `general`, `business`, `entertainment`, `health`,
`science`, `sports`, `technology`, `politics`, `other`. Las primeras ocho
coinciden con el feed de NewsAPI existente en la app (para no introducir un
segundo vocabulario); `other` es una categoría propia de la app, sin
equivalente en NewsAPI.

**Por qué `articles` es colección raíz y no subcolección de `users`:** el feed
global (query dominante) necesitaría `collectionGroup` sobre una
subcolección, lo que reintroduce el mismo chequeo de `authorId` en las rules
sin ganar nada. Con colección raíz + campo `authorId`, "mis artículos" es
`where('authorId', '==', uid)` y el feed es
`where('status', '==', 'published').orderBy('publishedAt', 'desc')`.

**Por qué el rename de autor no toca `updatedAt`:** si lo tocara, cambiar la
foto de perfil reordenaría "Mis artículos" sin que el usuario haya tocado
ningún artículo. El fan-out (`WriteBatch` sobre todos los artículos del
autor) solo puede escribir `authorName`/`authorPhotoURL`; las rules tienen
una rama dedicada para permitir exactamente esa combinación de campos sin
exigir `updatedAt == request.time`.

**Por qué el feed no necesita filtrar borradores en las rules:** como el feed
siempre ordena por `publishedAt` y los borradores tienen `publishedAt ==
null`, Firestore los excluye del índice usado por esa query. Aunque las
rules tuvieran un fallo, un borrador no podría aparecer ahí. Aun así, la
regla de lectura exige `published` o ser el dueño, como defensa en
profundidad.

## Storage

### `media/articles/{uid}/{articleId}/{imageId}.{ext}`

| Parte del path | Uso |
|---|---|
| `uid` | Permite validar ownership en `storage.rules` sin un `firestore.get()` (que se factura en cada subida). |
| `articleId` | Generado **en cliente antes** de subir la imagen (no después: si no, no podría ir en el path). Hace trivial el borrado en cascada de todas las imágenes de un artículo. |
| `imageId.ext` | Nombre único por imagen (permite más de una por artículo a futuro). |

Reglas: lectura pública (las miniaturas se muestran en el feed a cualquiera,
autenticado o no), escritura y borrado solo por el `uid` dueño del path,
tamaño máximo 5 MB, `contentType` debe empezar con `image/`.

### Orden de borrado: Storage primero, Firestore después

De los dos fallos posibles se elige el recuperable. Si se borrara Firestore
primero y fallara Storage, quedaría un blob invisible que se paga para
siempre. Al revés, queda un documento con imagen rota que el usuario ve y
puede volver a borrar. El error `object-not-found` de Storage se trata como
éxito, lo que hace el reintento idempotente.

## Índices

`firestore.indexes.json` tiene 5 índices compuestos desplegados sobre
`articles`:

- `authorId ASC, updatedAt DESC, __name__ DESC` ("mis artículos", incluye
  borradores).
- `status ASC, publishedAt DESC, __name__ DESC` (feed publicado, orden
  cronológico).
- `status ASC, category ASC, publishedAt DESC, __name__ DESC` (feed filtrado
  por categoría).
- `status ASC, searchKeywords CONTAINS, publishedAt DESC, __name__ DESC`
  (búsqueda por token, sin filtro de categoría).
- `status ASC, category ASC, searchKeywords CONTAINS, publishedAt DESC,
  __name__ DESC` (búsqueda por token con categoría a la vez).

El emulador crea índices al vuelo, así que los tests contra el emulador
(`backend/tests/`) no detectan un índice mal escrito o faltante en este
archivo — solo se verifica con `firebase deploy --only firestore:indexes` o
con el `FAILED_PRECONDITION` (con link directo a la consola) que Firestore
devuelve en producción si falta uno.
