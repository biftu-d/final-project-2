import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class ServiceProvider with ChangeNotifier {
  List<ServiceModel> _services = [];
  List<ServiceModel> _featuredServices = [];
  List<Booking> _bookings = [];
  List<Booking> _providerBookings = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  List<ServiceModel> get featuredServices => _featuredServices;
  List<Booking> get bookings => _bookings;
  List<Booking> get providerBookings => _providerBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> searchServices(
    String query, {
    String? category,
    String? location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.searchServices(
        query: query,
        category: category,
        location: location,
      );
      _services = data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
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

  Future<bool> createBooking(
    String token,
    Map<String, dynamic> bookingData,
  ) async {
    try {
      await ApiService.createBooking(token, bookingData);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBookingStatus(
    String token,
    String bookingId,
    BookingStatus status,
  ) async {
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
    String token,
    Map<String, dynamic> serviceData,
  ) async {
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
}
