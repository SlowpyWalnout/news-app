import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:news_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:news_app/features/auth/presentation/bloc/auth/auth_state.dart';

import '../../../../../helpers/helpers.dart';

AuthBloc _buildBloc(MockAuthRepository repo) {
  return AuthBloc(
    GetCurrentUserUseCase(repo),
    SignInUseCase(repo),
    SignUpUseCase(repo),
    SignOutUseCase(repo),
    SignInWithGoogleUseCase(repo),
  );
}

void main() {
  setUpAll(registerCommonFallbacks);

  group('AuthBloc', () {
    late MockAuthRepository repo;

    setUp(() {
      repo = MockAuthRepository();
    });

    blocTest<AuthBloc, AuthState>(
      'AuthSessionChecked sin sesión emite unauthenticated',
      setUp: () => when(() => repo.getCurrentUser()).thenAnswer((_) async => null),
      build: () => _buildBloc(repo),
      act: (bloc) => bloc.add(const AuthSessionChecked()),
      verify: (bloc) => expect(bloc.state.status, AuthStatus.unauthenticated),
    );

    blocTest<AuthBloc, AuthState>(
      'AuthSessionChecked con sesión emite authenticated con el usuario',
      setUp: () => when(() => repo.getCurrentUser()).thenAnswer((_) async => testUser),
      build: () => _buildBloc(repo),
      act: (bloc) => bloc.add(const AuthSessionChecked()),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.user, testUser);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'AuthSignInSubmitted con credenciales inválidas deja submitError',
      setUp: () => when(() => repo.signIn(any()))
          .thenAnswer((_) async => const DataFailed(AuthFailure('Email o contraseña incorrectos.'))),
      build: () => _buildBloc(repo),
      act: (bloc) => bloc.add(const AuthSignInSubmitted(email: 'rosa@correo.com', password: 'wrongpass')),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.unauthenticated);
        expect(bloc.state.submitError, isA<AuthFailure>());
      },
    );

    blocTest<AuthBloc, AuthState>(
      'AuthSignUpSubmitted exitoso emite authenticated',
      setUp: () => when(() => repo.signUp(any())).thenAnswer((_) async => DataSuccess(testUser)),
      build: () => _buildBloc(repo),
      act: (bloc) => bloc.add(const AuthSignUpSubmitted(displayName: 'Rosa', email: 'rosa@correo.com', password: '123456')),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.user, testUser);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'AuthRegisterFieldsChanged calcula errores de validación en vivo',
      build: () => _buildBloc(repo),
      act: (bloc) => bloc.add(const AuthRegisterFieldsChanged(displayName: 'Rosa', email: 'correo-invalido', password: '123')),
      verify: (bloc) {
        expect(bloc.state.registerEmailError, isNotNull);
        expect(bloc.state.registerPasswordError, isNotNull);
        expect(bloc.state.registerPasswordValid, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'AuthGoogleSignInRequested exitoso emite authenticated',
      setUp: () => when(() => repo.signInWithGoogle()).thenAnswer((_) async => DataSuccess(testUser)),
      build: () => _buildBloc(repo),
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.user, testUser);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'AuthSubmitErrorCleared limpia un error previo',
      setUp: () => when(() => repo.signIn(any()))
          .thenAnswer((_) async => const DataFailed(AuthFailure('Email o contraseña incorrectos.'))),
      build: () => _buildBloc(repo),
      act: (bloc) async {
        bloc.add(const AuthSignInSubmitted(email: 'rosa@correo.com', password: 'wrongpass'));
        await Future.delayed(Duration.zero);
        expect(bloc.state.submitError, isNotNull);
        bloc.add(const AuthSubmitErrorCleared());
      },
      verify: (bloc) => expect(bloc.state.submitError, isNull),
    );

    // No re-lee getCurrentUser() tras signOut: un stub estático es
    // equivalente al fake stateful original, que sí ponía currentUser=null.
    blocTest<AuthBloc, AuthState>(
      'AuthSignedOut limpia el usuario',
      setUp: () {
        when(() => repo.getCurrentUser()).thenAnswer((_) async => testUser);
        when(() => repo.signOut()).thenAnswer((_) async => const DataSuccess(null));
      },
      build: () => _buildBloc(repo),
      act: (bloc) async {
        bloc.add(const AuthSessionChecked());
        await Future.delayed(Duration.zero);
        bloc.add(const AuthSignedOut());
      },
      verify: (bloc) => expect(bloc.state.status, AuthStatus.unauthenticated),
    );
  });
}
