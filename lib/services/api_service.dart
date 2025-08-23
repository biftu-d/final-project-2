import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/booking_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:6061/api';

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
      return jsonDecode(response.body);
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

  // User Profile
  static Future<Map<String, dynamic>> updateProfile(
      String token, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: _getHeaders(token: token),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Profile update failed: ${response.body}');
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

  static Future<List<dynamic>> searchServices({
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
    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['services'];
    } else {
      throw Exception('Failed to search services');
    }
  }

  static Future<List<dynamic>> getNearbyServices(
    double latitude,
    double longitude, {
    double radius = 10.0, // Default 10km radius
    String? category,
  }) async {
    final queryParams = <String, String>{
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'radius': radius.toString(),
    };

    if (category != null) queryParams['category'] = category;

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
}
