import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/auth/data/data_sources/remote/firebase_auth_data_source.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';
import 'package:news_app/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app/shared/data/mappers/firebase_failure_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<DataState<UserEntity>> signIn(SignInParams params) async {
    try {
      final user = await _dataSource.signIn(params.email, params.password);
      return DataSuccess(user);
    } on fb_auth.FirebaseAuthException catch (e) {
      return DataFailed(mapFirebaseAuthExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<UserEntity>> signUp(SignUpParams params) async {
    try {
      final user = await _dataSource.signUp(
        params.email,
        params.password,
        params.displayName,
      );
      return DataSuccess(user);
    } on fb_auth.FirebaseAuthException catch (e) {
      return DataFailed(mapFirebaseAuthExceptionToFailure(e));
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<UserEntity>> signInWithGoogle() async {
    try {
      final user = await _dataSource.signInWithGoogle();
      return DataSuccess(user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const DataFailed(AuthCancelledFailure());
      }
      return DataFailed(AuthFailure(e.description ?? 'No se pudo iniciar sesión con Google.'));
    } on fb_auth.FirebaseAuthException catch (e) {
      return DataFailed(mapFirebaseAuthExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<void>> signOut() async {
    await _dataSource.signOut();
    return const DataSuccess(null);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _dataSource.currentUser;
  }
}
