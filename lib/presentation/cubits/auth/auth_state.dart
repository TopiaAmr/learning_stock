import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class RegisterSuccess extends AuthState {
  final User user;

  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class SignInSuccess extends AuthState {
  final User user;

  const SignInSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class SignOutSuccess extends AuthState {
  const SignOutSuccess();
}

class BalanceUpdateSuccess extends AuthState {
  final User user;
  final double newBalance;

  const BalanceUpdateSuccess(this.user, this.newBalance);

  @override
  List<Object?> get props => [user, newBalance];
}
