import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/bottom_action_sheet.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';

class MapSelectionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialLocation;

  const MapSelectionScreen({super.key, this.initialLocation});

  @override
  ConsumerState<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends ConsumerState<MapSelectionScreen> {
  MapboxMap? _mapboxMap;
  Point? _selectedPoint;
  String _placeName = "";
  bool _loadingLocation = true;
  double _mapLat = 48.8566; // Defaults to Paris
  double _mapLng = 2.3522;
  PointAnnotationManager? _pointAnnotationManager;

  @override
  void initState() {
    super.initState();
    _initCoordinates();
  }

  Future<void> _initCoordinates() async {
    if (widget.initialLocation != null) {
      setState(() {
        _mapLat = widget.initialLocation!['lat'];
        _mapLng = widget.initialLocation!['lng'];
        _placeName = widget.initialLocation!['name'] ?? "Selected Location";
        _selectedPoint = Point(coordinates: Position(_mapLng, _mapLat));
        _loadingLocation = false;
      });
      _showConfirmationSheet();
    } else {
      _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final loc = ref.read(locationServiceProvider);
      final pos = await loc.getCurrentPosition();
      if (mounted) {
        setState(() {
          _mapLat = pos.latitude;
          _mapLng = pos.longitude;
          _loadingLocation = false;
        });
        _moveCamera(_mapLat, _mapLng);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  void _moveCamera(double lat, double lng) {
    _mapboxMap?.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: 13.5,
      ),
    );
  }

  Future<void> _onMapTapped(Point point) async {
    setState(() {
      _selectedPoint = point;
      _mapLat = point.coordinates.lat.toDouble();
      _mapLng = point.coordinates.lng.toDouble();
      _placeName = "Custom Pin (${_mapLat.toStringAsFixed(4)}, ${_mapLng.toStringAsFixed(4)})";
    });

    await _drawMarker(point);
    _showConfirmationSheet();
  }

  Future<void> _drawMarker(Point point) async {
    if (_mapboxMap == null) return;
    
    // Create annotation manager if not initialized
    _pointAnnotationManager ??= await _mapboxMap!.annotations.createPointAnnotationManager();
    
    // Clear old markers
    await _pointAnnotationManager!.deleteAll();
    
    // Add new pin marker
    await _pointAnnotationManager!.create(
      PointAnnotationOptions(
        geometry: point,
        iconImage: "marker-icon", // Mapbox default marker assets or system default
        iconSize: 1.5,
      ),
    );
  }

  void _showConfirmationSheet() {
    BottomActionSheet.show(
      context: context,
      title: _placeName,
      subtitle: "${_mapLat.toStringAsFixed(6)}, ${_mapLng.toStringAsFixed(6)}",
      actions: [
        PrimaryButton(
          text: "Confirm Stop",
          icon: Icons.check_circle_rounded,
          onPressed: () {
            // Register inside recent trips
            ref.read(recentsProvider.notifier).addRecent(_placeName, "Custom map coordinate", _mapLat, _mapLng);
            
            // Trigger GPS tracking
            ref.read(trackingProvider.notifier).startTracking(
                  name: _placeName,
                  latitude: _mapLat,
                  longitude: _mapLng,
                );
                
            context.pop(); // Close bottom sheet
            context.go('/tracking');
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const Text(
            "Configure Stop",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.star_border_rounded, color: Colors.amber),
            title: const Text("Save Stop to Favorites", style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              ref.read(favoritesProvider.notifier).addFavorite(_placeName, "Saved Coordinates", _mapLat, _mapLng);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Saved $_placeName to Favorites"),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Pick Spot on Map",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: _getUserLocation,
            icon: const Icon(Icons.my_location_rounded, color: AppColors.primaryLight),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _loadingLocation
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : MapWidget(
                  key: const ValueKey("selectMap"),
                  cameraOptions: CameraOptions(
                    center: Point(coordinates: Position(_mapLng, _mapLat)),
                    zoom: 13.0,
                  ),
                  onMapCreated: (MapboxMap mapboxMap) {
                    _mapboxMap = mapboxMap;
                    
                    // Hook tap/long press listeners
                    // On newer mapbox versions, we can tap the map directly
                    _mapboxMap!.gestures.addOnMapClickListener((point) {
                      _onMapTapped(Point(coordinates: point));
                      return true;
                    });
                    
                    _mapboxMap!.gestures.addOnMapLongClickListener((point) {
                      _onMapTapped(Point(coordinates: point));
                      return true;
                    });
                    
                    // If initial coord exists, draw it immediately
                    if (_selectedPoint != null) {
                      _drawMarker(_selectedPoint!);
                    }
                  },
                ),
                
          // Guide overlay
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_rounded, size: 16, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text(
                      "Tap or long-press map to place your arrival alert pin",
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
