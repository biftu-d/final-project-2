import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class NavigationService {
  /// Opens Google Maps with navigation from current location to the destination
  static Future<void> openGoogleMapsNavigation({
    required double destinationLatitude,
    required double destinationLongitude,
    String? destinationLabel,
  }) async {
    final String googleMapsUrl;

    if (Platform.isAndroid) {
      // Android uses google.navigation
      googleMapsUrl =
          'google.navigation:q=$destinationLatitude,$destinationLongitude';
    } else if (Platform.isIOS) {
      // iOS uses comgooglemaps
      googleMapsUrl =
          'comgooglemaps://?daddr=$destinationLatitude,$destinationLongitude&directionsmode=driving';
    } else {
      // Fallback to web URL
      googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$destinationLatitude,$destinationLongitude';
    }

    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      final bool canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If Google Maps is not installed, fall back to web URL
        final Uri webUri = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$destinationLatitude,$destinationLongitude');
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      throw Exception('Could not open navigation: $e');
    }
  }

  /// Opens Google Maps to show a specific location (without navigation)
  static Future<void> openGoogleMapsLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final String googleMapsUrl;

    if (Platform.isAndroid) {
      googleMapsUrl =
          'geo:$latitude,$longitude?q=$latitude,$longitude${label != null ? '($label)' : ''}';
    } else if (Platform.isIOS) {
      googleMapsUrl = 'comgooglemaps://?center=$latitude,$longitude&zoom=14';
    } else {
      googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    }

    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      final bool canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to web URL
        final Uri webUri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      throw Exception('Could not open location: $e');
    }
  }

  /// Opens navigation from a specific starting point to destination
  static Future<void> openGoogleMapsNavigationWithOrigin({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    final String googleMapsUrl;

    if (Platform.isAndroid) {
      googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&origin=$originLatitude,$originLongitude&destination=$destinationLatitude,$destinationLongitude&travelmode=driving';
    } else if (Platform.isIOS) {
      googleMapsUrl =
          'comgooglemaps://?saddr=$originLatitude,$originLongitude&daddr=$destinationLatitude,$destinationLongitude&directionsmode=driving';
    } else {
      googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&origin=$originLatitude,$originLongitude&destination=$destinationLatitude,$destinationLongitude&travelmode=driving';
    }

    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      final bool canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to web URL
        final Uri webUri = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&origin=$originLatitude,$originLongitude&destination=$destinationLatitude,$destinationLongitude&travelmode=driving');
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      throw Exception('Could not open navigation: $e');
    }
  }
}
