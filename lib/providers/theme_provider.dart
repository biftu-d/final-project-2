import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true; // Default to dark mode
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true; // Default to dark
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  ThemeData get _darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppTheme.accentGold,
        scaffoldBackgroundColor: AppTheme.primaryBlack,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: AppTheme.accentGold,
          secondary: AppTheme.successGreen,
          surface: AppTheme.secondaryGray,
          error: AppTheme.errorRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.primaryBlack,
          elevation: 0,
          titleTextStyle: AppTheme.headingMedium,
          iconTheme: IconThemeData(color: AppTheme.primaryWhite),
        ),
      );

  ThemeData get _lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: AppTheme.accentGold,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: AppTheme.accentGold,
          secondary: AppTheme.successGreen,
          surface: Colors.grey,
          error: AppTheme.errorRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Inter',
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      );
}
