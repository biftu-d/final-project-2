import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final serviceProvider = Provider.of<ServiceProvider>(
        context,
        listen: false,
      );
      final token = authProvider.token;
      if (token != null) {
        serviceProvider.loadProviderBookings(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = authProvider.user;
    final bookings = serviceProvider.providerBookings;

    // Calculate statistics
    final totalBookings = bookings.length;
    final pendingBookings = bookings
        .where((b) => b.status.name == 'pending')
        .length;
    final completedBookings = bookings
        .where((b) => b.status.name == 'completed')
        .length;
    final totalEarnings = completedBookings * 500; // Placeholder calculation

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard', style: AppTheme.headingSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primaryWhite),
            onPressed: () {
              _showAddServiceDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration.copyWith(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGold.withOpacity(0.1),
                    AppTheme.successGreen.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.name ?? 'Provider'}!',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Here\'s how your business is performing',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Statistics Grid
            const Text('Overview', style: AppTheme.headingSmall),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                StatCard(
                  title: 'Total Bookings',
                  value: totalBookings.toString(),
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.accentGold,
                ),
                StatCard(
                  title: 'Pending Requests',
                  value: pendingBookings.toString(),
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange,
                ),
                StatCard(
                  title: 'Completed',
                  value: completedBookings.toString(),
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.successGreen,
                ),
                StatCard(
                  title: 'Total Earnings',
                  value: '${totalEarnings} ETB',
                  icon: Icons.monetization_on_rounded,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text('Quick Actions', style: AppTheme.headingSmall),
            const SizedBox(height: 16),
            _buildQuickActionCard(
              'Add New Service',
              'Create a new service listing',
              Icons.add_business_rounded,
              AppTheme.accentGold,
              () => _showAddServiceDialog(),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              'Update Availability',
              'Manage your working hours',
              Icons.schedule_rounded,
              AppTheme.successGreen,
              () {
                // Navigate to availability settings
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              'View Analytics',
              'See detailed performance metrics',
              Icons.analytics_rounded,
              Colors.blue,
              () {
                // Navigate to analytics
              },
            ),
            const SizedBox(height: 24),
            // Recent Activity
            const Text('Recent Activity', style: AppTheme.headingSmall),
            const SizedBox(height: 16),
            if (bookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 48,
                        color: AppTheme.textGray,
                      ),
                      SizedBox(height: 12),
                      Text('No recent activity', style: AppTheme.bodyMedium),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.take(3).length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              booking.status,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getStatusIcon(booking.status),
                            color: _getStatusColor(booking.status),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.serviceName,
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                booking.customerName,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          booking.status.name.toUpperCase(),
                          style: AppTheme.bodySmall.copyWith(
                            color: _getStatusColor(booking.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
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
              child: Icon(icon, color: color, size: 20),
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

  Color _getStatusColor(status) {
    switch (status.name) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return AppTheme.successGreen;
      case 'cancelled':
        return AppTheme.errorRed;
      default:
        return AppTheme.textGray;
    }
  }

  IconData _getStatusIcon(status) {
    switch (status.name) {
      case 'pending':
        return Icons.pending_actions_rounded;
      case 'confirmed':
        return Icons.check_circle_outline_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryGray,
        title: const Text('Add New Service', style: AppTheme.headingSmall),
        content: const Text(
          'Service creation feature coming soon!',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }
}
