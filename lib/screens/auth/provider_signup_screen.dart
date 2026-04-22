import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/language_selector.dart';
import '../../services/file_upload_service.dart';
import '../main_navigation.dart';

class ProviderSignupScreen extends StatefulWidget {
  const ProviderSignupScreen({super.key});

  @override
  State<ProviderSignupScreen> createState() => _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends State<ProviderSignupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form keys for each step
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Controllers for all fields
  final _providerNameController = TextEditingController();
  final _serviceNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _priceRangeController = TextEditingController();

  // File variables
  File? _profilePicture;
  File? _nationalId;
  File? _businessLicense;

  String _selectedCategory = '';
  String _selectedAvailability = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final bool _hasBusinessLicense = false;

  final List<String> _serviceCategories = [
    'provider.plum'.tr(),
    'provider.elec'.tr(),
    'provider.mech'.tr()
  ];

  final List<String> _availabilityOptions = [
    'provider.wek'.tr(),
    'provider.week'.tr(),
    'provider.full'.tr(),
    'provider.flex'.tr(),
    'provider.byap'.tr()
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _providerNameController.dispose();
    _serviceNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _priceRangeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_formKeys[_currentStep].currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKeys[_currentStep].currentState!.validate()) return;

    // Validate required files
    if (_profilePicture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('provider.ppreq'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_nationalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('provider.natreq'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_businessLicense == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('provider.busreq'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userData = {
        'name': _providerNameController.text.trim(),
        'serviceName': _serviceNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'password': _passwordController.text,
        'priceRange': _priceRangeController.text.trim(),
        'availability': _selectedAvailability,
        'profilePicture': _profilePicture?.path,
        'nationalId': _nationalId?.path,
        'businessLicense': _businessLicense?.path,
        'verificationStatus': 'pending', // Will be approved by admin
      };

      final success = await authProvider.register(userData, UserRole.provider);

      if (success && mounted) {
        // Show pending verification message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('provider.regsubmitted'.tr()),
            backgroundColor: AppTheme.accentGold,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
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
        title: Text(
          'provider.service_provide'.tr(),
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        actions: [
          LanguageSelector(isDarkMode: isDark),
          const ThemeToggleButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: StepIndicator(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              stepTitles: [
                'provider.basic'.tr(),
                'provider.servdetail'.tr(),
                'provider.accsecur'.tr(),
                'provider.busdet'.tr()
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildServiceDetailsStep(),
                _buildAccountSecurityStep(),
                _buildBusinessDetailsStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'provider.basic'.tr(),
              style:
                  isDark ? AppTheme.headingMedium : AppTheme.headingMediumLight,
            ),
            const SizedBox(height: 8),
            Text(
              'provider.tellus'.tr(),
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
            ),
            const SizedBox(height: 30),
            // Profile Picture (Required)
            Text(
              'provider.pp'.tr(),
              style: isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight,
            ),
            const SizedBox(height: 10),
            _buildImageUploadSection(
              'provider.pp'.tr(),
              Icons.person,
              _profilePicture,
              (file) => setState(() => _profilePicture = file),
              isRequired: true,
            ),
            const SizedBox(height: 20),
            // National ID (Required)
            Text(
              'provider.natid'.tr(),
              style: isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight,
            ),
            const SizedBox(height: 10),
            _buildImageUploadSection(
              'provider.natid'.tr(),
              Icons.credit_card,
              _nationalId,
              (file) => setState(() => _nationalId = file),
              isRequired: true,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _providerNameController,
              label: 'provider.pname'.tr(),
              validator: Validators.validateName,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _serviceNameController,
              label: 'provider.busname'.tr(),
              validator: Validators.validateServiceName,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _emailController,
              label: 'auth.email'.tr(),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _phoneController,
              label: 'auth.pnumber'.tr(),
              keyboardType: TextInputType.phone,
              validator: Validators.validateEthiopianPhone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsStep() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'provider.servdetail'.tr(),
              style:
                  isDark ? AppTheme.headingMedium : AppTheme.headingMediumLight,
            ),
            const SizedBox(height: 8),
            Text(
              'provider.descurser'.tr(),
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
            ),
            const SizedBox(height: 30),
            Text(
              'provider.servcat'.tr(),
              style: isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _serviceCategories.map((category) {
                final isSelected = _selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentGold
                          : (isDark
                              ? AppTheme.secondaryGray
                              : AppTheme.lightCard),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.accentGold
                            : AppTheme.borderGray,
                      ),
                    ),
                    child: Text(
                      category,
                      style: AppTheme.bodySmall.copyWith(
                        color: isSelected
                            ? AppTheme.primaryBlack
                            : (isDark
                                ? AppTheme.primaryWhite
                                : AppTheme.lightText),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _descriptionController,
              label: 'provider.servdesc'.tr(),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'provider.pleasedesc'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _locationController,
              label: 'provider.servloc'.tr(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your service location';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _experienceController,
              label: 'provider.yearex'.tr(),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your years of experience';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSecurityStep() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'provider.accsecur'.tr(),
              style:
                  isDark ? AppTheme.headingMedium : AppTheme.headingMediumLight,
            ),
            const SizedBox(height: 8),
            Text(
              'provider.creatsec'.tr(),
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: _passwordController,
              label: 'auth.password'.tr(),
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color:
                      isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'auth.confirm_password'.tr(),
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color:
                      isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'auth.passwords_dont_match'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.secondaryGray : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'auth.passreq'.tr(),
                    style:
                        isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement('auth.passatleast'.tr()),
                  _buildPasswordRequirement('auth.passcontain'.tr()),
                  _buildPasswordRequirement('auth.passunique'.tr()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppTheme.successGreen,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsStep() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'provider.busdet'.tr(),
              style:
                  isDark ? AppTheme.headingMedium : AppTheme.headingMediumLight,
            ),
            const SizedBox(height: 8),
            Text(
              'provider.completebp'.tr(),
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
            ),
            const SizedBox(height: 30),
            Text(
              'provider.avail'.tr(),
              style: isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight,
            ),
            const SizedBox(height: 10),
            Column(
              children: _availabilityOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(
                    option,
                    style:
                        isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
                  ),
                  value: option,
                  groupValue: _selectedAvailability,
                  onChanged: (value) {
                    setState(() {
                      _selectedAvailability = value!;
                    });
                  },
                  activeColor: AppTheme.accentGold,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _priceRangeController,
              label: 'provider.pricerange'.tr(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your price range';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.secondaryGray : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'provider.buslic'.tr(),
                    style:
                        isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight,
                  ),
                  const SizedBox(height: 10),
                  _buildPDFUploadSection(
                    'provider.buspdf'.tr(),
                    Icons.description,
                    _businessLicense,
                    (file) => setState(() => _businessLicense = file),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.accentGold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'provider.verfproc'.tr(),
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'provider.reviewed'.tr(),
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(
    String title,
    IconData icon,
    File? currentFile,
    Function(File?) onFileSelected, {
    bool isRequired = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              currentFile != null ? AppTheme.successGreen : AppTheme.borderGray,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                currentFile != null ? AppTheme.successGreen : AppTheme.textGray,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title + (isRequired ? ' *' : ''),
                  style: AppTheme.bodyMedium,
                ),
                if (currentFile != null)
                  Text(
                    FileUploadService.getFileName(currentFile.path),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.successGreen,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final file = await FileUploadService.pickImage(context);
              if (file != null) {
                onFileSelected(file);
              }
            },
            child: Text(
              currentFile != null ? 'Change' : 'Upload',
              style: const TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFUploadSection(
    String title,
    IconData icon,
    File? currentFile,
    Function(File?) onFileSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              currentFile != null ? AppTheme.successGreen : AppTheme.borderGray,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                currentFile != null ? AppTheme.successGreen : AppTheme.textGray,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium,
                ),
                if (currentFile != null) ...[
                  Text(
                    FileUploadService.getFileName(currentFile.path),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.successGreen,
                    ),
                  ),
                  Text(
                    FileUploadService.getFileSize(currentFile),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final file = await FileUploadService.pickPDF(context);
              if (file != null) {
                onFileSelected(file);
              }
            },
            child: Text(
              currentFile != null ? 'Change' : 'Upload',
              style: const TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'will.back'.tr(),
                onPressed: _previousStep,
                backgroundColor: AppTheme.secondaryGray,
                textColor: AppTheme.primaryWhite,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return CustomButton(
                  text: _currentStep == _totalSteps - 1
                      ? 'will.subapp'.tr()
                      : 'will.next'.tr(),
                  onPressed: authProvider.isLoading ? null : _nextStep,
                  isLoading: authProvider.isLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
