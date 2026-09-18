import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:news_app/l10n/app_localizations_es.dart';
import 'package:news_app/shared/utils/article_byline.dart';

void main() {
  final l10n = AppLocalizationsEs();

  setUpAll(() => initializeDateFormatting('es'));

  test('with a publishedAt, combines the formatted date and the read-time label', () {
    final result = articleByline(l10n, publishedAt: DateTime(2026, 3, 4), body: 'palabra ' * 100);

    expect(result.contains('·'), isTrue);
    expect(result.toLowerCase().contains('mar'), isTrue);
  });

  test('without a publishedAt, returns only the read-time label', () {
    final result = articleByline(l10n, publishedAt: null, body: 'palabra ' * 100);

    expect(result.contains('·'), isFalse);
    expect(result, l10n.readTimeMinutes(1));
  });
}
