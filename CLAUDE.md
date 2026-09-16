# CLAUDE.md

Contexto de trabajo para este repo. Fuente de verdad del plan y estado real: **`ROADMAP.md`** (raíz). Leerlo siempre al empezar sesión nueva.

## Reglas fijas

- **Nunca** correr `git commit`, `git push` ni crear PRs sin que José lo pida explícitamente. Preparar cambios y avisar.
- **Nunca** correr `firebase deploy` sin confirmación explícita de José (sobrescribe reglas del proyecto real).
- Estructura de carpetas objetivo: alineada con `docs/APP_ARCHITECTURE.md` (`presentation/screens`, `domain/use_cases`, `domain/params`, `lib/shared/`, `test/` espejo de `lib/`).
- Convención de commits: Conventional Commits.
- `applicationId`/paquete: `com.trikedevs.news_app`.

## Docs relevantes del repo

- `README.md` — encargo original.
- `ROADMAP.md` — plan de fases, decisiones tomadas, estado real verificado (no re-explorar lo ya confirmado ahí).
- `docs/APP_ARCHITECTURE.md`, `docs/ARCHITECTURE_VIOLATIONS.md`, `docs/CODING_GUIDELINES.md`, `docs/CONTRIBUTION_GUIDELINES.md`, `docs/DB_SCHEMA.md` (a crear en Fase 2), `docs/REPORT.md` (a crear en Fase 9).
- `backend/` — proyecto Firebase (rules, indexes, firebase.json, .firebaserc).
- `frontend/` — app Flutter.

## Al retomar sesión

1. Leer `ROADMAP.md`, sección "Empieza aquí".
2. Verificar con `git log`/`git status` si el estado ahí descrito sigue vigente (el roadmap es un snapshot, puede quedar desactualizado tras un `/clear`).
3. Seguir el orden de fases; no saltar a features nuevas sin cerrar bloqueantes de la fase actual.
