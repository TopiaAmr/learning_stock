import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Register a new user with email and password
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    double initialBalance = 0.0,
  });

  /// Sign in an existing user with email and password
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  /// Sign out the currently signed-in user
  Future<Either<Failure, void>> signOut();

  /// Get the current user, if any
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if a user is currently signed in
  Future<bool> isSignedIn();
  
  /// Update the user's balance
  Future<Either<Failure, User>> updateBalance({
    required String email,
    required double newBalance,
  });
}
