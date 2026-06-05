import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class AlertScreen extends ConsumerStatefulWidget {
  const AlertScreen({super.key});

  @override
  ConsumerState<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends ConsumerState<AlertScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _wave1Controller;
  late AnimationController _wave2Controller;
  late AnimationController _wave3Controller;
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    
    // Slow breathing animation controller for the main card text
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Staggered controllers for the concentric pulse waves
    _wave1Controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _wave2Controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(period: const Duration(seconds: 3));
    _wave3Controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(period: const Duration(seconds: 3));

    // Stagger waves manually to create continuous delay loops
    Timer(const Duration(seconds: 1), () {
      if (mounted) _wave2Controller.forward(from: 0.0)..repeat();
    });
    Timer(const Duration(seconds: 2), () {
      if (mounted) _wave3Controller.forward(from: 0.0)..repeat();
    });

    // Trigger strong periodic haptic vibration if enabled
    final settingsVal = ref.read(settingsProvider).value;
    final vibrationEnabled = settingsVal?.vibrationEnabled ?? true;

    if (vibrationEnabled) {
      _startVibrationLoop();
    }
  }

  void _startVibrationLoop() {
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _wave1Controller.dispose();
    _wave2Controller.dispose();
    _wave3Controller.dispose();
    _vibrationTimer?.cancel();
    super.dispose();
  }

  void _dismissAlarm() {
    ref.read(trackingProvider.notifier).stopTracking();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final destinationName = ref.watch(trackingProvider.select((state) => state.destinationName));
    final displayName = destinationName.isNotEmpty ? destinationName : "Kozhikode Railway Station";

    return Scaffold(
      backgroundColor: const Color(0xFF02050E), // Deep luxury black-blue
      body: Stack(
        alignment: Alignment.center,
        children: [
          
          // 1. Cinematic Background glow vectors
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
                valueSerializer: null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.08),
                    blurRadius: 80,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // 2. Concentric Pulsing Light Rings
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildPulseRing(_wave1Controller),
                _buildPulseRing(_wave2Controller),
                _buildPulseRing(_wave3Controller),
                
                // Central Glowing Location Emblem
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0x990F172A),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.35), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: sin(_pulseController.value * pi) * 0.1,
                          child: Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primaryLight,
                            size: 50,
                            shadows: [
                              Shadow(
                                color: AppColors.primaryLight.withOpacity(0.5),
                                blurRadius: 15,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. UI Labels & Action Panel overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  // Top Header setup
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: AppColors.primaryLight, size: 14),
                        SizedBox(width: 6),
                        Text(
                          "STOP ALERT",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.black,
                            color: AppColors.primaryLight,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Text Titles (Breathing Animation)
                  Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: 0.75 + (_pulseController.value * 0.25),
                            child: const Text(
                              "YOU ARE ARRIVING SOON",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.black,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Glassmorphic Stop card description
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0x660F172A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "ARRIVING STATION",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Alarm Dismiss Button
                  PrimaryButton(
                    text: "STOP ALARM",
                    icon: Icons.notifications_off_rounded,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    height: 60,
                    borderRadius: 30,
                    onPressed: _dismissAlarm,
                  ),
                  
                ],
              ),
            ),
          ),
          
          // iOS Indicator line
          Positioned(
            bottom: 8,
            child: Container(
              width: 130,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // Wave ripple paint widget helper
  Widget _buildPulseRing(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = 1.0 + (controller.value * 1.2);
        final opacity = (1.0 - controller.value).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.45), width: 1.5),
                color: AppColors.primary.withOpacity(0.03),
              ),
            ),
          ),
        );
      },
    );
  }
}
