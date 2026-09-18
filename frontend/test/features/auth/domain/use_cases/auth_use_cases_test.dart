import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_up_use_case.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  group('SignInUseCase', () {
    test('delegates to the repository when credentials are valid', () async {
      when(() => repo.signIn(any())).thenAnswer((_) async => DataSuccess(testUser));
      const params = SignInParams(email: 'rosa@correo.com', password: '123456');

      final result = await SignInUseCase(repo)(params);

      expect(result, isA<DataSuccess>());
      verify(() => repo.signIn(params)).called(1);
    });

    test('short-circuits with ValidationFailure on a bad email, never touching the repository', () async {
      final result = await SignInUseCase(repo)(const SignInParams(email: 'not-an-email', password: '123456'));

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<ValidationFailure>());
      verifyNever(() => repo.signIn(any()));
    });
  });

  group('SignUpUseCase', () {
    test('delegates to the repository when everything is valid', () async {
      when(() => repo.signUp(any())).thenAnswer((_) async => DataSuccess(testUser));
      const params = SignUpParams(email: 'rosa@correo.com', password: '123456', displayName: 'Rosa');

      final result = await SignUpUseCase(repo)(params);

      expect(result, isA<DataSuccess>());
    });

    test('short-circuits on an empty display name, never touching the repository', () async {
      final result =
          await SignUpUseCase(repo)(const SignUpParams(email: 'rosa@correo.com', password: '123456', displayName: ' '));

      expect(result, isA<DataFailed>());
      verifyNever(() => repo.signUp(any()));
    });
  });

  test('SignOutUseCase delegates to the repository', () async {
    when(() => repo.signOut()).thenAnswer((_) async => const DataSuccess(null));

    final result = await SignOutUseCase(repo)(const NoParams());

    expect(result, isA<DataSuccess<void>>());
  });

  test('SignInWithGoogleUseCase delegates to the repository', () async {
    when(() => repo.signInWithGoogle()).thenAnswer((_) async => DataSuccess(testUser));

    final result = await SignInWithGoogleUseCase(repo)(const NoParams());

    expect(result, isA<DataSuccess>());
  });
}
