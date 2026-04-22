import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/language_selector.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          LanguageSelector(isDarkMode: isDark),
          const ThemeToggleButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const LogoWidget(size: 90, showText: true),
              const SizedBox(height: 30),
              Text(
                'welcome.welcome_to_promatch'.tr(),
                style:
                    isDark ? AppTheme.headingLarge : AppTheme.headingLargeLight,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'welcome.choose_role'.tr(),
                style: isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  children: [
                    _RoleCard(
                      title: 'welcome.i_need_service'.tr(),
                      subtitle: 'welcome.find_trusted_providers'.tr(),
                      icon: Icons.search_rounded,
                      color: AppTheme.successGreen,
                      onTap: () => _selectRole(context, UserRole.user),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _RoleCard(
                      title: 'welcome.i_provide_services'.tr(),
                      subtitle: 'welcome.grow_your_business'.tr(),
                      icon: Icons.work_rounded,
                      color: AppTheme.accentGold,
                      onTap: () => _selectRole(context, UserRole.provider),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _selectRole(BuildContext context, UserRole role) {
    Provider.of<UserProvider>(context, listen: false).setUserRole(role);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LoginScreen(userRole: role)));
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: AppTheme.getCardDecoration(isDark).copyWith(
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style:
                  isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
