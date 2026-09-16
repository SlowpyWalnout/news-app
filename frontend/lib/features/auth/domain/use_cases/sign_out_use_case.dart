import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/auth/domain/repository/auth_repository.dart';

class SignOutUseCase implements UseCase<DataState<void>, NoParams> {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<DataState<void>> call(NoParams params) {
    return _repository.signOut();
  }
}
