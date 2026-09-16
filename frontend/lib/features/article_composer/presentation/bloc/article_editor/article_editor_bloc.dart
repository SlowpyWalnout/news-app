import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';

import '../../../domain/entities/article_category.dart';
import '../../../domain/entities/article_status.dart';
import '../../../domain/entities/authored_article_entity.dart';
import '../../../domain/params/upload_thumbnail_params.dart';
import '../../../domain/use_cases/edit_article_use_case.dart';
import '../../../domain/use_cases/publish_article_use_case.dart';
import '../../../domain/use_cases/save_draft_use_case.dart';
import '../../../domain/use_cases/upload_thumbnail_use_case.dart';
import 'article_editor_event.dart';
import 'article_editor_state.dart';

/// 5 MB, matching the prototype's cover-image cap.
const int kMaxCoverSizeBytes = 5 * 1024 * 1024;

class ArticleEditorBloc extends Bloc<ArticleEditorEvent, ArticleEditorState> {
  ArticleEditorBloc(
    this._saveDraftUseCase,
    this._publishArticleUseCase,
    this._editArticleUseCase,
    this._uploadThumbnailUseCase,
  ) : super(const ArticleEditorState()) {
    on<EditorStarted>(onStarted);
    on<EditorTitleChanged>(onTitleChanged);
    on<EditorBodyChanged>(onBodyChanged);
    on<EditorCategorySelected>(onCategorySelected);
    on<EditorCoverPicked>(onCoverPicked);
    on<EditorCoverRemoved>(onCoverRemoved);
    on<EditorDraftSaved>(onDraftSaved);
    on<EditorPublishRequested>(onPublishRequested);
  }

  final SaveDraftUseCase _saveDraftUseCase;
  final PublishArticleUseCase _publishArticleUseCase;
  final EditArticleUseCase _editArticleUseCase;
  final UploadThumbnailUseCase _uploadThumbnailUseCase;

  Future<void> onStarted(EditorStarted event, Emitter<ArticleEditorState> emit) async {
    final article = event.article;
    emit(ArticleEditorState(
      articleId: article?.id ?? '',
      authorId: event.authorId,
      authorName: event.authorName,
      title: article?.title ?? '',
      body: article?.body ?? '',
      category: article?.category ?? ArticleCategory.general,
      thumbnailURL: article?.thumbnailURL,
    ));
  }

  Future<void> onTitleChanged(EditorTitleChanged event, Emitter<ArticleEditorState> emit) async {
    emit(state.copyWith(title: event.title, touched: true));
  }

  Future<void> onBodyChanged(EditorBodyChanged event, Emitter<ArticleEditorState> emit) async {
    emit(state.copyWith(body: event.body, touched: true));
  }

  Future<void> onCategorySelected(EditorCategorySelected event, Emitter<ArticleEditorState> emit) async {
    emit(state.copyWith(category: event.category));
  }

  Future<void> onCoverPicked(EditorCoverPicked event, Emitter<ArticleEditorState> emit) async {
    if (event.fileSizeBytes > kMaxCoverSizeBytes) {
      final sizeMb = (event.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      emit(state.copyWith(coverError: sizeMb, clearCover: true));
      return;
    }
    emit(state.copyWith(coverLocalPath: event.filePath, clearCoverError: true));
  }

  Future<void> onCoverRemoved(EditorCoverRemoved event, Emitter<ArticleEditorState> emit) async {
    emit(state.copyWith(clearCover: true, thumbnailURL: '', clearCoverError: true));
  }

  Future<void> onDraftSaved(EditorDraftSaved event, Emitter<ArticleEditorState> emit) async {
    emit(state.copyWith(submitStatus: EditorSubmitStatus.savingDraft, clearError: true));
    final result = await _saveDraftUseCase(_buildEntity(status: ArticleStatus.draft));
    await _finishSubmit(result, emit);
  }

  Future<void> onPublishRequested(EditorPublishRequested event, Emitter<ArticleEditorState> emit) async {
    emit(state.copyWith(touched: true));
    if (!state.isValid) return;
    emit(state.copyWith(submitStatus: EditorSubmitStatus.publishing, clearError: true));
    final result = await _publishArticleUseCase(_buildEntity(status: ArticleStatus.published));
    await _finishSubmit(result, emit);
  }

  AuthoredArticleEntity _buildEntity({required ArticleStatus status}) {
    final now = DateTime.now();
    return AuthoredArticleEntity(
      id: state.articleId,
      authorId: state.authorId,
      authorName: state.authorName,
      title: state.title,
      body: state.body,
      status: status,
      category: state.category,
      thumbnailURL: state.thumbnailURL,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _finishSubmit(
    DataState<AuthoredArticleEntity> result,
    Emitter<ArticleEditorState> emit,
  ) async {
    if (result is DataFailed) {
      emit(state.copyWith(submitStatus: EditorSubmitStatus.failure, error: result.error));
      return;
    }
    if (result is! DataSuccess || result.data == null) return;
    var saved = result.data!;

    final coverPath = state.coverLocalPath;
    if (coverPath != null) {
      final uploadResult = await _uploadThumbnailUseCase(
        UploadThumbnailParams(articleId: saved.id, filePath: coverPath),
      );
      if (uploadResult is DataSuccess && uploadResult.data != null) {
        final withThumbnail = saved.copyWith(
          thumbnailURL: uploadResult.data!.url,
          thumbnailPath: uploadResult.data!.path,
        );
        final reattach = saved.status == ArticleStatus.draft
            ? await _saveDraftUseCase(withThumbnail)
            : await _editArticleUseCase(withThumbnail);
        if (reattach is DataSuccess && reattach.data != null) {
          saved = reattach.data!;
        }
      }
    }

    emit(state.copyWith(
      articleId: saved.id,
      thumbnailURL: saved.thumbnailURL,
      clearCover: true,
      submitStatus: EditorSubmitStatus.success,
    ));
  }
}
