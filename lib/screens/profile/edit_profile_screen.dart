import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../services/file_upload_service.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  File? _profileImage;
  File? _nationalIdImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    _bioController.text = user?.bio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isProfilePic) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isProfilePic) {
            _profileImage = File(image.path);
          } else {
            _nationalIdImage = File(image.path);
          }
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog(bool isProfilePic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isProfilePic);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isProfilePic);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        _showError('Not authenticated');
        return;
      }

      Map<String, dynamic> updates = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      if (_bioController.text.isNotEmpty) {
        updates['bio'] = _bioController.text.trim();
      }

      // Upload profile picture if changed
      if (_profileImage != null) {
        final uploadService = FileUploadService();
        final profilePicUrl = await uploadService.uploadFile(
          _profileImage!,
          'profile_pictures',
          authProvider.user!.id,
        );
        updates['profilePicture'] = profilePicUrl;
      }

      // Upload national ID if changed (for users)
      final isProvider = authProvider.user?.role == UserRole.provider;
      if (!isProvider && _nationalIdImage != null) {
        final uploadService = FileUploadService();
        final nationalIdUrl = await uploadService.uploadFile(
          _nationalIdImage!,
          'national_ids',
          authProvider.user!.id,
        );
        updates['nationalId'] = nationalIdUrl;
      }

      // Check if this is a resubmission (provider with rejected status)
      final isRejectedProvider =
          isProvider && authProvider.user?.verificationStatus == 'rejected';

      // Update profile on backend or resubmit application
      final response = isRejectedProvider
          ? await ApiService.resubmitApplication(token, updates)
          : await ApiService.updateProfile(token, updates);

      if (response['success'] == true) {
        // Update local user data
        final updatedUser = User.fromJson(response['user']);
        authProvider.updateUser(updatedUser);

        if (mounted) {
          final message = isRejectedProvider
              ? 'Application resubmitted successfully'
              : 'Profile updated successfully';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        _showError(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _showError('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isProvider = user?.role == UserRole.provider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color: AppTheme.accentGold,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: _profileImage != null
                            ? Image.file(
                                _profileImage!,
                                fit: BoxFit.cover,
                              )
                            : user?.profilePicture != null
                                ? Image.network(
                                    user!.profilePicture!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        isProvider
                                            ? Icons.business_rounded
                                            : Icons.person_rounded,
                                        size: 50,
                                        color: AppTheme.accentGold,
                                      );
                                    },
                                  )
                                : Icon(
                                    isProvider
                                        ? Icons.business_rounded
                                        : Icons.person_rounded,
                                    size: 50,
                                    color: AppTheme.accentGold,
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showImageSourceDialog(true),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: const Icon(Icons.person),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),

              // Phone Field
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+251912345678',
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                validator: Validators.validateEthiopianPhone,
              ),
              const SizedBox(height: 16),

              // Bio Field (optional)
              CustomTextField(
                controller: _bioController,
                label: 'Bio (Optional)',
                hint: 'Tell us about yourself',
                prefixIcon: const Icon(Icons.info),
                maxLines: 3,
              ),

              // National ID for users only
              if (!isProvider) ...[
                const SizedBox(height: 24),
                const Text(
                  'National ID Document',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showImageSourceDialog(false),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.accentGold,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.accentGold.withOpacity(0.1),
                    ),
                    child: _nationalIdImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _nationalIdImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : user?.nationalId != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  user!.nationalId!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 50,
                                            color: AppTheme.accentGold,
                                          ),
                                          SizedBox(height: 8),
                                          Text('Tap to upload National ID'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: AppTheme.accentGold,
                                    ),
                                    SizedBox(height: 8),
                                    Text('Tap to upload National ID'),
                                  ],
                                ),
                              ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
