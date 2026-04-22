import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/stat_card.dart';
import '../add_service_screen.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/language_selector.dart';
import '../../services/api_service.dart';
import 'package:easy_localization/easy_localization.dart';

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
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final bookings = serviceProvider.providerBookings;

    // Calculate statistics
    final totalBookings = bookings.length;
    final pendingBookings =
        bookings.where((b) => b.status.name == 'pending').length;
    final completedBookings =
        bookings.where((b) => b.status.name == 'completed').length;
    final totalEarnings = completedBookings * 500; // Placeholder calculation
    final recentBookings =
        bookings.length > 3 ? bookings.sublist(0, 3) : bookings;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'dashboard.dash'.tr(),
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        actions: [
          LanguageSelector(isDarkMode: isDark),
          const ThemeToggleButton(),
          const SizedBox(width: 16),
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
                    'Welcome Back, ${user?.name ?? 'Provider'}!',
                    style: isDark
                        ? AppTheme.headingMedium
                        : AppTheme.headingMediumLight, // light theme variant
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'home.business_performance'.tr(),
                    style: isDark
                        ? AppTheme.bodyMedium
                        : AppTheme.bodyMediumLight, // light theme variant
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Grid
            Text(
              'home.overview'.tr(),
              style:
                  isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                StatCard(
                  title: 'home.total_bookings'.tr(),
                  value: totalBookings.toString(),
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.accentGold,
                ),
                StatCard(
                  title: 'home.pending_requests'.tr(),
                  value: pendingBookings.toString(),
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange,
                ),
                StatCard(
                  title: 'booking.completed'.tr(),
                  value: completedBookings.toString(),
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.successGreen,
                ),
                StatCard(
                  title: 'dashboard.total_earnings'.tr(),
                  value: '$totalEarnings ETB',
                  icon: Icons.monetization_on_rounded,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'home.quick_actions'.tr(),
              style:
                  isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
            ),
            const SizedBox(height: 16),
            _buildQuickActionCard(
              'home.add_new_service'.tr(),
              'home.create_service_listing'.tr(),
              Icons.add_business_rounded,
              AppTheme.accentGold,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddServiceScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              'home.update_availability'.tr(),
              'home.manage_working_hours'.tr(),
              Icons.schedule_rounded,
              AppTheme.successGreen,
              () => _showAvailabilityDialog(),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              'home.view_analytics'.tr(),
              'home.detailed_performance'.tr(),
              Icons.analytics_rounded,
              Colors.blue,
              () => _showAnalyticsDialog(),
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'dashboard.recent_activity'.tr(),
              style:
                  isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
            ),
            const SizedBox(height: 16),
            if (bookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inbox_rounded,
                        size: 48,
                        color: AppTheme.textGray,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'dashboard.no_recent'.tr(),
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentBookings.length,
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
                            color: _getStatusColor(booking.status)
                                .withOpacity(0.2),
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
                          booking.status
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
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
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.secondaryGray
              : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (Theme.of(context).brightness != Brightness.dark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.bodyMedium
                        : AppTheme.bodyMediumLight,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.bodySmall
                        : AppTheme.bodySmallLight,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddServiceScreen(),
      ),
    );
  }

  void _showAvailabilityDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    showDialog(
      context: context,
      builder: (context) => _AvailabilityDialog(
        currentAvailability:
            user?.isAvailable == true ? 'Available' : 'Unavailable',
        onUpdate: (newAvailability) async {
          try {
            final token = authProvider.token;
            if (token != null) {
              await ApiService.updateAvailability(token, newAvailability);
              await authProvider.refreshUser(token);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Availability updated successfully!'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update availability: $e'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showAnalyticsDialog() {
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
        backgroundColor: isDark
            ? AppTheme.secondaryGray
            : AppTheme.cardDecorationLight.color,
        title: Text(
          'home.analytics_overview'.tr(),
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              _buildAnalyticsItem('home.total_bookings'.tr(),
                  totalBookings.toString(), Icons.calendar_today, isDark),
              _buildAnalyticsItem('home.pending_requests'.tr(),
                  pendingBookings.toString(), Icons.pending_actions, isDark),
              _buildAnalyticsItem('dashboard.booking_month'.tr(),
                  bookingsThisMonth.toString(), Icons.calendar_today, isDark),
              _buildAnalyticsItem('dashboard.average_rating'.tr(),
                  averageRating.toStringAsFixed(1), Icons.star, isDark),
              _buildAnalyticsItem('dashboard.completed_job'.tr(),
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
        color: isDark ? AppTheme.primaryBlack : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style:
                      isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight)),
          Text(
            value,
            style: (isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight)
                .copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityDialog extends StatefulWidget {
  final String? currentAvailability;
  final Function(String) onUpdate;

  const _AvailabilityDialog({
    required this.currentAvailability,
    required this.onUpdate,
  });

  @override
  State<_AvailabilityDialog> createState() => _AvailabilityDialogState();
}

class _AvailabilityDialogState extends State<_AvailabilityDialog> {
  late String _selectedAvailability;
  bool _isUpdating = false;

  final List<String> _availabilityOptions = [
    'provider.wek'.tr(),
    'provider.week'.tr(),
    'provider.full'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAvailability = widget.currentAvailability ?? 'Full Week (Mon-Sun)';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.secondaryGray,
      title: Text(
        'home.update_availability'.tr(),
        style: AppTheme.headingSmall,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'dashboard.select_availability'.tr(),
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ..._availabilityOptions.map((option) {
              final isSelected = _selectedAvailability == option;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentGold.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.accentGold : AppTheme.borderGray,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    option,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isSelected
                          ? AppTheme.accentGold
                          : AppTheme.primaryWhite,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  value: option,
                  groupValue: _selectedAvailability,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAvailability = value;
                      });
                    }
                  },
                  activeColor: AppTheme.accentGold,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
          child: Text(
            'will.cancel'.tr(),
            style: const TextStyle(color: AppTheme.textGray),
          ),
        ),
        TextButton(
          onPressed: _isUpdating
              ? null
              : () async {
                  setState(() {
                    _isUpdating = true;
                  });

                  await widget.onUpdate(_selectedAvailability);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
          child: _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accentGold,
                  ),
                )
              : Text(
                  'will.update'.tr(),
                  style: const TextStyle(color: AppTheme.accentGold),
                ),
        ),
      ],
    );
  }
}
