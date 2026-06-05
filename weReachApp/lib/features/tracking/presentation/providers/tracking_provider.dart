import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class TrackingState {
  final bool isTracking;
  final bool isPaused;
  final String destinationName;
  final double destinationLatitude;
  final double destinationLongitude;
  final double? currentLatitude;
  final double? currentLongitude;
  final double remainingDistance;
  final double progress; // 0.0 to 1.0
  final double speed; // km/h
  final int? etaMinutes;
  final bool hasArrived;
  final bool hasGpsSignal;

  TrackingState({
    this.isTracking = false,
    this.isPaused = false,
    this.destinationName = "",
    this.destinationLatitude = 0.0,
    this.destinationLongitude = 0.0,
    this.currentLatitude,
    this.currentLongitude,
    this.remainingDistance = 0.0,
    this.progress = 0.0,
    this.speed = 0.0,
    this.etaMinutes,
    this.hasArrived = false,
    this.hasGpsSignal = false,
  });

  TrackingState copyWith({
    bool? isTracking,
    bool? isPaused,
    String? destinationName,
    double? destinationLatitude,
    double? destinationLongitude,
    double? currentLatitude,
    double? currentLongitude,
    double? remainingDistance,
    double? progress,
    double? speed,
    int? etaMinutes,
    bool? hasArrived,
    bool? hasGpsSignal,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      isPaused: isPaused ?? this.isPaused,
      destinationName: destinationName ?? this.destinationName,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      remainingDistance: remainingDistance ?? this.remainingDistance,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      hasArrived: hasArrived ?? this.hasArrived,
      hasGpsSignal: hasGpsSignal ?? this.hasGpsSignal,
    );
  }
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  final Ref _ref;
  StreamSubscription<Position>? _positionSubscription;
  double? _initialDistance;

  TrackingNotifier(this._ref) : super(TrackingState());

  Future<void> startTracking({
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    // Reset any ongoing subscriptions
    await stopTracking();

    state = TrackingState(
      isTracking: true,
      destinationName: name,
      destinationLatitude: latitude,
      destinationLongitude: longitude,
    );

    // Save as last trip in settings
    _ref.read(settingsProvider.notifier).updateSettings(
          lastDestinationName: name,
          lastDestinationLatitude: latitude,
          lastDestinationLongitude: longitude,
        );

    final locationService = _ref.read(locationServiceProvider);
    
    // Attempt to request GPS
    try {
      final pos = await locationService.getCurrentPosition();
      _handlePositionUpdate(pos);
    } catch (_) {
      // Allow it to transition to listening stream directly
    }

    _positionSubscription = locationService.getPositionStream().listen(
      (pos) {
        _handlePositionUpdate(pos);
      },
      onError: (err) {
        state = state.copyWith(hasGpsSignal: false);
      },
    );
  }

  void _handlePositionUpdate(Position position) {
    final locationService = _ref.read(locationServiceProvider);
    
    final dist = locationService.calculateDistance(
      position.latitude,
      position.longitude,
      state.destinationLatitude,
      state.destinationLongitude,
    );

    _initialDistance ??= dist;
    if (dist > _initialDistance!) {
      _initialDistance = dist; // Adjust scale for progress calculating
    }

    // Settings config
    final settingsVal = _ref.read(settingsProvider).value;
    final alertRadius = settingsVal?.alertRadius ?? 1.0;

    // Calculate progress
    final double maxScale = _initialDistance!;
    final double progress = maxScale > alertRadius
        ? ((maxScale - dist) / (maxScale - alertRadius)).clamp(0.0, 1.0)
        : 1.0;

    // Calculate Speed in km/h (position.speed is in m/s)
    final double speedKmh = position.speed * 3.6;

    // Calculate ETA in minutes
    int? eta;
    if (speedKmh > 5.0) {
      eta = ((dist / speedKmh) * 60).round();
    }

    final arrived = dist <= alertRadius;

    state = state.copyWith(
      currentLatitude: position.latitude,
      currentLongitude: position.longitude,
      remainingDistance: dist,
      progress: progress,
      speed: speedKmh,
      etaMinutes: eta,
      hasArrived: arrived,
      hasGpsSignal: true,
    );

    if (arrived) {
      _triggerArrivalAlert();
    }
  }

  void _triggerArrivalAlert() {
    // Stop subscription to conserve battery
    _positionSubscription?.cancel();
    _positionSubscription = null;

    final settingsVal = _ref.read(settingsProvider).value;
    final soundEnabled = settingsVal?.soundEnabled ?? true;
    final vibrationEnabled = settingsVal?.vibrationEnabled ?? true;
    final alarmName = settingsVal?.alarmSound ?? "default";

    // Play notifications & alarm audio
    _ref.read(notificationServiceProvider).showArrivalNotification(
      title: "Wake Up!",
      body: "You are arriving at ${state.destinationName} soon.",
    );

    if (soundEnabled) {
      _ref.read(audioServiceProvider).playAlarm(alarmName);
    }
    
    // Trigger loop trigger of vibration if enabled (handled within presentation/AlertScreen or service)
  }

  Future<void> pauseTracking() async {
    if (!state.isTracking || state.isPaused) return;

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    state = state.copyWith(isPaused: true, hasGpsSignal: false);
  }

  Future<void> resumeTracking() async {
    if (!state.isTracking || !state.isPaused) return;

    state = state.copyWith(isPaused: false);
    final locationService = _ref.read(locationServiceProvider);

    _positionSubscription = locationService.getPositionStream().listen(
      (pos) {
        _handlePositionUpdate(pos);
      },
      onError: (err) {
        state = state.copyWith(hasGpsSignal: false);
      },
    );
  }

  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _initialDistance = null;

    await _ref.read(audioServiceProvider).stopAlarm();
    await _ref.read(notificationServiceProvider).cancelAll();

    state = TrackingState();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier(ref);
});
