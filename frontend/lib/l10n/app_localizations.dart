import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Logo text shown before the accent dot on Login/Feed.
  ///
  /// In es, this message translates to:
  /// **'NEWS'**
  String get appWordmark;

  /// No description provided for @loginHeroTitle.
  ///
  /// In es, this message translates to:
  /// **'Las noticias del barrio, escritas por el barrio.'**
  String get loginHeroTitle;

  /// No description provided for @loginHeroSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Entra para leer y publicar.'**
  String get loginHeroSubtitle;

  /// No description provided for @networkErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectarnos'**
  String get networkErrorTitle;

  /// No description provided for @networkErrorBody.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión. Lo intentamos de nuevo cuando toques «Iniciar sesión».'**
  String get networkErrorBody;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @emailPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'nombre@correo.com'**
  String get emailPlaceholder;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Al menos 6 caracteres'**
  String get passwordPlaceholder;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In es, this message translates to:
  /// **'Entrando…'**
  String get signingIn;

  /// No description provided for @noAccountYet.
  ///
  /// In es, this message translates to:
  /// **'¿Aún no tienes cuenta?'**
  String get noAccountYet;

  /// No description provided for @signUp.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get signUp;

  /// No description provided for @loginCredentialError.
  ///
  /// In es, this message translates to:
  /// **'El correo o la contraseña no coinciden. Inténtalo de nuevo o restablece tu contraseña.'**
  String get loginCredentialError;

  /// No description provided for @emailRequired.
  ///
  /// In es, this message translates to:
  /// **'Te falta el correo.'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe un correo válido, con @ y punto.'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In es, this message translates to:
  /// **'Te falta la contraseña.'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña necesita 6 caracteres o más.'**
  String get passwordTooShort;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @createAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear tu cuenta'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tres datos y listo.'**
  String get createAccountSubtitle;

  /// No description provided for @registerEmailTaken.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con ese correo. Inicia sesión o usa otro.'**
  String get registerEmailTaken;

  /// No description provided for @displayNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre para mostrar'**
  String get displayNameLabel;

  /// No description provided for @displayNamePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Cómo te van a ver los lectores'**
  String get displayNamePlaceholder;

  /// No description provided for @displayNameCounter.
  ///
  /// In es, this message translates to:
  /// **'{count} / 60'**
  String displayNameCounter(int count);

  /// No description provided for @displayNameEmpty.
  ///
  /// In es, this message translates to:
  /// **'Escribe al menos 1 carácter.'**
  String get displayNameEmpty;

  /// No description provided for @displayNameTooLong.
  ///
  /// In es, this message translates to:
  /// **'Máximo 60 caracteres.'**
  String get displayNameTooLong;

  /// No description provided for @passwordValid.
  ///
  /// In es, this message translates to:
  /// **'Contraseña válida'**
  String get passwordValid;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @creatingAccount.
  ///
  /// In es, this message translates to:
  /// **'Creando…'**
  String get creatingAccount;

  /// No description provided for @searchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Buscar en News'**
  String get searchPlaceholder;

  /// No description provided for @categoryAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get categoryAll;

  /// No description provided for @categoryGeneral.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryBusiness.
  ///
  /// In es, this message translates to:
  /// **'Negocios'**
  String get categoryBusiness;

  /// No description provided for @categoryEntertainment.
  ///
  /// In es, this message translates to:
  /// **'Espectáculos'**
  String get categoryEntertainment;

  /// No description provided for @categoryHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get categoryHealth;

  /// No description provided for @categoryScience.
  ///
  /// In es, this message translates to:
  /// **'Ciencia'**
  String get categoryScience;

  /// No description provided for @categorySports.
  ///
  /// In es, this message translates to:
  /// **'Deportes'**
  String get categorySports;

  /// No description provided for @categoryTechnology.
  ///
  /// In es, this message translates to:
  /// **'Tecnología'**
  String get categoryTechnology;

  /// No description provided for @categoryPolitics.
  ///
  /// In es, this message translates to:
  /// **'Política'**
  String get categoryPolitics;

  /// No description provided for @feedLoadingCaption.
  ///
  /// In es, this message translates to:
  /// **'Buscando las últimas noticias…'**
  String get feedLoadingCaption;

  /// No description provided for @feedNetworkErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'El servidor no responde'**
  String get feedNetworkErrorTitle;

  /// No description provided for @feedNetworkErrorBody.
  ///
  /// In es, this message translates to:
  /// **'Error 503 al pedir el feed. Tus borradores siguen guardados en el teléfono.'**
  String get feedNetworkErrorBody;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @feedEmptySearchTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get feedEmptySearchTitle;

  /// No description provided for @feedEmptySearchBody.
  ///
  /// In es, this message translates to:
  /// **'No encontramos noticias con esas palabras. Prueba con menos palabras.'**
  String get feedEmptySearchBody;

  /// No description provided for @feedEmptyFilterTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay noticias aquí'**
  String get feedEmptyFilterTitle;

  /// No description provided for @feedEmptyFilterBody.
  ///
  /// In es, this message translates to:
  /// **'Nadie publicó en esta categoría esta semana. Puedes ser la primera persona.'**
  String get feedEmptyFilterBody;

  /// No description provided for @viewAllCategories.
  ///
  /// In es, this message translates to:
  /// **'Ver todas las categorías'**
  String get viewAllCategories;

  /// No description provided for @readTimeMinutes.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String readTimeMinutes(int minutes);

  /// No description provided for @backToFeed.
  ///
  /// In es, this message translates to:
  /// **'Feed'**
  String get backToFeed;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In es, this message translates to:
  /// **'Guardado ✓'**
  String get saved;

  /// No description provided for @savedToast.
  ///
  /// In es, this message translates to:
  /// **'Guardado en tus favoritos'**
  String get savedToast;

  /// No description provided for @unsavedToast.
  ///
  /// In es, this message translates to:
  /// **'Quitado de favoritos'**
  String get unsavedToast;

  /// No description provided for @editAction.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get deleteAction;

  /// No description provided for @notYoursTitle.
  ///
  /// In es, this message translates to:
  /// **'Este artículo no es tuyo'**
  String get notYoursTitle;

  /// No description provided for @notYoursBody.
  ///
  /// In es, this message translates to:
  /// **'Lo publicó {author}, así que no puedes editarlo ni borrarlo. Puedes guardarlo o escribir tu propia noticia.'**
  String notYoursBody(String author);

  /// No description provided for @exit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get exit;

  /// No description provided for @newArticleTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo artículo'**
  String get newArticleTitle;

  /// No description provided for @editArticleTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar artículo'**
  String get editArticleTitle;

  /// No description provided for @titleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get titleLabel;

  /// No description provided for @titlePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Cuenta en una línea qué pasó'**
  String get titlePlaceholder;

  /// No description provided for @titleCounter.
  ///
  /// In es, this message translates to:
  /// **'{count} / 120'**
  String titleCounter(int count);

  /// No description provided for @titleEmptyError.
  ///
  /// In es, this message translates to:
  /// **'El título no puede quedar vacío.'**
  String get titleEmptyError;

  /// No description provided for @categoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get categoryLabel;

  /// No description provided for @coverLabel.
  ///
  /// In es, this message translates to:
  /// **'Imagen de portada'**
  String get coverLabel;

  /// No description provided for @chooseCoverImage.
  ///
  /// In es, this message translates to:
  /// **'Elegir imagen'**
  String get chooseCoverImage;

  /// No description provided for @removeCoverImage.
  ///
  /// In es, this message translates to:
  /// **'Quitar imagen'**
  String get removeCoverImage;

  /// No description provided for @coverHint.
  ///
  /// In es, this message translates to:
  /// **'JPG · PNG · WEBP — hasta 5 MB'**
  String get coverHint;

  /// No description provided for @coverTooLarge.
  ///
  /// In es, this message translates to:
  /// **'La imagen pesa {sizeMb} MB y el límite es 5 MB. Prueba con una foto más pequeña o bájale la calidad.'**
  String coverTooLarge(String sizeMb);

  /// No description provided for @bodyLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuerpo de la noticia'**
  String get bodyLabel;

  /// No description provided for @bodyPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Escribe lo que viste, quién te lo contó y cuándo pasó.'**
  String get bodyPlaceholder;

  /// No description provided for @bodyCounter.
  ///
  /// In es, this message translates to:
  /// **'{count} / 20.000'**
  String bodyCounter(String count);

  /// No description provided for @bodyEmptyError.
  ///
  /// In es, this message translates to:
  /// **'Falta el cuerpo de la nota.'**
  String get bodyEmptyError;

  /// No description provided for @saveDraft.
  ///
  /// In es, this message translates to:
  /// **'Guardar borrador'**
  String get saveDraft;

  /// No description provided for @publish.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publish;

  /// No description provided for @publishing.
  ///
  /// In es, this message translates to:
  /// **'Publicando…'**
  String get publishing;

  /// No description provided for @draftSavedToast.
  ///
  /// In es, this message translates to:
  /// **'Borrador guardado en este teléfono'**
  String get draftSavedToast;

  /// No description provided for @publishedToast.
  ///
  /// In es, this message translates to:
  /// **'¡Publicado! Ya está en el feed'**
  String get publishedToast;

  /// No description provided for @myArticlesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis artículos'**
  String get myArticlesTitle;

  /// No description provided for @tabAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get tabAll;

  /// No description provided for @tabDrafts.
  ///
  /// In es, this message translates to:
  /// **'Borradores'**
  String get tabDrafts;

  /// No description provided for @tabPublished.
  ///
  /// In es, this message translates to:
  /// **'Publicados'**
  String get tabPublished;

  /// No description provided for @myArticlesNetErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos traer tu lista'**
  String get myArticlesNetErrorTitle;

  /// No description provided for @myArticlesNetErrorBody.
  ///
  /// In es, this message translates to:
  /// **'La conexión se cortó al pedir la página 1. Tus borradores locales siguen aquí.'**
  String get myArticlesNetErrorBody;

  /// No description provided for @myArticlesEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no has escrito nada'**
  String get myArticlesEmptyTitle;

  /// No description provided for @myArticlesEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Tu primera noticia puede ser corta: qué pasó, dónde y cuándo. Se guarda sola como borrador.'**
  String get myArticlesEmptyBody;

  /// No description provided for @myArticlesEmptyDraftTitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes borradores'**
  String get myArticlesEmptyDraftTitle;

  /// No description provided for @myArticlesEmptyDraftBody.
  ///
  /// In es, this message translates to:
  /// **'Todo lo que empezaste ya está publicado.'**
  String get myArticlesEmptyDraftBody;

  /// No description provided for @writeFirstArticle.
  ///
  /// In es, this message translates to:
  /// **'Escribir mi primer artículo'**
  String get writeFirstArticle;

  /// No description provided for @draftPill.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get draftPill;

  /// No description provided for @publishedPill.
  ///
  /// In es, this message translates to:
  /// **'Publicado'**
  String get publishedPill;

  /// No description provided for @loadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get loadMore;

  /// No description provided for @noMore.
  ///
  /// In es, this message translates to:
  /// **'No hay más'**
  String get noMore;

  /// No description provided for @publishedStatLabel.
  ///
  /// In es, this message translates to:
  /// **'publicados'**
  String get publishedStatLabel;

  /// No description provided for @draftsStatLabel.
  ///
  /// In es, this message translates to:
  /// **'borradores'**
  String get draftsStatLabel;

  /// No description provided for @myArticlesRow.
  ///
  /// In es, this message translates to:
  /// **'Mis artículos'**
  String get myArticlesRow;

  /// No description provided for @writeArticleRow.
  ///
  /// In es, this message translates to:
  /// **'Escribir un artículo'**
  String get writeArticleRow;

  /// No description provided for @savedArticlesRow.
  ///
  /// In es, this message translates to:
  /// **'Guardados'**
  String get savedArticlesRow;

  /// No description provided for @appearanceRow.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearanceRow;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @accessibleModeRow.
  ///
  /// In es, this message translates to:
  /// **'Modo accesible'**
  String get accessibleModeRow;

  /// No description provided for @on.
  ///
  /// In es, this message translates to:
  /// **'Activado'**
  String get on;

  /// No description provided for @off.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get off;

  /// No description provided for @languageRow.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageRow;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @logOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logOut;

  /// No description provided for @profileStaleDataTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus datos están desactualizados'**
  String get profileStaleDataTitle;

  /// No description provided for @profileStaleDataBody.
  ///
  /// In es, this message translates to:
  /// **'Mostramos la última copia guardada en el teléfono. Lo reintentamos automáticamente cuando vuelva la conexión.'**
  String get profileStaleDataBody;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar este artículo?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'«{title}» se elimina para siempre, también para quienes lo guardaron.'**
  String confirmDeleteBody(String title);

  /// No description provided for @confirmDeleteYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, borrar'**
  String get confirmDeleteYes;

  /// No description provided for @confirmDeleteNo.
  ///
  /// In es, this message translates to:
  /// **'No, volver'**
  String get confirmDeleteNo;

  /// No description provided for @articleDeletedToast.
  ///
  /// In es, this message translates to:
  /// **'Artículo borrado'**
  String get articleDeletedToast;

  /// No description provided for @navFeed.
  ///
  /// In es, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navMyArticles.
  ///
  /// In es, this message translates to:
  /// **'Mis artículos'**
  String get navMyArticles;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @savedArticlesTitle.
  ///
  /// In es, this message translates to:
  /// **'Guardados'**
  String get savedArticlesTitle;

  /// No description provided for @savedArticlesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no guardaste ningún artículo.'**
  String get savedArticlesEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
