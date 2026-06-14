import 'package:flutter/material.dart';
import '../core/storage/token_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  String? _token;
  String? _customerId;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  Map<String, dynamic>? get userProfile => _userProfile;
  String? get token => _token;
  String? get customerId => _customerId;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _token = await TokenStorage.getToken();
      if (_token != null && _token!.isNotEmpty) {
        _userProfile = await _authService.getProfile();
        if (_userProfile != null && _userProfile!["email"] != null) {
          final cust = await _authService.getCustomerByEmail(_userProfile!["email"]);
          _customerId = cust["id"];
        }
        _isAuthenticated = true;
      }
    } catch (e) {
      _token = null;
      _customerId = null;
      _isAuthenticated = false;
      await TokenStorage.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.login(email: email, password: password);
      await TokenStorage.saveToken(token);
      _token = token;
      _userProfile = await _authService.getProfile();
      if (_userProfile != null && _userProfile!["email"] != null) {
        final cust = await _authService.getCustomerByEmail(_userProfile!["email"]);
        _customerId = cust["id"];
      }
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      _customerId = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
      );
      await TokenStorage.saveToken(token);
      _token = token;
      _userProfile = await _authService.getProfile();
      if (_userProfile != null && _userProfile!["email"] != null) {
        final cust = await _authService.getCustomerByEmail(_userProfile!["email"]);
        _customerId = cust["id"];
      }
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      _customerId = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> socialLogin({
    required String email,
    required String provider,
    required String providerId,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.socialLogin(
        email: email,
        provider: provider,
        providerId: providerId,
        firstName: firstName,
        lastName: lastName,
      );
      await TokenStorage.saveToken(token);
      _token = token;
      _userProfile = await _authService.getProfile();
      if (_userProfile != null && _userProfile!["email"] != null) {
        final cust = await _authService.getCustomerByEmail(_userProfile!["email"]);
        _customerId = cust["id"];
      }
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      _customerId = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> socialRegister({
    required String email,
    required String provider,
    required String providerId,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.socialRegister(
        email: email,
        provider: provider,
        providerId: providerId,
        firstName: firstName,
        lastName: lastName,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    _token = null;
    _userProfile = null;
    _customerId = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      _userProfile = updated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
