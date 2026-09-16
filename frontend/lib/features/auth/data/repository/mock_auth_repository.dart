import 'package:uuid/uuid.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';
import 'package:news_app/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app/features/auth/domain/repository/auth_repository.dart';

// Temporary in-memory stand-in for the FirebaseAuth-backed implementation
// Fase 6 will add. Lets Fase 5 build login/registro/perfil screens against a
// real AuthRepository contract before the Firebase SDK is wired in.
class MockAuthRepository implements AuthRepository {
  final Map<String, _MockAccount> _accountsByEmail = {};
  final _uuid = const Uuid();
  UserEntity? _currentUser;

  @override
  Future<DataState<UserEntity>> signIn(SignInParams params) async {
    final account = _accountsByEmail[params.email];
    if (account == null || account.password != params.password) {
      return const DataFailed(AuthFailure('Email o contraseña incorrectos.'));
    }
    _currentUser = account.user;
    return DataSuccess(account.user);
  }

  @override
  Future<DataState<UserEntity>> signUp(SignUpParams params) async {
    if (_accountsByEmail.containsKey(params.email)) {
      return const DataFailed(AuthFailure('Ya existe una cuenta con este email.'));
    }
    final user = UserEntity(
      uid: _uuid.v4(),
      email: params.email,
      displayName: params.displayName,
    );
    _accountsByEmail[params.email] = _MockAccount(user, params.password);
    _currentUser = user;
    return DataSuccess(user);
  }

  @override
  Future<DataState<void>> signOut() async {
    _currentUser = null;
    return const DataSuccess(null);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }
}

class _MockAccount {
  final UserEntity user;
  final String password;

  const _MockAccount(this.user, this.password);
}
