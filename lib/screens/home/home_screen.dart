import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/service_card.dart';
import '../../widgets/category_card.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(
        context,
        listen: false,
      ).loadFeaturedServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'color': Colors.blue},
    {
      'name': 'Electrical',
      'icon': Icons.electrical_services,
      'color': Colors.orange,
    },
    {
      'name': 'Cleaning',
      'icon': Icons.cleaning_services,
      'color': Colors.green,
    },
    {
      'name': 'Beauty',
      'icon': Icons.face_retouching_natural,
      'color': Colors.pink,
    },
    {'name': 'Tutoring', 'icon': Icons.school, 'color': Colors.purple},
    {'name': 'Delivery', 'icon': Icons.delivery_dining, 'color': Colors.red},
    {'name': 'Photography', 'icon': Icons.camera_alt, 'color': Colors.indigo},
    {'name': 'Repairs', 'icon': Icons.build, 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = authProvider.user;
    final isProvider = user?.role == UserRole.provider;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isProvider ? 'Welcome back,' : 'Hello,',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textGray,
                              ),
                            ),
                            Text(
                              user?.name ?? 'User',
                              style: AppTheme.headingMedium,
                            ),
                          ],
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                      ],
                    ),
                    if (!isProvider) ...[
                      const SizedBox(height: 30),
                      // Search Bar
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SearchScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryGray,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: AppTheme.textGray,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Search for services...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (!isProvider) ...[
                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Categories', style: AppTheme.headingSmall),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right:
                                    index == _categories.length - 1 ? 24 : 16,
                                left: index == 0 ? 0 : 0,
                              ),
                              child: CategoryCard(
                                name: category['name'],
                                icon: category['icon'],
                                color: category['color'],
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SearchScreen(
                                        initialCategory: category['name'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
              // Featured Services / Provider Dashboard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProvider ? 'Quick Actions' : 'Featured Services',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 16),
                    if (isProvider) ...[
                      _buildProviderQuickActions(),
                    ] else ...[
                      if (serviceProvider.isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentGold,
                            ),
                          ),
                        )
                      else if (serviceProvider.featuredServices.isEmpty)
                        const Center(
                          child: Text(
                            'No featured services available',
                            style: AppTheme.bodyMedium,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: serviceProvider.featuredServices.length,
                          itemBuilder: (context, index) {
                            final service =
                                serviceProvider.featuredServices[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ServiceCard(service: service),
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 100), // Bottom padding for navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderQuickActions() {
    return Column(
      children: [
        _buildQuickActionCard(
          'Manage Services',
          'Update your service listings',
          Icons.edit_rounded,
          AppTheme.accentGold,
          () {
            // Navigate to manage services
          },
        ),
        const SizedBox(height: 16),
        _buildQuickActionCard(
          'View Bookings',
          'Check your upcoming appointments',
          Icons.calendar_today_rounded,
          AppTheme.successGreen,
          () {
            // Navigate to bookings
          },
        ),
        const SizedBox(height: 16),
        _buildQuickActionCard(
          'Analytics',
          'View your performance metrics',
          Icons.analytics_rounded,
          Colors.blue,
          () {
            // Navigate to analytics
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
