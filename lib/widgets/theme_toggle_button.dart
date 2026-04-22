import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
            // Show feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  themeProvider.isDarkMode
                      ? 'Switched to Dark Mode'
                      : 'Switched to Light Mode',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? AppTheme.primaryWhite
                        : AppTheme.primaryBlack,
                  ),
                ),
                duration: const Duration(seconds: 1),
                backgroundColor: themeProvider.isDarkMode
                    ? AppTheme.secondaryGray
                    : AppTheme.lightSurface,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? AppTheme.secondaryGray
                  : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? AppTheme.borderGray
                    : AppTheme.lightBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(
                  turns: animation,
                  child: child,
                );
              },
              child: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                key: ValueKey(themeProvider.isDarkMode),
                color: themeProvider.isDarkMode
                    ? AppTheme.accentGold
                    : Colors.orange[700],
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
