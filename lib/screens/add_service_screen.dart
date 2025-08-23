import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();

  String _selectedCategory = '';
  final List<String> _selectedAvailability = [];

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
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _priceRangeController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _createService() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service category'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_selectedAvailability.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your availability'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      final serviceData = {
        'serviceName': _serviceNameController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'priceRange': _priceRangeController.text.trim(),
        'availability': _selectedAvailability,
        'experience': int.tryParse(_experienceController.text) ?? 0,
      };

      final success = await serviceProvider.createService(
        authProvider.token!,
        serviceData,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service created successfully!'),
            backgroundColor: AppTheme.successGreen,
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
          'Add New Service',
          style: AppTheme.headingSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _serviceNameController,
                label: 'Service Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Selection
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                    return 'Please describe your service';
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
                    return 'Please enter service location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _priceRangeController,
                label: 'Price Range (e.g., 500-1000 ETB)',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price range';
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
                    return 'Please enter years of experience';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Availability Selection
              const Text(
                'Availability',
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Column(
                children: _availabilityOptions.map((day) {
                  final isSelected = _selectedAvailability.contains(day);
                  return CheckboxListTile(
                    title: Text(day, style: AppTheme.bodyMedium),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedAvailability.add(day);
                        } else {
                          _selectedAvailability.remove(day);
                        }
                      });
                    },
                    activeColor: AppTheme.accentGold,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              Consumer<ServiceProvider>(
                builder: (context, serviceProvider, child) {
                  return CustomButton(
                    text: 'Create Service',
                    onPressed:
                        serviceProvider.isLoading ? null : _createService,
                    isLoading: serviceProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
