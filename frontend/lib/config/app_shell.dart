import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../features/article_composer/presentation/screens/article_editor/article_editor_screen.dart';
import '../features/article_composer/presentation/screens/feed/feed_screen.dart';
import '../features/article_composer/presentation/screens/my_articles/my_articles_screen.dart';
import '../features/article_composer/presentation/screens/profile/profile_screen.dart';

/// Hosts the three bottom-nav tabs (Feed / Mis artículos / Perfil) plus the
/// "Nuevo artículo" FAB, which is only shown on the first two tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = 0});

  static const routeName = '/Home';

  final int initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialTab;

  static const _tabs = [
    FeedScreen(),
    MyArticlesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showFab = _index == 0 || _index == 1;

    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ArticleEditorScreen()),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.newArticleTitle, style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w700)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.article_outlined), selectedIcon: const Icon(Icons.article), label: l10n.navFeed),
          NavigationDestination(icon: const Icon(Icons.edit_note_outlined), selectedIcon: const Icon(Icons.edit_note), label: l10n.navMyArticles),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: l10n.navProfile),
        ],
      ),
    );
  }
}
