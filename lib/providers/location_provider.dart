import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String _currentAddress = '';
  bool _isLoading = false;
  String? _error;
  bool _locationPermissionGranted = false;

  Position? get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get locationPermissionGranted => _locationPermissionGranted;

  Future<void> requestLocationPermission() async {
    _isLoading = true;
    notifyListeners();

    try {
      _locationPermissionGranted =
          await LocationService.requestLocationPermission();
      if (_locationPermissionGranted) {
        await getCurrentLocation();
      } else {
        _error = 'Location permission denied';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPosition = await LocationService.getCurrentLocation();
      if (_currentPosition != null) {
        _currentAddress = await LocationService.getAddressFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  double? calculateDistanceToProvider(double providerLat, double providerLng) {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      providerLat,
      providerLng,
    );
  }
}
