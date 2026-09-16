#!/usr/bin/env bash
# firebase emulators:exec no sirve aquí: el binario compilado de firebase-tools
# ejecuta el script hijo con su propio Node embebido (viejo), que no puede
# hacer require() de un módulo ESM (vitest.mjs). Por eso se levanta el
# emulador aparte, con el Node/npm reales del sistema para correr vitest.
set -euo pipefail
cd "$(dirname "$0")/.."

LOG_FILE="$(mktemp)"
firebase emulators:start --project=news-app-f979a --only firestore,storage > "$LOG_FILE" 2>&1 &
EMULATOR_PID=$!

cleanup() {
  kill "$EMULATOR_PID" 2>/dev/null || true
  wait "$EMULATOR_PID" 2>/dev/null || true
  rm -f "$LOG_FILE"
}
trap cleanup EXIT

for _ in $(seq 1 60); do
  if grep -q "All emulators ready" "$LOG_FILE"; then
    break
  fi
  sleep 1
done

if ! grep -q "All emulators ready" "$LOG_FILE"; then
  echo "Los emuladores no arrancaron a tiempo:"
  cat "$LOG_FILE"
  exit 1
fi

cd tests
npx vitest run
