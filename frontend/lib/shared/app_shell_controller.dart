import 'package:flutter/foundation.dart';

/// Cross-screen signal for routes pushed on top of [AppShell] (editor,
/// article detail, profile) that need to hand control back to it.
///
/// [AppShell] keeps every tab's bloc alive in an `IndexedStack`, so a route
/// pushed on top of it (e.g. the article editor) can't just navigate to a
/// fresh, standalone copy of a tab screen after a save — that both loses the
/// bottom nav bar (the fresh screen isn't hosted by the shell) and leaves
/// the shell's own "My articles" bloc unaware anything changed. This lets
/// that route ask the shell to switch tab and refresh instead.
class AppShellController extends ChangeNotifier {
  int? _pendingTabIndex;
  int _myArticlesRefreshTick = 0;
  String? _myArticlesSubTab;

  int get myArticlesRefreshTick => _myArticlesRefreshTick;

  int? consumePendingTabIndex() {
    final index = _pendingTabIndex;
    _pendingTabIndex = null;
    return index;
  }

  String? consumeMyArticlesSubTab() {
    final tab = _myArticlesSubTab;
    _myArticlesSubTab = null;
    return tab;
  }

  /// [subTab] is one of 'all' / 'drafts' / 'published', the same values
  /// `MyArticlesScreen.initialTab` already accepts.
  void notifyMyArticlesChanged({required int tabIndex, String? subTab}) {
    _pendingTabIndex = tabIndex;
    _myArticlesSubTab = subTab;
    _myArticlesRefreshTick++;
    notifyListeners();
  }
}
