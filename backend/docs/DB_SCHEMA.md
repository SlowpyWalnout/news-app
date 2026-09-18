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
| `role` | `'staff'` \| ausente | Fase 6e. Nunca lo escribe el propio usuario — `users/{uid}` ya restringe `create`/`update` a `hasOnly(['displayName','photoURL'(,'createdAt')])`, así que `role` solo lo puede poner alguien con acceso directo a la consola de Firebase (Admin SDK/consola). Ausente equivale a usuario normal. |

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
| `reportCount` | `number` \| ausente | Fase 6e. Escrito solo por la Cloud Function `onReportCreated`. Ausente equivale a 0 — no se hizo backfill sobre artículos existentes. |
| `moderationState` | `'suspended' \| 'approved' \| 'removed'` \| ausente | Fase 6e. Escrito por la Cloud Function (`'suspended'`) o por staff vía `firestore.rules` (`'approved'`/`'removed'`). Ausente equivale a "nunca moderado". |
| `suspendedAt` | `timestamp \| null` | Fase 6e. Escrito por la Cloud Function al suspender. |
| `approvedAt` | `timestamp \| null` | Fase 6e. Escrito por staff al aprobar. Se compara contra `updatedAt` para derivar el umbral de re-suspensión (ver más abajo). |
| `approvedBy` | `string` (uid) `\| null` | Fase 6e. UID del staff que aprobó; `firestore.rules` exige que coincida con `request.auth.uid`, así que no se puede falsear. |
| `suspensionCount` | `number` \| ausente | Fase 6e. Escrito por la Cloud Function, **nunca se reinicia** (ni al editar ni al aprobar) — es la memoria de reincidencia del artículo. |
| `source` | `'guardian' \| 'gnews'` \| ausente | Noticias externas. Escrito solo por `syncGuardianNews`/`syncGnewsHeadlines` (Admin SDK). Ausente equivale a artículo de la comunidad. |
| `sourceName` | `string` \| ausente | Nombre del medio (`'The Guardian'` o el `source.name` de GNews). Se renderiza siempre en la UI — es la atribución que exigen los términos de ambas APIs. |
| `sourceUrl` | `string` \| ausente | URL canónica del artículo original. |
| `hasFullBody` | `bool` \| ausente | `true` solo en Guardian. Decide si el detalle muestra `body` completo o un resumen + CTA a la fuente (GNews trunca el cuerpo en su free tier). |
| `lang` | `'es' \| 'en'` \| ausente | Alimenta la priorización por idioma del Feed (no filtra, solo reordena). |
| `expiresAt` | `timestamp` \| ausente | `fetchedAt + 24h` (Guardian) o `+7d` (GNews). Los cron la usan para autopurgarse; Guardian exige por contrato no conservar contenido más de 24h. |

**Por qué estos seis campos NO están en el `hasOnly` de `create`/`update` de
`firestore.rules`:** son server-only por omisión, no por una regla explícita.
Un cliente que intente escribir `source` en un artículo propio falla el
`hasOnly` igual que si escribiera cualquier otro campo inventado — el badge
de "Titular" es estructuralmente infalsificable, no solo por convención.
`authorId` de un artículo externo es un valor sintético (`'external:guardian'`
/`'external:gnews'`) que no coincide con ningún UID real, así que las mismas
reglas de `isOwner` que protegen la edición/borrado de artículos de usuarios
protegen también a estos: nadie puede editarlos ni borrarlos porque nadie es
su dueño.

Los siete campos de moderación son opcionales y solo los escribe el servidor
(Admin SDK) o la rama de staff de `firestore.rules` — nunca el autor, ni
siquiera al editar. `firestore.rules` lo hace explícito: la rama de edición
del autor exige
`!diff(resource.data).affectedKeys().hasAny(moderationFields())`.

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

### `articles/{articleId}/reports/{reporterUid}` (Fase 6e)

| Campo | Tipo | Notas |
|---|---|---|
| `reason` | enum: `sexual`, `violence`, `hate`, `spam`, `misinformation`, `other` | Obligatorio. |
| `note` | `string` (≤300) \| ausente | Detalle libre opcional. |
| `createdAt` | `timestamp` | Fijado por el servidor (`request.time`). |

El id del documento es el UID del reportero: hace el doble reporte
estructuralmente imposible (un `create` sobre un id que ya existe falla,
`firestore.rules` no necesita contar nada). Solo se puede crear sobre un
artículo `published` y nunca sobre el propio (`authorId != request.auth.uid`).
Lectura restringida a staff — ni el propio autor ve quién lo reportó.
`update`/`delete` son `if false`: la Cloud Function `onArticleContentEdited`
los borra con el Admin SDK, que bypasa las rules.

### Moderación: umbral de suspensión (Fase 6e)

Dos Cloud Functions (`backend/functions/`) mantienen `reportCount` y
`moderationState`:

- **`onReportCreated`** (trigger `onDocumentCreated` sobre `.../reports/{uid}`):
  incrementa `reportCount` en transacción y, si `status == 'published'` y
  `reportCount` alcanza el umbral, pone `status: 'draft'`,
  `moderationState: 'suspended'`, `suspendedAt: now`,
  `suspensionCount: increment(1)`.
- **`onArticleContentEdited`** (trigger `onDocumentUpdated` sobre `articles/{id}`):
  si el autor cambió contenido real (`title`/`body`/`category`/`thumbnailURL`),
  reinicia `reportCount: 0`, limpia `moderationState`/`suspendedAt` y borra la
  subcolección `reports` en lote. `suspensionCount` no se toca — es memoria
  permanente de reincidencia.

El umbral no se cuenta aparte, se deriva del historial que ya existe:

```js
const threshold = (approvedAt && approvedAt >= updatedAt) ? 10 : 2;
```

Sin aprobación de staff, o con el artículo editado después de la última
aprobación (`updatedAt` adelantó a `approvedAt`), el umbral es 2. Un artículo
aprobado por staff y no vuelto a editar necesita 10 reportes para
re-suspenderse. La aprobación cubre *la versión revisada*, no el artículo para
siempre — editar reinicia la protección sin que la Function necesite llevar
la cuenta de ediciones por separado.

**Por qué un umbral de 2 es un riesgo aceptado, no ideal:** dos cuentas
bastan para tumbar cualquier artículo nuevo. Se acepta porque cada mitigación
más fuerte (límite de reportes por usuario/día, ponderar por reputación del
reportero) exige almacenamiento y lógica que no caben en el presupuesto de
esta fase — quedan documentadas como diseño propuesto para `docs/REPORT.md`,
no construidas. Lo que sí está construido: deduplicación por UID, prohibición
de auto-reporte, reportes ilegibles para el autor, y `suspensionCount` que
nunca se reinicia (una re-suspensión repetida queda visible para staff aunque
el contador de reportes vuelva a cero en cada edición).

**Por qué la decisión de staff no usa una Cloud Function callable:** aprobar/
retirar es una escritura directa a Firestore autorizada por `isStaff()` en
`firestore.rules`, no una función invocable desde el cliente. Evita añadir el
paquete `cloud_functions` a `pubspec.yaml` — cada dependencia nueva en este
repo ha sido fuente de conflictos de resolución (`ionicons`, el pin de
`analyzer ^6.4.1` por `floor_generator`). Una callable sería la forma más
canónica en un proyecto con más superficie de moderación; documentado como
alternativa, no como pendiente.

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
- `moderationState ASC, suspendedAt DESC, __name__ DESC` (Fase 6e, cola de
  revisión de staff — el único índice nuevo de la fase; los 6 campos de
  moderación restantes no necesitan ninguno porque toda otra query de
  moderación pasa por `articleId`, que ya es la clave del documento).

El emulador crea índices al vuelo, así que los tests contra el emulador
(`backend/tests/`) no detectan un índice mal escrito o faltante en este
archivo — solo se verifica con `firebase deploy --only firestore:indexes` o
con el `FAILED_PRECONDITION` (con link directo a la consola) que Firestore
devuelve en producción si falta uno.
