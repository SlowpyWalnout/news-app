import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';
import 'package:news_app/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app/features/auth/domain/use_cases/auth_validator.dart';

class SignInUseCase implements UseCase<DataState<UserEntity>, SignInParams> {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  @override
  Future<DataState<UserEntity>> call(SignInParams params) async {
    final validationError = validateEmailAndPassword(params.email, params.password);
    if (validationError != null) {
      return DataFailed(validationError);
    }
    return _repository.signIn(params);
  }
}
