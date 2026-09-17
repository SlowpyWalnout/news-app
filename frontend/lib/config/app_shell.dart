import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../injection_container.dart';
import '../l10n/app_localizations.dart';
import '../features/article_composer/presentation/screens/article_editor/article_editor_screen.dart';
import '../features/article_composer/presentation/screens/feed/feed_screen.dart';
import '../features/article_composer/presentation/screens/my_articles/my_articles_screen.dart';
import '../features/article_composer/presentation/screens/profile/profile_screen.dart';
import '../shared/app_shell_controller.dart';
import '../shared/presentation/connectivity_cubit.dart';
import '../shared/widgets/inline_banner.dart';

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
  late final _pageController = PageController(initialPage: _index);
  final _shellController = sl<AppShellController>();

  static const _tabs = [
    FeedScreen(),
    MyArticlesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _shellController.addListener(_onShellControllerChanged);
  }

  @override
  void dispose() {
    _shellController.removeListener(_onShellControllerChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onShellControllerChanged() {
    final index = _shellController.consumePendingTabIndex();
    if (index != null && mounted) _goToIndex(index);
  }

  void _goToIndex(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showFab = _index == 0 || _index == 1;

    return Scaffold(
      body: Column(
        children: [
          BlocBuilder<ConnectivityCubit, bool>(
            builder: (context, online) {
              if (online) return const SizedBox.shrink();
              return SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: InlineBanner(
                    title: l10n.offlineBannerTitle,
                    body: l10n.offlineBannerBody,
                    variant: BannerVariant.warn,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _index = i),
              children: _tabs,
            ),
          ),
        ],
      ),
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
        onDestinationSelected: _goToIndex,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.article_outlined), selectedIcon: const Icon(Icons.article), label: l10n.navFeed),
          NavigationDestination(icon: const Icon(Icons.edit_note_outlined), selectedIcon: const Icon(Icons.edit_note), label: l10n.navMyArticles),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: l10n.navProfile),
        ],
      ),
    );
  }
}
