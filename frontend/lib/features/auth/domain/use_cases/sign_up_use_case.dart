import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';
import 'package:news_app/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app/features/auth/domain/use_cases/auth_validator.dart';

class SignUpUseCase implements UseCase<DataState<UserEntity>, SignUpParams> {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  @override
  Future<DataState<UserEntity>> call(SignUpParams params) async {
    final credentialsError = validateEmailAndPassword(params.email, params.password);
    if (credentialsError != null) {
      return DataFailed(credentialsError);
    }
    final nameError = validateDisplayName(params.displayName);
    if (nameError != null) {
      return DataFailed(nameError);
    }
    return _repository.signUp(params);
  }
}
