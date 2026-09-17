import 'package:flutter/foundation.dart';

/// Cross-screen signal for routes pushed on top of [AppShell] (editor,
/// article detail, profile) that need to hand control back to it.
///
/// [AppShell] keeps every tab's bloc alive via `AutomaticKeepAliveClientMixin`
/// on its `PageView` children, so a route pushed on top of it (e.g. the
/// article editor) can't just navigate to a
/// fresh, standalone copy of a tab screen after a save — that both loses the
/// bottom nav bar (the fresh screen isn't hosted by the shell) and leaves
/// the shell on whatever tab it was on. This lets that route ask the shell
/// to switch tab. Refreshing a tab's own bloc after a save is a separate
/// concern, handled by `ArticleChangesNotifier`.
class AppShellController extends ChangeNotifier {
  int? _pendingTabIndex;

  int? consumePendingTabIndex() {
    final index = _pendingTabIndex;
    _pendingTabIndex = null;
    return index;
  }

  void goToTab(int tabIndex) {
    _pendingTabIndex = tabIndex;
    notifyListeners();
  }
}
