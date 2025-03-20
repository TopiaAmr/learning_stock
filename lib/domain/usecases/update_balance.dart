import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateBalance {
  final AuthRepository repository;

  UpdateBalance(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required double newBalance,
  }) async {
    return await repository.updateBalance(
      email: email,
      newBalance: newBalance,
    );
  }
}
