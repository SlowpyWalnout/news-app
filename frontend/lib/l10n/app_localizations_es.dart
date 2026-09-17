// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appWordmark => 'NEWS';

  @override
  String get loginHeroTitle =>
      'Las noticias del barrio, escritas por el barrio.';

  @override
  String get loginHeroSubtitle => 'Entra para leer y publicar.';

  @override
  String get networkErrorTitle => 'No pudimos conectarnos';

  @override
  String get networkErrorBody =>
      'Revisa tu conexión. Lo intentamos de nuevo cuando toques «Iniciar sesión».';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailPlaceholder => 'nombre@correo.com';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordPlaceholder => 'Al menos 6 caracteres';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signingIn => 'Entrando…';

  @override
  String get noAccountYet => '¿Aún no tienes cuenta?';

  @override
  String get signUp => 'Regístrate';

  @override
  String get orDivider => 'o';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get googleSignInError =>
      'No se pudo iniciar sesión con Google. Inténtalo de nuevo.';

  @override
  String get loginCredentialError =>
      'El correo o la contraseña no coinciden. Inténtalo de nuevo o restablece tu contraseña.';

  @override
  String get emailRequired => 'Te falta el correo.';

  @override
  String get emailInvalid => 'Escribe un correo válido, con @ y punto.';

  @override
  String get passwordRequired => 'Te falta la contraseña.';

  @override
  String get passwordTooShort => 'La contraseña necesita 6 caracteres o más.';

  @override
  String get back => 'Volver';

  @override
  String get createAccountTitle => 'Crear tu cuenta';

  @override
  String get createAccountSubtitle => 'Tres datos y listo.';

  @override
  String get registerEmailTaken =>
      'Ya existe una cuenta con ese correo. Inicia sesión o usa otro.';

  @override
  String get displayNameLabel => 'Nombre para mostrar';

  @override
  String get displayNamePlaceholder => 'Cómo te van a ver los lectores';

  @override
  String displayNameCounter(int count) {
    return '$count / 60';
  }

  @override
  String get displayNameEmpty => 'Escribe al menos 1 carácter.';

  @override
  String get displayNameTooLong => 'Máximo 60 caracteres.';

  @override
  String get passwordValid => 'Contraseña válida';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get creatingAccount => 'Creando…';

  @override
  String get searchPlaceholder => 'Buscar en News';

  @override
  String get searchClear => 'Limpiar búsqueda';

  @override
  String get categoryAll => 'Todas';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryBusiness => 'Negocios';

  @override
  String get categoryEntertainment => 'Espectáculos';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categoryScience => 'Ciencia';

  @override
  String get categorySports => 'Deportes';

  @override
  String get categoryTechnology => 'Tecnología';

  @override
  String get categoryPolitics => 'Política';

  @override
  String get categoryOther => 'Otro';

  @override
  String get feedLoadingCaption => 'Buscando las últimas noticias…';

  @override
  String get feedNetworkErrorTitle => 'El servidor no responde';

  @override
  String get feedNetworkErrorBody =>
      'Error 503 al pedir el feed. Tus borradores siguen guardados en el teléfono.';

  @override
  String get retry => 'Reintentar';

  @override
  String get feedEmptySearchTitle => 'Sin resultados';

  @override
  String get feedEmptySearchBody =>
      'No encontramos noticias con esas palabras. Prueba con menos palabras.';

  @override
  String get feedEmptyFilterTitle => 'Aún no hay noticias aquí';

  @override
  String get feedEmptyFilterBody =>
      'Nadie publicó en esta categoría esta semana. Puedes ser la primera persona.';

  @override
  String get viewAllCategories => 'Ver todas las categorías';

  @override
  String readTimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get backToFeed => 'Feed';

  @override
  String get readLaterAdd => 'Leer después';

  @override
  String get readLaterAdded => 'Leer después ✓';

  @override
  String get readLaterAddedToast => 'Agregado a Leer después';

  @override
  String get readLaterRemovedToast => 'Quitado de Leer después';

  @override
  String get editAction => 'Editar';

  @override
  String get deleteAction => 'Borrar';

  @override
  String get notYoursTitle => 'Este artículo no es tuyo';

  @override
  String notYoursBody(String author) {
    return 'Lo publicó $author, así que no puedes editarlo ni borrarlo. Puedes marcarlo como Leer después o escribir tu propia noticia.';
  }

  @override
  String get exit => 'Salir';

  @override
  String get newArticleTitle => 'Nuevo artículo';

  @override
  String get editArticleTitle => 'Editar artículo';

  @override
  String get titleLabel => 'Título';

  @override
  String get titlePlaceholder => 'Cuenta en una línea qué pasó';

  @override
  String titleCounter(int count) {
    return '$count / 120';
  }

  @override
  String get titleEmptyError => 'El título no puede quedar vacío.';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get coverLabel => 'Imagen de portada';

  @override
  String get chooseCoverImage => 'Elegir imagen';

  @override
  String get removeCoverImage => 'Quitar imagen';

  @override
  String get coverHint => 'JPG · PNG · WEBP — hasta 5 MB';

  @override
  String coverTooLarge(String sizeMb) {
    return 'La imagen pesa $sizeMb MB y el límite es 5 MB. Prueba con una foto más pequeña o bájale la calidad.';
  }

  @override
  String get bodyLabel => 'Cuerpo de la noticia';

  @override
  String get bodyPlaceholder =>
      'Escribe lo que viste, quién te lo contó y cuándo pasó.';

  @override
  String bodyCounter(String count) {
    return '$count / 20.000';
  }

  @override
  String get bodyEmptyError => 'Falta el cuerpo de la nota.';

  @override
  String get writeTab => 'Escribir';

  @override
  String get previewTab => 'Vista previa';

  @override
  String get previewEmpty => 'Nada que previsualizar todavía.';

  @override
  String get markdownBold => 'Negrita';

  @override
  String get markdownItalic => 'Cursiva';

  @override
  String get markdownHeading2 => 'Subtítulo';

  @override
  String get markdownHeading3 => 'Subtítulo pequeño';

  @override
  String get markdownQuote => 'Cita';

  @override
  String get markdownBullet => 'Lista';

  @override
  String get markdownPlaceholder => 'texto';

  @override
  String get saveDraft => 'Guardar';

  @override
  String get publish => 'Publicar';

  @override
  String get publishing => 'Publicando…';

  @override
  String get emptyDraftToast =>
      'Escribe un título o el cuerpo antes de guardar';

  @override
  String get draftSavedToast => 'Borrador guardado en este teléfono';

  @override
  String get publishedToast => '¡Publicado! Ya está en el feed';

  @override
  String get myArticlesTitle => 'Mis artículos';

  @override
  String get tabAll => 'Todas';

  @override
  String get tabDrafts => 'Borradores';

  @override
  String get tabPublished => 'Publicados';

  @override
  String get myArticlesNetErrorTitle => 'No pudimos traer tu lista';

  @override
  String get myArticlesNetErrorBody =>
      'La conexión se cortó al pedir la página 1. Tus borradores locales siguen aquí.';

  @override
  String get myArticlesEmptyTitle => 'Aún no has escrito nada';

  @override
  String get myArticlesEmptyBody =>
      'Tu primera noticia puede ser corta: qué pasó, dónde y cuándo. Se guarda sola como borrador.';

  @override
  String get myArticlesEmptyDraftTitle => 'No tienes borradores';

  @override
  String get myArticlesEmptyDraftBody =>
      'Todo lo que empezaste ya está publicado.';

  @override
  String get writeFirstArticle => 'Escribir mi primer artículo';

  @override
  String get draftPill => 'Borrador';

  @override
  String get publishedPill => 'Publicado';

  @override
  String get loadMore => 'Cargar más';

  @override
  String get noMore => 'No hay más';

  @override
  String get publishedStatLabel => 'publicados';

  @override
  String get draftsStatLabel => 'borradores';

  @override
  String get myArticlesRow => 'Mis artículos';

  @override
  String get writeArticleRow => 'Escribir un artículo';

  @override
  String get readLaterRow => 'Leer después';

  @override
  String get appearanceRow => 'Apariencia';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get accessibleModeRow => 'Modo accesible';

  @override
  String get on => 'Activado';

  @override
  String get off => 'Desactivado';

  @override
  String get languageRow => 'Idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get profileStaleDataTitle => 'Tus datos están desactualizados';

  @override
  String get profileStaleDataBody =>
      'Mostramos la última copia guardada en el teléfono. Lo reintentamos automáticamente cuando vuelva la conexión.';

  @override
  String get confirmDeleteTitle => '¿Borrar este artículo?';

  @override
  String confirmDeleteBody(String title) {
    return '«$title» se elimina para siempre, también para quienes lo marcaron Leer después.';
  }

  @override
  String get confirmDeleteYes => 'Sí, borrar';

  @override
  String get confirmDeleteNo => 'No, volver';

  @override
  String get articleDeletedToast => 'Artículo borrado';

  @override
  String get navFeed => 'Feed';

  @override
  String get navMyArticles => 'Mis artículos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get readLaterTitle => 'Leer después';

  @override
  String get readLaterEmpty =>
      'Todavía no marcaste ningún artículo para leer después.';

  @override
  String get readLaterAlreadyRead => 'Ya lo leí';

  @override
  String get readLaterErrorTitle => 'No se pudo cargar tu lista';

  @override
  String get readLaterErrorBody =>
      'Algo falló al cargar Leer después. Tus artículos guardados siguen en el teléfono.';

  @override
  String get reportAction => 'Reportar';

  @override
  String get reportAlreadyDone => 'Ya reportaste';

  @override
  String get reportSheetTitle => '¿Por qué reportas este artículo?';

  @override
  String get reportSheetBody =>
      'Tu reporte es anónimo para el autor. Revisamos los artículos con varios reportes.';

  @override
  String get reportReasonSexual => 'Contenido sexual';

  @override
  String get reportReasonViolence => 'Violencia';

  @override
  String get reportReasonHate => 'Discurso de odio';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonMisinformation => 'Desinformación';

  @override
  String get reportReasonOther => 'Otro motivo';

  @override
  String get reportNoteLabel => 'Detalle (opcional)';

  @override
  String get reportSubmit => 'Enviar reporte';

  @override
  String get reportCancel => 'Cancelar';

  @override
  String get reportSentToast => 'Reporte enviado';

  @override
  String get reportErrorToast => 'No se pudo enviar el reporte';

  @override
  String get statusSuspended => 'Suspendido';

  @override
  String get suspendedBannerTitle => 'Este artículo fue suspendido';

  @override
  String get suspendedBannerBody =>
      'Recibió varios reportes de la comunidad. Edítalo para corregir lo que haga falta y volver a publicarlo.';

  @override
  String get staffReviewRow => 'Revisión de reportes';

  @override
  String get staffReviewQueueTitle => 'Artículos suspendidos';

  @override
  String get staffReviewQueueEmpty =>
      'No hay artículos suspendidos para revisar.';

  @override
  String get staffApprove => 'Aprobar';

  @override
  String get staffRemove => 'Retirar';

  @override
  String get staffDecisionApprovedToast => 'Artículo republicado';

  @override
  String get staffDecisionRemovedToast => 'Artículo retirado';
}
