import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class GPSService {
  // Get current location with high accuracy
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Start location tracking (for providers)
  static Stream<Position> trackLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  // Calculate distance between two points
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  // Open navigation to location
  static Future<void> navigateToLocation(double latitude, double longitude,
      {String? label}) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

    final String appleMapsUrl =
        'https://maps.apple.com/?daddr=$latitude,$longitude';

    try {
      // Try Google Maps first
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl),
            mode: LaunchMode.externalApplication);
      }
      // Fallback to Apple Maps on iOS
      else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(Uri.parse(appleMapsUrl),
            mode: LaunchMode.externalApplication);
      }
      // Fallback to generic maps URL
      else {
        final String fallbackUrl = 'geo:$latitude,$longitude';
        await launchUrl(Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      throw Exception('Could not open navigation: $e');
    }
  }

  // Get address from coordinates (reverse geocoding)
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Unknown location';
    }
  }

  // Check if location is within service area
  static bool isWithinServiceArea(
    double userLat,
    double userLng,
    double providerLat,
    double providerLng,
    double maxDistanceKm,
  ) {
    double distance =
        calculateDistance(userLat, userLng, providerLat, providerLng);
    return distance <= (maxDistanceKm * 1000); // Convert km to meters
  }
}

// Placeholder for reverse geocoding
class Placemark {
  final String? street;
  final String? locality;
  final String? administrativeArea;
  final String? country;

  Placemark({
    this.street,
    this.locality,
    this.administrativeArea,
    this.country,
  });
}

Future<List<Placemark>> placemarkFromCoordinates(
  double latitude,
  double longitude,
) async {
  // This would use a real geocoding service in production
  return [
    Placemark(
      street: 'Sample Street',
      locality: 'Addis Ababa',
      administrativeArea: 'Addis Ababa',
      country: 'Ethiopia',
    ),
  ];
}
