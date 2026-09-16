import 'package:flutter/material.dart';

/// Shows a single toast at the bottom of the screen, mirroring the
/// prototype's dark pill toast (2400ms auto-dismiss, one at a time).
void showAppToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final scheme = Theme.of(context).colorScheme;
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 24,
      right: 24,
      bottom: 28,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: scheme.onSurface,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 28, offset: const Offset(0, 12)),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: scheme.surface),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 2400), () {
    if (entry.mounted) entry.remove();
  });
}
