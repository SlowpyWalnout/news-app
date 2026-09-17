import 'package:flutter/material.dart';
import 'package:news_app/config/theme/app_dimensions.dart';
import 'package:news_app/config/theme/app_palette.dart';
import 'package:news_app/features/moderation/domain/entities/report_reason.dart';
import 'package:news_app/l10n/app_localizations.dart';
import 'package:news_app/shared/widgets/app_buttons.dart';
import 'package:news_app/shared/widgets/app_text_field.dart';

/// Devuelve el motivo elegido (y nota opcional) si el usuario envía el
/// reporte, `null` si cancela. Modelado sobre confirm_delete_sheet.dart.
Future<(ReportReason, String?)?> showReportSheet(BuildContext context) {
  return showModalBottomSheet<(ReportReason, String?)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _ReportSheet(),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet();

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason _reason = ReportReason.sexual;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _reasonLabel(AppLocalizations l10n, ReportReason reason) {
    switch (reason) {
      case ReportReason.sexual:
        return l10n.reportReasonSexual;
      case ReportReason.violence:
        return l10n.reportReasonViolence;
      case ReportReason.hate:
        return l10n.reportReasonHate;
      case ReportReason.spam:
        return l10n.reportReasonSpam;
      case ReportReason.misinformation:
        return l10n.reportReasonMisinformation;
      case ReportReason.other:
        return l10n.reportReasonOther;
    }
  }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reportSheetTitle,
                style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fLg),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.reportSheetBody,
                style: TextStyle(fontSize: dims.fSm, height: 1.5, color: palette.ink2),
              ),
              const SizedBox(height: 12),
              RadioGroup<ReportReason>(
                groupValue: _reason,
                onChanged: (value) => setState(() => _reason = value!),
                child: Column(
                  children: ReportReason.values
                      .map(
                        (reason) => RadioListTile<ReportReason>(
                          value: reason,
                          title: Text(_reasonLabel(l10n, reason), style: TextStyle(fontSize: dims.fMd)),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: l10n.reportNoteLabel,
                controller: _noteController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: l10n.reportSubmit,
                  onPressed: () => Navigator.of(context).pop((_reason, _noteController.text.trim())),
                ),
              ),
              const SizedBox(height: 11),
              SecondaryButton(
                label: l10n.reportCancel,
                icon: const Icon(Icons.close, size: 18),
                expand: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
