import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  /// Register a new user with email and password
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    double initialBalance = 0.0,
  });

  /// Sign in an existing user with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Sign out the currently signed-in user
  Future<void> signOut();

  /// Get the current user, if any
  Future<UserModel?> getCurrentUser();

  /// Check if a user is currently signed in
  Future<bool> isSignedIn();
  
  /// Update the user's balance
  Future<UserModel> updateBalance({
    required String email,
    required double newBalance,
  });
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final Uuid uuid;

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.uuid,
  });

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    double initialBalance = 0.0,
  }) async {
    // Check if user already exists
    final usersJson = sharedPreferences.getString(AppConstants.usersKey) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);

    if (users.containsKey(email)) {
      throw const AuthException(
        message: 'Email already in use',
        code: 'email-already-in-use',
      );
    }

    // Create new user
    final String id = uuid.v4();
    final String hashedPassword = _hashPassword(password);

    final UserModel newUser = UserModel(
      id: id,
      email: email,
      name: name,
      balance: initialBalance,
    );

    // Save user to storage
    users[email] = {
      ...newUser.toJson(),
      'password': hashedPassword,
    };

    await sharedPreferences.setString(AppConstants.usersKey, json.encode(users));

    // Set current user
    await sharedPreferences.setString(
      AppConstants.currentUserKey,
      json.encode(newUser.toJson()),
    );

    return newUser;
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Get users from storage
    final usersJson = sharedPreferences.getString(AppConstants.usersKey) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);

    // Check if user exists
    if (!users.containsKey(email)) {
      throw const AuthException(
        message: 'No user found with this email',
        code: 'user-not-found',
      );
    }

    // Check password
    final Map<String, dynamic> userData = users[email];
    final String storedPassword = userData['password'];
    final String hashedPassword = _hashPassword(password);

    if (storedPassword != hashedPassword) {
      throw const AuthException(
        message: 'Invalid password',
        code: 'wrong-password',
      );
    }

    // Create user model
    final UserModel user = UserModel.fromJson(userData);

    // Set current user
    await sharedPreferences.setString(
      AppConstants.currentUserKey,
      json.encode(user.toJson()),
    );

    return user;
  }

  @override
  Future<void> signOut() async {
    await sharedPreferences.remove(AppConstants.currentUserKey);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userJson = sharedPreferences.getString(AppConstants.currentUserKey);
    if (userJson == null) {
      return null;
    }

    return UserModel.fromJson(json.decode(userJson));
  }

  @override
  Future<bool> isSignedIn() async {
    return sharedPreferences.containsKey(AppConstants.currentUserKey);
  }
  
  @override
  Future<UserModel> updateBalance({
    required String email,
    required double newBalance,
  }) async {
    // Get users from storage
    final usersJson = sharedPreferences.getString(AppConstants.usersKey) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);

    // Check if user exists
    if (!users.containsKey(email)) {
      throw const AuthException(
        message: 'No user found with this email',
        code: 'user-not-found',
      );
    }

    // Update user's balance
    final userData = users[email];
    userData['balance'] = newBalance;
    users[email] = userData;

    // Save updated users data
    await sharedPreferences.setString(AppConstants.usersKey, json.encode(users));

    return UserModel.fromJson(userData);
  }

  // Helper method to hash passwords
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
