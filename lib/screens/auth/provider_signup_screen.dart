import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/step_indicator.dart';
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
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Beauty & Hair',
    'Tutoring',
    'Delivery',
    'Photography',
    'Repairs',
    'Carpentry',
    'Painting',
    'Gardening',
    'Other'
  ];

  final List<String> _availabilityOptions = [
    'Weekdays (Mon-Fri)',
    'Weekends (Sat-Sun)',
    'Full Week (Mon-Sun)',
    'Flexible Schedule',
    'By Appointment Only'
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
        const SnackBar(
          content: Text('Profile picture is required'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_nationalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('National ID is required'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_businessLicense == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business license is required'),
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
          const SnackBar(
            content: Text('Registration submitted! Awaiting admin approval.'),
            backgroundColor: AppTheme.accentGold,
            duration: Duration(seconds: 3),
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
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Service Provider Registration',
          style: AppTheme.headingSmall,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: StepIndicator(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              stepTitles: const [
                'Basic Info',
                'Service Details',
                'Account Security',
                'Business Details'
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us about yourself and your business',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            // Profile Picture (Required)
            const Text(
              'Profile Picture *',
              style: AppTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            _buildImageUploadSection(
              'Profile Picture',
              Icons.person,
              _profilePicture,
              (file) => setState(() => _profilePicture = file),
              isRequired: true,
            ),
            const SizedBox(height: 20),
            // National ID (Required)
            const Text(
              'National ID *',
              style: AppTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            _buildImageUploadSection(
              'National ID',
              Icons.credit_card,
              _nationalId,
              (file) => setState(() => _nationalId = file),
              isRequired: true,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _providerNameController,
              label: 'Provider Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _serviceNameController,
              label: 'Service/Business Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your service name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Details',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe your services and expertise',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            const Text(
              'Service Category',
              style: AppTheme.bodyLarge,
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
                          : AppTheme.secondaryGray,
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
                            : AppTheme.primaryWhite,
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
              label: 'Service Description',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe your services';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _locationController,
              label: 'Service Location',
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
              label: 'Years of Experience',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Security',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a secure password for your account',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textGray,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppTheme.textGray,
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
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
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
                    'Password Requirements:',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement('At least 6 characters'),
                  _buildPasswordRequirement('Contains letters and numbers'),
                  _buildPasswordRequirement('Unique and secure'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Details',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete your business profile',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            const Text(
              'Availability',
              style: AppTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Column(
              children: _availabilityOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(
                    option,
                    style: AppTheme.bodyMedium,
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
              label: 'Price Range (e.g., 500-1000 ETB)',
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
                color: AppTheme.secondaryGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business License *',
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  _buildPDFUploadSection(
                    'Business License (PDF)',
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.accentGold,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Verification Process',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your information will be reviewed by our admin team. You will receive a verification notification once approved.',
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
                text: 'Back',
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
                      ? 'Submit for Approval'
                      : 'Next',
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
