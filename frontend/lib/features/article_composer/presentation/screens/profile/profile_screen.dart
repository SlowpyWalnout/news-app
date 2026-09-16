import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/settings/presentation/cubit/settings_cubit.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth/auth_event.dart';
import '../../../../daily_news/presentation/screens/saved_article/saved_article.dart';
import '../../bloc/my_articles/my_articles_bloc.dart';
import '../../bloc/my_articles/my_articles_event.dart';
import '../../bloc/my_articles/my_articles_state.dart';
import '../article_editor/article_editor_screen.dart';
import '../my_articles/my_articles_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authorId = context.read<AuthBloc>().state.user?.uid ?? '';
    return BlocProvider(
      create: (_) => sl<MyArticlesBloc>()..add(MyArticlesRequested(authorId)),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final user = context.watch<AuthBloc>().state.user;
    final settings = context.watch<SettingsCubit>().state;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialsAvatar(initials: _initials(user?.displayName ?? ''), size: 84, fontSize: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.displayName ?? '', style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: 28)),
                        Text(user?.email ?? '', style: TextStyle(fontSize: 15, color: palette.ink2)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BlocBuilder<MyArticlesBloc, MyArticlesState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          value: state.publishedCount,
                          label: l10n.publishedStatLabel,
                          filled: true,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: _StatTile(
                          value: state.draftsCount,
                          label: l10n.draftsStatLabel,
                          filled: false,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              _SettingsRow(
                label: l10n.myArticlesRow,
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyArticlesScreen())),
              ),
              const SizedBox(height: 11),
              _SettingsRow(
                label: l10n.writeArticleRow,
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ArticleEditorScreen())),
              ),
              const SizedBox(height: 11),
              _SettingsRow(
                label: l10n.savedArticlesRow,
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedArticles())),
              ),
              const SizedBox(height: 11),
              _SettingsRow(
                label: l10n.appearanceRow,
                trailingText: settings.themeMode == ThemeMode.dark ? l10n.themeDark : l10n.themeLight,
                onTap: () => context.read<SettingsCubit>().toggleTheme(),
              ),
              const SizedBox(height: 11),
              _SettingsRow(
                label: l10n.accessibleModeRow,
                trailingText: settings.accessible ? l10n.on : l10n.off,
                onTap: () => context.read<SettingsCubit>().toggleAccessible(),
              ),
              const SizedBox(height: 11),
              _SettingsRow(
                label: l10n.languageRow,
                trailingText: settings.locale.languageCode == 'es' ? l10n.languageSpanish : l10n.languageEnglish,
                onTap: () => context.read<SettingsCubit>().toggleLocale(),
              ),
              const SizedBox(height: 19),
              _SettingsRow(
                label: l10n.logOut,
                isDestructive: true,
                onTap: () {
                  context.read<AuthBloc>().add(const AuthSignedOut());
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.filled});

  final int value;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: filled ? scheme.primary : scheme.surface,
        border: filled ? null : Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w700, fontSize: 30, color: filled ? scheme.onPrimary : scheme.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: filled ? scheme.onPrimary : palette.ink2),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.onTap,
    this.trailing,
    this.trailingText,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? trailingText;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final color = isDestructive ? scheme.error : scheme.onSurface;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: scheme.surface,
          foregroundColor: color,
          side: BorderSide(color: isDestructive ? scheme.error : palette.line, width: isDestructive ? 2.5 : 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17.5)),
            if (trailingText != null)
              Text(trailingText!, style: TextStyle(fontWeight: FontWeight.w500, color: palette.ink2))
            else if (trailing != null)
              trailing!,
          ],
        ),
      ),
    );
  }
}
