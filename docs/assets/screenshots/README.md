# Guion de captura

Este documento no contiene imágenes. Es la lista exacta de qué capturar para
completar la sección "Prueba del proyecto" de `docs/REPORT.md`. El REPORT ya
referencia estas rutas con `![...](assets/screenshots/NN-nombre.png)`; basta
con guardar cada archivo con el nombre indicado para que las imágenes
aparezcan sin tocar el Markdown.

## Cómo capturar

- **Android** (`emulator-5554` u otro dispositivo conectado):
  `adb exec-out screencap -p > docs/assets/screenshots/NN-nombre.png`
- **iOS** (simulador): con el simulador enfocado, `Cmd+S` guarda el PNG en el
  escritorio; mover el archivo a esta carpeta con el nombre indicado.
- **Video** (`demo.mp4`): grabación de pantalla del flujo completo, formato
  libre (mp4/mov), guardado como `docs/assets/screenshots/demo.mp4`.

## Lista

| Archivo | Qué mostrar |
|---|---|
| `01-login.png` | Pantalla de Login, con el aviso de política de privacidad/términos visible |
| `02-feed.png` | Feed con artículos publicados, buscador y rail de categorías |
| `03-feed-busqueda.png` | Feed con una búsqueda activa y resultados filtrados |
| `04-editor-escritura.png` | Editor de artículo, pestaña "Escribir", con formato Markdown en vivo (negrita/cursiva visibles mientras se escribe) |
| `05-editor-preview.png` | Editor de artículo, pestaña "Vista previa" |
| `06-detalle.png` | Detalle de un artículo con el cuerpo Markdown ya renderizado |
| `07-mis-articulos.png` | "Mis artículos" con las pestañas Publicados/Borradores |
| `08-leer-despues.png` | "Leer después" con al menos un artículo marcado "Ya lo leí" |
| `09-reportar.png` | Bottom sheet de reporte con las 5 razones visibles |
| `10-cola-revision.png` | Cola de revisión de staff, con un artículo suspendido |
| `11-tema-oscuro.png` | Feed en tema oscuro |
| `12-modo-accesible.png` | La misma pantalla que `11` o `02`, con modo accesible activado (para comparar tamaños) |
| `13-perfil-config.png` | Perfil y pantalla de Configuración |
| `14-offline.png` | Banner de "sin conexión" (activar modo avión con la app abierta) |
| `demo.mp4` | Flujo completo: registro → publicar artículo con foto → verlo en el feed → editarlo → borrarlo |

No se generaron estas capturas en esta sesión por falta de herramienta de UI
automation. `docs/REPORT.md` lo dice explícitamente en su sección 5.
