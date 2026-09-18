import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';

/// Pagination footer shared by Feed and "Mis artículos": a spinner while a
/// page is loading, an outlined "cargar más" button otherwise, or nothing
/// once the list has no more pages.
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({
    super.key,
    required this.hasMore,
    required this.isLoadingMore,
    required this.label,
    required this.onPressed,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) return const SizedBox.shrink();
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Center(
        child: isLoadingMore
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  side: BorderSide(color: palette.edge),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
      ),
    );
  }
}
