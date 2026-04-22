import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService();
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');

    if (_token != null && userJson != null) {
      try {
        // Verify token with backend
        final userData = await ApiService.verifyToken(_token!);
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await _storage.read(key: 'auth_token');
      if (_token != null && !JwtDecoder.isExpired(_token!)) {
        final userData = await _apiService.getCurrentUser(_token!);
        _user = User.fromJson(userData);
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password, role);
      _token = response['token'];
      _user = User.fromJson(response['user']);
      _isAuthenticated = true;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', _user!.toJson().toString());

      await _updateFCMToken();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> register(Map<String, dynamic> userData, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(userData, role);
      _token = response['token'];
      _user = User.fromJson(response['user']);
      _isAuthenticated = true;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', _user!.toJson().toString());
      await _updateFCMToken();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _updateFCMToken() async {
    try {
      final fcmToken = await NotificationService.getFCMToken();
      if (fcmToken != null && _token != null) {
        await ApiService.updateFCMToken(_token!, fcmToken);
      }
    } catch (e) {
      print('Failed to update FCM token: $e');
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _isAuthenticated = false;

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> userData) async {
    try {
      final updatedUser = await ApiService.updateProfile(_token!, userData);
      _user = User.fromJson(updatedUser);

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', _user!.toJson().toString());

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      await ApiService.requestPasswordReset(email);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      await ApiService.resetPassword(token, newPassword);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Update user data locally and persist
  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    notifyListeners();

    // Save updated user data to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', updatedUser.toJson().toString());
  }

  Future<void> refreshUser(String token) async {
    try {
      final userData = await ApiService.verifyToken(token);
      _user = User.fromJson(userData);

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', _user!.toJson().toString());

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
