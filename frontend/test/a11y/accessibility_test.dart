import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/article_composer/presentation/screens/article_editor/markdown_toolbar.dart';
import 'package:news_app/features/article_composer/presentation/widgets/compact_article_card.dart';
import 'package:news_app/features/article_composer/presentation/widgets/featured_article_card.dart';
import 'package:news_app/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app/shared/widgets/app_buttons.dart';
import 'package:news_app/shared/widgets/category_chip.dart';
import 'package:news_app/shared/widgets/segmented_tabs.dart';

import '../helpers/helpers.dart';

// Fase 7 — cierre de accesibilidad, sobre widgets aislados en vez de
// pantallas completas para no tener que levantar get_it. meetsGuideline()
// checa la geometría/semántica real renderizada, no una aproximación.
final _article = authoredArticle(
  'a1',
  authorId: 'u1',
  authorName: 'Jane Doe',
  title: 'A real headline about the neighborhood',
  body: 'Body text.',
);

final _readLaterArticle = readLaterArticle(title: 'A read-later headline', description: 'Description text.');

void main() {
  group('tap targets + labels', () {
    testWidgets('CompactArticleCard', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(CompactArticleCard(article: _article, onTap: () {}));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('FeaturedArticleCard', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(SizedBox(height: 330, child: FeaturedArticleCard(article: _article, onTap: () {})));
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
      await tester.pumpApp(ArticleWidget(article: _readLaterArticle, onArticlePressed: (_) {}, isRemovable: true, onRemove: (_) {}));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('CategoryChip', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(CategoryChip(label: 'General', active: false, onTap: () {}));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('SegmentedTabs', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(SizedBox(
        width: 320,
        child: SegmentedTabs(
          items: const [SegmentedTabItem(label: 'Todas', value: 'all'), SegmentedTabItem(label: 'Borradores', value: 'drafts')],
          selected: 'all',
          onSelected: (_) {},
        ),
      ));
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
      await tester.pumpApp(MarkdownToolbar(controller: controller, focusNode: focusNode, onChanged: (_) {}));
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
      await tester.pumpApp(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(label: 'Publicar', onPressed: () {}),
          SecondaryButton(label: 'Editar', onPressed: () {}),
          DestructiveButton(label: 'Borrar', onPressed: () {}),
        ],
      ));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('PrimaryButton / SecondaryButton / DestructiveButton — dark', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(label: 'Publicar', onPressed: () {}),
            SecondaryButton(label: 'Editar', onPressed: () {}),
            DestructiveButton(label: 'Borrar', onPressed: () {}),
          ],
        ),
        dark: true,
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
