import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';
import 'package:news_app/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:news_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:news_app/features/auth/presentation/bloc/auth/auth_state.dart';

const _user = UserEntity(uid: 'u1', email: 'rosa@correo.com', displayName: 'Rosa');

/// Hand-written fake — mocktail isn't available (see pubspec.yaml note).
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.currentUser});

  UserEntity? currentUser;

  @override
  Future<UserEntity?> getCurrentUser() async => currentUser;

  @override
  Future<DataState<UserEntity>> signIn(SignInParams params) async {
    return const DataFailed(AuthFailure('Email o contraseña incorrectos.'));
  }

  @override
  Future<DataState<UserEntity>> signUp(SignUpParams params) async {
    return DataSuccess(_user);
  }

  @override
  Future<DataState<void>> signOut() async {
    currentUser = null;
    return const DataSuccess(null);
  }

  @override
  Future<DataState<UserEntity>> signInWithGoogle() async {
    return DataSuccess(_user);
  }
}

AuthBloc _buildBloc(_FakeAuthRepository repo) {
  return AuthBloc(
    GetCurrentUserUseCase(repo),
    SignInUseCase(repo),
    SignUpUseCase(repo),
    SignOutUseCase(repo),
    SignInWithGoogleUseCase(repo),
  );
}

void main() {
  group('AuthBloc', () {
    test('AuthSessionChecked sin sesión emite unauthenticated', () async {
      final bloc = _buildBloc(_FakeAuthRepository());
      bloc.add(const AuthSessionChecked());
      await Future.delayed(Duration.zero);
      expect(bloc.state.status, AuthStatus.unauthenticated);
      await bloc.close();
    });

    test('AuthSessionChecked con sesión emite authenticated con el usuario', () async {
      final bloc = _buildBloc(_FakeAuthRepository(currentUser: _user));
      bloc.add(const AuthSessionChecked());
      await Future.delayed(Duration.zero);
      expect(bloc.state.status, AuthStatus.authenticated);
      expect(bloc.state.user, _user);
      await bloc.close();
    });

    test('AuthSignInSubmitted con credenciales inválidas deja submitError', () async {
      final bloc = _buildBloc(_FakeAuthRepository());
      bloc.add(const AuthSignInSubmitted(email: 'rosa@correo.com', password: 'wrongpass'));
      await Future.delayed(Duration.zero);
      expect(bloc.state.status, AuthStatus.unauthenticated);
      expect(bloc.state.submitError, isA<AuthFailure>());
      await bloc.close();
    });

    test('AuthSignUpSubmitted exitoso emite authenticated', () async {
      final bloc = _buildBloc(_FakeAuthRepository());
      bloc.add(const AuthSignUpSubmitted(displayName: 'Rosa', email: 'rosa@correo.com', password: '123456'));
      await Future.delayed(Duration.zero);
      expect(bloc.state.status, AuthStatus.authenticated);
      expect(bloc.state.user, _user);
      await bloc.close();
    });

    test('AuthRegisterFieldsChanged calcula errores de validación en vivo', () async {
      final bloc = _buildBloc(_FakeAuthRepository());
      bloc.add(const AuthRegisterFieldsChanged(displayName: 'Rosa', email: 'correo-invalido', password: '123'));
      await Future.delayed(Duration.zero);
      expect(bloc.state.registerEmailError, isNotNull);
      expect(bloc.state.registerPasswordError, isNotNull);
      expect(bloc.state.registerPasswordValid, isFalse);
      await bloc.close();
    });

    test('AuthGoogleSignInRequested exitoso emite authenticated', () async {
      final bloc = _buildBloc(_FakeAuthRepository());
      bloc.add(const AuthGoogleSignInRequested());
      await Future.delayed(Duration.zero);
      expect(bloc.state.status, AuthStatus.authenticated);
      expect(bloc.state.user, _user);
      await bloc.close();
    });

    test('AuthSubmitErrorCleared limpia un error previo', () async {
      final bloc = _buildBloc(_FakeAuthRepository());
      bloc.add(const AuthSignInSubmitted(email: 'rosa@correo.com', password: 'wrongpass'));
      await Future.delayed(Duration.zero);
      expect(bloc.state.submitError, isNotNull);
      bloc.add(const AuthSubmitErrorCleared());
      await Future.delayed(Duration.zero);
      expect(bloc.state.submitError, isNull);
      await bloc.close();
    });

    test('AuthSignedOut limpia el usuario', () async {
      final repo = _FakeAuthRepository(currentUser: _user);
      final bloc = _buildBloc(repo);
      bloc.add(const AuthSessionChecked());
      await Future.delayed(Duration.zero);
      bloc.add(const AuthSignedOut());
      await Future.delayed(Duration.zero);
      expect(bloc.state.status, AuthStatus.unauthenticated);
      await bloc.close();
    });
  });
}
