import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://obligable-voidable-radia.ngrok-free.dev/api';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Authentication
  static Future<Map<String, dynamic>> login(
      String email, String password, UserRole role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role.toString().split('.').last,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 🔥 SAVE TOKEN HERE
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);

      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData, UserRole role) async {
    userData['role'] = role.toString().split('.').last;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user data: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> verifyToken(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/verify'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Token verification failed');
    }
  }

  static Future<void> updateFCMToken(String token, String fcmToken) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/fcm-token'),
      headers: _getHeaders(token: token),
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('FCM token update failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateAvailability(
      String token, String availability) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/availability'),
      headers: _getHeaders(token: token),
      body: jsonEncode({'availability': availability}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Availability update failed: ${response.body}');
    }
  }

  // Services
  static Future<List<dynamic>> getFeaturedServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/services/featured'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['services'];
    } else {
      throw Exception('Failed to load featured services');
    }
  }

  static Future<Map<String, dynamic>> searchServices({
    String? query,
    String? category,
    String? location,
    double? latitude,
    double? longitude,
    double? radius, // in kilometers
  }) async {
    final queryParams = <String, String>{};
    if (query != null) queryParams['q'] = query;
    if (category != null) queryParams['category'] = category;
    if (location != null) queryParams['location'] = location;
    if (latitude != null) queryParams['lat'] = latitude.toString();
    if (longitude != null) queryParams['lng'] = longitude.toString();
    if (radius != null) queryParams['radius'] = radius.toString();

    final uri = Uri.parse('$baseUrl/services/search')
        .replace(queryParameters: queryParams);
    print("📤 Sending request to: $uri");
    final response = await http.get(uri, headers: _getHeaders());

    print("📥 Response status: ${response.statusCode}"); // 👈 Debug: see status
    print("📥 Raw response body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded; // ✅ now correct type
      } else {
        throw Exception('Unexpected response format: not a Map');
      }
    } else {
      throw Exception('Failed to search services');
    }
  }

  static Future<List<dynamic>> getNearbyServices(
    double latitude,
    double longitude, {
    double radius = 10.0, // Default 10km radius
    String? category,
    String? sortBy,
  }) async {
    final queryParams = <String, String>{
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'radius': radius.toString(),
    };

    if (category != null) queryParams['category'] = category;
    if (sortBy != null) queryParams['sortBy'] = sortBy;

    final uri = Uri.parse('$baseUrl/services/nearby')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['services'];
    } else {
      throw Exception('Failed to load nearby services');
    }
  }

  static Future<Map<String, dynamic>> createService(
      String token, Map<String, dynamic> serviceData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/services'),
      headers: _getHeaders(token: token),
      body: jsonEncode(serviceData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create service: ${response.body}');
    }
  }

  // Bookings
  static Future<List<dynamic>> getUserBookings(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/user'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['bookings'];
    } else {
      throw Exception('Failed to load user bookings');
    }
  }

  static Future<List<dynamic>> getProviderBookings(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/provider'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['bookings'];
    } else {
      throw Exception('Failed to load provider bookings');
    }
  }

  static Future<Map<String, dynamic>> createBooking(
      String token, Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _getHeaders(token: token),
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create booking: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateBookingStatus(
      String token, String bookingId, BookingStatus status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/bookings/$bookingId/status'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'status': status.toString().split('.').last,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update booking status: ${response.body}');
    }
  }

  static Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to send reset email');
    }
  }

  static Future<void> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: _getHeaders(),
      body: jsonEncode({
        'token': token,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to reset password');
    }
  }

  // Payment methods — booking completion flow
  static Future<Map<String, dynamic>> initializeChapaPaymentForBooking({
    required String token,
    required String bookingId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/payment/initialize'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'amount': amount}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'checkoutUrl': data['checkoutUrl'],
          'txRef': data['txRef'],
          'paymentBreakdown': data['paymentBreakdown'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to initialize payment',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyBookingPayment({
    required String token,
    required String bookingId,
    required String txRef,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/$bookingId/payment/verify/$txRef'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Payment verification failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> completeCashPaymentForBooking({
    required String token,
    required String bookingId,
    required double amount,
    required String paidBy,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/payment/cash'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'amount': amount,
          'paidBy': paidBy,
          'notes': notes ?? '',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to record cash payment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: _getHeaders(token: token),
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Resubmit provider application
  static Future<Map<String, dynamic>> resubmitApplication(
    String token,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/resubmit'),
        headers: _getHeaders(token: token),
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to resubmit application',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Verify payment status
  static Future<Map<String, dynamic>> verifyPayment(
    String token,
    String paymentReference,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/verify/$paymentReference'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify payment');
      }
    } catch (e) {
      throw Exception('Error verifying payment: $e');
    }
  }

  // Submit review
  static Future<Map<String, dynamic>> submitReview(
    String token,
    String providerId,
    int rating,
    String comment,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'providerId': providerId,
          'rating': rating,
          'comment': comment,
        }),
      );
      print("📥 RESPONSE: ${response.body}");

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      throw Exception('Error submitting review: $e');
    }
  }

  // Add provider to favorites
  static Future<void> addToFavorites(
    String token,
    String providerId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/favorites/$providerId'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add to favorites');
      }
    } catch (e) {
      throw Exception('Error adding to favorites: $e');
    }
  }

  // Remove provider from favorites
  static Future<void> removeFromFavorites(
    String token,
    String providerId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/favorites/$providerId'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove from favorites');
      }
    } catch (e) {
      throw Exception('Error removing from favorites: $e');
    }
  }

  // Get user's favorites
  static Future<List<dynamic>> getFavorites(String token) async {
    try {
      print("🔑 TOKEN: $token");
      final response = await http.get(
        Uri.parse('$baseUrl/users/favorites'),
        headers: _getHeaders(token: token),
      );
      print("📥 STATUS: ${response.statusCode}");
      print("📥 BODY: ${response.body}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['favorites'] ?? [];
      } else {
        throw Exception('Failed to get favorites');
      }
    } catch (e) {
      throw Exception('Error getting favorites: $e');
    }
  }

  // Get provider reviews
  static Future<Map<String, dynamic>> getProviderReviews(
    String providerId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/provider/$providerId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get provider reviews');
      }
    } catch (e) {
      throw Exception('Error getting reviews: $e');
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/change-password'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to change password'
        };
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }

  // Setup 2FA
  static Future<Map<String, dynamic>> setup2FA(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/2fa/setup'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'email': data['email'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to setup 2FA'
        };
      }
    } catch (e) {
      throw Exception('Error setting up 2FA: $e');
    }
  }

  // Verify 2FA
  static Future<Map<String, dynamic>> verify2FA(
    String token,
    String code,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/2fa/verify'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'code': code}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid code'};
      }
    } catch (e) {
      throw Exception('Error verifying 2FA: $e');
    }
  }

  // Disable 2FA
  static Future<Map<String, dynamic>> disable2FA(
    String token,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/2fa/disable'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to disable 2FA'
        };
      }
    } catch (e) {
      throw Exception('Error disabling 2FA: $e');
    }
  }

  // Export user data
  static Future<Map<String, dynamic>> exportUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/data-export'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Data exported successfully',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to export data'
        };
      }
    } catch (e) {
      throw Exception('Error exporting data: $e');
    }
  }

  // Contact support
  static Future<Map<String, dynamic>> contactSupport(
    String token,
    String subject,
    String message,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support/contact'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'subject': subject,
          'message': message,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Message sent successfully'};
      } else {
        return {'success': false, 'message': 'Failed to send message'};
      }
    } catch (e) {
      return {
        'success': true,
        'message': 'Message will be sent to support@promatch.et'
      };
    }
  }
  // ----- Notifications -----

  static Future<Map<String, dynamic>> getNotifications(
    String token, {
    int page = 1,
    int limit = 30,
    bool unreadOnly = false,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/notifications?page=$page&limit=$limit&unreadOnly=$unreadOnly',
      );
      final response = await http.get(uri, headers: _getHeaders(token: token));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'notifications': [], 'unreadCount': 0};
    } catch (e) {
      return {'notifications': [], 'unreadCount': 0};
    }
  }

  static Future<int> getUnreadNotificationCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: _getHeaders(token: token),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> markNotificationRead(
      String token, String notificationId) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: _getHeaders(token: token),
      );
    } catch (_) {}
  }

  static Future<void> markAllNotificationsRead(String token) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: _getHeaders(token: token),
      );
    } catch (_) {}
  }

  static Future<void> deleteNotification(
      String token, String notificationId) async {
    try {
      await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: _getHeaders(token: token),
      );
    } catch (_) {}
  }

  // Report problem
  static Future<Map<String, dynamic>> reportProblem(
    String token,
    String category,
    String description,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support/report'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'category': category,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Problem reported successfully'};
      } else {
        return {'success': false, 'message': 'Failed to report problem'};
      }
    } catch (e) {
      return {
        'success': true,
        'message': 'Problem report will be sent to our team'
      };
    }
  }
}
