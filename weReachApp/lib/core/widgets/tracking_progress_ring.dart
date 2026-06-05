import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TrackingProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double remainingDistance; // km
  final VoidCallback? onTapTestSound;
  final bool hasError;

  const TrackingProgressRing({
    super.key,
    required this.progress,
    required this.remainingDistance,
    this.onTapTestSound,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapTestSound,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (hasError ? AppColors.alert : AppColors.primary)
                  .withOpacity(0.08),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return CustomPaint(
              painter: _RingPainter(
                progress: value,
                strokeColor: hasError ? AppColors.alert : AppColors.primary,
                trackColor: Colors.white.withOpacity(0.05),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasError) ...[
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.alert,
                        size: 44,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "GPS Alert",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.alert,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Signal Weak",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      // Remaining Distance
                      Text(
                        remainingDistance >= 100 
                            ? remainingDistance.toStringAsFixed(0)
                            : remainingDistance.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w200,
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                          letterSpacing: -1,
                        ),
                      ),
                      const Text(
                        "KM REMAINING",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (onTapTestSound != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.volume_up_rounded, 
                                size: 12, 
                                color: Colors.white.withOpacity(0.4)
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "TEST ALARM",
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white.withOpacity(0.4),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color strokeColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.strokeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 8;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress stroke
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          strokeColor.withOpacity(0.3),
          strokeColor,
        ],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    // We start from top (-pi / 2) and draw sweeps up to 2 * pi
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
