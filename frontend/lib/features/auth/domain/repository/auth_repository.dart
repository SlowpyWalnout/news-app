import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';
import 'package:news_app/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app/features/auth/domain/params/sign_up_params.dart';

abstract class AuthRepository {
  Future<DataState<UserEntity>> signIn(SignInParams params);

  Future<DataState<UserEntity>> signUp(SignUpParams params);

  Future<DataState<void>> signOut();

  Future<UserEntity?> getCurrentUser();
}
