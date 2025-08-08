import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../utils/app_theme.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final Function(BookingStatus)? onStatusUpdate;

  const BookingCard({super.key, required this.booking, this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(booking.status),
                  color: _getStatusColor(booking.status),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Provider: ${booking.providerName}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status.name.toUpperCase(),
                  style: AppTheme.bodySmall.copyWith(
                    color: _getStatusColor(booking.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Booking Details
          _buildDetailRow(
            Icons.calendar_today_rounded,
            'Date',
            DateFormat('MMM dd, yyyy').format(booking.scheduledDate),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.access_time_rounded,
            'Time',
            booking.scheduledTime,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.location_on_rounded,
            'Location',
            booking.location,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.monetization_on_rounded,
            'Price',
            booking.price,
          ),

          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes:',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(booking.notes!, style: AppTheme.bodySmall),
                ],
              ),
            ),
          ],

          // Action Buttons for Providers
          if (onStatusUpdate != null &&
              booking.status == BookingStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Decline',
                    AppTheme.errorRed,
                    () => onStatusUpdate!(BookingStatus.cancelled),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Accept',
                    AppTheme.successGreen,
                    () => onStatusUpdate!(BookingStatus.confirmed),
                  ),
                ),
              ],
            ),
          ],

          if (onStatusUpdate != null &&
              booking.status == BookingStatus.confirmed) ...[
            const SizedBox(height: 16),
            _buildActionButton(
              'Mark as Completed',
              AppTheme.accentGold,
              () => onStatusUpdate!(BookingStatus.completed),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textGray),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textGray),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryWhite,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return AppTheme.accentGold;
      case BookingStatus.completed:
        return AppTheme.successGreen;
      case BookingStatus.cancelled:
        return AppTheme.errorRed;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.pending_actions_rounded;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case BookingStatus.inProgress:
        return Icons.work_outline_rounded;
      case BookingStatus.completed:
        return Icons.check_circle_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}
