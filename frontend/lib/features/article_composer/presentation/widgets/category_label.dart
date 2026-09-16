import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/article_category.dart';

/// Localized display label for an [ArticleCategory].
String categoryLabel(AppLocalizations l10n, ArticleCategory category) {
  switch (category) {
    case ArticleCategory.general:
      return l10n.categoryGeneral;
    case ArticleCategory.business:
      return l10n.categoryBusiness;
    case ArticleCategory.entertainment:
      return l10n.categoryEntertainment;
    case ArticleCategory.health:
      return l10n.categoryHealth;
    case ArticleCategory.science:
      return l10n.categoryScience;
    case ArticleCategory.sports:
      return l10n.categorySports;
    case ArticleCategory.technology:
      return l10n.categoryTechnology;
    case ArticleCategory.politics:
      return l10n.categoryPolitics;
  }
}
