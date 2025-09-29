import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class ServiceProvider with ChangeNotifier {
  List<ServiceModel> _services = [];
  List<ServiceModel> _featuredServices = [];
  List<ServiceModel> _nearbyServices = [];
  List<Booking> _bookings = [];
  List<Booking> _providerBookings = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  List<ServiceModel> get featuredServices => _featuredServices;
  List<ServiceModel> get nearbyServices => _nearbyServices;
  List<Booking> get bookings => _bookings;
  List<Booking> get providerBookings => _providerBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add this inside your ServiceProvider class:

  int get totalBookings => _providerBookings.length;

  double get totalRevenue => _providerBookings.fold(
      0.0, (sum, booking) => sum + (booking.amount ?? 0));

  List<Booking> get recentActivities {
    // Return the most recent 5 bookings (or all)
    final sorted = List<Booking>.from(_providerBookings);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  void setServices(List<ServiceModel> services) {
    _services = services;
    notifyListeners();
  }

  Future<void> loadFeaturedServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getFeaturedServices();
      _featuredServices =
          data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNearbyServices(double latitude, double longitude,
      {double radius = 10.0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getNearbyServices(latitude, longitude,
          radius: radius);
      _nearbyServices =
          data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchServices(String query,
      {String? category, String? location}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ✅ Call API and get full response as Map
      final Map<String, dynamic> responseMap = await ApiService.searchServices(
        query: query,
        category: category,
        location: location,
      );

      final List<ServiceModel> servicesList = (responseMap['services'] as List)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();

      _services = servicesList
          .where((s) =>
              s.verificationStatus.toLowerCase() == 'approved' && s.isAvailable)
          .toList();
    } catch (e) {
      _error = e.toString();
      _services = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserBookings(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getUserBookings(token);
      _bookings = data.map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProviderBookings(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getProviderBookings(token);
      _providerBookings = data.map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBooking(String token, String serviceId) async {
    // Wrap the serviceId inside a Map
    final response = await ApiService.createBooking(token, {
      'serviceId': serviceId,
    });

    if (response['success'] == true) {
      final newBooking = Booking.fromJson(response['booking']);
      bookings.add(newBooking);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateBookingStatus(
      String token, String bookingId, BookingStatus status) async {
    try {
      await ApiService.updateBookingStatus(token, bookingId, status);
      // Refresh bookings
      await loadProviderBookings(token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createService(
      String token, Map<String, dynamic> serviceData) async {
    try {
      await ApiService.createService(token, serviceData);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void sortServices(String sortBy) {
    switch (sortBy) {
      case 'distance':
        _nearbyServices.sort((a, b) => (a.distance ?? double.infinity)
            .compareTo(b.distance ?? double.infinity));
        break;
      case 'rating':
        _nearbyServices.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'experience':
        _nearbyServices.sort((a, b) => b.experience.compareTo(a.experience));
        break;
      case 'reviews':
        _nearbyServices
            .sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
        break;
      case 'newest':
        _nearbyServices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }
}
