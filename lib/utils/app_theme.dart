import 'package:flutter/material.dart';

class AppTheme {
  // Dark theme colors
  static const Color primaryBlack = Color(0xFF1E1E1E);
  static const Color secondaryGray = Color(0xFF2A2A2A);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color successGreen = Color(0xFF28A745);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF888888);
  static const Color borderGray = Color(0xFF333333);
  static const Color errorRed = Color(0xFFFF4444);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF212529);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightBorder = Color(0xFFE9ECEF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Text Styles for Dark Theme
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryWhite,
    fontFamily: 'Inter',
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryWhite,
    fontFamily: 'Inter',
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryWhite,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: primaryWhite,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: primaryWhite,
    fontFamily: 'Inter',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textGray,
    fontFamily: 'Inter',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    color: textGray,
    fontFamily: 'Inter',
  );

  // Text Styles for Light Theme
  static const TextStyle headingLargeLight = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: lightText,
    fontFamily: 'Inter',
  );

  static const TextStyle headingMediumLight = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: lightText,
    fontFamily: 'Inter',
  );

  static const TextStyle headingSmallLight = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: lightText,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyLargeLight = TextStyle(
    fontSize: 16,
    color: lightText,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyMediumLight = TextStyle(
    fontSize: 14,
    color: lightText,
    fontFamily: 'Inter',
  );

  static const TextStyle bodySmallLight = TextStyle(
    fontSize: 12,
    color: lightTextSecondary,
    fontFamily: 'Inter',
  );

  // Button Styles
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: successGreen,
    foregroundColor: primaryWhite,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
    ),
  );

  static final ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: accentGold,
    foregroundColor: primaryBlack,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
    ),
  );

  static final ButtonStyle outlineButton = OutlinedButton.styleFrom(
    foregroundColor: primaryWhite,
    side: const BorderSide(color: borderGray),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
    ),
  );

  // Card Style
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: secondaryGray,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final BoxDecoration cardDecorationLight = BoxDecoration(
    color: lightCard,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Theme Data
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: accentGold,
    scaffoldBackgroundColor: primaryBlack,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: accentGold,
      secondary: successGreen,
      surface: secondaryGray,
      error: errorRed,
      onPrimary: primaryBlack,
      onSecondary: primaryWhite,
      onSurface: primaryWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlack,
      elevation: 0,
      titleTextStyle: headingMedium,
      iconTheme: IconThemeData(color: primaryWhite),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButton),
    outlinedButtonTheme: OutlinedButtonThemeData(style: outlineButton),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryGray,
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
        borderSide: const BorderSide(color: accentGold, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      hintStyle: const TextStyle(color: textGray),
      labelStyle: const TextStyle(color: primaryWhite),
    ),
    cardTheme: CardThemeData(
      color: secondaryGray,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    dividerTheme: const DividerThemeData(color: borderGray),
    iconTheme: const IconThemeData(color: primaryWhite),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: accentGold,
    scaffoldBackgroundColor: lightBackground,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: accentGold,
      secondary: successGreen,
      surface: lightSurface,
      error: errorRed,
      onPrimary: primaryBlack,
      onSecondary: primaryWhite,
      onSurface: lightText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      elevation: 1,
      titleTextStyle: headingMediumLight,
      iconTheme: IconThemeData(color: lightText),
      shadowColor: Colors.black12,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: successGreen,
        foregroundColor: primaryWhite,
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
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightText,
        side: const BorderSide(color: lightBorder),
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
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentGold, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      hintStyle: const TextStyle(color: lightTextSecondary),
      labelStyle: const TextStyle(color: lightText),
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    dividerTheme: const DividerThemeData(color: lightBorder),
    iconTheme: const IconThemeData(color: lightText),
  );

  // Helper methods to get theme-aware colors
  static Color getBackgroundColor(bool isDark) {
    return isDark ? primaryBlack : lightBackground;
  }

  static Color getSurfaceColor(bool isDark) {
    return isDark ? secondaryGray : lightSurface;
  }

  static Color getTextColor(bool isDark) {
    return isDark ? primaryWhite : lightText;
  }

  static Color getSecondaryTextColor(bool isDark) {
    return isDark ? textGray : lightTextSecondary;
  }

  static BoxDecoration getCardDecoration(bool isDark) {
    return isDark ? cardDecoration : cardDecorationLight;
  }
}
