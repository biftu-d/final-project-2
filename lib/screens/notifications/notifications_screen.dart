import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton(
              onPressed: () => notifProvider.markAllRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ),
        ],
      ),
      body: notifProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold))
          : notifProvider.notifications.isEmpty
              ? _buildEmpty(isDark)
              : RefreshIndicator(
                  color: AppTheme.accentGold,
                  onRefresh: () => notifProvider.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifProvider.notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifProvider.notifications[index];
                      return _NotificationTile(
                        notification: n,
                        isDark: isDark,
                        onTap: () => notifProvider.markRead(n.id),
                        onDismiss: () => notifProvider.delete(n.id),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 72,
            color: AppTheme.textGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: (isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight)
                .copyWith(color: AppTheme.textGray),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see booking updates,\npayment confirmations and more here.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(notification.type);
    final color = _colorForType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDark ? AppTheme.secondaryGray : AppTheme.lightSurface)
                : (isDark
                    ? AppTheme.accentGold.withOpacity(0.08)
                    : AppTheme.accentGold.withOpacity(0.06)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? AppTheme.borderGray.withOpacity(0.2)
                  : AppTheme.accentGold.withOpacity(0.4),
              width: notification.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: (isDark
                                    ? AppTheme.bodyMedium
                                    : AppTheme.bodyMediumLight)
                                .copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark
                            ? AppTheme.textGray
                            : AppTheme.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textGray.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'booking_created':
        return Icons.calendar_today_rounded;
      case 'booking_accepted':
        return Icons.check_circle_rounded;
      case 'booking_declined':
        return Icons.cancel_rounded;
      case 'booking_in_progress':
        return Icons.play_circle_rounded;
      case 'booking_completed':
        return Icons.task_alt_rounded;
      case 'booking_cancelled':
        return Icons.event_busy_rounded;
      case 'payment_received':
        return Icons.attach_money_rounded;
      case 'payment_confirmed':
        return Icons.payment_rounded;
      case 'payment_failed':
        return Icons.money_off_rounded;
      case 'provider_approved':
        return Icons.verified_rounded;
      case 'provider_rejected':
        return Icons.report_rounded;
      case 'new_message':
        return Icons.chat_rounded;
      case 'new_review':
        return Icons.star_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'booking_accepted':
      case 'booking_completed':
      case 'payment_received':
      case 'payment_confirmed':
      case 'provider_approved':
        return AppTheme.successGreen;
      case 'booking_declined':
      case 'booking_cancelled':
      case 'payment_failed':
      case 'provider_rejected':
        return AppTheme.errorRed;
      case 'booking_in_progress':
        return Colors.blue;
      case 'new_review':
        return AppTheme.accentGold;
      default:
        return AppTheme.accentGold;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
