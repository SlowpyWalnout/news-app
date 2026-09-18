import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/app_shell_controller.dart';
import '../../../../../shared/article_changes_notifier.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../../../../shared/widgets/settings_row.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth/auth_event.dart';
import '../../../../daily_news/presentation/screens/read_later/read_later_screen.dart';
import '../../../../moderation/presentation/screens/review_queue/review_queue_screen.dart';
import '../../../../moderation/presentation/staff_gate.dart';
import '../../bloc/my_articles/my_articles_bloc.dart';
import '../../bloc/my_articles/my_articles_event.dart';
import '../../bloc/my_articles/my_articles_state.dart';
import '../article_editor/article_editor_screen.dart';
import '../settings/settings_screen.dart';

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

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _articleChanges = sl<ArticleChangesNotifier>();
  late int _lastSeenRevision = _articleChanges.revision;
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    _articleChanges.addListener(_onArticlesChanged);
    sl<StaffGate>().isStaff.then((value) {
      if (mounted) setState(() => _isStaff = value);
    });
  }

  @override
  void dispose() {
    _articleChanges.removeListener(_onArticlesChanged);
    super.dispose();
  }

  void _onArticlesChanged() {
    if (!mounted) return;
    final revision = _articleChanges.revision;
    if (revision == _lastSeenRevision) return;
    _lastSeenRevision = revision;
    final bloc = context.read<MyArticlesBloc>();
    if (bloc.isClosed) return;
    final authorId = context.read<AuthBloc>().state.user?.uid ?? '';
    bloc.add(MyArticlesRequested(authorId));
  }

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
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final user = context.watch<AuthBloc>().state.user;

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
                        Text(user?.displayName ?? '', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fH)),
                        Text(user?.email ?? '', style: TextStyle(fontSize: dims.fSm, color: palette.ink2)),
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
              SettingsRow(
                label: l10n.myArticlesRow,
                leading: Icons.article_outlined,
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () => sl<AppShellController>().goToTab(1),
              ),
              const SizedBox(height: 11),
              SettingsRow(
                label: l10n.writeArticleRow,
                leading: Icons.edit_outlined,
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ArticleEditorScreen())),
              ),
              const SizedBox(height: 11),
              SettingsRow(
                label: l10n.readLaterRow,
                leading: Icons.bookmark_border,
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReadLaterScreen())),
              ),
              if (_isStaff) ...[
                const SizedBox(height: 11),
                SettingsRow(
                  label: l10n.staffReviewRow,
                  leading: Icons.shield_outlined,
                  trailing: const Icon(Icons.arrow_forward, size: 18),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReviewQueueScreen())),
                ),
              ],
              const SizedBox(height: 11),
              SettingsRow(
                label: l10n.settingsRow,
                leading: Icons.settings_outlined,
                trailing: const Icon(Icons.arrow_forward, size: 18),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              const SizedBox(height: 19),
              SettingsRow(
                label: l10n.logOut,
                leading: Icons.logout,
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
    final dims = Theme.of(context).extension<AppDimensions>()!;

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
            style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w700, fontSize: dims.fH, color: filled ? scheme.onPrimary : scheme.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fXs, color: filled ? scheme.onPrimary : palette.ink2),
          ),
        ],
      ),
    );
  }
}
