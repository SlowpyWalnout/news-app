import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInException, GoogleSignInExceptionCode;
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/auth/data/models/user_model.dart';
import 'package:news_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app/features/auth/domain/params/sign_up_params.dart';

import '../../../../helpers/helpers.dart';

const _model = UserModel(uid: 'u1', email: 'rosa@correo.com', displayName: 'Rosa');

void main() {
  setUpAll(registerCommonFallbacks);

  late MockFirebaseAuthDataSource dataSource;
  late AuthRepositoryImpl repo;

  setUp(() {
    dataSource = MockFirebaseAuthDataSource();
    repo = AuthRepositoryImpl(dataSource);
  });

  group('signIn', () {
    test('success wraps the user', () async {
      when(() => dataSource.signIn(any(), any())).thenAnswer((_) async => _model);

      final result = await repo.signIn(const SignInParams(email: 'rosa@correo.com', password: '123456'));

      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, _model);
    });

    test('wrong-password maps to AuthFailure(invalidCredentials)', () async {
      when(() => dataSource.signIn(any(), any()))
          .thenThrow(fb_auth.FirebaseAuthException(code: 'wrong-password'));

      final result = await repo.signIn(const SignInParams(email: 'rosa@correo.com', password: 'bad'));

      expect(result, isA<DataFailed>());
      final failure = (result as DataFailed).error as AuthFailure;
      expect(failure.code, FailureCode.invalidCredentials);
    });
  });

  group('signUp', () {
    test('a FirebaseAuthException is mapped through the auth mapper', () async {
      when(() => dataSource.signUp(any(), any(), any()))
          .thenThrow(fb_auth.FirebaseAuthException(code: 'email-already-in-use'));

      final result = await repo.signUp(const SignUpParams(email: 'a@a.com', password: '123456', displayName: 'A'));

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<AuthFailure>());
      expect((result.error as AuthFailure).code, FailureCode.emailAlreadyInUse);
    });

    // La escritura del perfil (users/{uid}) lanza FirebaseException, no
    // FirebaseAuthException — distinta rama del catch.
    test('a plain FirebaseException (profile write) is mapped through the generic mapper', () async {
      when(() => dataSource.signUp(any(), any(), any()))
          .thenThrow(FirebaseException(plugin: 'firestore', code: 'unavailable'));

      final result = await repo.signUp(const SignUpParams(email: 'a@a.com', password: '123456', displayName: 'A'));

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<NetworkFailure>());
    });
  });

  group('signInWithGoogle', () {
    test('a canceled picker maps to AuthCancelledFailure', () async {
      when(() => dataSource.signInWithGoogle())
          .thenThrow(const GoogleSignInException(code: GoogleSignInExceptionCode.canceled));

      final result = await repo.signInWithGoogle();

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<AuthCancelledFailure>());
    });

    test('any other Google error code carries its description', () async {
      when(() => dataSource.signInWithGoogle()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.interrupted, description: 'red caída'),
      );

      final result = await repo.signInWithGoogle();

      expect(result, isA<DataFailed>());
      final failure = (result as DataFailed).error as AuthFailure;
      expect(failure.message, 'red caída');
    });
  });

  test('signOut delegates and always succeeds', () async {
    when(() => dataSource.signOut()).thenAnswer((_) async {});

    final result = await repo.signOut();

    expect(result, isA<DataSuccess<void>>());
    verify(() => dataSource.signOut()).called(1);
  });

  test('getCurrentUser returns the data source current user', () async {
    when(() => dataSource.currentUser).thenReturn(_model);

    final user = await repo.getCurrentUser();

    expect(user, _model);
  });
}
