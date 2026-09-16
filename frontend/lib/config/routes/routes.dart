import 'package:flutter/material.dart';

import '../../features/article_composer/domain/entities/authored_article_entity.dart';
import '../../features/article_composer/presentation/screens/article_detail/article_detail_screen.dart';
import '../../features/article_composer/presentation/screens/article_editor/article_editor_screen.dart';
import '../../features/article_composer/presentation/screens/my_articles/my_articles_screen.dart';
import '../../features/article_composer/presentation/screens/profile/profile_screen.dart';
import '../../features/auth/presentation/screens/login/login_screen.dart';
import '../../features/auth/presentation/screens/register/register_screen.dart';
import '../../features/daily_news/presentation/screens/read_later/read_later_screen.dart';
import '../app_shell.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case AppShell.routeName:
        return _materialRoute(const AppShell());

      case LoginScreen.routeName:
        return _materialRoute(const LoginScreen());

      case RegisterScreen.routeName:
        return _materialRoute(const RegisterScreen());

      case '/ArticleDetails':
        return _materialRoute(
          ArticleDetailScreen(article: settings.arguments as AuthoredArticleEntity),
        );

      case '/ArticleEditor':
        return _materialRoute(
          ArticleEditorScreen(article: settings.arguments as AuthoredArticleEntity?),
        );

      case '/MyArticles':
        return _materialRoute(const MyArticlesScreen());

      case '/Profile':
        return _materialRoute(const ProfileScreen());

      case '/ReadLater':
        return _materialRoute(const ReadLaterScreen());

      default:
        return _materialRoute(const AppShell());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
