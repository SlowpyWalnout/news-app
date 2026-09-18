import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/presentation/screens/legal_document_screen.dart';
import 'package:news_app/shared/widgets/markdown_text.dart';

import '../../helpers/helpers.dart';

// Regression: Localizations.localeOf(context) was read from initState(),
// which throws ("dependOnInheritedWidgetOfExactType... called before
// initState() completed") the instant the screen mounts — reported by José
// as the app freezing when tapping "Privacy policy" in Profile. Covers both
// documents LegalDocumentScreen serves.
void main() {
  for (final doc in ['privacy', 'terms']) {
    testWidgets('opening LegalDocumentScreen($doc) does not throw and renders content', (tester) async {
      await tester.pumpApp(
        LegalDocumentScreen(assetBaseName: doc, title: 'Title', errorMessage: 'Error'),
        centerInScaffold: false,
      );

      expect(tester.takeException(), isNull);

      for (var i = 0; i < 10 && find.byType(MarkdownText).evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
      }

      expect(find.byType(MarkdownText), findsOneWidget);
    });
  }
}
