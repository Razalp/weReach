import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/map_search_bar.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  double _userLat = 11.2588; // Kozhikode default
  double _userLng = 75.7804;
  bool _loadingLocation = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final loc = ref.read(locationServiceProvider);
      final pos = await loc.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLat = pos.latitude;
          _userLng = pos.longitude;
          _loadingLocation = false;
        });
        
        _updateMapCamera(_userLat, _userLng);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  void _updateMapCamera(double lat, double lng) {
    _mapboxMap?.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: 12.5,
        pitch: 45.0,
        bearing: -10.0,
      ),
    );
  }

  // Draw Marker Pin for Selected Destination in Mapbox
  Future<void> _updateDestinationMarker(double lat, double lng) async {
    if (_mapboxMap == null) return;
    
    _pointAnnotationManager ??= await _mapboxMap!.annotations.createPointAnnotationManager();
    await _pointAnnotationManager!.deleteAll();

    final destPt = Point(coordinates: Position(lng, lat));

    await _pointAnnotationManager!.create(
      PointAnnotationOptions(
        geometry: destPt,
        iconImage: "marker-icon",
        iconSize: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final recents = ref.watch(recentsProvider);
    final selectedDest = ref.watch(selectedDestinationProvider);

    // Update camera and marker if selection changes
    if (_mapboxMap != null && selectedDest != null) {
      _updateDestinationMarker(selectedDest.latitude, selectedDest.longitude);
      _updateMapCamera(selectedDest.latitude, selectedDest.longitude);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Map Background (Mapbox 3D dark perspective)
          Positioned.fill(
            child: _loadingLocation
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : MapWidget(
                    key: const ValueKey("homeMap"),
                    styleUri: "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json",
                    cameraOptions: CameraOptions(
                      center: Point(coordinates: Position(_userLng, _userLat)),
                      zoom: 12.0,
                      pitch: 45.0,
                      bearing: -10.0,
                    ),
                    onMapCreated: (MapboxMap mapboxMap) {
                      _mapboxMap = mapboxMap;
                      if (selectedDest != null) {
                        _updateDestinationMarker(selectedDest.latitude, selectedDest.longitude);
                        _updateMapCamera(selectedDest.latitude, selectedDest.longitude);
                      }
                    },
                  ),
          ),

          // Cinematic vignette overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 0.85],
                ),
              ),
            ),
          ),

          // 2. UI Layout Overlays
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // Top Header (Spark Icon + Wereach Title & Location Refresh)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: const Icon(
                              Icons.star_purple500_rounded,
                              color: AppColors.primaryLight,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Wereach",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.black,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                "Don't miss your stop",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Refresh GPS Location Button
                      ClipOval(
                        child: Container(
                          color: Colors.white.withOpacity(0.06),
                          child: IconButton(
                            onPressed: _getUserLocation,
                            icon: const Icon(
                              Icons.compass_calibration_outlined,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Search Bar over map
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: MapSearchBar(
                    hintText: selectedDest != null ? selectedDest.name : "Where are you going?",
                    readOnly: true,
                    onTap: () => context.push('/search'),
                    onLocationPressed: _getUserLocation,
                  ),
                ),

                const Spacer(),

                // Bottom Overlay Stack
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      // Slide-up place preview card if destination selected
                      if (selectedDest != null) ...[
                        GlassCard(
                          backgroundColor: const Color(0xE60A0F1E),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                                ),
                                child: const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedDest.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      selectedDest.address,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedDest.distanceText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() => _isBookmarked = !_isBookmarked);
                                },
                                icon: Icon(
                                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                  color: _isBookmarked ? AppColors.primaryLight : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Recent Places
                      const Text(
                        "RECENT PLACES",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 96,
                        child: recents.when(
                          data: (list) {
                            if (list.isEmpty) {
                              return const Center(child: Text("No recents yet", style: TextStyle(color: AppColors.textMuted, fontSize: 12)));
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: list.length > 5 ? 5 : list.length,
                              itemBuilder: (context, index) {
                                final item = list[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      final mockDist = (Random().nextDouble() * 12 + 1).toStringAsFixed(1);
                                      ref.read(selectedDestinationProvider.notifier).state = SelectedDestination(
                                        name: item.name,
                                        address: item.address,
                                        latitude: item.latitude,
                                        longitude: item.longitude,
                                        distanceText: "$mockDist km away",
                                      );
                                    },
                                    child: GlassCard(
                                      width: 140,
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.train_rounded, color: AppColors.primaryLight, size: 16),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const Text(
                                                "Recent Stop",
                                                style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          error: (_, __) => const SizedBox(),
                          loading: () => const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Favorites Row
                      const Text(
                        "FAVORITES",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        child: favorites.when(
                          data: (list) {
                            if (list.isEmpty) {
                              return const Center(child: Text("No favorites yet", style: TextStyle(color: AppColors.textMuted, fontSize: 12)));
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final item = list[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      final mockDist = (Random().nextDouble() * 12 + 1).toStringAsFixed(1);
                                      ref.read(selectedDestinationProvider.notifier).state = SelectedDestination(
                                        name: item.name,
                                        address: item.address,
                                        latitude: item.latitude,
                                        longitude: item.longitude,
                                        distanceText: "$mockDist km away",
                                      );
                                    },
                                    child: GlassCard(
                                      width: 155,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.home_filled, color: Colors.greenAccent, size: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const Text(
                                                  "Favorite",
                                                  style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          error: (_, __) => const SizedBox(),
                          loading: () => const Center(child: CircularProgressIndicator()),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Continue Pill Action Button
                      Opacity(
                        opacity: selectedDest != null ? 1.0 : 0.4,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: selectedDest != null 
                              ? () => context.push('/settings') 
                              : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "Continue",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}
