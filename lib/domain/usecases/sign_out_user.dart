import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

class SignOutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}
