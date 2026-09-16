import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';
import 'app_buttons.dart';

/// Full-width card for empty states: accent icon block, title, body and a
/// primary CTA.
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.onCtaPressed,
    this.icon = Icons.article_outlined,
  });

  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback onCtaPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: palette.line, width: dims.borderWidth),
        borderRadius: BorderRadius.circular(AppRadii.r22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(AppRadii.r14)),
            child: Icon(icon, color: scheme.onPrimary),
          ),
          const SizedBox(height: 18),
          Text(title, style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fLg)),
          const SizedBox(height: 10),
          Text(body, style: TextStyle(fontSize: dims.fMd, height: 1.5, color: palette.ink2)),
          const SizedBox(height: 20),
          PrimaryButton(label: ctaLabel, onPressed: onCtaPressed),
        ],
      ),
    );
  }
}

/// Full-width card for network-error states: danger icon block, title, body
/// and a dark "Reintentar" CTA.
class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({
    super.key,
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.onRetryPressed,
  });

  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(
        color: palette.dangerSoft,
        border: Border.all(color: scheme.error, width: 2.5),
        borderRadius: BorderRadius.circular(AppRadii.r22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: scheme.error, borderRadius: BorderRadius.circular(AppRadii.r14)),
            child: const Icon(Icons.cloud_off, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(title, style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fLg)),
          const SizedBox(height: 10),
          Text(body, style: TextStyle(fontSize: dims.fMd, height: 1.5, color: palette.ink2)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: dims.tap,
            child: ElevatedButton(
              onPressed: onRetryPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.onSurface,
                foregroundColor: scheme.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r15)),
              ),
              child: Text(retryLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
