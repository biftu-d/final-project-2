import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? bookingId;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.bookingId,
    required this.createdAt,
    required this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? '',
      type: json['type'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      bookingId: json['bookingId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      data: (json['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      bookingId: bookingId,
      createdAt: createdAt,
      data: data,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _pollTimer;
  String? _token;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void startPolling(String token) {
    _token = token;
    _fetchNotifications();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchNotifications(silent: true);
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _token = null;
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_token != null) {
      await _fetchNotifications();
    }
  }

  Future<void> _fetchNotifications({bool silent = false}) async {
    if (_token == null) return;
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final data = await ApiService.getNotifications(_token!, limit: 50);
      final List rawList = data['notifications'] ?? [];
      final newNotifications =
          rawList.map((n) => AppNotification.fromJson(n)).toList();

      final prevUnread = _unreadCount;
      _notifications = newNotifications;
      _unreadCount = data['unreadCount'] ?? 0;

      if (silent && _unreadCount != prevUnread) {
        notifyListeners();
      } else if (!silent) {
        notifyListeners();
      }
    } catch (_) {
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> markRead(String notificationId) async {
    if (_token == null) return;
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx == -1 || _notifications[idx].isRead) return;

    _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    if (_unreadCount > 0) _unreadCount--;
    notifyListeners();

    await ApiService.markNotificationRead(_token!, notificationId);
  }

  Future<void> markAllRead() async {
    if (_token == null) return;
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    await ApiService.markAllNotificationsRead(_token!);
  }

  Future<void> delete(String notificationId) async {
    if (_token == null) return;
    final removed =
        _notifications.firstWhere((n) => n.id == notificationId, orElse: () {
      return AppNotification(
          id: '',
          type: '',
          title: '',
          message: '',
          isRead: true,
          createdAt: DateTime.now(),
          data: {});
    });

    _notifications.removeWhere((n) => n.id == notificationId);
    if (!removed.isRead && _unreadCount > 0) _unreadCount--;
    notifyListeners();

    await ApiService.deleteNotification(_token!, notificationId);
  }
}
