import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Check permissions and request if not granted
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get user's current GPS position
  Future<Position> getCurrentPosition() async {
    final hasPerm = await checkPermission();
    if (!hasPerm) {
      throw Exception("Location permissions denied.");
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Stream of user positions
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters change
      ),
    );
  }

  /// Calculate distance in kilometers between two points
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    // Geolocator returns distance in meters, so we divide by 1000 to get kilometers
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000.0;
  }
}
