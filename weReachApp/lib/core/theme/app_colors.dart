import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2563EB); // Royal Electric Blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color accent = Color(0xFF06B6D4); // Cyan Active State
  
  // Dark Theme Palette (Linear/Shadcn inspired)
  static const Color background = Color(0xFF030712); // Deep Rich Slate/Black
  static const Color surface = Color(0xFF0F172A); // Slate-900 (Solid Cards)
  static const Color cardBg = Color(0x661E293B); // Translucent Card Base (40% opacity Slate-800)
  static const Color border = Color(0xFF1E293B); // Slate-800 for solid borders
  static const Color glassBorder = Color(0x33FFFFFF); // Subtle white tint border for Glassmorphism
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate-50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate-400
  static const Color textMuted = Color(0xFF64748B); // Slate-500
  
  // Status Colors
  static const Color alert = Color(0xFFEF4444); // Crimson Alert
  static const Color alertGlow = Color(0x33EF4444);
  static const Color success = Color(0xFF10B981); // Emerald Active
  static const Color warning = Color(0xFFF59E0B); // Amber
  
  // Overlays
  static const Color scrim = Color(0x80000000);
}
