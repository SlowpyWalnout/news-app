import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';
import '../../l10n/app_localizations.dart';
import '../presentation/screens/legal_document_screen.dart';

/// "By continuing, you agree to our Terms of Service and our Privacy
/// policy." with the two names as tappable links, shown on Login/Register.
/// A StatefulWidget (not a plain build-time RichText) because
/// TapGestureRecognizer must be disposed explicitly — building a fresh one
/// on every build() without disposing the old one leaks.
class LegalLinksNotice extends StatefulWidget {
  const LegalLinksNotice({super.key});

  @override
  State<LegalLinksNotice> createState() => _LegalLinksNoticeState();
}

class _LegalLinksNoticeState extends State<LegalLinksNotice> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = () => _open(assetBaseName: 'terms');
    _privacyRecognizer = TapGestureRecognizer()..onTap = () => _open(assetBaseName: 'privacy');
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _open({required String assetBaseName}) {
    final l10n = AppLocalizations.of(context)!;
    final isTerms = assetBaseName == 'terms';
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LegalDocumentScreen(
        assetBaseName: assetBaseName,
        title: isTerms ? l10n.termsOfServiceTitle : l10n.privacyPolicyTitle,
        errorMessage: isTerms ? l10n.termsOfServiceError : l10n.privacyPolicyError,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final baseStyle = TextStyle(fontSize: dims.fXs, height: 1.5, color: palette.ink2);
    final linkStyle = baseStyle.copyWith(fontWeight: FontWeight.w700, color: palette.accentInk);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: l10n.legalNoticePrefix),
          // Line break so "Términos y condiciones ... Política de privacidad"
          // stays together on its own line instead of splitting mid-phrase
          // wherever the prefix happens to run out of width.
          const TextSpan(text: '\n'),
          TextSpan(text: l10n.termsOfServiceRow, style: linkStyle, recognizer: _termsRecognizer),
          TextSpan(text: l10n.legalNoticeAnd),
          TextSpan(text: l10n.privacyPolicyRow, style: linkStyle, recognizer: _privacyRecognizer),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
