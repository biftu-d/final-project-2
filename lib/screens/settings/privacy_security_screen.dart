import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

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
          'Privacy & Security',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.lock_reset_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            icon: Icons.security_rounded,
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            onTap: () => _show2FADialog(context),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_rounded,
            title: 'Data & Privacy',
            subtitle: 'Manage your data and privacy settings',
            onTap: () => _showDataPrivacyDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.getCardDecoration(isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.accentGold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        (isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight)
                            .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                        AppTheme.bodySmall.copyWith(color: AppTheme.textGray),
                  ),
                ],
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

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor:
              isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
          title: Text(
            'Change Password',
            style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: currentPasswordController,
                  label: 'Current Password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: newPasswordController,
                  label: 'New Password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: confirmPasswordController,
                  label: 'Confirm New Password',
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: (isDark
                                ? AppTheme.bodySmall
                                : AppTheme.bodySmallLight)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• At least 8 characters\n'
                        '• One uppercase letter\n'
                        '• One lowercase letter\n'
                        '• One number\n'
                        '• One special character',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textGray,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color:
                      isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (currentPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.accentGold),
                  ),
                );

                try {
                  await ApiService.changePassword(
                    authProvider.token!,
                    currentPasswordController.text,
                    newPasswordController.text,
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully!'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              },
              child: const Text(
                'Change Password',
                style: TextStyle(color: AppTheme.accentGold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _show2FADialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
        title: Text(
          'Two-Factor Authentication',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2FA adds an extra layer of security to your account by requiring a verification code sent to your email.',
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppTheme.accentGold, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'ll receive a 6-digit code via email',
                      style: AppTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGold),
                ),
              );

              try {
                final response = await ApiService.setup2FA(authProvider.token!);

                if (!context.mounted) return;
                Navigator.pop(context);

                if (response['success']) {
                  _show2FAVerificationDialog(context, response['email']);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message']),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            child: const Text(
              'Enable 2FA',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  void _show2FAVerificationDialog(BuildContext context, String email) {
    final codeController = TextEditingController();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
        title: Text(
          'Enter Verification Code',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A 6-digit code has been sent to $email',
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: codeController,
              label: 'Verification Code',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (codeController.text.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a 6-digit code'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGold),
                ),
              );

              try {
                final response = await ApiService.verify2FA(
                  authProvider.token!,
                  codeController.text,
                );

                if (!context.mounted) return;
                Navigator.pop(context);

                if (response['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('2FA enabled successfully!'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message']),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            child: const Text(
              'Verify',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDataPrivacyDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
        title: Text(
          'Data & Privacy',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy Matters',
                style: (isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'We take your privacy seriously and are committed to protecting your personal data.',
                style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
              ),
              const SizedBox(height: 16),
              _buildPrivacyOption(
                context,
                'Download My Data',
                'Get a copy of all your data',
                Icons.download_rounded,
                () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.accentGold),
                    ),
                  );

                  try {
                    final response = await ApiService.exportUserData(
                      authProvider.token!,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    if (response['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data export ready! Check your email.'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message']),
                          backgroundColor: AppTheme.errorRed,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildPrivacyOption(
                context,
                'Privacy Policy',
                'Read our privacy policy',
                Icons.policy_rounded,
                () {
                  Navigator.pop(context);
                  _showPrivacyPolicyDialog(context);
                },
              ),
              const SizedBox(height: 12),
              _buildPrivacyOption(
                context,
                'Data Usage',
                'See how we use your data',
                Icons.info_outline_rounded,
                () {
                  Navigator.pop(context);
                  _showDataUsageDialog(context);
                },
              ),
            ],
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

  Widget _buildPrivacyOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderGray.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isDark
                            ? AppTheme.bodyMedium
                            : AppTheme.bodyMediumLight)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppTheme.textGray,
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
        title: Text(
          'Privacy Policy',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              'ProMatch Privacy Policy\n\n'
              '1. Information We Collect\n'
              'We collect information you provide directly to us, including name, email, phone number, and location data.\n\n'
              '2. How We Use Your Information\n'
              '• To provide and improve our services\n'
              '• To connect you with service providers\n'
              '• To send important notifications\n'
              '• To prevent fraud and abuse\n\n'
              '3. Information Sharing\n'
              'We do not sell your personal information. We share data only with service providers you choose to connect with.\n\n'
              '4. Data Security\n'
              'We implement strong security measures to protect your data, including encryption and secure storage.\n\n'
              '5. Your Rights\n'
              'You have the right to access, update, or delete your data at any time.\n\n'
              '6. Contact Us\n'
              'For privacy concerns, contact us at privacy@promatch.et',
              style: isDark ? AppTheme.bodySmall : AppTheme.bodySmallLight,
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

  void _showDataUsageDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
        title: Text(
          'Data Usage',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How We Use Your Data',
                  style: (isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildDataUsageItem(
                  'Profile Information',
                  'Used to create your account and display to service providers',
                  Icons.person_rounded,
                ),
                _buildDataUsageItem(
                  'Location Data',
                  'Used to find nearby service providers and show relevant services',
                  Icons.location_on_rounded,
                ),
                _buildDataUsageItem(
                  'Contact Information',
                  'Used to send notifications and allow providers to contact you',
                  Icons.contact_phone_rounded,
                ),
                _buildDataUsageItem(
                  'Payment Information',
                  'Securely processed through Chapa for booking payments',
                  Icons.payment_rounded,
                ),
                _buildDataUsageItem(
                  'Usage Analytics',
                  'Used to improve app performance and user experience',
                  Icons.analytics_rounded,
                ),
              ],
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

  Widget _buildDataUsageItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.accentGold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textGray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
