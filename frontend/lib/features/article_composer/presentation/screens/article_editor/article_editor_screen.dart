import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/widgets/app_buttons.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/app_toast.dart';
import '../../../../../shared/widgets/branded_splash.dart';
import '../../../../../shared/widgets/category_chip.dart';
import '../../widgets/dashed_border_box.dart';
import '../../../../../shared/widgets/inline_banner.dart';
import '../../../../../shared/widgets/markdown_text.dart';
import '../../../../../shared/widgets/screen_header.dart';
import '../../../../../shared/widgets/scrim_overlay.dart';
import '../../../../../shared/widgets/segmented_tabs.dart';
import '../../../../../shared/widgets/striped_image_placeholder.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../domain/entities/article_category.dart';
import '../../../domain/entities/authored_article_entity.dart';
import '../../bloc/article_editor/article_editor_bloc.dart';
import '../../bloc/article_editor/article_editor_event.dart';
import '../../bloc/article_editor/article_editor_state.dart';
import '../../../../../shared/app_shell_controller.dart';
import '../../../../../shared/article_changes_notifier.dart';
import '../../widgets/category_label.dart';
import 'markdown_editing_controller.dart';
import 'markdown_toolbar.dart';

class ArticleEditorScreen extends StatelessWidget {
  const ArticleEditorScreen({super.key, this.article});

  final AuthoredArticleEntity? article;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;
    return BlocProvider(
      create: (_) => sl<ArticleEditorBloc>()
        ..add(EditorStarted(
          authorId: user?.uid ?? '',
          authorName: user?.displayName ?? '',
          article: article,
        )),
      child: const _ArticleEditorView(),
    );
  }
}

class _ArticleEditorView extends StatefulWidget {
  const _ArticleEditorView();

  @override
  State<_ArticleEditorView> createState() => _ArticleEditorViewState();
}

enum _EditorAction { none, draft, publish }

class _ArticleEditorViewState extends State<_ArticleEditorView> {
  final TextEditingController _titleController = TextEditingController();
  final MarkdownEditingController _bodyController = MarkdownEditingController();
  final FocusNode _bodyFocusNode = FocusNode();
  String? _syncedArticleId;
  _EditorAction _lastAction = _EditorAction.none;
  String _bodyTab = 'write';

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  // Pushes the branded splash on top of the editor, holds it for a moment,
  // then pops everything back to the shell in one go — same deliberate-delay
  // pattern as the sign-out splash in AuthGate, so publishing feels like an
  // intentional beat instead of the toast+instant-pop it used to be. A
  // PageRouteBuilder with an explicit FadeTransition (not MaterialPageRoute)
  // so both the push in and the pop back out dissolve instead of cutting.
  void _showPublishedSplashThenReturn(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const BrandedSplash(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ));
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  Future<void> _pickCover(BuildContext context) async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null || !context.mounted) return;
    final size = await File(picked.path).length();
    if (!context.mounted) return;
    context
        .read<ArticleEditorBloc>()
        .add(EditorCoverPicked(picked.path, size, picked.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;

    return BlocConsumer<ArticleEditorBloc, ArticleEditorState>(
      listenWhen: (a, b) => a.submitStatus != b.submitStatus || a.articleId != b.articleId,
      listener: (context, state) {
        if (_syncedArticleId != state.articleId) {
          _titleController.text = state.title;
          _bodyController.text = state.body;
          _syncedArticleId = state.articleId;
        }
        if (state.submitStatus == EditorSubmitStatus.emptyDraftRejected) {
          showAppToast(context, l10n.emptyDraftToast);
        }
        if (state.submitStatus == EditorSubmitStatus.success) {
          final wasDraft = _lastAction == _EditorAction.draft;
          sl<ArticleChangesNotifier>().notifyArticleSaved(
            subTab: wasDraft ? 'drafts' : 'published',
          );
          sl<AppShellController>().goToTab(1);
          if (wasDraft) {
            showAppToast(context, l10n.draftSavedToast);
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            _showPublishedSplashThenReturn(context);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeader(title: state.isEditing ? l10n.editArticleTitle : l10n.newArticleTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: l10n.titleLabel,
                          controller: _titleController,
                          placeholder: l10n.titlePlaceholder,
                          maxLines: 2,
                          fontFamily: 'Space Grotesk',
                          errorText: state.titleError,
                          counterText: l10n.titleCounter(state.title.length),
                          onChanged: (v) => context
                              .read<ArticleEditorBloc>()
                              .add(EditorTitleChanged(v)),
                        ),
                        const SizedBox(height: 22),
                        Text(l10n.categoryLabel,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: dims.fSm)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final category in ArticleCategory.values)
                              CategoryChip(
                                label: categoryLabel(l10n, category),
                                icon: categoryIcon(category),
                                active: state.category == category,
                                onTap: () => context
                                    .read<ArticleEditorBloc>()
                                    .add(EditorCategorySelected(category)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(l10n.coverLabel,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: dims.fSm)),
                        const SizedBox(height: 10),
                        if (state.hasCover)
                          _CoverPreview(state: state)
                        else
                          SizedBox(
                            width: double.infinity,
                            height: dims.tap,
                            child: DashedBorderBox(
                              color: palette.edge,
                              radius: AppRadii.r15,
                              strokeWidth: 2.5,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.r15),
                                  onTap: () => _pickCover(context),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                      const SizedBox(width: 10),
                                      Text(
                                        l10n.chooseCoverImage,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (state.coverError != null) ...[
                          const SizedBox(height: 10),
                          InlineBanner(
                              title: '',
                              body: l10n.coverTooLarge(state.coverError!)),
                        ],
                        const SizedBox(height: 10),
                        Text(l10n.coverHint,
                            style: TextStyle(
                                fontSize: dims.fXs, color: palette.ink3)),
                        const SizedBox(height: 22),
                        Text(l10n.bodyLabel,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: dims.fSm)),
                        const SizedBox(height: 8),
                        SegmentedTabs(
                          items: [
                            SegmentedTabItem(label: l10n.writeTab, value: 'write'),
                            SegmentedTabItem(label: l10n.previewTab, value: 'preview'),
                          ],
                          selected: _bodyTab,
                          onSelected: (v) => setState(() => _bodyTab = v),
                        ),
                        const SizedBox(height: 10),
                        if (_bodyTab == 'write') ...[
                          MarkdownToolbar(
                            controller: _bodyController,
                            focusNode: _bodyFocusNode,
                            onChanged: (v) => context
                                .read<ArticleEditorBloc>()
                                .add(EditorBodyChanged(v)),
                          ),
                          const SizedBox(height: 10),
                          AppTextField(
                            controller: _bodyController,
                            focusNode: _bodyFocusNode,
                            placeholder: l10n.bodyPlaceholder,
                            maxLines: 9,
                            errorText: state.bodyError,
                            counterText:
                                l10n.bodyCounter(state.body.length.toString()),
                            onChanged: (v) => context
                                .read<ArticleEditorBloc>()
                                .add(EditorBodyChanged(v)),
                          ),
                        ] else
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: dims.tap * 2),
                            padding: const EdgeInsets.all(17),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadii.r15),
                              border: Border.all(color: palette.edge, width: dims.borderWidth),
                            ),
                            child: state.body.trim().isEmpty
                                ? Text(
                                    l10n.previewEmpty,
                                    style: TextStyle(fontSize: dims.fSm, color: palette.ink3),
                                  )
                                : MarkdownText(state.body),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: palette.line, width: 1.5))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.uploadProgress != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: state.uploadProgress! > 0
                                ? state.uploadProgress
                                : null,
                            minHeight: 4,
                            backgroundColor: palette.line,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: SecondaryButton(
                              label: l10n.saveDraft,
                              onPressed: () {
                                _lastAction = _EditorAction.draft;
                                context
                                    .read<ArticleEditorBloc>()
                                    .add(const EditorDraftSaved());
                              },
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: PrimaryButton(
                              label: state.submitStatus ==
                                      EditorSubmitStatus.publishing
                                  ? l10n.publishing
                                  : l10n.publish,
                              loading: state.submitStatus ==
                                  EditorSubmitStatus.publishing,
                              enabled: state.isValid,
                              onPressed: () {
                                _lastAction = _EditorAction.publish;
                                context
                                    .read<ArticleEditorBloc>()
                                    .add(const EditorPublishRequested());
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _coverBadgeLabel(String fileName, int? sizeBytes) {
  if (sizeBytes == null) return fileName;
  final mb = sizeBytes / (1024 * 1024);
  return '$fileName · ${mb.toStringAsFixed(1)} MB';
}

class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.state});
  final ArticleEditorState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final path = state.coverLocalPath;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          border: Border.all(color: palette.line),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (path != null)
                  ExcludeSemantics(child: Image.file(File(path), fit: BoxFit.cover))
                else
                  StripedImagePlaceholder(imageUrl: state.thumbnailURL),
                const ScrimOverlay(opacityTop: 0.9, opacityBottom: 0.0),
                if (state.coverFileName != null)
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 7),
                          color: palette.glass,
                          child: Text(
                            _coverBadgeLabel(
                                state.coverFileName!, state.coverFileSizeBytes),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () => context
                .read<ArticleEditorBloc>()
                .add(const EditorCoverRemoved()),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                  border:
                      Border(top: BorderSide(color: palette.line, width: 1.5))),
              alignment: Alignment.center,
              child: Text(
                l10n.removeCoverImage,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: dims.fSm,
                    color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
