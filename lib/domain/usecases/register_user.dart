import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final String name;
  final double initialBalance;

  RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    this.initialBalance = 0.0,
  });
}

class RegisterUser implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      initialBalance: params.initialBalance,
    );
  }
}
