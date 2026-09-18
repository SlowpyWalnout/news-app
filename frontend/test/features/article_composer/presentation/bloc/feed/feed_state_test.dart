import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/article_composer/presentation/bloc/feed/feed_state.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('FeedState.visibleArticles — language priority', () {
    test('with no preferredLang set, order is untouched', () {
      final state = FeedState(articles: [
        authoredArticle('1', lang: 'en'),
        authoredArticle('2', lang: 'es'),
        authoredArticle('3'), // community article, lang == null
      ]);

      expect(state.visibleArticles.map((a) => a.id), ['1', '2', '3']);
    });

    test('matching-language headlines float to the top without hiding the rest', () {
      final state = FeedState(
        preferredLang: 'es',
        articles: [
          authoredArticle('1', lang: 'en'),
          authoredArticle('2', lang: 'es'),
          authoredArticle('3'), // community
          authoredArticle('4', lang: 'es'),
        ],
      );

      final visible = state.visibleArticles;
      expect(visible.map((a) => a.id), ['2', '4', '1', '3']);
      expect(visible.length, 4); // nothing hidden
    });

    test('each group keeps its own relative (date) order', () {
      final state = FeedState(
        preferredLang: 'en',
        articles: [
          authoredArticle('1', lang: 'es'),
          authoredArticle('2'), // community
          authoredArticle('3', lang: 'en'),
          authoredArticle('4', lang: 'en'),
        ],
      );

      // 'en' group keeps 3 before 4; the rest keeps 1 before 2.
      expect(state.visibleArticles.map((a) => a.id), ['3', '4', '1', '2']);
    });

    test('community articles never change group relative to each other', () {
      final withoutPriority = FeedState(articles: [
        authoredArticle('1'),
        authoredArticle('2'),
      ]).visibleArticles;
      final withPriority = FeedState(
        preferredLang: 'es',
        articles: [
          authoredArticle('1'),
          authoredArticle('2'),
        ],
      ).visibleArticles;

      expect(withoutPriority.map((a) => a.id), withPriority.map((a) => a.id));
    });

    test('composes with the existing search-token filter', () {
      final state = FeedState(
        preferredLang: 'es',
        query: 'guia de flutter',
        articles: [
          authoredArticle('1', lang: 'en', searchKeywords: ['flutter']),
          authoredArticle('2', lang: 'es', searchKeywords: ['flutter', 'guia']),
        ],
      );

      // 'flutter' matches both via array-contains server-side; 'guia' is the
      // residual client-side filter — only article 2 has it.
      expect(state.visibleArticles.map((a) => a.id), ['2']);
    });
  });
}
