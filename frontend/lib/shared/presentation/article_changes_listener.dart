import 'package:flutter/widgets.dart';

import '../../injection_container.dart';
import '../article_changes_notifier.dart';

/// Subscribes a `State` to `ArticleChangesNotifier` for the screen's
/// lifetime, de-duplicating by revision so the same save doesn't trigger
/// [onArticlesChanged] twice. Shared by Feed, "Mis artículos" and Perfil,
/// each of which only differs in what it does once notified.
mixin ArticleChangesListenerMixin<T extends StatefulWidget> on State<T> {
  final ArticleChangesNotifier _articleChanges = sl<ArticleChangesNotifier>();
  late int _lastSeenRevision = _articleChanges.revision;

  /// Called when a new revision arrives and this widget is still mounted.
  void onArticlesChanged(ArticleChangesNotifier notifier);

  @override
  void initState() {
    super.initState();
    _articleChanges.addListener(_handleChange);
  }

  @override
  void dispose() {
    _articleChanges.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (!mounted) return;
    final revision = _articleChanges.revision;
    if (revision == _lastSeenRevision) return;
    _lastSeenRevision = revision;
    onArticlesChanged(_articleChanges);
  }
}
