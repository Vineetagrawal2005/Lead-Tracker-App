/// Local authentication logic against Hive storage.
///
/// This is a placeholder for a real backend. Passwords are stored as SHA-256
/// hashes - never plain text. See the README for the REST endpoints a real
/// backend would expose.
library;

import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../services/storage_service.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AuthService {
  AuthService(this._storage);

  final StorageService _storage;
  final _uuid = const Uuid();

  /// Create a new account. Rejects if the email is already registered.
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = _storage.getUserByEmail(normalizedEmail);
    if (existing != null) {
      throw const AuthException('An account with this email already exists.');
    }

    final user = UserModel(
      id: _uuid.v4(),
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: UserModel.hashPassword(password),
      createdAt: DateTime.now(),
    );
    await _storage.saveUser(user);
    return user;
  }

  /// Sign in. Compares password hashes.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _storage.getUserByEmail(normalizedEmail);
    if (user == null) {
      throw const AuthException('No account found with this email.');
    }
    if (!user.verifyPassword(password)) {
      throw const AuthException('Wrong password. Please try again.');
    }
    return user;
  }
}
