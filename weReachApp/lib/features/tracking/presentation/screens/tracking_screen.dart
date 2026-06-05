import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/tracking_progress_ring.dart';
import '../../../../core/providers/core_providers.dart';
import '../providers/tracking_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineAnnotationManager;
  PointAnnotationManager? _pointAnnotationManager;
  bool _showMap = true; // Enabled by default for premium design
  Timer? _simTimer;

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  // Debug function to trigger mock arrival alert instantly
  void _simulateArrival() {
    ref.read(trackingProvider.notifier).stopTracking();
    context.go('/alert');
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingProvider);
    final settingsVal = ref.watch(settingsProvider).value;
    final alarmRadius = settingsVal?.alertRadius ?? 1.5;

    // Reactively transition to AlertScreen on arrival
    ref.listen<TrackingState>(trackingProvider, (previous, next) {
      if (next.hasArrived && !(previous?.hasArrived ?? false)) {
        context.go('/alert');
      }
    });

    // Handle Map updates when coordinates change
    if (_mapboxMap != null && tracking.currentLatitude != null && tracking.currentLongitude != null) {
      _updateMapAnnotations(
        tracking.currentLatitude!,
        tracking.currentLongitude!,
        tracking.destinationLatitude,
        tracking.destinationLongitude,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Background Map (Mapbox vector tilted by default)
          if (_showMap && tracking.currentLatitude != null && tracking.currentLongitude != null)
            Positioned.fill(
              child: MapWidget(
                key: const ValueKey("trackingMap"),
                styleUri: "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json",
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(tracking.currentLongitude!, tracking.currentLatitude!)),
                  zoom: 13.0,
                  pitch: 45.0,
                  bearing: -10.0,
                ),
                onMapCreated: (MapboxMap mapboxMap) {
                  _mapboxMap = mapboxMap;
                  _updateMapAnnotations(
                    tracking.currentLatitude!,
                    tracking.currentLongitude!,
                    tracking.destinationLatitude,
                    tracking.destinationLongitude,
                  );
                },
              ),
            )
          else
            Positioned.fill(
              child: Container(color: Colors.black),
            ),

          // HUD Dark gradient overlay for visual clarity
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(_showMap ? 0.55 : 0.95),
                    Colors.transparent,
                    Colors.black.withOpacity(_showMap ? 0.75 : 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 2. Active Screen Layout HUD
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top control bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.navigation_rounded,
                            color: AppColors.primaryLight,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tracking.hasGpsSignal 
                                ? "GPS ACTIVE" 
                                : (tracking.isPaused ? "PAUSED" : "CONNECTING..."),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.black,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      
                      // Map View Toggle & Cancel Trip Button
                      Row(
                        children: [
                          // Simulate Arrival Button (helpful for testing)
                          TextButton(
                            onPressed: _simulateArrival,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.cyan.withOpacity(0.12),
                              foregroundColor: Colors.cyanAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
                              ),
                            ),
                            child: const Text(
                              "Simulate",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),

                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showMap = !_showMap;
                              });
                            },
                            icon: Icon(
                              _showMap ? Icons.radar_rounded : Icons.map_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.08),
                              shape: const CircleBorder(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Cancel Button
                          TextButton(
                            onPressed: () {
                              ref.read(trackingProvider.notifier).stopTracking();
                              context.go('/home');
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.alert.withOpacity(0.15),
                              foregroundColor: AppColors.alert,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Stats HUD Container
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Progress HUD Ring
                      Opacity(
                        opacity: _showMap ? 0.9 : 1.0,
                        child: TrackingProgressRing(
                          progress: tracking.progress,
                          remainingDistance: tracking.remainingDistance > 0 ? tracking.remainingDistance : 3.4,
                          hasError: !tracking.hasGpsSignal && !tracking.isPaused && tracking.currentLatitude == null,
                          onTapTestSound: () {
                            ref.read(audioServiceProvider).testBeep();
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Stop name info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          tracking.destinationName.isNotEmpty ? tracking.destinationName : "Kozhikode Railway Station",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.black,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Alert set for ${alarmRadius.toStringAsFixed(1)} km radius",
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Panel showing Speed, ETA, and Control Toggles
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: const Color(0xEB0A0D15),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stats columns row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            "Speed",
                            "${tracking.speed > 0 ? tracking.speed.round() : 35} km/h",
                            Icons.speed_rounded,
                          ),
                          _buildStatColumn(
                            "ETA",
                            tracking.etaMinutes != null 
                                ? "${tracking.etaMinutes} mins" 
                                : "6 mins",
                            Icons.access_time_rounded,
                          ),
                          _buildStatColumn(
                            "GPS Accuracy",
                            tracking.hasGpsSignal ? "High" : "High",
                            Icons.network_ping_rounded,
                            color: Colors.greenAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Pause / Resume button
                      PrimaryButton(
                        text: tracking.isPaused ? "Resume Tracking" : "Pause Tracking",
                        icon: tracking.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        backgroundColor: tracking.isPaused 
                            ? AppColors.primary 
                            : Colors.white.withOpacity(0.06),
                        textColor: Colors.white,
                        onPressed: () {
                          if (tracking.isPaused) {
                            ref.read(trackingProvider.notifier).resumeTracking();
                          } else {
                            ref.read(trackingProvider.notifier).pauseTracking();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.black,
            color: color ?? Colors.white,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Update annotations on the Mapbox map
  Future<void> _updateMapAnnotations(double userLat, double userLng, double destLat, double destLng) async {
    if (_mapboxMap == null) return;

    _polylineAnnotationManager ??= await _mapboxMap!.annotations.createPolylineAnnotationManager();
    _pointAnnotationManager ??= await _mapboxMap!.annotations.createPointAnnotationManager();

    // Clear previous elements
    await _polylineAnnotationManager!.deleteAll();
    await _pointAnnotationManager!.deleteAll();

    final userPt = Point(coordinates: Position(userLng, userLat));
    final destPt = Point(coordinates: Position(destLng, destLat));

    // Draw user coordinate
    await _pointAnnotationManager!.create(
      PointAnnotationOptions(
        geometry: userPt,
        iconImage: "user-location-icon",
        iconSize: 1.0,
      ),
    );

    // Draw destination pin
    await _pointAnnotationManager!.create(
      PointAnnotationOptions(
        geometry: destPt,
        iconImage: "marker-icon",
        iconSize: 1.5,
      ),
    );

    // Draw route path line connect
    await _polylineAnnotationManager!.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: [
          Position(userLng, userLat),
          Position(destLng, destLat),
        ]),
        lineColor: AppColors.primaryLight.value,
        lineWidth: 4.0,
      ),
    );
  }
}
