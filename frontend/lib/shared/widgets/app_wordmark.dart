import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';

/// The "NEWS." wordmark, with the trailing dot in the accent color. Used on
/// Feed and Login.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, required this.text, this.letterSpacing = -0.8});

  final String text;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w700,
          fontSize: dims.fH,
          letterSpacing: letterSpacing,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: text),
          TextSpan(text: '.', style: TextStyle(color: palette.accentInk)),
        ],
      ),
    );
  }
}
