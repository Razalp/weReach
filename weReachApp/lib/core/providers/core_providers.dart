import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/isar_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';

// Providers for core infrastructure singletons
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

class SelectedDestination {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String distanceText;

  SelectedDestination({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceText,
  });
}

final selectedDestinationProvider = StateProvider<SelectedDestination?>((ref) => null);

