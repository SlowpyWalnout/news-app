# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema

Detalle completo y justificación de cada decisión en
[`docs/DB_SCHEMA.md`](docs/DB_SCHEMA.md). Resumen:

### `users/{uid}`

| Campo | Tipo |
|---|---|
| `displayName` | `string` (1–60) |
| `photoURL` | `string \| null` |
| `createdAt` | `timestamp` |

### `articles/{articleId}` (colección raíz, no subcolección de `users`)

| Campo | Tipo |
|---|---|
| `authorId` | `string` |
| `authorName` | `string` (1–60, denormalizado) |
| `authorPhotoURL` | `string \| null` (denormalizado) |
| `title` | `string` (1–120) |
| `body` | `string` (1–20000) |
| `status` | `'draft' \| 'published'` |
| `category` | `general \| business \| entertainment \| health \| science \| sports \| technology \| politics \| other` |
| `thumbnailURL` | `string \| null` |
| `thumbnailPath` | `string \| null` |
| `searchKeywords` | `array<string>` (≤30) |
| `createdAt` | `timestamp` |
| `updatedAt` | `timestamp` |
| `publishedAt` | `timestamp \| null` |

### Storage: `media/articles/{uid}/{articleId}/{imageId}.{ext}`

Lectura pública, escritura/borrado solo del `uid` dueño, ≤5 MB, solo
`image/*`. Borrado de artículo: primero Storage, después Firestore (el orden
recuperable ante fallos, ver `docs/DB_SCHEMA.md`).

## Getting Started
Before starting to work on the backend, you must have a Firebase project with the [Firebase Firestore](https://firebase.google.com/docs/firestore), [Firebase Cloud Storage](https://firebase.google.com/docs/storage) and [Firebase Local Emulator Suite](https://firebase.google.com/docs/emulator-suite) technologies enabled.
To do this, create a project but enable only Firebase Cloud Storage, Firebase Firestore, and Firebase Local Emulator Suite technologies.


## Deploying the Project
In order to deploy the Firestore rules from this repository to the [Firebase console](https://firebase.google.com/)  of your project, follow these steps:

### 1. Install firebase CLI
```
npm install -g firebase-tools
```
### 2. Login to your account
```
firebase login
```

### 3. Add your project id to the .firebasesrc file 
This corresponds to the project Id of the firebase project you created in the Firebase web-app.
[Change project id](.firebaserc)

### 4. Initialize the project
```
firebase init
```

You should leave everything as it is, choose:
- emulators
- firestore
- cloud storage

### 5. Deploy to firebase
```
firebase deploy
```
This will deploy all the rules you write in `firestore.rules` to your Firebase Firestore project.
Be careful becasuse it will overwrite the existing firestore.rules file of your project.

## Running the project in a local emulator
To run the application locally, use the following command:

```firebase emulators:start```

## Backfill de `searchKeywords` (Fase 6b)

Los artículos publicados antes de Fase 6b tienen `searchKeywords: []` (nadie
generaba tokens). `backend/scripts/backfill-search-keywords.mjs` los
recalcula con las mismas reglas que usa el cliente al publicar/editar.

```
cd backend/scripts
npm install
```

1. **Ensayo contra el emulador** (no toca datos reales):
   ```
   FIRESTORE_EMULATOR_HOST=localhost:8080 node backfill-search-keywords.mjs --project=news-app-f979a --apply
   ```
2. **Dry run contra producción** (por defecto, no escribe nada — imprime
   escaneados/cambiarían/sin cambios y los primeros 10 diffs):
   ```
   GOOGLE_APPLICATION_CREDENTIALS=<ruta a tu service account> node backfill-search-keywords.mjs --project=news-app-f979a
   ```
3. **Aplicar de verdad**, agregando `--apply` al comando anterior.

**Antes de aplicar en producción**, desplegar los índices nuevos
(`firebase deploy --only firestore:indexes`) para que la búsqueda funcione
apenas los tokens queden escritos. El script es idempotente — una segunda
corrida no reescribe nada — así que una pasada interrumpida se retoma
volviendo a correrlo.
