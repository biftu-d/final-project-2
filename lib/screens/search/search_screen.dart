import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/service_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;

  const SearchScreen({super.key, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedCategory;
  bool _isMapView = false;

  final List<String> _categories = [
    'All',
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
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    if (widget.initialCategory != null) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final serviceProvider = Provider.of<ServiceProvider>(
      context,
      listen: false,
    );
    serviceProvider.searchServices(
      _searchController.text,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      location:
          _locationController.text.isEmpty ? null : _locationController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Search Services', style: AppTheme.headingSmall),
        actions: [
          IconButton(
            icon: Icon(
              _isMapView ? Icons.list_rounded : Icons.map_rounded,
              color: AppTheme.primaryWhite,
            ),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Filters
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Search Bar
                CustomTextField(
                  controller: _searchController,
                  label: 'Search services...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.textGray,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _performSearch();
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Location Filter
                CustomTextField(
                  controller: _locationController,
                  label: 'Location (optional)',
                  prefixIcon: const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.textGray,
                  ),
                  onChanged: (value) => _performSearch(),
                ),
                const SizedBox(height: 16),
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == _categories.length - 1 ? 0 : 12,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _performSearch();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.accentGold
                                  : AppTheme.secondaryGray,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: AppTheme.bodySmall.copyWith(
                                color: isSelected
                                    ? AppTheme.primaryBlack
                                    : AppTheme.primaryWhite,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child:
                _isMapView ? _buildMapView() : _buildListView(serviceProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(ServiceProvider serviceProvider) {
    if (serviceProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
        ),
      );
    }

    if (serviceProvider.services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textGray),
            const SizedBox(height: 16),
            const Text('No services found', style: AppTheme.headingSmall),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textGray),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      itemCount: serviceProvider.services.length,
      itemBuilder: (context, index) {
        final service = serviceProvider.services[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ServiceCard(service: service),
        );
      },
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: AppTheme.secondaryGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, size: 64, color: AppTheme.textGray),
            SizedBox(height: 16),
            Text('Map View', style: AppTheme.headingSmall),
            SizedBox(height: 8),
            Text('Map integration coming soon', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
