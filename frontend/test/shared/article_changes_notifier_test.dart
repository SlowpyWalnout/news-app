import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/article_changes_notifier.dart';

void main() {
  group('ArticleChangesNotifier', () {
    test('notifyArticleSaved sube revision, guarda subTab y notifica', () {
      final notifier = ArticleChangesNotifier();
      var notified = 0;
      notifier.addListener(() => notified++);

      notifier.notifyArticleSaved(subTab: 'published');

      expect(notifier.revision, 1);
      expect(notifier.lastSubTab, 'published');
      expect(notified, 1);
    });

    test('lastSubTab sigue legible tras varias lecturas (no es consume-once)', () {
      final notifier = ArticleChangesNotifier();
      notifier.notifyArticleSaved(subTab: 'drafts');

      expect(notifier.lastSubTab, 'drafts');
      expect(notifier.lastSubTab, 'drafts');
      expect(notifier.revision, 1);
    });

    test('una llamada sin subTab lo deja en null', () {
      final notifier = ArticleChangesNotifier();
      notifier.notifyArticleSaved(subTab: 'published');
      notifier.notifyArticleSaved();

      expect(notifier.revision, 2);
      expect(notifier.lastSubTab, isNull);
    });
  });
}
