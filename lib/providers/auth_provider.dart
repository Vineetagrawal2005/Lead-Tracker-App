/// Authentication provider.
///
/// State: [currentUser], [isLoading], [errorMessage], [isLoggedIn].
/// Methods: [checkSession], [signup], [login], [logout].
///
/// Session persistence is delegated to [StorageService] (SharedPreferences).
library;

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._storage) : _auth = AuthService(_storage);

  final StorageService _storage;
  final AuthService _auth;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  /// Restore the session from SharedPreferences on app start.
  Future<bool> checkSession() async {
    if (!_storage.isLoggedIn) {
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
      return false;
    }
    final userId = _storage.currentUserId;
    if (userId == null) {
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
      return false;
    }
    _currentUser = _storage.getUser(userId);
    _isLoggedIn = _currentUser != null;
    if (!_isLoggedIn) {
      // Session data is stale - clear it.
      await _storage.clearSession();
    }
    notifyListeners();
    return _isLoggedIn;
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _auth.signup(
        name: name,
        email: email,
        password: password,
      );
      // Signup automatically logs the user in (remember me = true).
      await _storage.saveSession(
        isLoggedIn: true,
        userId: user.id,
        rememberMe: true,
      );
      _currentUser = user;
      _isLoggedIn = true;
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _auth.login(email: email, password: password);
      await _storage.saveSession(
        isLoggedIn: true,
        userId: user.id,
        rememberMe: rememberMe,
      );
      _currentUser = user;
      _isLoggedIn = true;
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _storage.clearSession();
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
