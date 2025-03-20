import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final bool isEmailVerified;
  final double balance;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.isEmailVerified = false,
    this.balance = 0.0,
  });

  @override
  List<Object?> get props => [id, email, name, isEmailVerified, balance];
}
