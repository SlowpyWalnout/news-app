import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app/features/auth/domain/use_cases/auth_validator.dart';
import 'package:news_app/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:news_app/features/auth/domain/use_cases/sign_up_use_case.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._getCurrentUserUseCase,
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutUseCase,
  ) : super(const AuthState.initial()) {
    on<AuthSessionChecked>(onSessionChecked);
    on<AuthSignInSubmitted>(onSignInSubmitted);
    on<AuthRegisterFieldsChanged>(onRegisterFieldsChanged);
    on<AuthSignUpSubmitted>(onSignUpSubmitted);
    on<AuthSignedOut>(onSignedOut);
  }

  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;

  Future<void> onSessionChecked(AuthSessionChecked event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    // GetCurrentUserUseCase returns a bare nullable UserEntity (not DataState)
    // since "no session yet" is not a failure.
    final user = await _getCurrentUserUseCase(const NoParams());
    emit(state.copyWith(
      status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: user,
    ));
  }

  Future<void> onSignInSubmitted(AuthSignInSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearSubmitError: true));
    final result = await _signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );
    if (result is DataSuccess<dynamic> && result.data != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: result.data));
    } else if (result is DataFailed<dynamic>) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, submitError: result.error));
    }
  }

  Future<void> onRegisterFieldsChanged(
    AuthRegisterFieldsChanged event,
    Emitter<AuthState> emit,
  ) async {
    final nameError = validateDisplayName(event.displayName);
    emit(state.copyWith(
      registerNameError: event.displayName.trim().isEmpty ? null : nameError?.message,
      registerEmailError: event.email.trim().isEmpty || isValidEmail(event.email)
          ? null
          : 'Escribe un correo válido, con @ y punto.',
      registerPasswordError: event.password.isEmpty || isValidPassword(event.password)
          ? null
          : 'La contraseña necesita $kPasswordMinLength caracteres o más.',
      registerPasswordValid: isValidPassword(event.password),
    ));
  }

  Future<void> onSignUpSubmitted(AuthSignUpSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearSubmitError: true));
    final result = await _signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );
    if (result is DataSuccess<dynamic> && result.data != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: result.data));
    } else if (result is DataFailed<dynamic>) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, submitError: result.error));
    }
  }

  Future<void> onSignedOut(AuthSignedOut event, Emitter<AuthState> emit) async {
    await _signOutUseCase(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
