import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/config/theme/app_colors.dart';
import 'package:news_app/config/theme/app_themes.dart';
import 'package:news_app/l10n/app_localizations.dart';
import 'package:news_app/shared/presentation/screens/legal_document_screen.dart';
import 'package:news_app/shared/widgets/markdown_text.dart';

// Regression: Localizations.localeOf(context) was read from initState(),
// which throws ("dependOnInheritedWidgetOfExactType... called before
// initState() completed") the instant the screen mounts — reported by José
// as the app freezing when tapping "Privacy policy" in Profile. Covers both
// documents LegalDocumentScreen serves.
void main() {
  for (final doc in ['privacy', 'terms']) {
    testWidgets('opening LegalDocumentScreen($doc) does not throw and renders content', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: appTheme(brightness: Brightness.light, accent: AppAccent.lime, accessible: false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LegalDocumentScreen(assetBaseName: doc, title: 'Title', errorMessage: 'Error'),
      ));

      expect(tester.takeException(), isNull);

      for (var i = 0; i < 10 && find.byType(MarkdownText).evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
      }

      expect(find.byType(MarkdownText), findsOneWidget);
    });
  }
}
