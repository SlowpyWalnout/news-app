import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/presentation/screens/legal_document_screen.dart';
import '../../../../../shared/settings/presentation/cubit/settings_cubit.dart';
import '../../../../../shared/widgets/screen_header.dart';
import '../../../../../shared/widgets/settings_row.dart';

/// Appearance, accessible mode, language, and the two legal documents —
/// split out of Profile so its own row list doesn't grow without bound.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsCubit>().state;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.settingsTitle),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsRow(
                      label: l10n.appearanceRow,
                      leading: Icons.palette_outlined,
                      trailingText: settings.themeMode == ThemeMode.dark ? l10n.themeDark : l10n.themeLight,
                      toggled: settings.themeMode == ThemeMode.dark,
                      onTap: () => context.read<SettingsCubit>().toggleTheme(),
                    ),
                    const SizedBox(height: 11),
                    SettingsRow(
                      label: l10n.accessibleModeRow,
                      leading: Icons.accessibility_new_outlined,
                      trailingText: settings.accessible ? l10n.on : l10n.off,
                      toggled: settings.accessible,
                      onTap: () => context.read<SettingsCubit>().toggleAccessible(),
                    ),
                    const SizedBox(height: 11),
                    SettingsRow(
                      label: l10n.languageRow,
                      leading: Icons.language_outlined,
                      trailingText: settings.locale.languageCode == 'es' ? l10n.languageSpanish : l10n.languageEnglish,
                      onTap: () => context.read<SettingsCubit>().toggleLocale(),
                    ),
                    const SizedBox(height: 11),
                    SettingsRow(
                      label: l10n.termsOfServiceRow,
                      leading: Icons.description_outlined,
                      trailing: const Icon(Icons.arrow_forward, size: 18),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => LegalDocumentScreen(
                          assetBaseName: 'terms',
                          title: l10n.termsOfServiceTitle,
                          errorMessage: l10n.termsOfServiceError,
                        ),
                      )),
                    ),
                    const SizedBox(height: 11),
                    SettingsRow(
                      label: l10n.privacyPolicyRow,
                      leading: Icons.privacy_tip_outlined,
                      trailing: const Icon(Icons.arrow_forward, size: 18),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => LegalDocumentScreen(
                          assetBaseName: 'privacy',
                          title: l10n.privacyPolicyTitle,
                          errorMessage: l10n.privacyPolicyError,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
