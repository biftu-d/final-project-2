import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/service_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/service_model.dart';
import '../bookings/bookings_screen.dart'; // adjust the path

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;
  final String? initialLocation;

  const SearchScreen({
    super.key,
    this.initialCategory,
    this.initialQuery,
    this.initialLocation,
  });

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

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }

    if (widget.initialLocation != null) {
      _locationController.text = widget.initialLocation!;
    }

    // Only call search once if any initial value exists
    if (widget.initialCategory != null ||
        widget.initialQuery != null ||
        widget.initialLocation != null) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);

    try {
      await serviceProvider.searchServices(
        _searchController.text,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        location:
            _locationController.text.isEmpty ? null : _locationController.text,
      );
    } catch (e) {
      print("❌ Search Error: $e");
    }
  }

  Future<String?> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  double _getPrice(ServiceModel service) {
    final parts = service.priceRange.split('-');
    if (parts.isNotEmpty) {
      return double.tryParse(parts[0].trim()) ?? 0.0;
    }
    return 0.0;
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
        title: const Text(
          'Search Services',
          style: AppTheme.headingSmall,
        ),
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
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.textGray),
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
                  prefixIcon: const Icon(Icons.location_on_rounded,
                      color: AppTheme.textGray),
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
                                horizontal: 20, vertical: 8),
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
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.textGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'No services found',
              style: AppTheme.headingSmall,
            ),
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
          child: ServiceCard(
              service: service,
              onTap: () {
                // (optional) open service details page
              },
              onBookNow: () async {
                final token = await getUserToken();
                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ User token not found!')),
                  );
                  return;
                }

                // Example: show a simple dialog to pick date/time before booking
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );

                if (selectedDate == null) return;

                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (selectedTime == null) return;

                // Construct booking payload
                final bookingData = {
                  'serviceId': service.id,
                  'providerId': service.providerId,
                  'scheduledDate': selectedDate.toIso8601String(),
                  'scheduledTime': selectedTime.format(context),
                  'location': _locationController.text.isNotEmpty
                      ? _locationController.text
                      : service.location,
                  'notes': '',
                  'price': _getPrice(
                      service), // you can add a field for notes if needed
                };

                try {
                  await ApiService.createBooking(token, bookingData);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Booking successful!')),
                  );
                  // Refresh bookings
                  final serviceProvider =
                      Provider.of<ServiceProvider>(context, listen: false);
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);

                  if (authProvider.user?.role == UserRole.provider) {
                    await serviceProvider
                        .loadProviderBookings(authProvider.token!);
                  } else {
                    await serviceProvider.loadUserBookings(authProvider.token!);
                  }

                  // Navigate to BookingScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingsScreen()),
                  );
                  // adjust your route
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Booking failed: $e')),
                  );
                }
              }),
        );
      },
    );
  }

  Widget _buildMapView() {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);

    // if no providers or location text is empty → show your placeholder
    if (serviceProvider.services.isEmpty || _locationController.text.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        height: 300,
        decoration: BoxDecoration(
          color: AppTheme.secondaryGray,
          borderRadius: BorderRadius.circular(20),
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

    // convert all provider addresses to coordinates
    Future<List<Marker>> getProviderMarkers() async {
      List<Marker> markers = [];

      for (var s in serviceProvider.services) {
        if (s.location.isNotEmpty) {
          try {
            final results = await locationFromAddress(s.location);
            if (results.isNotEmpty) {
              final loc = results.first;
              markers.add(
                Marker(
                  markerId: MarkerId(s.id.toString()),
                  position: LatLng(loc.latitude, loc.longitude),
                  infoWindow: InfoWindow(
                    title: s.name,
                    snippet: s.category,
                  ),
                ),
              );
            }
          } catch (e) {
            print("❌ Could not geocode ${s.location}: $e");
          }
        }
      }

      return markers;
    }

    return FutureBuilder<List<Marker>>(
      future: getProviderMarkers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            height: 300,
            decoration: BoxDecoration(
              color: AppTheme.secondaryGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final markers = snapshot.data ?? [];
        if (markers.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            height: 300,
            decoration: BoxDecoration(
              color: AppTheme.secondaryGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text("❌ No provider locations found"),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          height: 300,
          decoration: BoxDecoration(
            color: AppTheme.secondaryGray,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: markers.first.position, // focus on first provider
              zoom: 13,
            ),
            markers: markers.toSet(),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
        );
      },
    );
  }
}
