import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';
import 'package:news_app/features/article_composer/presentation/bloc/article_editor/article_editor_bloc.dart';
import 'package:news_app/features/article_composer/presentation/bloc/article_editor/article_editor_event.dart';
import 'package:news_app/features/article_composer/presentation/bloc/article_editor/article_editor_state.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockSaveDraftUseCase saveDraft;
  late MockPublishArticleUseCase publishArticle;
  late MockEditArticleUseCase editArticle;
  late MockUploadThumbnailUseCase uploadThumbnail;

  ArticleEditorBloc buildBloc() => ArticleEditorBloc(saveDraft, publishArticle, editArticle, uploadThumbnail);

  setUp(() {
    saveDraft = MockSaveDraftUseCase();
    publishArticle = MockPublishArticleUseCase();
    editArticle = MockEditArticleUseCase();
    uploadThumbnail = MockUploadThumbnailUseCase();
  });

  group('EditorStarted', () {
    blocTest<ArticleEditorBloc, ArticleEditorState>(
      'a new draft (article == null) hydrates from authorId/authorName only',
      build: buildBloc,
      act: (bloc) => bloc.add(const EditorStarted(authorId: 'u1', authorName: 'Rosa')),
      verify: (bloc) {
        expect(bloc.state.articleId, '');
        expect(bloc.state.authorId, 'u1');
        expect(bloc.state.title, '');
        expect(bloc.state.isEditing, isFalse);
      },
    );

    blocTest<ArticleEditorBloc, ArticleEditorState>(
      'an existing article pre-fills the form',
      build: buildBloc,
      act: (bloc) => bloc.add(EditorStarted(
        authorId: 'u1',
        authorName: 'Rosa',
        article: authoredArticle('a1', title: 'Ya existente'),
      )),
      verify: (bloc) {
        expect(bloc.state.articleId, 'a1');
        expect(bloc.state.title, 'Ya existente');
        expect(bloc.state.isEditing, isTrue);
      },
    );
  });

  group('EditorCoverPicked', () {
    blocTest<ArticleEditorBloc, ArticleEditorState>(
      'under the 5 MB cap sets the cover and clears any previous error',
      build: buildBloc,
      act: (bloc) => bloc.add(const EditorCoverPicked('/tmp/x.jpg', 1024, 'x.jpg')),
      verify: (bloc) {
        expect(bloc.state.coverLocalPath, '/tmp/x.jpg');
        expect(bloc.state.coverError, isNull);
        expect(bloc.state.hasCover, isTrue);
      },
    );

    blocTest<ArticleEditorBloc, ArticleEditorState>(
      'over the 5 MB cap rejects the cover and reports the size in MB',
      build: buildBloc,
      act: (bloc) => bloc.add(const EditorCoverPicked('/tmp/x.jpg', 6 * 1024 * 1024, 'x.jpg')),
      verify: (bloc) {
        expect(bloc.state.coverLocalPath, isNull);
        expect(bloc.state.coverError, '6.0');
      },
    );
  });

  blocTest<ArticleEditorBloc, ArticleEditorState>(
    'EditorDraftSaved on an empty draft is rejected without touching the use case',
    build: buildBloc,
    act: (bloc) => bloc.add(const EditorDraftSaved()),
    // La pareja de emisiones ES el contrato de este handler (ver
    // article_editor_bloc.dart onDraftSaved) — aquí sí corresponde expect:.
    expect: () => [
      isA<ArticleEditorState>().having((s) => s.submitStatus, 'submitStatus', EditorSubmitStatus.emptyDraftRejected),
      isA<ArticleEditorState>().having((s) => s.submitStatus, 'submitStatus', EditorSubmitStatus.idle),
    ],
    verify: (_) => verifyNever(() => saveDraft.call(any())),
  );

  blocTest<ArticleEditorBloc, ArticleEditorState>(
    'EditorPublishRequested while invalid marks touched and never calls the use case',
    build: buildBloc,
    act: (bloc) => bloc.add(const EditorPublishRequested()),
    verify: (bloc) {
      expect(bloc.state.touched, isTrue);
      verifyNever(() => publishArticle.call(any()));
    },
  );

  blocTest<ArticleEditorBloc, ArticleEditorState>(
    'a successful publish without a cover reaches success directly',
    setUp: () {
      when(() => publishArticle.call(any())).thenAnswer((_) async => DataSuccess(authoredArticle('a1')));
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const EditorTitleChanged('Título'));
      bloc.add(const EditorBodyChanged('Cuerpo'));
      bloc.add(const EditorPublishRequested());
    },
    verify: (bloc) {
      expect(bloc.state.submitStatus, EditorSubmitStatus.success);
      verifyNever(() => uploadThumbnail.call(any()));
    },
  );

  blocTest<ArticleEditorBloc, ArticleEditorState>(
    'a successful publish with a cover uploads it and reattaches via editArticle, reporting progress',
    setUp: () {
      when(() => publishArticle.call(any())).thenAnswer((_) async => DataSuccess(authoredArticle('a1')));
      when(() => uploadThumbnail.call(any(), onProgress: any(named: 'onProgress'))).thenAnswer((invocation) async {
        final onProgress = invocation.namedArguments[#onProgress] as void Function(double)?;
        onProgress?.call(0.5);
        return const DataSuccess(UploadThumbnailResult(url: 'https://x/y.jpg', path: 'media/articles/u1/a1/y.jpg'));
      });
      when(() => editArticle.call(any())).thenAnswer((_) async => DataSuccess(authoredArticle('a1')));
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const EditorTitleChanged('Título'));
      bloc.add(const EditorBodyChanged('Cuerpo'));
      bloc.add(const EditorCoverPicked('/tmp/x.jpg', 1024, 'x.jpg'));
      bloc.add(const EditorPublishRequested());
    },
    verify: (bloc) {
      expect(bloc.state.submitStatus, EditorSubmitStatus.success);
      verifyInOrder([
        () => publishArticle.call(any()),
        () => uploadThumbnail.call(any(), onProgress: any(named: 'onProgress')),
        () => editArticle.call(any()),
      ]);
    },
  );

  blocTest<ArticleEditorBloc, ArticleEditorState>(
    'saving a draft with a cover reattaches via saveDraft, not editArticle',
    setUp: () {
      when(() => saveDraft.call(any())).thenAnswer((_) async => DataSuccess(authoredArticle('a1', status: ArticleStatus.draft)));
      when(() => uploadThumbnail.call(any(), onProgress: any(named: 'onProgress'))).thenAnswer(
        (_) async => const DataSuccess(UploadThumbnailResult(url: 'https://x/y.jpg', path: 'media/articles/u1/a1/y.jpg')),
      );
      when(() => saveDraft.call(any())).thenAnswer((_) async => DataSuccess(authoredArticle('a1', status: ArticleStatus.draft)));
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const EditorTitleChanged('Título'));
      bloc.add(const EditorCoverPicked('/tmp/x.jpg', 1024, 'x.jpg'));
      bloc.add(const EditorDraftSaved());
    },
    verify: (bloc) {
      expect(bloc.state.submitStatus, EditorSubmitStatus.success);
      verifyNever(() => editArticle.call(any()));
      verify(() => saveDraft.call(any())).called(2);
    },
  );

  blocTest<ArticleEditorBloc, ArticleEditorState>(
    'a DataFailed result surfaces as failure with the error attached',
    setUp: () {
      when(() => publishArticle.call(any())).thenAnswer((_) async => const DataFailed(ServerFailure('boom')));
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const EditorTitleChanged('Título'));
      bloc.add(const EditorBodyChanged('Cuerpo'));
      bloc.add(const EditorPublishRequested());
    },
    verify: (bloc) {
      expect(bloc.state.submitStatus, EditorSubmitStatus.failure);
      expect(bloc.state.error, isA<ServerFailure>());
    },
  );
}
