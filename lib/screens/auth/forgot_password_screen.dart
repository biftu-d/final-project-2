import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success =
          await authProvider.requestPasswordReset(_emailController.text.trim());

      if (success && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                ? AppTheme.secondaryGray
                : AppTheme.lightSurface,
            title: Text(
              'auth.check_email'.tr(),
              style: Provider.of<ThemeProvider>(context).isDarkMode
                  ? AppTheme.headingSmall
                  : AppTheme.headingSmallLight,
            ),
            content: Text(
              'auth.reset_link_sent'.tr(),
              style: Provider.of<ThemeProvider>(context).isDarkMode
                  ? AppTheme.bodyMedium
                  : AppTheme.bodyMediumLight,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'will.ok'.tr(),
                  style: const TextStyle(color: AppTheme.accentGold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? AppTheme.primaryWhite : AppTheme.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'auth.reset_password'.tr(),
                  style: isDark
                      ? AppTheme.headingLarge
                      : AppTheme.headingLargeLight,
                ),
                const SizedBox(height: 8),
                Text(
                  'auth.reset_password_instruction'.tr(),
                  style: isDark
                      ? AppTheme.bodyLarge.copyWith(color: AppTheme.textGray)
                      : AppTheme.bodyLargeLight
                          .copyWith(color: AppTheme.lightTextSecondary),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  label: 'auth.email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'auth.send_reset_link'.tr(),
                  onPressed: _isLoading ? null : _requestPasswordReset,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'auth.back_to_login'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
