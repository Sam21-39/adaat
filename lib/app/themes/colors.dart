import 'package:flutter/material.dart';

/// Adaat Color Palette - Gen-Z Vibrant Aesthetic
class AppColors {
  AppColors._();

  // Primary Gradient Colors (Orange to Pink)
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryPink = Color(0xFFFF4080);
  static const Color primaryPurple = Color(0xFF7C3AED);

  // Accent Colors
  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color accentRed = Color(0xFFEF4444);

  // Heatmap Colors (GitHub style)
  static const Color heatmapEmpty = Color(0xFFEBEDF0);
  static const Color heatmapLevel1 = Color(0xFF9BE9A8);
  static const Color heatmapLevel2 = Color(0xFF40C463);
  static const Color heatmapLevel3 = Color(0xFF30A14E);
  static const Color heatmapLevel4 = Color(0xFF216E39);

  // Category Colors
  static const Color categoryHealth = Color(0xFFEF4444);
  static const Color categoryLearning = Color(0xFF3B82F6);
  static const Color categoryMoney = Color(0xFF22C55E);
  static const Color categoryProductivity = Color(0xFFF59E0B);
  static const Color categoryWellness = Color(0xFF8B5CF6);
  static const Color categoryCreative = Color(0xFFEC4899);
  static const Color categorySpiritual = Color(0xFF6366F1);

  // Light Theme
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFF3F4F6);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkDivider = Color(0xFF334155);

  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [primaryPurple, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [accentGreen, Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
