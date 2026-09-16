import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';
import 'package:news_app/features/auth/domain/repository/auth_repository.dart';

class SignInWithGoogleUseCase implements UseCase<DataState<UserEntity>, NoParams> {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  @override
  Future<DataState<UserEntity>> call(NoParams params) => _repository.signInWithGoogle();
}
