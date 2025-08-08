import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

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
        final userData = await ApiService.getCurrentUser(_token!);
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

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
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

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
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
      throw e;
    }
  }
}
