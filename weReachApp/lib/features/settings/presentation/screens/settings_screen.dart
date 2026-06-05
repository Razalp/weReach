import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final selectedDest = ref.watch(selectedDestinationProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Blurred background map for premium styling
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: selectedDest != null
                  ? MapWidget(
                      key: const ValueKey("settingsMap"),
                      styleUri: "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json",
                      cameraOptions: CameraOptions(
                        center: Point(coordinates: Position(selectedDest.longitude, selectedDest.latitude)),
                        zoom: 12.0,
                        pitch: 45.0,
                      ),
                    )
                  : Container(color: Colors.black),
            ),
          ),

          // Deep dark gradient vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Main Scrollable HUD Content
          SafeArea(
            child: settingsState.when(
              data: (settings) {
                final displayDestName = selectedDest?.name ?? settings.lastDestinationName ?? "Select Stop";
                final displayDestAddr = selectedDest?.address ?? "Awaiting destination...";
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar (Back button + Alert Setup badge)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          ClipOval(
                            child: Container(
                              color: Colors.white.withOpacity(0.06),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                                onPressed: () => context.pop(),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.notifications_active_rounded, color: AppColors.primaryLight, size: 12),
                                SizedBox(width: 6),
                                Text(
                                  "Alert setup",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            
                            // Destination Info Card
                            GlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.route_rounded, color: AppColors.primaryLight, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "DESTINATION",
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    displayDestName,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.black, color: Colors.white, height: 1.2),
                                  ),
                                  if (selectedDest != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      displayDestAddr,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Coords: ${selectedDest.latitude.toStringAsFixed(4)}° N, ${selectedDest.longitude.toStringAsFixed(4)}° E",
                                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textMuted),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Radius Config Slider (Thick Apple Style)
                            const Text(
                              "TRIGGER PREFERENCE",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 10),
                            GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.between,
                                    children: [
                                      const Text(
                                        "Alert Radius",
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Row(
                                        baseline: TextBaseline.alphabetic,
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        children: [
                                          Text(
                                            settings.alertRadius.toStringAsFixed(1),
                                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.black, color: AppColors.primaryLight),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            "km",
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Customized Apple Slider Theme
                                  SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 12,
                                      activeTrackColor: AppColors.primary,
                                      inactiveTrackColor: Colors.white.withOpacity(0.08),
                                      thumbColor: Colors.white,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                                    ),
                                    child: Slider(
                                      value: settings.alertRadius,
                                      min: 0.5,
                                      max: 10.0,
                                      divisions: 19,
                                      onChanged: (val) {
                                        ref.read(settingsProvider.notifier).updateSettings(alertRadius: val);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Text(
                                      "Alarm rings when entering ${settings.alertRadius.toStringAsFixed(1)} km out.",
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Switch Config list
                            const Text(
                              "ALARM INTERACTION",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 10),
                            GlassCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.volume_up_rounded, color: AppColors.primaryLight, size: 18),
                                    ),
                                    title: const Text("Sound Alarm", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                                    subtitle: const Text("Play high-frequency audio alert", style: TextStyle(fontSize: 11)),
                                    trailing: Switch(
                                      value: settings.soundEnabled,
                                      activeColor: AppColors.primaryLight,
                                      onChanged: (val) {
                                        ref.read(settingsProvider.notifier).updateSettings(soundEnabled: val);
                                      },
                                    ),
                                  ),
                                  const Divider(color: Colors.white10, height: 1, thickness: 0.5),
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.pink.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.vibration_rounded, color: Colors.pinkAccent, size: 18),
                                    ),
                                    title: const Text("Vibration alert", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                                    subtitle: const Text("Vibrate device periodically", style: TextStyle(fontSize: 11)),
                                    trailing: Switch(
                                      value: settings.vibrationEnabled,
                                      activeColor: Colors.pinkAccent,
                                      onChanged: (val) {
                                        ref.read(settingsProvider.notifier).updateSettings(vibrationEnabled: val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),

                    // Start Tracking Glowing Button
                    Padding(
                      padding: const EdgeInsets.all(20.0),
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
                              ? () {
                                  // Save recent
                                  ref.read(recentsProvider.notifier).addRecent(
                                        selectedDest.name,
                                        selectedDest.address,
                                        selectedDest.latitude,
                                        selectedDest.longitude,
                                      );

                                  // Start GPS tracking
                                  ref.read(trackingProvider.notifier).startTracking(
                                        name: selectedDest.name,
                                        latitude: selectedDest.latitude,
                                        longitude: selectedDest.longitude,
                                      );

                                  context.go('/tracking');
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.navigation_rounded, color: Colors.white.withOpacity(0.7), size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Start Tracking",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                );
              },
              error: (err, _) => const Center(child: Text("Error loading configurations", style: TextStyle(color: AppColors.alert))),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          )
        ],
      ),
    );
  }
}
