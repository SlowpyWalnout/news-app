import 'package:flutter/foundation.dart';

/// Cross-screen signal that an authored article was published or saved as a
/// draft, so the Feed, "My articles" and Profile tabs (each with its own
/// live bloc, see [AppShellController]) know to reload.
///
/// [lastSubTab] is a plain getter, not consume-once: several listeners read
/// it after the same [notifyArticleSaved] call, and an earlier consume-once
/// version of this signal (folded into `AppShellController`) let an
/// unrelated `goToTab()` swallow a pending sub-tab before "My articles" ever
/// saw it.
class ArticleChangesNotifier extends ChangeNotifier {
  int _revision = 0;
  String? _lastSubTab;

  int get revision => _revision;

  /// One of 'drafts' / 'published', or null when the save didn't pick a
  /// specific sub-tab to land on.
  String? get lastSubTab => _lastSubTab;

  void notifyArticleSaved({String? subTab}) {
    _lastSubTab = subTab;
    _revision++;
    notifyListeners();
  }
}
