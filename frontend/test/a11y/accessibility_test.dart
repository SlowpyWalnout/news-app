import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/config/theme/app_colors.dart';
import 'package:news_app/config/theme/app_themes.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/presentation/screens/article_editor/markdown_toolbar.dart';
import 'package:news_app/features/article_composer/presentation/widgets/compact_article_card.dart';
import 'package:news_app/features/article_composer/presentation/widgets/featured_article_card.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app/l10n/app_localizations.dart';
import 'package:news_app/shared/widgets/app_buttons.dart';
import 'package:news_app/shared/widgets/category_chip.dart';
import 'package:news_app/shared/widgets/segmented_tabs.dart';

// Fase 7 — cierre de accesibilidad. No hay tests de widgets previos en el
// repo (ver deuda de Fase 5: bloc_test/mocktail no instalables); estos son
// los primeros, sobre widgets aislados en vez de pantallas completas, para
// no tener que levantar get_it. meetsGuideline() checa la geometría/semántica
// real renderizada, no una aproximación.
Widget _wrap(Widget child, {bool dark = false}) {
  return MaterialApp(
    theme: appTheme(brightness: Brightness.light, accent: AppAccent.lime, accessible: false),
    darkTheme: appTheme(brightness: Brightness.dark, accent: AppAccent.lime, accessible: false),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

final _article = AuthoredArticleEntity(
  id: 'a1',
  authorId: 'u1',
  authorName: 'Jane Doe',
  title: 'A real headline about the neighborhood',
  body: 'Body text.',
  status: ArticleStatus.published,
  category: ArticleCategory.general,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  publishedAt: DateTime(2026, 1, 1),
);

const _readLaterArticle = ArticleEntity(
  id: 1,
  title: 'A read-later headline',
  description: 'Description text.',
  publishedAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  group('tap targets + labels', () {
    testWidgets('CompactArticleCard', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(CompactArticleCard(article: _article, onTap: () {})));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('FeaturedArticleCard', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(SizedBox(height: 330, child: FeaturedArticleCard(article: _article, onTap: () {}))));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('ArticleWidget (read later tile) — main tap + remove button', (tester) async {
      final handle = tester.ensureSemantics();
      // No outer SizedBox: the widget sizes its image off
      // MediaQuery.of(context).size.width directly (see article_tile.dart),
      // so it needs the test viewport's actual width, not a local constraint.
      await tester.pumpWidget(_wrap(ArticleWidget(article: _readLaterArticle, onArticlePressed: (_) {}, isRemovable: true, onRemove: (_) {})));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('CategoryChip', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(CategoryChip(label: 'General', active: false, onTap: () {})));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('SegmentedTabs', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(SizedBox(
        width: 320,
        child: SegmentedTabs(
          items: const [SegmentedTabItem(label: 'Todas', value: 'all'), SegmentedTabItem(label: 'Borradores', value: 'drafts')],
          selected: 'all',
          onSelected: (_) {},
        ),
      )));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('MarkdownToolbar buttons', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = TextEditingController();
      final focusNode = FocusNode();
      await tester.pumpWidget(_wrap(MarkdownToolbar(controller: controller, focusNode: focusNode, onChanged: (_) {})));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
      focusNode.dispose();
      controller.dispose();
    });
  });

  group('color contrast — solid-background controls', () {
    testWidgets('PrimaryButton / SecondaryButton / DestructiveButton — light', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(label: 'Publicar', onPressed: () {}),
          SecondaryButton(label: 'Editar', onPressed: () {}),
          DestructiveButton(label: 'Borrar', onPressed: () {}),
        ],
      )));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('PrimaryButton / SecondaryButton / DestructiveButton — dark', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(label: 'Publicar', onPressed: () {}),
            SecondaryButton(label: 'Editar', onPressed: () {}),
            DestructiveButton(label: 'Borrar', onPressed: () {}),
          ],
        ),
        dark: true,
      ));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
