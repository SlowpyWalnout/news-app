import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/article_composer/domain/entities/article_source.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('AuthoredArticleEntity.toFeedArticle', () {
    test('a community article keeps its content and no url', () {
      final article = authoredArticle('a1', body: 'Cuerpo completo del artículo.');

      final feedArticle = article.toFeedArticle();

      expect(feedArticle.content, 'Cuerpo completo del artículo.');
      expect(feedArticle.url, isNull);
    });

    test('an external headline never caches content, only carries the source url', () {
      final article = authoredArticle(
        'h1',
        source: ArticleSource.guardian,
        sourceUrl: 'https://www.theguardian.com/some-article',
        body: 'Cuerpo que The Guardian no permite conservar más de 24h.',
      );

      final feedArticle = article.toFeedArticle();

      expect(feedArticle.content, isNull);
      expect(feedArticle.url, 'https://www.theguardian.com/some-article');
    });
  });

  group('AuthoredArticleEntity.isExternal', () {
    test('is false when source is null', () {
      expect(authoredArticle('a1').isExternal, isFalse);
    });

    test('is true when source is set', () {
      expect(authoredArticle('h1', source: ArticleSource.gnews).isExternal, isTrue);
    });
  });
}
