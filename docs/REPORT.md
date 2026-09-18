# Report — Applicant Showcase App

Este documento sigue las 7 secciones de [`REPORT_INSTRUCTIONS.md`](./REPORT_INSTRUCTIONS.md).
Lo escribo en primera persona porque quiero que se lea como lo que es: mi
experiencia real construyendo esto, no un informe técnico impersonal. Si algo
les interesa antes que nada, probablemente sea ver la app funcionando —
la sección 5 tiene capturas y un video del flujo completo.

## 1. Introducción

Antes de tocar una sola línea de código, mi primera reacción al enterarme de
que tenía 72 horas para esta prueba fue una mezcla de emoción y terror. Por
un momento me acordé de esos exámenes de la universidad donde te dejan solo
tres preguntas, el examen es a libro abierto, y tienes todo el día para
entregarlo — esa sensación de "tengo todo el tiempo del mundo y a la vez
ninguno". Y de cierto modo dio más miedo ver cómo tenían armado el propio
repositorio: instrucciones y guías pensadas para que aprendieras la
tecnología sobre la marcha, y un historial de pull requests abiertos y
cerrados que literal parecía un campo de batalla, con el registro de quién
había pasado la prueba y quién no. No quería dejar mi propio pull request
ahí para que alguien más lo viera después y pensara lo mismo de mí que yo
pensé de otros al leerlos jaja. Como además quería usar este proyecto como
pieza de portafolio, bajé el starter y me hice mi propio repositorio aparte,
y fue ahí donde empecé a trabajar de verdad.

Coordinarme para las 72 horas tampoco fue trivial: tengo otras
responsabilidades durante el día, así que terminé dedicando las mañanas y
las noches a avanzar en el MVP.

Empecé este proyecto abriendo el starter y encontrándome con que ni siquiera
compilaba: versiones de Dart incompatibles entre sí, un archivo de
configuración de Firebase con JSON inválido, un archivo de índices vacío.
Ni una línea de código propia escrita todavía y ya había que arreglar cosas.

Tengo experiencia previa con Flutter, así que no partía de cero en la
tecnología. Lo que sí decidí desde el principio fue ser honesto sobre cómo
trabajé: usé Claude Code de forma intensiva para construir este MVP. No fue
una decisión que tomé a la ligera ni algo que quiera esconder — al revisar
cómo estaban trabajando otros postulantes en sus pull requests, vi que
prácticamente todos estaban apoyándose en IA para este mismo reto, y no
quería quedarme atrás compitiendo con una mano atada. Además, mientras
avanzaba me fui entusiasmando con la idea de que este proyecto me sirviera
como pieza de portafolio para otras postulaciones y entrevistas técnicas, y
eso me empujó a exigirme más de lo mínimo pedido: quería algo que se sintiera
terminado, no un ejercicio a medio hacer.

Dicho esto, quiero ser claro sobre qué parte es mía: las decisiones de
arquitectura, qué construir y qué no, cómo diseñar el esquema de la base de
datos, qué reglas de negocio tenía sentido aplicar, y la verificación de que
todo lo que se construyó realmente funciona en un dispositivo real, las tomé
yo. Claude fue la herramienta que aceleró la escritura de código y me ayudó a
detectar bugs que de otra forma me hubiera tomado mucho más tiempo encontrar,
pero las decisiones y la responsabilidad del resultado son mías.

Para organizar el trabajo en las 72 horas armé un roadmap con fases (vive en
`ROADMAP.md` en la raíz del repo, si quieren ver el detalle día a día). A
grandes rasgos fue: arreglar el proyecto para que compilara, definir el
esquema de la base de datos y las reglas de seguridad, montar la capa de
dominio con datos de prueba, construir toda la interfaz sobre esos datos de
prueba, conectar todo a Firebase de verdad, y después varias rondas de
pulido y corrección de bugs probando la app en un dispositivo real.

## 2. Proceso de aprendizaje

No llegué sabiéndolo todo de memoria, y hubo partes que aprendí sobre la
marcha construyendo:

- **Cómo pensar el esquema de una base de datos NoSQL.** La pregunta no es
  "qué campos tiene un artículo" sino "qué voy a consultar después". Por eso
  los artículos son una colección propia (no algo anidado dentro de cada
  usuario): así el feed principal es una sola consulta simple, no docenas de
  consultas pequeñas.
- **Guardar dos referencias para una misma imagen.** Una para mostrarla y
  otra para poder borrarla después sin tener que adivinar la ruta a partir de
  la URL.
- **Las reglas de seguridad de Firestore son casi un lenguaje aparte.** No es
  código normal con `if/else`, son condiciones que evalúan un documento
  completo. Me tomó práctica aprender a validar bien qué puede escribir cada
  usuario y qué no.
- **BLoC tiene detalles que ningún tutorial básico cubre.** Por ejemplo, hay
  que tener cuidado con comparar estados que tienen campos que a veces son
  nulos, y hay que verificar que un bloc siga "vivo" antes de emitir un nuevo
  estado después de esperar algo asíncrono. Aprendí esto depurando un freeze
  real de la app (lo cuento en la sección 3).
- **Leer las reglas de arquitectura del propio repo como si fueran un
  checklist.** El repo ya traía un documento (`docs/ARCHITECTURE_VIOLATIONS.md`)
  con reglas numeradas de separación de capas. Usarlo como lista de
  verificación al final del proyecto (ver sección 7) fue más útil que
  cualquier video.

## 3. Desafíos enfrentados

Estos son los casos que más tiempo me tomaron y de los que más aprendí:

**La app se congelaba al cambiar de pestaña durante un refresh.** Probando
en el celular, si hacía pull-to-refresh en el feed y cambiaba de pestaña
antes de que terminara de cargar, toda la app se quedaba pegada. La causa
era que al cambiar de pestaña, Flutter destruye el estado de la pestaña
anterior a mitad de esa carga, y el código intentaba seguir usando algo que
ya no existía. Lo arreglé agregando verificaciones antes de cada paso
asíncrono y manteniendo vivas las pestañas en segundo plano.

**La búsqueda no buscaba realmente nada.** Revisando mi propio código (nadie
me reportó esto, lo encontré yo) me di cuenta de que la barra de búsqueda
solo filtraba los artículos que ya estaban cargados en pantalla, nunca
consultaba la base de datos completa. La implementé de verdad, con
paginación funcionando correctamente.

**Una pantalla se quedaba en blanco sin ningún error visible.** La pantalla
de política de privacidad no cargaba nada y no aparecía ningún error en la
consola. El problema era que estaba pidiendo información del idioma del
usuario en un momento del ciclo de vida del widget donde todavía no estaba
disponible. Lo diagnostiqué escribiendo un test que reprodujo el error
exacto, y ese mismo test quedó como prueba de que no vuelva a pasar.

**Una dependencia externa rompía la compilación.** Una librería de íconos
usaba una técnica que ya no es compatible con versiones recientes de Dart.
La quité por completo y reemplacé los íconos por los nativos de Flutter.

**Faltaban índices en la base de datos.** Algunas consultas necesitan un
índice especial en Firestore para funcionar. Sin ellos, la app mostraba un
error genérico de conexión que en realidad no tenía nada que ver con la red.
Los agregué todos.

**Encontré un bug antes de que causara daño.** Al revisar cómo se guardaban
las ediciones de artículos, noté que un usuario editando su propio artículo
podía sin querer borrar información de moderación (como reportes que había
recibido). Lo corregí antes de que se convirtiera en un problema real.

## 4. Reflexión y direcciones futuras

Lo que más se repitió en estos desafíos no fue "no sabía usar esta
herramienta", sino "el código decía una cosa y hacía otra": un comentario
que describía algo que ya no era cierto, una función de búsqueda que estaba
conectada pero nunca se usaba, una operación que sobrescribía datos sin
querer. Ese fue para mí el aprendizaje más grande de todo el proyecto: hay
que leer el propio trabajo con la misma desconfianza sana con la que uno
revisaría el código de otra persona.

También aprendí que decidir explícitamente qué NO construir, y dejarlo
anotado con su razón, dice tanto de uno como construirlo. Por ejemplo,
cambié la idea original de un feed social (likes, comentarios) por un
sistema de moderación de contenido, porque me pareció una mejor forma de
usar el mismo tiempo disponible.

Si continuara con una segunda versión de este proyecto, esto es lo que me
gustaría trabajar:

1. Registrar la firma de release real en Firebase para que el inicio de
   sesión con Google funcione también fuera de modo de desarrollo.
2. Probar la app con un lector de pantalla real (no solo revisar que la
   semántica esté bien puesta en el código).
3. Afinar el umbral de reportes que suspende un artículo automáticamente,
   para que sea más difícil de abusar.
4. Publicar los documentos legales (privacidad, términos) en una URL pública
   fuera de la app, como piden las tiendas de aplicaciones.
5. Terminar de automatizar la fuente de noticias externas con una función
   programada en el servidor (empecé la idea y la documenté, y de hecho
   terminé implementándola — lo cuento en la sección 6).

Y la reflexión que me llevo de todo el proceso, volviendo a la pregunta que
me hice al empezar: creo que lo más honesto que puedo decir es que no elegí
entre "hacerlo sin IA" o "hacerlo con IA" como si fueran caminos opuestos.
Elegí usar la herramienta para ir más rápido y dedicar mi tiempo a las
partes que sí requieren criterio — diseño, decisiones, verificación — en
vez de a escribir cada línea a mano. Me hubiera gustado preguntar antes qué
valoran más entre esas dos cosas, pero confío en que mostrar el proceso
completo con transparencia es la mejor respuesta que puedo dar sin haberlo
preguntado.

En lo personal, y más allá de si paso o no esta prueba técnica, me quedo con
un buen sabor de boca: con este proyecto perdí el miedo a crear
aplicaciones. Sé que puedo armar un buen MVP en menos de 72 horas trabajando
con obsesión, y ya tengo varias ideas en mente que me gustaría desarrollar y
subir a las tiendas.

## 5. Prueba del proyecto

Capturas y video tomados en dispositivo/simulador real.

| | |
|---|---|
| ![Login](./assets/screenshots/01-login.png) | ![Feed](./assets/screenshots/02-feed.png) |
| ![Búsqueda](./assets/screenshots/03-feed-busqueda.png) | ![Editor - preview](./assets/screenshots/05-editor-preview.png) |
| ![Detalle](./assets/screenshots/06-detalle.png) | ![Mis artículos](./assets/screenshots/07-mis-articulos.png) |
| ![Leer después](./assets/screenshots/08-leer-despues.png) | ![Cola de revisión](./assets/screenshots/10-cola-revision.png) |
| ![Tema oscuro](./assets/screenshots/11-tema-oscuro.png) | ![Perfil y configuración](./assets/screenshots/13-perfil-config.png) |

Video del flujo completo: [`assets/screenshots/demo.mp4`](./assets/screenshots/demo.mp4)
(registro → publicar artículo con foto → verlo en el feed → editarlo →
borrarlo).

## 6. Overdelivery

### 6.1 Funciones y reglas de la app

Más allá de poder subir tus propios artículos (que era el encargo base),
así quedó la app terminada, en un orden que no sigue ninguna prioridad en
particular:

- **Cuenta propia**: registro e inicio de sesión con correo y contraseña, o
  con Google.
- **Publicar y editar artículos**: con imagen de portada, categoría, y la
  posibilidad de guardarlos como borrador antes de publicarlos.
- **Editor con formato de texto**: negrita, cursiva, encabezados, listas y
  citas, con vista previa de cómo se va a ver antes de publicar.
- **Feed principal** con búsqueda de verdad (no solo entre lo ya cargado en
  pantalla) y filtro por categorías.
- **Noticias reales mezcladas en el feed**: además de los artículos de los
  usuarios, la app trae titulares reales de dos fuentes de noticias, para
  que el feed nunca se vea vacío. Se marcan con una etiqueta visible de
  "Titular" para que quede claro qué es contenido externo y qué es de un
  usuario — esa distinción no se puede falsificar desde la app, solo se
  escribe desde el servidor.
- **Mis artículos**: donde cada usuario ve y administra lo que ha publicado
  o dejado en borrador.
- **Leer después**: para guardar artículos y volver a ellos, incluso sin
  conexión, con marcado de leído/no leído.
- **Reportar contenido**: cualquier usuario puede reportar un artículo ajeno
  por una de varias razones. Si un artículo acumula suficientes reportes se
  suspende automáticamente, y hay una cola de revisión (solo visible para
  cuentas de staff) para aprobarlo de nuevo o retirarlo definitivamente.
- **Idioma**: la app está completa en español e inglés.
- **Tema claro/oscuro** con varios colores de acento, y un modo accesible
  real que agranda texto, botones y bordes (no es solo un interruptor
  cosmético).
- **Aviso de conexión**: la app avisa cuando se pierde la conexión, y
  distingue claramente entre "no hay internet" y "contraseña incorrecta" en
  los mensajes de error.
- **Documentos legales** (privacidad, términos) disponibles dentro de la
  app en ambos idiomas.
- **Identidad visual propia**: ícono y pantalla de carga diseñados para este
  proyecto.
- **Build de release firmado** de verdad, listo para subir a una tienda.
- Cobertura de pruebas automatizadas amplia, tanto de las reglas de
  seguridad de la base de datos como de la lógica de la app (el detalle
  exacto está en la sección 7).
- **Automatización en el servidor**: dos funciones programadas que traen
  noticias reales cada cierto tiempo, respetando los términos de uso de
  esas fuentes (dando siempre crédito visible, y borrando automáticamente
  el contenido que ya no se puede conservar).

### 6.2 Prototipos creados

- El esquema completo de la base de datos, documentado con el porqué de
  cada decisión, no solo la forma de los datos (`backend/docs/DB_SCHEMA.md`).
- Las reglas de seguridad de Firestore y Storage, con sus propias pruebas
  automatizadas, funcionando como un prototipo real de política de acceso.
- El diseño de un futuro feed social (likes, comentarios, contador de
  vistas) que decidí no construir esta vez, pero que dejé documentado en
  `ROADMAP.md` con el esquema que habría tenido.
- La idea de traer noticias reales automáticamente, que empezó como boceto
  documentado y terminé construyendo por completo (ver 6.1).

### 6.3 Ideas para una siguiente versión

- Afinar el umbral de reportes que suspende un artículo automáticamente,
  para que sea más difícil de manipular entre pocas cuentas coordinadas.
- Agregar sinónimos de búsqueda entre español e inglés por categoría.
- Agregar un contador de lecturas por artículo.
- Formatear todo el código de forma consistente y sumarlo como paso
  obligatorio en la integración continua.
- Pasar a un plan de pago en las fuentes de noticias externas si esto
  llegara a usarse en producción real, ya que sus planes gratuitos son solo
  para uso no comercial.
- Hacer que la priorización de artículos por idioma en el feed funcione
  sobre todo el contenido, no solo sobre la página ya cargada.

## 7. Secciones extra

### 7.1 Revisión propia contra las reglas del repo

Al no haber historial de pull requests (todo el trabajo quedó en commits
directos, según la regla de este repo descrita en `CLAUDE.md`), hice al
final una revisión de mi propio código contra las reglas de arquitectura y
de estilo que ya traía el repo (`docs/ARCHITECTURE_VIOLATIONS.md` y
`docs/CODING_GUIDELINES.md`). Encontré y corregí algunas violaciones que se
me habían colado durante el desarrollo — por ejemplo, un componente de
presentación que estaba llamando directo a Firebase Auth en vez de pasar
por la capa de dominio, y una pantalla que saltaba una capa de lógica. Las
corregí todas antes de dar por cerrado el proyecto.

También hubo un par de reglas de estilo que decidí no aplicar de forma
estricta (algunas reglas de lint adicionales, y dividir dos pantallas
grandes en componentes más chicos) por tiempo, y lo dejo anotado aquí en
vez de simplemente omitirlo.

### 7.2 Números del proyecto

- 229 pruebas automatizadas de Flutter, todas en verde.
- 46 pruebas de las reglas de seguridad de Firestore/Storage, corridas
  contra el emulador real, todas en verde.
- 8 pruebas de las funciones de servidor (Cloud Functions), todas en verde.
- `flutter analyze` sin errores.
- 37 commits en total.

### 7.3 Cosas que sé que quedaron pendientes

Para cerrar con la misma honestidad con la que empecé este reporte:

- El inicio de sesión con Google todavía necesita que registre la firma de
  release real en Firebase antes de funcionar fuera de modo desarrollo.
- La app se probó mucho más en Android que en iOS (compila y corre en
  simulador de iOS, pero con menos horas de prueba en dispositivo real).
- No probé la app todavía con un lector de pantalla real, solo revisé que
  la semántica y el contraste estuvieran bien puestos en el código.
- Los workflows de integración continua nunca se corrieron en un runner
  real de GitHub dentro de esta sesión de trabajo, solo se validó su lógica
  localmente.

---

De antemano, gracias por tomarse el tiempo de leer todo esto. Si mi proceso
de selección llega hasta aquí, quiero agradecerle a Alex por interesarse en
mi perfil y por darme la oportunidad de hacer esta prueba técnica. Y si en
algún momento necesitan contactarme de nuevo, estoy abierto a escuchar ideas
o propuestas para trabajar en conjunto.
