import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_bottom_sheet.dart';
import 'app_buttons.dart';

/// Bottom sheet asking for delete confirmation. Returns `true` if the user
/// confirmed, `false`/`null` otherwise.
Future<bool?> showConfirmDeleteSheet(BuildContext context, {required String articleTitle}) {
  return showAppBottomSheet<bool>(
    context,
    builder: (sheetContext) => _ConfirmDeleteSheet(articleTitle: articleTitle),
  );
}

class _ConfirmDeleteSheet extends StatelessWidget {
  const _ConfirmDeleteSheet({required this.articleTitle});

  final String articleTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBottomSheetCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(title: l10n.confirmDeleteTitle, body: l10n.confirmDeleteBody(articleTitle)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: DestructiveButton(
              label: l10n.confirmDeleteYes,
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
          const SizedBox(height: 11),
          SecondaryButton(
            label: l10n.confirmDeleteNo,
            icon: const Icon(Icons.close, size: 18),
            expand: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
