import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/user_model.dart';
import '../../models/service_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/service_card.dart';
import '../search/search_screen.dart';
import '../payment/payment_screen.dart';
import '../bookings/bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  final double size;
  const HomeScreen({super.key, this.size = 60});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      // Request location permission and get current location
      locationProvider.requestLocationPermission().then((_) {
        if (locationProvider.currentPosition != null) {
          _loadNearbyServices();
        }
      });

      serviceProvider.loadFeaturedServices();
    });
  }

  void _loadNearbyServices() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);

    if (locationProvider.currentPosition != null) {
      serviceProvider.loadNearbyServices(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMapMarkers();
  }

  void _updateMapMarkers() {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    _markers.clear();

    // Add user location marker
    if (locationProvider.currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            locationProvider.currentPosition!.latitude,
            locationProvider.currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add service provider markers
    for (var service in serviceProvider.nearbyServices) {
      if (service.latitude != null && service.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(service.id),
            position: LatLng(service.latitude!, service.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: service.serviceName,
              snippet: '${service.providerName} - ${service.priceRange}',
            ),
          ),
        );
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final user = authProvider.user;
    final isProvider = user?.role == UserRole.provider;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: SafeArea(
        child: isProvider
            ? _buildProviderHome()
            : _buildUserHome(locationProvider, serviceProvider),
      ),
    );
  }

  Widget _buildUserHome(
      LocationProvider locationProvider, ServiceProvider serviceProvider) {
    return Column(
      children: [
        // Header with Logo and App Name
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Hammer
                    Transform.rotate(
                      angle: -0.785398, // -45 degrees
                      child: Icon(
                        Icons.build,
                        size: widget.size * 0.4,
                        color: const Color(0xFF2A2A2A),
                      ),
                    ),
                    // Screwdriver
                    Transform.rotate(
                      angle: 0.785398, // 45 degrees
                      child: Icon(
                        Icons.construction,
                        size: widget.size * 0.4,
                        color: const Color(0xFF2A2A2A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // App Name
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'ProMatch',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showNotifications(context),
                icon: const Icon(Icons.notifications_rounded,
                    color: AppTheme.accentGold),
              ),
            ],
          ),
        ),

        // Google Map
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: locationProvider.currentPosition != null
                  ? GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          locationProvider.currentPosition!.latitude,
                          locationProvider.currentPosition!.longitude,
                        ),
                        zoom: 14.0,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    )
                  : Container(
                      color: AppTheme.secondaryGray,
                      child: Center(
                        child: locationProvider.isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accentGold),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_off_rounded,
                                    size: 48,
                                    color: AppTheme.textGray,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Location access required',
                                    style: AppTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => locationProvider
                                        .requestLocationPermission(),
                                    style: AppTheme.primaryButton,
                                    child: const Text('Enable Location'),
                                  ),
                                ],
                              ),
                      ),
                    ),
            ),
          ),
        ),

        // Search and Action Buttons Section
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppTheme.secondaryGray.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlack,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: AppTheme.textGray.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.textGray,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) _performRealTimeSearch(value);
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SearchScreen(initialQuery: value),
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildActionButton(
                        'Category',
                        Icons.category_rounded,
                        () => _showCategoryDialog(),
                      ),
                      _buildActionButton(
                        'Location',
                        Icons.location_on_rounded,
                        () => _showLocationDialog(),
                      ),
                      _buildActionButton(
                        'Filter/Sort',
                        Icons.filter_list_rounded,
                        () => _showFilterDialog(),
                      ),
                      _buildActionButton(
                        'Favorite',
                        Icons.favorite_rounded,
                        () => _showFavoritesDialog(),
                      ),
                    ],
                  ),
                ),

                // Nearby Services
                if (serviceProvider.nearbyServices.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nearby Services',
                      style: AppTheme.headingSmall.copyWith(
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: serviceProvider.nearbyServices.take(5).length,
                      itemBuilder: (context, index) {
                        final service = serviceProvider.nearbyServices[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          child: ServiceCard(
                            service: service,
                            onTap: () => _handleServiceTap(service),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryBlack,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primaryWhite,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderHome() {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text('Welcome, ${user?.name ?? 'Provider'}',
                  style: AppTheme.headingLarge),
              const Spacer(),
              IconButton(
                icon:
                    const Icon(Icons.notifications, color: AppTheme.accentGold),
                onPressed: () => _showNotifications(context),
              ),
            ],
          ),
        ),

        // Stats (Bookings, Revenue, etc.)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      'Total Bookings',
                      '${serviceProvider.totalBookings}',
                      Icons.book_online,
                      Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      'Total Revenue',
                      'ETB ${serviceProvider.totalRevenue}',
                      Icons.attach_money,
                      Colors.green)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Recent Activity
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              itemCount: serviceProvider.providerBookings.length,
              itemBuilder: (context, index) {
                final booking = serviceProvider.providerBookings[index];
                return _buildRecentActivityCard(
                  booking.serviceName, // service name as title
                  'Customer: ${booking.customerName}', // customer name as subtitle
                  '${booking.scheduledDate.toLocal().toString().split(' ')[0]} ${booking.scheduledTime}', // scheduled date + time
                  Icons.work_outline,
                  Colors.orange,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Icon(
                Icons.trending_up_rounded,
                color: AppTheme.successGreen,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBookings() {
    // Navigate to bookings screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BookingsScreen(),
      ),
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text(
          'Service Categories',
          style: AppTheme.headingSmall,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: _serviceCategories.length,
            itemBuilder: (context, index) {
              final category = _serviceCategories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _searchByCategory(category['name']!);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(category['color'] as int).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 32,
                        color: Color(category['color'] as int),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name']!,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
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

  void _showLocationDialog() {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    final uniqueLocations = serviceProvider.nearbyServices
        .map((service) => service.location)
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text(
          'Provider Locations',
          style: AppTheme.headingSmall,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Location Option
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      color: AppTheme.accentGold,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Current Location',
                            style: AppTheme.bodyMedium,
                          ),
                          Text(
                            locationProvider.currentAddress.isNotEmpty
                                ? locationProvider.currentAddress
                                : 'Location not available',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Available Provider Locations:',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: uniqueLocations.isEmpty
                    ? const Center(
                        child: Text(
                          'No providers found in your area',
                          style: AppTheme.bodySmall,
                        ),
                      )
                    : ListView.builder(
                        itemCount: uniqueLocations.length,
                        itemBuilder: (context, index) {
                          final location = uniqueLocations[index];
                          final providersInLocation = serviceProvider
                              .nearbyServices
                              .where((service) => service.location == location)
                              .length;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.location_on_rounded,
                              color: AppTheme.successGreen,
                              size: 20,
                            ),
                            title: Text(
                              location,
                              style: AppTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              '$providersInLocation provider${providersInLocation > 1 ? 's' : ''}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textGray,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _searchByLocation(location);
                            },
                          );
                        },
                      ),
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

  void _showFilterDialog() {
    String selectedSort = 'distance'; // Default sort option

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.secondaryGray,
          title: const Text(
            'Filter & Sort Options',
            style: AppTheme.headingSmall,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort By:',
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                _buildSortOption(
                  'Distance (Nearest First)',
                  'distance',
                  Icons.near_me_rounded,
                  selectedSort,
                  (value) => setState(() => selectedSort = value),
                ),
                _buildSortOption(
                  'Rating (Highest First)',
                  'rating',
                  Icons.star_rounded,
                  selectedSort,
                  (value) => setState(() => selectedSort = value),
                ),
                _buildSortOption(
                  'Experience (Most Experienced)',
                  'experience',
                  Icons.work_history_rounded,
                  selectedSort,
                  (value) => setState(() => selectedSort = value),
                ),
                _buildSortOption(
                  'Reviews (Most Reviewed)',
                  'reviews',
                  Icons.reviews_rounded,
                  selectedSort,
                  (value) => setState(() => selectedSort = value),
                ),
                _buildSortOption(
                  'Newest Providers',
                  'newest',
                  Icons.new_releases_rounded,
                  selectedSort,
                  (value) => setState(() => selectedSort = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textGray),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _applySorting(selectedSort);
              },
              child: const Text(
                'Apply',
                style: TextStyle(color: AppTheme.accentGold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    String title,
    String value,
    IconData icon,
    String selectedValue,
    Function(String) onChanged,
  ) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentGold.withOpacity(0.1)
              : AppTheme.primaryBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : AppTheme.borderGray,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accentGold : AppTheme.textGray,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color:
                      isSelected ? AppTheme.accentGold : AppTheme.primaryWhite,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.accentGold,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showFavoritesDialog() {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);

    final favoriteServices = serviceProvider.nearbyServices.take(2).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text(
          'Your Favorite Services',
          style: AppTheme.headingSmall,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: favoriteServices.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: AppTheme.textGray,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Favorites Yet',
                        style: AppTheme.bodyLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start adding services to your favorites!',
                        style: AppTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteServices.length,
                  itemBuilder: (context, index) {
                    final service = favoriteServices[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlack,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderGray),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.work_rounded,
                              color: AppTheme.accentGold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.serviceName,
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  service.providerName,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textGray,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: AppTheme.accentGold,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${service.rating.toStringAsFixed(1)} • ${service.location}',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Remove from favorites
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Removed from favorites'),
                                  backgroundColor: AppTheme.errorRed,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.favorite_rounded,
                              color: AppTheme.errorRed,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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

  // Service category data with icons and colors
  final List<Map<String, dynamic>> _serviceCategories = [
    {
      'name': 'Plumbing',
      'icon': Icons.plumbing_rounded,
      'color': 0xFF2196F3, // Blue
    },
    {
      'name': 'Electrical',
      'icon': Icons.electrical_services_rounded,
      'color': 0xFFFFC107, // Amber
    },
    {
      'name': 'Cleaning',
      'icon': Icons.cleaning_services_rounded,
      'color': 0xFF4CAF50, // Green
    },
    {
      'name': 'Beauty & Hair',
      'icon': Icons.face_rounded,
      'color': 0xFFE91E63, // Pink
    },
    {
      'name': 'Tutoring',
      'icon': Icons.school_rounded,
      'color': 0xFF9C27B0, // Purple
    },
    {
      'name': 'Delivery',
      'icon': Icons.delivery_dining_rounded,
      'color': 0xFFFF5722, // Deep Orange
    },
    {
      'name': 'Photography',
      'icon': Icons.camera_alt_rounded,
      'color': 0xFF607D8B, // Blue Grey
    },
    {
      'name': 'Repairs',
      'icon': Icons.build_rounded,
      'color': 0xFF795548, // Brown
    },
    {
      'name': 'Carpentry',
      'icon': Icons.carpenter_rounded,
      'color': 0xFF8BC34A, // Light Green
    },
    {
      'name': 'Painting',
      'icon': Icons.format_paint_rounded,
      'color': 0xFFFF9800, // Orange
    },
    {
      'name': 'Gardening',
      'icon': Icons.grass_rounded,
      'color': 0xFF4CAF50, // Green
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz_rounded,
      'color': 0xFF9E9E9E, // Grey
    },
  ];

  void _searchByCategory(String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialCategory: category),
      ),
    );
  }

  void _searchByLocation(String location) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialLocation: location),
      ),
    );
  }

  void _applySorting(String sortBy) {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    serviceProvider.sortServices(sortBy);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Services sorted by ${_getSortDisplayName(sortBy)}'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  String _getSortDisplayName(String sortBy) {
    switch (sortBy) {
      case 'distance':
        return 'distance';
      case 'rating':
        return 'rating';
      case 'experience':
        return 'experience';
      case 'reviews':
        return 'reviews';
      case 'newest':
        return 'newest providers';
      default:
        return 'distance';
    }
  }

  void _handleServiceTap(ServiceModel service) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);

    if (authProvider.token == null) return;

    // Check if user already has access to this provider
    final hasAccess = await paymentProvider.checkAccess(
      authProvider.token!,
      service.providerId,
      service.id,
    );

    if (hasAccess) {
      // User already has access, show contact info or navigate to chat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have access to this provider'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      // Navigate to payment screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(service: service),
        ),
      );
    }
  }

  void _performRealTimeSearch(String query) {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    serviceProvider.searchServices(query);
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text(
          'Notifications',
          style: AppTheme.headingSmall,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              _buildNotificationItem(
                '✅ Verification Complete',
                'Your provider account has been approved!',
                '2 hours ago',
              ),
              _buildNotificationItem(
                '📅 New Booking',
                'John Doe requested your plumbing service.',
                '1 day ago',
              ),
              _buildNotificationItem(
                '💰 Payment Received',
                'You received ETB 500 for your service.',
                '2 days ago',
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

  Widget _buildNotificationItem(String title, String message, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: AppTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
