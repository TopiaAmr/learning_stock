import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String name,
    bool isEmailVerified = false,
    double balance = 0.0,
  }) : super(
          id: id,
          email: email,
          name: name,
          isEmailVerified: isEmailVerified,
          balance: balance,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      balance: (json['balance'] != null) ? (json['balance'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isEmailVerified': isEmailVerified,
      'balance': balance,
    };
  }

  factory UserModel.fromUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      isEmailVerified: user.isEmailVerified,
      balance: user.balance,
    );
  }
}
