import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';
import '../../l10n/app_localizations.dart';
import 'app_buttons.dart';

/// Bottom sheet asking for delete confirmation. Returns `true` if the user
/// confirmed, `false`/`null` otherwise.
Future<bool?> showConfirmDeleteSheet(BuildContext context, {required String articleTitle}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _ConfirmDeleteSheet(articleTitle: articleTitle),
  );
}

class _ConfirmDeleteSheet extends StatelessWidget {
  const _ConfirmDeleteSheet({required this.articleTitle});

  final String articleTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: palette.edge, width: dims.borderWidth),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.confirmDeleteTitle,
              style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fLg),
            ),
            const SizedBox(height: 11),
            Text(
              l10n.confirmDeleteBody(articleTitle),
              style: TextStyle(fontSize: dims.fMd, height: 1.5, color: palette.ink2),
            ),
            const SizedBox(height: 20),
            DestructiveButton(
              label: l10n.confirmDeleteYes,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 11),
            SecondaryButton(
              label: l10n.confirmDeleteNo,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
