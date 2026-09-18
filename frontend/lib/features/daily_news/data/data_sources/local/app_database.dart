import 'package:sqflite/sqflite.dart';

import 'DAO/article_dao.dart';

/// Plain sqflite wrapper — replaced Floor (Fase 8) because its code
/// generator no longer runs against the current analyzer/SDK combo (see
/// ROADMAP.md); `app_database.g.dart` had been hand-edited to fake codegen
/// output since Fase 6c. This class does openly by hand what that file was
/// already doing in disguise, with no `floor`/`floor_generator` dependency.
class AppDatabase {
  AppDatabase._(this.articleDAO);

  final ArticleDao articleDAO;

  static Future<AppDatabase> open(String name) async {
    final path = await getDatabasesPath();
    final database = await openDatabase(
      '$path/$name',
      version: 3,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS `article` (`id` INTEGER, `sourceId` TEXT, `author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, `isRead` INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (`id`))',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE article ADD COLUMN sourceId TEXT');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE article ADD COLUMN isRead INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
    return AppDatabase._(ArticleDao(database));
  }
}
