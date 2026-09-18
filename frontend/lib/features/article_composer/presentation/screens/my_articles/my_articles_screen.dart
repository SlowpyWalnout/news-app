import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/article_changes_notifier.dart';
import '../../../../../shared/presentation/article_changes_listener.dart';
import '../../../../../shared/utils/bloc_refresh.dart';
import '../../../../../shared/widgets/blurred_sliver_header.dart';
import '../../../../../shared/widgets/segmented_tabs.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../bloc/my_articles/my_articles_bloc.dart';
import '../../bloc/my_articles/my_articles_event.dart';
import '../../bloc/my_articles/my_articles_state.dart';
import 'my_articles_body.dart';

class MyArticlesScreen extends StatelessWidget {
  const MyArticlesScreen({super.key, this.initialTab});

  /// One of 'all' / 'drafts' / 'published'. Used when arriving from a
  /// "Guardar borrador"/"Publicar" action so the right tab is pre-selected.
  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    final authorId = context.read<AuthBloc>().state.user?.uid ?? '';
    return BlocProvider(
      create: (_) {
        final bloc = sl<MyArticlesBloc>()..add(MyArticlesRequested(authorId));
        final tab = MyArticlesTab.fromSubTab(initialTab ?? sl<ArticleChangesNotifier>().lastSubTab);
        if (tab != null) bloc.add(MyArticlesTabChanged(tab));
        return bloc;
      },
      child: const _MyArticlesView(),
    );
  }
}

class _MyArticlesView extends StatefulWidget {
  const _MyArticlesView();

  @override
  State<_MyArticlesView> createState() => _MyArticlesViewState();
}

class _MyArticlesViewState extends State<_MyArticlesView>
    with AutomaticKeepAliveClientMixin, ArticleChangesListenerMixin<_MyArticlesView> {
  @override
  bool get wantKeepAlive => true;

  @override
  void onArticlesChanged(ArticleChangesNotifier notifier) {
    final bloc = context.read<MyArticlesBloc>();
    if (bloc.isClosed) return;
    final tab = MyArticlesTab.fromSubTab(notifier.lastSubTab);
    if (tab != null) bloc.add(MyArticlesTabChanged(tab));
    final authorId = context.read<AuthBloc>().state.user?.uid ?? '';
    bloc.add(MyArticlesRequested(authorId));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final dims = Theme.of(context).extension<AppDimensions>()!;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: context.palette.accentInk,
          onRefresh: () => refreshAndSettle(
            bloc: context.read<MyArticlesBloc>(),
            event: MyArticlesRefreshed(context.read<AuthBloc>().state.user?.uid ?? ''),
            isSettled: (s) => s.status != MyArticlesStatus.loading,
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              BlurredSliverHeader(
                preferredHeight: 14 + dims.fH * 1.3 + 14 + 58 + 12 + 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.myArticlesTitle,
                        style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fH)),
                    const SizedBox(height: 14),
                    BlocBuilder<MyArticlesBloc, MyArticlesState>(
                      buildWhen: (a, b) => a.tab != b.tab,
                      builder: (context, state) => SegmentedTabs(
                        items: [
                          SegmentedTabItem(label: l10n.tabAll, value: MyArticlesTab.all.name),
                          SegmentedTabItem(label: l10n.tabDrafts, value: MyArticlesTab.drafts.name),
                          SegmentedTabItem(label: l10n.tabPublished, value: MyArticlesTab.published.name),
                        ],
                        selected: state.tab.name,
                        onSelected: (v) => context
                            .read<MyArticlesBloc>()
                            .add(MyArticlesTabChanged(MyArticlesTab.values.byName(v))),
                      ),
                    ),
                  ],
                ),
              ),
              const MyArticlesBody(),
            ],
          ),
        ),
      ),
    );
  }
}
