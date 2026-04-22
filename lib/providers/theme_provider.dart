import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false; // Default to dark
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppTheme.primaryBlack,
          selectedItemColor: AppTheme.accentGold,
          unselectedItemColor: AppTheme.textGray,
          type: BottomNavigationBarType.fixed,
        ),
        elevatedButtonTheme:
            ElevatedButtonThemeData(style: AppTheme.primaryButton),
        outlinedButtonTheme:
            OutlinedButtonThemeData(style: AppTheme.outlineButton),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.secondaryGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.accentGold, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          hintStyle: const TextStyle(color: AppTheme.textGray),
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.accentGold,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.accentGold, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      );
}
