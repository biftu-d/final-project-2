import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../models/user_model.dart';
import '../../models/booking_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/booking_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isProvider = authProvider.user?.role == UserRole.provider;

    _tabController = TabController(length: isProvider ? 4 : 3, vsync: this);

    // Load bookings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceProvider = Provider.of<ServiceProvider>(
        context,
        listen: false,
      );
      final token = authProvider.token;
      if (token != null) {
        if (isProvider) {
          serviceProvider.loadProviderBookings(token);
        } else {
          serviceProvider.loadUserBookings(token);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final isProvider = authProvider.user?.role == UserRole.provider;
    final bookings = isProvider
        ? serviceProvider.providerBookings
        : serviceProvider.bookings;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isProvider ? 'Service Requests' : 'My Bookings',
          style: AppTheme.headingSmall,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: AppTheme.textGray,
          labelStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
          tabs: isProvider
              ? const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Confirmed'),
                  Tab(text: 'Completed'),
                  Tab(text: 'All'),
                ]
              : const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'All'),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: isProvider
            ? [
                _buildBookingsList(bookings, BookingStatus.pending),
                _buildBookingsList(bookings, BookingStatus.confirmed),
                _buildBookingsList(bookings, BookingStatus.completed),
                _buildBookingsList(bookings, null),
              ]
            : [
                _buildBookingsList(bookings, BookingStatus.confirmed),
                _buildBookingsList(bookings, BookingStatus.completed),
                _buildBookingsList(bookings, null),
              ],
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> allBookings, BookingStatus? status) {
    final filteredBookings = status == null
        ? allBookings
        : allBookings.where((booking) => booking.status == status).toList();
    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 64,
              color: AppTheme.textGray,
            ),
            const SizedBox(height: 16),
            Text(
              status == null ? 'No bookings yet' : 'No ${status.name} bookings',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your bookings will appear here',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textGray),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BookingCard(
            booking: booking,
            onStatusUpdate: (newStatus) {
              _updateBookingStatus(booking.id, newStatus);
            },
          ),
        );
      },
    );
  }

  void _updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final serviceProvider = Provider.of<ServiceProvider>(
      context,
      listen: false,
    );
    final token = authProvider.token;

    if (token != null) {
      final success = await serviceProvider.updateBookingStatus(
        token,
        bookingId,
        newStatus,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking status updated successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update booking status'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
