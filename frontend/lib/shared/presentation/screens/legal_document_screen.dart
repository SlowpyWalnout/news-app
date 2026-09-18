import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../l10n/app_localizations.dart';
import '../../widgets/markdown_text.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/skeleton_block.dart';
import '../../widgets/state_cards.dart';

/// Renders assets/legal/{assetBaseName}_{es,en}.md (same content published
/// at docs/, e.g. PRIVACY_POLICY.md / TERMS_OF_SERVICE.md) through the
/// closed Markdown subset MarkdownText already supports for article bodies
/// — no new dependency, no url_launcher. Shared by the privacy policy and
/// terms of service screens; the two differ only in which asset/title/error
/// string they use.
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.assetBaseName,
    required this.title,
    required this.errorMessage,
  });

  final String assetBaseName;
  final String title;
  final String errorMessage;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late Future<String> _content;
  bool _requested = false;

  // Localizations.localeOf(context) reads an InheritedWidget — calling it
  // from initState() throws ("dependOnInheritedWidgetOfExactType... called
  // before initState() completed"), since dependencies aren't wired up yet
  // at that point. didChangeDependencies() is the first safe place; the
  // _requested guard keeps it from re-triggering on every later dependency
  // change (e.g. toggling the app's language while this screen is open).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      _content = _load();
    }
  }

  Future<String> _load() {
    final locale = Localizations.localeOf(context).languageCode == 'es' ? 'es' : 'en';
    // Timeout as a safety net, not the fix for any particular bug: it just
    // keeps a stuck asset resolution from reading as a frozen screen —
    // it falls back to the error state instead.
    return rootBundle.loadString('assets/legal/${widget.assetBaseName}_$locale.md').timeout(const Duration(seconds: 6));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: widget.title),
            Expanded(
              child: FutureBuilder<String>(
                future: _content,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                      child: Column(
                        children: [
                          SkeletonBlock(height: 28, borderRadius: 8),
                          SizedBox(height: 16),
                          SkeletonBlock(height: 120, borderRadius: 18),
                        ],
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      child: ErrorStateCard(
                        title: widget.title,
                        body: widget.errorMessage,
                        retryLabel: l10n.retry,
                        onRetryPressed: () => setState(() => _content = _load()),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: MarkdownText(snapshot.data!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
