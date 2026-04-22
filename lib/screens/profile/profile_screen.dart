import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/user_model.dart';
import '../../services/file_upload_service.dart';
import '../../utils/app_theme.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/language_selector.dart';
import '../auth/role_selection_screen.dart';
import '../settings/privacy_security_screen.dart';
import '../settings/help_support_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = authProvider.user;
    final isProvider = user?.role == UserRole.provider;
    final unread = Provider.of<NotificationProvider>(context).unreadCount;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'profile.profile'.tr(),
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: isDark ? AppTheme.primaryWhite : AppTheme.lightText,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_rounded,
                  color: isDark ? AppTheme.primaryWhite : AppTheme.lightText,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              ),
              if (unread > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    constraints:
                        const BoxConstraints(minWidth: 15, minHeight: 15),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          LanguageSelector(isDarkMode: isDark),
          const ThemeToggleButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.getCardDecoration(isDark),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: AppTheme.accentGold,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: (user?.profilePicture != null &&
                                  user!.profilePicture!.isNotEmpty) ||
                              (user?.avatar != null && user!.avatar!.isNotEmpty)
                          ? Image.network(
                              user.profilePicture ?? user.avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  isProvider
                                      ? Icons.business_rounded
                                      : Icons.person_rounded,
                                  size: 50,
                                  color: AppTheme.primaryBlack,
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : Icon(
                              isProvider
                                  ? Icons.business_rounded
                                  : Icons.person_rounded,
                              size: 50,
                              color: AppTheme.primaryBlack,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'profile.user'.tr(),
                    style: isDark
                        ? AppTheme.headingMedium
                        : AppTheme.headingMediumLight,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: (isDark
                            ? AppTheme.bodyMedium
                            : AppTheme.bodyMediumLight)
                        .copyWith(
                            color: AppTheme.getSecondaryTextColor(isDark)),
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
                      isProvider
                          ? 'profile.service_provider'.tr()
                          : 'Customer'.tr(),
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
            // Rejection Notice for Providers
            if (isProvider && user?.verificationStatus == 'rejected') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.errorRed, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error,
                            color: AppTheme.errorRed, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'profile.appln_rejected'.tr(),
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (user?.rejectionReason != null) ...[
                      Text(
                        'profile.reason'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.primaryWhite
                              : AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user!.rejectionReason!,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textGray
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    CustomButton(
                      text: 'profile.resubmit_appln'.tr(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Profile Information
            _buildInfoSection(
                'profile.personal_info'.tr(),
                [
                  _buildInfoItem(
                    'profile.phone'.tr(),
                    user?.phone ?? 'Not provided',
                    Icons.phone_rounded,
                    isDark,
                  ),
                  _buildInfoItem(
                    'profile.location'.tr(),
                    user?.location ?? 'Not provided',
                    Icons.location_on_rounded,
                    isDark,
                  ),
                  _buildInfoItem(
                    'profile.member'.tr(),
                    user?.createdAt != null
                        ? DateFormat("MMMM yyyy").format(user!.createdAt)
                        : 'Not provided',
                    Icons.calendar_today_rounded,
                    isDark,
                  ),
                ],
                isDark),
            const SizedBox(height: 16),

            if (isProvider) ...[
              _buildInfoSection(
                  'profile.basic_info'.tr(),
                  [
                    _buildInfoItem(
                      'home.total_bookings'.tr(),
                      '${user?.totalBookings ?? 0}',
                      Icons.calendar_today_rounded,
                      isDark,
                    ),
                    _buildInfoItem(
                      'profile.rating'.tr(),
                      user?.rating != null
                          ? '${user!.rating.toStringAsFixed(1)} ⭐'
                          : 'profile.no_rating'.tr(),
                      Icons.star_rounded,
                      isDark,
                    ),
                    _buildInfoItem(
                      'profile.service'.tr(),
                      (user?.verificationStatus == 'approved' &&
                              user?.isAvailable == true)
                          ? 'Active'
                          : 'Inactive',
                      Icons.work_rounded,
                      isDark,
                    ),
                  ],
                  isDark),
              const SizedBox(height: 8),
              CustomButton(
                text: 'profile.view_review'.tr(),
                onPressed: () => _showReviewsDialog(context, authProvider),
                backgroundColor:
                    const Color.fromARGB(36, 60, 255, 0).withOpacity(0.2),
              ),
              const SizedBox(height: 16),
            ],

            // Settings Section
            _buildSettingsSection(context, isDark),
            const SizedBox(height: 24),

            // Logout Button
            CustomButton(
              text: 'will.logout'.tr(),
              onPressed: () => _showLogoutDialog(context),
              backgroundColor: AppTheme.errorRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.getCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: (isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.getSecondaryTextColor(isDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: (isDark ? AppTheme.bodySmall : AppTheme.bodySmallLight)
                      .copyWith(
                    color: AppTheme.getSecondaryTextColor(isDark),
                  ),
                ),
                Text(
                  value,
                  style:
                      (isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight)
                          .copyWith(color: AppTheme.getTextColor(isDark)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.getCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'profile.setting'.tr(),
            style: isDark
                ? AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                : AppTheme.bodyLargeLight.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            'profile.edit_profile'.tr(),
            Icons.edit_rounded,
            () => _navigateToEditProfile(context),
            isDark,
          ),
          _buildSettingsItem(
            'profile.notification',
            Icons.notifications_rounded,
            () => _showNotificationSettings(context),
            isDark,
          ),
          _buildSettingsItem(
            'profile.privacy_security'.tr(),
            Icons.security_rounded,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacySecurityScreen(),
                ),
              );
            },
            isDark,
          ),
          _buildSettingsItem(
            'profile.help_support'.tr(),
            Icons.help_rounded,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
            isDark,
          ),
          _buildSettingsItem(
            'profile.term_condition'.tr(),
            Icons.description_rounded,
            () => _showTermsConditions(context),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
      String title, IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.getSecondaryTextColor(isDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.getSecondaryTextColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(isDark),
        title: Text(
          'will.logout'.tr(),
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: Text(
          'profile.sure_logout'.tr(),
          style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'will.cancel'.tr(),
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(isDark), // ✅ dynamic
              ),
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
            child: Text(
              'will.logout'.tr(),
              style: const TextStyle(color: AppTheme.errorRed),
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

  void _showTermsConditions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
        title: Text(
          'profile.term_condition'.tr(),
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: SizedBox(
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
              style: isDark ? AppTheme.bodySmall : AppTheme.bodySmallLight,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'will.close'.tr(),
              style: const TextStyle(color: AppTheme.accentGold),
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
  void initState() {
    super.initState();

    final user = Provider.of<AuthProvider>(context, listen: false).user;

    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _locationController.text = user.location;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
        title: Text(
          'profile.edit_profile'.tr(),
          style: AppTheme.headingSmall,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              try {
                // ✅ Trim inputs and fallback to empty string if null
                final userData = {
                  "name": _nameController.text.trim(),
                  "phone": _phoneController.text.trim(),
                  "location": _locationController.text.trim(),
                };

                // Call provider to update profile
                await authProvider.updateProfile(userData);

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating profile: $e'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            child: Text(
              'will.save'.tr(),
              style: const TextStyle(color: AppTheme.accentGold),
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
                labelText: 'auth.full_name'.tr(),
                labelStyle:
                    isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
                filled: true,
                fillColor:
                    isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'auth.pnumber'.tr(),
                labelStyle:
                    isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
                filled: true,
                fillColor:
                    isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'profile.location'.tr(),
                labelStyle:
                    isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
                filled: true,
                fillColor:
                    isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
            ),

            const SizedBox(height: 32),

// National ID Upload
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile.national_id'.tr(),
                    style:
                        isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'profile.upload_national'.tr(),
                    style:
                        isDark ? AppTheme.bodySmall : AppTheme.bodySmallLight,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final file = await FileUploadService.pickImage(
                        context,
                        title: 'provider.natid'.tr(),
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
                              style: isDark
                                  ? AppTheme.bodyMedium
                                  : AppTheme.bodyMediumLight,
                            ),
                          ),
                          Text(
                            _nationalId != null
                                ? 'will.change'
                                : 'will.upload'.tr(),
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

void _showReviewsDialog(BuildContext context, AuthProvider authProvider) async {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;
  final user = authProvider.user;

  if (user == null) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(color: AppTheme.accentGold),
    ),
  );

  try {
    final reviewsData = await ApiService.getProviderReviews(user.id);
    final reviews = reviewsData['reviews'] as List;

    if (!context.mounted) return;
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.secondaryGray : Colors.white,
        title: Text(
          'profile.my_review (${reviews.length})'.tr(),
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: AppTheme.textGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'profile.no_review'.tr(),
                        style: isDark
                            ? AppTheme.bodyLarge
                            : AppTheme.bodyLargeLight,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'profile.review_appear',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final rating = review['rating'] ?? 0;
                    final comment = review['review'] ?? '';
                    final userId = review['userId'];
                    final userName = userId?['name'] ?? 'Anonymous';
                    final createdAt = review['createdAt'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.primaryBlack
                            : AppTheme.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.borderGray.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    AppTheme.accentGold.withOpacity(0.2),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: AppTheme.accentGold,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: (isDark
                                              ? AppTheme.bodyMedium
                                              : AppTheme.bodyMediumLight)
                                          .copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (createdAt != null)
                                      Text(
                                        _formatDate(createdAt),
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.textGray,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < rating
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 14,
                                    color: AppTheme.accentGold,
                                  );
                                }),
                              ),
                            ],
                          ),
                          if (comment.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              comment,
                              style: (isDark
                                  ? AppTheme.bodySmall
                                  : AppTheme.bodySmallLight),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'will.close'.tr(),
              style: const TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading reviews: $e'),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }
}

String _formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? "month" : "months"} ago';
    }
  } catch (e) {
    return dateStr;
  }
}
