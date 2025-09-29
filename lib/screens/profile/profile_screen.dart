import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../services/file_upload_service.dart';
import '../../utils/app_theme.dart';
import 'dart:io';
import 'package:intl/intl.dart';
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
        title: const Text(
          'Profile',
          style: AppTheme.headingSmall,
        ),
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
                  Text(
                    user?.name ?? 'User',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'user@example.com',
                    style:
                        AppTheme.bodyMedium.copyWith(color: AppTheme.textGray),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                user?.createdAt != null
                    ? DateFormat("MMMM yyyy").format(user!.createdAt)
                    : 'Not provided',
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
                _buildInfoItem(
                  'Rating',
                  user?.rating != null
                      ? '${user!.rating.toStringAsFixed(1)} ⭐'
                      : 'No rating yet',
                  Icons.star_rounded,
                ),
                _buildInfoItem(
                  'Services',
                  (user?.verificationStatus == 'approved' &&
                          user?.isAvailable == true)
                      ? 'Active'
                      : 'Inactive',
                  Icons.work_rounded,
                ),
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
          Icon(
            icon,
            size: 20,
            color: AppTheme.textGray,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textGray),
                ),
                Text(
                  value,
                  style: AppTheme.bodyMedium,
                ),
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
          _buildSettingsItem(
            'Edit Profile',
            Icons.edit_rounded,
            () => _navigateToEditProfile(context),
          ),
          _buildSettingsItem(
            'Notifications',
            Icons.notifications_rounded,
            () => _showNotificationSettings(context),
          ),
          _buildSettingsItem(
            'Privacy & Security',
            Icons.security_rounded,
            () => _showPrivacySettings(context),
          ),
          _buildSettingsItem(
            'Help & Support',
            Icons.help_rounded,
            () => _showHelpSupport(context),
          ),
          _buildSettingsItem(
            'Terms & Conditions',
            Icons.description_rounded,
            () => _showTermsConditions(context),
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
            Icon(
              icon,
              size: 20,
              color: AppTheme.textGray,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyMedium,
              ),
            ),
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
        title: const Text(
          'Logout',
          style: AppTheme.headingSmall,
        ),
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

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text(
          'Notification Settings',
          style: AppTheme.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title:
                  const Text('Push Notifications', style: AppTheme.bodyMedium),
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.accentGold,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title:
                  const Text('Email Notifications', style: AppTheme.bodyMedium),
              value: false,
              onChanged: (value) {},
              activeColor: AppTheme.accentGold,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title:
                  const Text('SMS Notifications', style: AppTheme.bodyMedium),
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.accentGold,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Save',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text(
          'Privacy & Security',
          style: AppTheme.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Change Password', style: AppTheme.bodyMedium),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.textGray),
              onTap: () {},
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Two-Factor Authentication',
                  style: AppTheme.bodyMedium),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.textGray),
              onTap: () {},
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Data & Privacy', style: AppTheme.bodyMedium),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.textGray),
              onTap: () {},
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text(
          'Help & Support',
          style: AppTheme.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('FAQ', style: AppTheme.bodyMedium),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.textGray),
              onTap: () {},
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Contact Support', style: AppTheme.bodyMedium),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.textGray),
              onTap: () {},
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Report a Problem', style: AppTheme.bodyMedium),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.textGray),
              onTap: () {},
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text(
          'Terms & Conditions',
          style: AppTheme.headingSmall,
        ),
        content: const SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              'ProMatch Terms of Service\n\n'
              '1. Acceptance of Terms\n'
              'By using ProMatch, you agree to these terms...\n\n'
              '2. Service Description\n'
              'ProMatch is a platform connecting users with service providers...\n\n'
              '3. User Responsibilities\n'
              'Users must provide accurate information...\n\n'
              '4. Payment Terms\n'
              'All payments are processed through Chapa...\n\n'
              '5. Privacy Policy\n'
              'We respect your privacy and protect your data...',
              style: AppTheme.bodySmall,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  File? _profilePicture;
  File? _nationalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: AppTheme.headingSmall,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save changes
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: _profilePicture != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.file(
                              _profilePicture!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: AppTheme.primaryBlack,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        final file = await FileUploadService.pickImage(
                          context,
                          title: 'Profile Picture',
                        );
                        if (file != null) {
                          setState(() => _profilePicture = file);
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: AppTheme.primaryBlack, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppTheme.primaryWhite,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Form fields
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: AppTheme.bodyMedium,
                filled: true,
                fillColor: AppTheme.secondaryGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: AppTheme.bodyMedium,
                filled: true,
                fillColor: AppTheme.secondaryGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: AppTheme.bodyMedium,
                filled: true,
                fillColor: AppTheme.secondaryGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            // National ID Upload
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'National ID (For Security)',
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload your National ID for account verification. This is only accessible to admins.',
                    style: AppTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final file = await FileUploadService.pickImage(
                        context,
                        title: 'National ID',
                      );
                      if (file != null) {
                        setState(() => _nationalId = file);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _nationalId != null
                              ? AppTheme.successGreen
                              : AppTheme.borderGray,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: _nationalId != null
                                ? AppTheme.successGreen
                                : AppTheme.textGray,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _nationalId != null
                                  ? FileUploadService.getFileName(
                                      _nationalId!.path)
                                  : 'Upload National ID',
                              style: AppTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            _nationalId != null ? 'Change' : 'Upload',
                            style: const TextStyle(color: AppTheme.accentGold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
