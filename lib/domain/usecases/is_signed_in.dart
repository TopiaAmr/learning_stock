import '../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

class IsSignedIn {
  final AuthRepository repository;

  IsSignedIn(this.repository);

  Future<bool> call(NoParams params) {
    return repository.isSignedIn();
  }
}
