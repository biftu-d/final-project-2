import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/user_model.dart';
import '../../models/service_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/service_card.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/language_selector.dart';
import '../../services/navigation_service.dart';
import '../../services/api_service.dart';
import '../search/search_screen.dart';
import '../payment/payment_screen.dart';
import '../bookings/bookings_screen.dart';
import '../notifications/notifications_screen.dart';

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
  String _selectedSort = 'distance';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final user = authProvider.user;
    final isProvider = user?.role == UserRole.provider;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? AppTheme.primaryBlack
          : AppTheme.lightBackground,
      body: SafeArea(
        child: isProvider
            ? _buildProviderHome(themeProvider)
            : _buildUserHome(locationProvider, serviceProvider, themeProvider),
      ),
    );
  }

  Widget _buildUserHome(LocationProvider locationProvider,
      ServiceProvider serviceProvider, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    final unread = context.watch<NotificationProvider>().unreadCount;
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
              const Spacer(),
              // Notification bell
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      color:
                          isDark ? AppTheme.primaryWhite : AppTheme.lightText,
                      size: 26,
                    ),
                    if (unread > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              LanguageSelector(isDarkMode: themeProvider.isDarkMode),
              const SizedBox(width: 8),
              const ThemeToggleButton(),
            ],
          ),
        ),

        // Google Map
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
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
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                  )
                : Container(
                    color:
                        isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
                    child: Center(
                      child: locationProvider.isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentGold),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off_rounded,
                                  size: 40,
                                  color: isDark
                                      ? AppTheme.textGray
                                      : AppTheme.lightTextSecondary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'home.locreq'.tr(),
                                  style: isDark
                                      ? AppTheme.bodyMedium
                                      : AppTheme.bodyMediumLight,
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
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? const Color.fromARGB(255, 31, 31, 30).withOpacity(0.75)
                  : const Color.fromARGB(255, 173, 173, 171).withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? AppTheme.primaryWhite
                        : AppTheme.lightSurface,
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
                      hintText: 'home.search'.tr(),
                      hintStyle: TextStyle(
                        color: themeProvider.isDarkMode
                            ? AppTheme.textGray.withOpacity(0.7)
                            : AppTheme.lightTextSecondary,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: themeProvider.isDarkMode
                            ? AppTheme.textGray
                            : AppTheme.lightTextSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? AppTheme.primaryBlack
                          : AppTheme.lightText,
                    ),
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

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildActionButton(
                        'home.category'.tr(),
                        Icons.category_rounded,
                        () => _showCategoryDialog(),
                      ),
                      _buildActionButton(
                        'home.location'.tr(),
                        Icons.location_on_rounded,
                        () => _showLocationDialog(),
                      ),
                      _buildActionButton(
                        'home.filter_sort'.tr(),
                        Icons.filter_list_rounded,
                        () => _showFilterDialog(),
                      ),
                      _buildActionButton(
                        'home.favorite'.tr(),
                        Icons.favorite_rounded,
                        () => _showFavoritesDialog(),
                      ),
                    ],
                  ),
                ),

                if (serviceProvider.nearbyServices.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'home.nearby_services'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                        fontFamily: 'Inter',
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
          color: const Color.fromARGB(129, 255, 255, 255),
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
              color: AppTheme.primaryBlack,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderHome(ThemeProvider themeProvider) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final bookings = serviceProvider.providerBookings;
    final unread = context.watch<NotificationProvider>().unreadCount;

    // Calculate statistics
    final totalBookings = bookings.length;
    final pendingBookings =
        bookings.where((b) => b.status.name == 'pending').length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'welcome.provider_dashboard'.tr(),
                style:
                    isDark ? AppTheme.headingLarge : AppTheme.headingLargeLight,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_rounded,
                          color: isDark
                              ? AppTheme.primaryWhite
                              : AppTheme.lightText,
                          size: 26,
                        ),
                        if (unread > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(
                                  minWidth: 16, minHeight: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  LanguageSelector(isDarkMode: themeProvider.isDarkMode),
                  const SizedBox(width: 8),
                  const ThemeToggleButton(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: locationProvider.currentPosition != null
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          locationProvider.currentPosition!.latitude,
                          locationProvider.currentPosition!.longitude,
                        ),
                        zoom: 14.0,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('provider_location'),
                          position: LatLng(
                            locationProvider.currentPosition!.latitude,
                            locationProvider.currentPosition!.longitude,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueYellow),
                          infoWindow: InfoWindow(title: 'home.urloc'.tr()),
                        ),
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                    )
                  : Container(
                      color: isDark
                          ? AppTheme.secondaryGray
                          : AppTheme.lightSurface,
                      child: Center(
                        child: locationProvider.isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accentGold),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off_rounded,
                                    size: 40,
                                    color: isDark
                                        ? AppTheme.textGray
                                        : AppTheme.lightTextSecondary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'home.locaccessreq'.tr(),
                                    style: isDark
                                        ? AppTheme.bodyMedium
                                        : AppTheme.bodyMediumLight,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => locationProvider
                                        .requestLocationPermission(),
                                    style: AppTheme.primaryButton,
                                    child: Text('home.enable_loc'.tr()),
                                  ),
                                ],
                              ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Navigate Map Button
          GestureDetector(
            onTap: () async {
              // Step 1: Check permission first
              bool hasPermission =
                  await locationProvider.requestLocationPermission();

              if (!hasPermission) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('home.loc_permreq'.tr()),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
                return;
              }

              // Step 2: If we already have a cached location → use it immediately (FAST)
              if (locationProvider.currentPosition != null) {
                final cachedPosition = locationProvider.currentPosition!;

                await NavigationService.openGoogleMapsNavigation(
                  destinationLatitude: cachedPosition.latitude,
                  destinationLongitude: cachedPosition.longitude,
                );
              }

              // Step 3: Always try to get fresh GPS location (ACCURATE)
              await locationProvider.getCurrentLocation();

              final updatedPosition = locationProvider.currentPosition;

              // Step 4: If updated location is available → use it (more accurate)
              if (updatedPosition != null) {
                await NavigationService.openGoogleMapsNavigation(
                  destinationLatitude: updatedPosition.latitude,
                  destinationLongitude: updatedPosition.longitude,
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.navigation_rounded,
                    color: AppTheme.primaryBlack,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'home.navigate_map'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlack,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.getCardDecoration(themeProvider.isDarkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome.welcome_back'.tr(),
                  style: themeProvider.isDarkMode
                      ? AppTheme.headingMedium
                      : AppTheme.headingMediumLight,
                ),
                const SizedBox(height: 8),
                Text(
                  'home.business_performance'.tr(),
                  style: themeProvider.isDarkMode
                      ? AppTheme.bodyMedium
                      : AppTheme.bodyMediumLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'home.overview'.tr(),
            style: themeProvider.isDarkMode
                ? AppTheme.headingSmall
                : AppTheme.headingSmallLight,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                'home.total_bookings'.tr(),
                totalBookings.toString(),
                Icons.calendar_today_rounded,
                AppTheme.accentGold,
                themeProvider.isDarkMode,
              ),
              _buildStatCard(
                'home.pending_requests'.tr(),
                pendingBookings.toString(),
                Icons.pending_actions_rounded,
                Colors.orange,
                themeProvider.isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'home.quick_actions'.tr(),
            style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 12),
          _buildQuickActionCard(
            'home.update_availability'.tr(),
            'home.manage_working_hours'.tr(),
            Icons.schedule_rounded,
            AppTheme.successGreen,
            () => _showAvailabilityDialog(themeProvider),
            themeProvider.isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildQuickActionCard(
            'home.view_analytics'.tr(),
            'home.detailed_performance'.tr(),
            Icons.analytics_rounded,
            Colors.blue,
            () => _showAnalyticsDialog(themeProvider),
            themeProvider.isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.getCardDecoration(isDark),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.getCardDecoration(isDark),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? AppTheme.primaryWhite : AppTheme.lightText,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.textGray
                          : AppTheme.lightTextSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showAvailabilityDialog(ThemeProvider themeProvider) {
    Map<String, bool> availability = {
      'monday': true,
      'tuesday': true,
      'wednesday': false,
      'thursday': true,
      'friday': true,
      'saturday': false,
      'sunday': false,
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: themeProvider.isDarkMode
                  ? AppTheme.secondaryGray
                  : AppTheme.lightSurface,
              title: Text(
                'home.update_availability'.tr(),
                style: themeProvider.isDarkMode
                    ? AppTheme.headingSmall
                    : AppTheme.headingSmallLight,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: availability.keys.map((day) {
                    return CheckboxListTile(
                      title: Text(
                        'home.$day'.tr(),
                        style: themeProvider.isDarkMode
                            ? AppTheme.bodyMedium
                            : AppTheme.bodyMediumLight,
                      ),
                      value: availability[day],
                      activeColor: AppTheme.accentGold,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          availability[day] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'will.cancel'.tr(),
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? AppTheme.textGray
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    // 🔥 DEBUG (see selected days)
                    print("Selected availability: $availability");

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Availability updated!'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                  child: Text(
                    'will.update'.tr(),
                    style: const TextStyle(color: AppTheme.accentGold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAnalyticsDialog(ThemeProvider themeProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final bookings = serviceProvider.providerBookings;

    final totalBookings = bookings.length;

    // Compute analytics values
    final completedBookings =
        bookings.where((b) => b.status.name == 'completed').length;

    final pendingBookings = bookings
        .where((b) => b.status.name == 'pending')
        .length; // or your real metric
    final bookingsThisMonth = serviceProvider.providerBookings
        .where((b) => b.createdAt.month == DateTime.now().month)
        .length;
    final averageRating = serviceProvider.providerBookings.isEmpty
        ? 0
        : serviceProvider.providerBookings
                .map((b) => b.rating ?? 0)
                .reduce((a, b) => a + b) /
            serviceProvider.providerBookings.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode
            ? AppTheme.secondaryGray
            : AppTheme.lightSurface,
        title: Text(
          'home.analytics_overview'.tr(),
          style: themeProvider.isDarkMode
              ? AppTheme.headingSmall
              : AppTheme.headingSmallLight,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              _buildAnalyticsItem('Total Bookings', totalBookings.toString(),
                  Icons.calendar_today, isDark),
              _buildAnalyticsItem('Pending Requests',
                  pendingBookings.toString(), Icons.pending_actions, isDark),
              _buildAnalyticsItem('Bookings This Month',
                  bookingsThisMonth.toString(), Icons.calendar_today, isDark),
              _buildAnalyticsItem('Average Rating',
                  averageRating.toStringAsFixed(1), Icons.star, isDark),
              _buildAnalyticsItem('Completed Jobs',
                  completedBookings.toString(), Icons.check_circle, isDark),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'will.close'.tr(),
              style: const TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(
      String title, String value, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.primaryWhite : AppTheme.lightText,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentGold,
              fontFamily: 'Inter',
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
        title: Text(
          'home.serv_category'.tr(),
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
            child: Text(
              'will.close'.tr(),
              style: const TextStyle(color: AppTheme.accentGold),
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
        title: Text(
          'home.provider_loc'.tr(),
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
                          Text(
                            'home.urcurrentloc'.tr(),
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
              Text(
                'home.available_provloc'.tr(),
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: uniqueLocations.isEmpty
                    ? Center(
                        child: Text(
                          'home.no_provider_found'.tr(),
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
              'will.close',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.secondaryGray,
          title: Text(
            'home.filterandsort'.tr(),
            style: AppTheme.headingSmall,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.sort_by'.tr(),
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                _buildSortOption(
                  'home.distance'.tr(),
                  'distance',
                  Icons.near_me_rounded,
                  _selectedSort,
                  (value) {
                    setState(() => _selectedSort = value); // dialog UI update
                    this.setState(() {}); // 🔥 force main screen update
                  },
                ),
                _buildSortOption(
                  'home.rating'.tr(),
                  'rating',
                  Icons.star_rounded,
                  _selectedSort,
                  (value) {
                    setState(() => _selectedSort = value); // dialog UI update
                    this.setState(() {}); // 🔥 force main screen update
                  },
                ),
                _buildSortOption(
                  'home.experience'.tr(),
                  'experience',
                  Icons.work_history_rounded,
                  _selectedSort,
                  (value) {
                    setState(() => _selectedSort = value); // dialog UI update
                    this.setState(() {}); // 🔥 force main screen update
                  },
                ),
                _buildSortOption(
                  'home.review'.tr(),
                  'reviews',
                  Icons.reviews_rounded,
                  _selectedSort,
                  (value) {
                    setState(() => _selectedSort = value); // dialog UI update
                    this.setState(() {}); // 🔥 force main screen update
                  },
                ),
                _buildSortOption(
                  'home.newest'.tr(),
                  'newest',
                  Icons.new_releases_rounded,
                  _selectedSort,
                  (value) {
                    setState(() => _selectedSort = value); // dialog UI update
                    this.setState(() {}); // 🔥 force main screen update
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'will.cancel'.tr(),
                style: const TextStyle(color: AppTheme.textGray),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _applySorting(_selectedSort);
              },
              child: Text(
                'will.apply'.tr(),
                style: const TextStyle(color: AppTheme.accentGold),
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

  void _showFavoritesDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      ),
    );

    try {
      if (authProvider.token == null) return;
      final favorites = await ApiService.getFavorites(authProvider.token!);

      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? AppTheme.secondaryGray : Colors.white,
          title: Text(
            'home.your_favorite'.tr(),
            style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_border_rounded,
                          size: 48,
                          color: AppTheme.textGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'home.no_favorite'.tr(),
                          style: isDark
                              ? AppTheme.bodyLarge
                              : AppTheme.bodyLargeLight,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'home.add_favorite'.tr(),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final provider = favorites[index];
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
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  AppTheme.accentGold.withOpacity(0.2),
                              backgroundImage:
                                  provider['profilePicture'] != null
                                      ? NetworkImage(provider['profilePicture'])
                                      : null,
                              child: provider['profilePicture'] == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      color: AppTheme.accentGold,
                                      size: 24,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider['name'] ?? 'Provider',
                                    style: (isDark
                                            ? AppTheme.bodyMedium
                                            : AppTheme.bodyMediumLight)
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: AppTheme.accentGold,
                                      ),
                                      const SizedBox(width: 4),
                                      Builder(
                                        builder: (_) {
                                          double rating =
                                              (provider['rating'] is num)
                                                  ? (provider['rating'] as num)
                                                      .toDouble()
                                                  : 0.0;

                                          final totalReviews =
                                              provider['totalReviews'] ?? 0;

                                          return Text(
                                            rating > 0
                                                ? '${rating.toStringAsFixed(1)} ($totalReviews)'
                                                : 'home.no_rating'.tr(),
                                            style: AppTheme.bodySmall.copyWith(
                                              color: AppTheme.textGray,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  if (provider['location'] != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      provider['location'],
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textGray,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  await ApiService.removeFromFavorites(
                                    authProvider.token!,
                                    provider['_id'],
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('home.remove_favorite'.tr()),
                                      backgroundColor: AppTheme.successGreen,
                                    ),
                                  );
                                  _showFavoritesDialog();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: AppTheme.errorRed,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: AppTheme.errorRed,
                                size: 22,
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
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading favorites: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  // Service category data with icons and colors
  final List<Map<String, dynamic>> _serviceCategories = [
    {
      'name': 'provider.plum'.tr(),
      'icon': Icons.plumbing_rounded,
      'color': 0xFF2196F3, // Blue
    },
    {
      'name': 'provider.elec'.tr(),
      'icon': Icons.electrical_services_rounded,
      'color': 0xFFFFC107, // Amber
    },
    {
      'name': 'provider.mech'.tr(),
      'icon': Icons.build_rounded,
      'color': 0xFF4CAF50, // Green
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
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    // Reload services from backend with the selected sorting
    if (locationProvider.currentPosition != null) {
      serviceProvider.loadNearbyServices(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
        sortBy: sortBy,
      );
    }

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
        return 'Distance 📍';
      case 'rating':
        return 'Rating ⭐';
      case 'experience':
        return 'Experience 👷';
      case 'reviews':
        return 'Reviews 🔎';
      case 'newest':
        return 'Newest providers 🆕';
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
}
