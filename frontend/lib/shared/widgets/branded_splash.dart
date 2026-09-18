import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'app_wordmark.dart';

/// Full-screen branded splash — same background color as the native launch
/// splash (`flutter_native_splash` config, ROADMAP.md Fase 7) with the app
/// wordmark fading in. Used for brief, deliberate transitions (signing out,
/// publishing an article) instead of an abrupt cut between screens.
/// `TweenAnimationBuilder` (not an `AnimationController`) is enough here —
/// the fade plays once on mount and never needs to reverse or replay.
class BrandedSplash extends StatelessWidget {
  const BrandedSplash({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.stageDark : AppColors.stageLight,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: AppWordmark(text: l10n.appWordmark),
        ),
      ),
    );
  }
}
