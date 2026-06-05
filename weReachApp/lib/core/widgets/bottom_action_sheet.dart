import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

class BottomActionSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final bool isGlassmorphic;

  const BottomActionSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.isGlassmorphic = true,
  });

  @override
  Widget build(BuildContext context) {
    // If glassmorphic, wrap card with GlassCard inside Container.
    final sheetContent = Container(
      decoration: BoxDecoration(
        color: isGlassmorphic ? Colors.transparent : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: isGlassmorphic 
            ? null 
            : const Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header Info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Core Body Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: child,
              ),
            ),
            
            // Bottom Actions (if any)
            if (actions != null && actions!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  gap: 12,
                  children: actions!.map((act) => Expanded(child: act)).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isGlassmorphic) {
      return GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        blur: 20.0,
        backgroundColor: AppColors.surface.withOpacity(0.7),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        child: sheetContent,
      );
    }

    return sheetContent;
  }

  // Static helper to display sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget child,
    List<Widget>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BottomActionSheet(
            title: title,
            subtitle: subtitle,
            actions: actions,
            child: child,
          ),
        );
      },
    );
  }
}

// Extension to allow simple row gaps
extension on Row {
  Row get gap => this; // Placeholder since we can map list directly in actions mapping with spacers.
}
