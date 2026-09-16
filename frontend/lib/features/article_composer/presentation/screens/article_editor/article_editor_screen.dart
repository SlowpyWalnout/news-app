import 'dart:io';

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
import '../../../../../shared/widgets/category_chip.dart';
import '../../../../../shared/widgets/inline_banner.dart';
import '../../../../../shared/widgets/scrim_overlay.dart';
import '../../../../../shared/widgets/striped_image_placeholder.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../domain/entities/article_category.dart';
import '../../../domain/entities/authored_article_entity.dart';
import '../../bloc/article_editor/article_editor_bloc.dart';
import '../../bloc/article_editor/article_editor_event.dart';
import '../../bloc/article_editor/article_editor_state.dart';
import '../../widgets/category_label.dart';
import '../my_articles/my_articles_screen.dart';

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
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _initialized = false;
  _EditorAction _lastAction = _EditorAction.none;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickCover(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null || !context.mounted) return;
    final size = await File(picked.path).length();
    if (!context.mounted) return;
    context.read<ArticleEditorBloc>().add(EditorCoverPicked(picked.path, size));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;

    return BlocConsumer<ArticleEditorBloc, ArticleEditorState>(
      listenWhen: (a, b) => a.submitStatus != b.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == EditorSubmitStatus.success) {
          final wasDraft = _lastAction == _EditorAction.draft;
          showAppToast(context, wasDraft ? l10n.draftSavedToast : l10n.publishedToast);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MyArticlesScreen(initialTab: wasDraft ? 'drafts' : 'published'),
            ),
          );
        }
      },
      builder: (context, state) {
        if (!_initialized) {
          _titleController = TextEditingController(text: state.title);
          _bodyController = TextEditingController(text: state.body);
          _initialized = true;
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.line, width: 1.5))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: BackPillButton(label: l10n.exit, onPressed: () => Navigator.of(context).maybePop()),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          state.isEditing ? l10n.editArticleTitle : l10n.newArticleTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: 17.5),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
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
                          onChanged: (v) => context.read<ArticleEditorBloc>().add(EditorTitleChanged(v)),
                        ),
                        const SizedBox(height: 22),
                        Text(l10n.categoryLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fSm)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final category in ArticleCategory.values)
                              CategoryChip(
                                label: categoryLabel(l10n, category),
                                active: state.category == category,
                                onTap: () => context.read<ArticleEditorBloc>().add(EditorCategorySelected(category)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(l10n.coverLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fSm)),
                        const SizedBox(height: 10),
                        if (state.hasCover)
                          _CoverPreview(state: state)
                        else
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _pickCover(context),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: Size(0, dims.tap),
                                    side: BorderSide(color: palette.edge, width: 2.5, style: BorderStyle.solid),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: Text(l10n.chooseCoverImage, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        if (state.coverError != null) ...[
                          const SizedBox(height: 10),
                          InlineBanner(title: '', body: l10n.coverTooLarge(state.coverError!)),
                        ],
                        const SizedBox(height: 10),
                        Text(l10n.coverHint, style: TextStyle(fontSize: 12.5, color: palette.ink3)),
                        const SizedBox(height: 22),
                        AppTextField(
                          label: l10n.bodyLabel,
                          controller: _bodyController,
                          placeholder: l10n.bodyPlaceholder,
                          maxLines: 9,
                          errorText: state.bodyError,
                          counterText: l10n.bodyCounter(state.body.length.toString()),
                          onChanged: (v) => context.read<ArticleEditorBloc>().add(EditorBodyChanged(v)),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.line, width: 1.5))),
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: l10n.saveDraft,
                          onPressed: () {
                            _lastAction = _EditorAction.draft;
                            context.read<ArticleEditorBloc>().add(const EditorDraftSaved());
                          },
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: PrimaryButton(
                          label: state.submitStatus == EditorSubmitStatus.publishing ? l10n.publishing : l10n.publish,
                          loading: state.submitStatus == EditorSubmitStatus.publishing,
                          enabled: state.isValid,
                          onPressed: () {
                            _lastAction = _EditorAction.publish;
                            context.read<ArticleEditorBloc>().add(const EditorPublishRequested());
                          },
                        ),
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

class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.state});
  final ArticleEditorState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final path = state.coverLocalPath;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(border: Border.all(color: palette.line), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (path != null)
                  Image.file(File(path), fit: BoxFit.cover)
                else
                  StripedImagePlaceholder(imageUrl: state.thumbnailURL),
                const ScrimOverlay(opacityTop: 0.9, opacityBottom: 0.0),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.read<ArticleEditorBloc>().add(const EditorCoverRemoved()),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.line, width: 1.5))),
              alignment: Alignment.center,
              child: Text(
                l10n.removeCoverImage,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
