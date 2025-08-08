import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/logo_widget.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const LogoWidget(size: 100, showText: true),
              const SizedBox(height: 40),
              const Text(
                'Welcome to ProMatch',
                style: AppTheme.headingLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Connect with local service providers or offer your services',
                style: AppTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Column(
                  children: [
                    _RoleCard(
                      title: 'I need a service',
                      subtitle: 'Find local service providers',
                      icon: Icons.search_rounded,
                      color: AppTheme.successGreen,
                      onTap: () => _selectRole(context, UserRole.user),
                    ),
                    const SizedBox(height: 20),
                    _RoleCard(
                      title: 'I provide services',
                      subtitle: 'Offer your services and grow your business',
                      icon: Icons.work_rounded,
                      color: AppTheme.accentGold,
                      onTap: () => _selectRole(context, UserRole.provider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
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

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration.copyWith(
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
