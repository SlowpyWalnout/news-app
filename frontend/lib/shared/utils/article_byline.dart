import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'reading_time.dart';

/// "Mar 4 · 3 min" (or just "3 min" when there's no publish date yet) — the
/// byline shown under an article's title on Detail and the compact feed
/// card.
String articleByline(AppLocalizations l10n, {required DateTime? publishedAt, required String body}) {
  final dateLabel = publishedAt != null ? DateFormat.MMMd(l10n.localeName).format(publishedAt) : '';
  final readLabel = l10n.readTimeMinutes(estimateReadingMinutes(body));
  return dateLabel.isEmpty ? readLabel : '$dateLabel · $readLabel';
}
