import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  final bool isDarkMode;

  const LanguageSelector({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return PopupMenuButton<Locale>(
      icon: Icon(
        Icons.language_rounded,
        color: isDarkMode ? AppTheme.primaryWhite : AppTheme.lightText,
      ),
      tooltip: 'language'.tr(),
      offset: const Offset(0, 50),
      color: isDarkMode ? AppTheme.secondaryGray : AppTheme.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (BuildContext ctx) => [
        _buildLanguageItem(ctx, currentLocale, const Locale('en'), 'English'),
        _buildLanguageItem(ctx, currentLocale, const Locale('am'), 'አማርኛ'),
        _buildLanguageItem(
            ctx, currentLocale, const Locale('om'), 'Afaan Oromoo'),
      ],
      onSelected: (Locale locale) async {
        if (locale == currentLocale) return;
        await context.setLocale(locale);
      },
    );
  }

  PopupMenuItem<Locale> _buildLanguageItem(
    BuildContext context,
    Locale currentLocale,
    Locale locale,
    String languageName,
  ) {
    final isSelected = currentLocale.languageCode == locale.languageCode;
    return PopupMenuItem<Locale>(
      value: locale,
      child: Row(
        children: [
          Icon(
            Icons.language,
            size: 20,
            color: isSelected
                ? AppTheme.accentGold
                : (isDarkMode
                    ? AppTheme.textGray
                    : AppTheme.lightTextSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languageName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.accentGold
                    : (isDarkMode ? AppTheme.primaryWhite : AppTheme.lightText),
                fontFamily: 'Inter',
              ),
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              size: 20,
              color: AppTheme.accentGold,
            ),
        ],
      ),
    );
  }
}
