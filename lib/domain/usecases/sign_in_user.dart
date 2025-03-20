import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInParams {
  final String email;
  final String password;

  SignInParams({
    required this.email,
    required this.password,
  });
}

class SignInUser implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInUser(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) {
    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
