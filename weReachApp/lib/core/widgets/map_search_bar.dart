import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

class MapSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onLocationPressed;
  final TextEditingController? controller;
  final bool readOnly;
  final FocusNode? focusNode;

  const MapSearchBar({
    super.key,
    this.hintText = "Where are you going?",
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onLocationPressed,
    this.controller,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      blur: 20.0,
      backgroundColor: AppColors.surface.withOpacity(0.65),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            // Search Icon
            Icon(
              Icons.search_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 22,
            ),
            const SizedBox(width: 12),
            
            // Text Input
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: readOnly,
                onTap: onTap,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontWeight: FontWeight.w400,
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            
            // Divider
            if (onLocationPressed != null) ...[
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              // Location Button
              IconButton(
                onPressed: onLocationPressed,
                icon: const Icon(
                  Icons.gps_fixed_rounded,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
