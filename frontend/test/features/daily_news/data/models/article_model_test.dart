import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/daily_news/data/models/article.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';

void main() {
  test('fromEntity copies every field, isRead defaults to false', () {
    const entity = ArticleEntity(
      id: 7,
      sourceId: 'src-1',
      author: 'Autor',
      title: 'Título',
      description: 'Desc',
      url: 'https://x',
      urlToImage: 'https://x/y.jpg',
      publishedAt: '2026-01-01T00:00:00.000Z',
      content: 'Contenido',
    );

    final model = ArticleModel.fromEntity(entity);

    expect(model.id, 7);
    expect(model.sourceId, 'src-1');
    expect(model.author, 'Autor');
    expect(model.title, 'Título');
    expect(model.description, 'Desc');
    expect(model.url, 'https://x');
    expect(model.urlToImage, 'https://x/y.jpg');
    expect(model.publishedAt, '2026-01-01T00:00:00.000Z');
    expect(model.content, 'Contenido');
    expect(model.isRead, isFalse);
  });

  test('fromEntity preserves a null id', () {
    const entity = ArticleEntity(sourceId: 'src-1', title: 'Título');

    final model = ArticleModel.fromEntity(entity);

    expect(model.id, isNull);
  });

  test('fromEntity preserves isRead: true', () {
    const entity = ArticleEntity(id: 1, title: 'Título', isRead: true);

    final model = ArticleModel.fromEntity(entity);

    expect(model.isRead, isTrue);
  });
}
