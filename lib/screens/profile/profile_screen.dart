import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../auth/role_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isProvider = user?.role == UserRole.provider;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: AppTheme.headingSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryWhite),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      isProvider
                          ? Icons.business_rounded
                          : Icons.person_rounded,
                      size: 50,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.name ?? 'User', style: AppTheme.headingMedium),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isProvider
                          ? AppTheme.accentGold
                          : AppTheme.successGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isProvider ? 'Service Provider' : 'Customer',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Information
            _buildInfoSection('Personal Information', [
              _buildInfoItem(
                'Phone',
                user?.phone ?? 'Not provided',
                Icons.phone_rounded,
              ),
              _buildInfoItem(
                'Location',
                user?.location ?? 'Not provided',
                Icons.location_on_rounded,
              ),
              _buildInfoItem(
                'Member Since',
                'January 2024',
                Icons.calendar_today_rounded,
              ),
            ]),
            const SizedBox(height: 16),

            if (isProvider) ...[
              _buildInfoSection('Business Information', [
                _buildInfoItem(
                  'Total Bookings',
                  '${user?.totalBookings ?? 0}',
                  Icons.calendar_today_rounded,
                ),
                _buildInfoItem('Rating', '4.8 ⭐️', Icons.star_rounded),
                _buildInfoItem('Services', 'Active', Icons.work_rounded),
              ]),
              const SizedBox(height: 16),
            ],
            // Settings Section
            _buildSettingsSection(context),
            const SizedBox(height: 24),

            // Logout Button
            CustomButton(
              text: 'Logout',
              onPressed: () => _showLogoutDialog(context),
              backgroundColor: AppTheme.errorRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textGray),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textGray),
                ),
                Text(value, style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem('Edit Profile', Icons.edit_rounded, () {
            // Navigate to edit profile
          }),
          _buildSettingsItem('Notifications', Icons.notifications_rounded, () {
            // Navigate to notification settings
          }),
          _buildSettingsItem('Privacy & Security', Icons.security_rounded, () {
            // Navigate to privacy settings
          }),
          _buildSettingsItem('Help & Support', Icons.help_rounded, () {
            // Navigate to help
          }),
          _buildSettingsItem(
            'Terms & Conditions',
            Icons.description_rounded,
            () {
              // Navigate to terms
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textGray),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppTheme.bodyMedium)),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textGray,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text('Logout', style: AppTheme.headingSmall),
        content: const Text(
          'Are you sure you want to logout?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textGray),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
