import 'dart:ui';

/// App color palette for FarmaMap Sevilla
/// Supports both light and dark themes
class AppColors {
  AppColors._();

  // Primary palette - Pharmacy green
  static const Color primary = Color(0xFF00A86B);
  static const Color primaryLight = Color(0xFF4CD9A0);
  static const Color primaryDark = Color(0xFF005F3E);
  static const Color primaryContainer = Color(0xFFB8F0D8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF002114);

  // Secondary palette
  static const Color secondary = Color(0xFF005F3E);
  static const Color secondaryLight = Color(0xFF338F6E);
  static const Color secondaryContainer = Color(0xFFC2E8D4);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF001B0E);

  // Tertiary
  static const Color tertiary = Color(0xFF3B6B5E);
  static const Color tertiaryContainer = Color(0xFFBEECDB);

  // Error
  static const Color error = Color(0xFFE53935);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  // Light theme surfaces
  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEDF2EE);
  static const Color onBackgroundLight = Color(0xFF191C1A);
  static const Color onSurfaceLight = Color(0xFF191C1A);
  static const Color onSurfaceVariantLight = Color(0xFF414942);
  static const Color outlineLight = Color(0xFF717972);
  static const Color outlineVariantLight = Color(0xFFC1C9C1);

  // Dark theme surfaces
  static const Color backgroundDark = Color(0xFF0D1F1A);
  static const Color surfaceDark = Color(0xFF1A2E28);
  static const Color surfaceVariantDark = Color(0xFF253D35);
  static const Color onBackgroundDark = Color(0xFFE1E3DF);
  static const Color onSurfaceDark = Color(0xFFE1E3DF);
  static const Color onSurfaceVariantDark = Color(0xFFC1C9C1);
  static const Color outlineDark = Color(0xFF8B938C);
  static const Color outlineVariantDark = Color(0xFF414942);

  // Shadows
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Map markers
  static const Color markerPharmacy = Color(0xFF00A86B);
  static const Color markerUser = Color(0xFF2196F3);
  static const Color markerUserGlow = Color(0x402196F3);

  // Favorites
  static const Color favorite = Color(0xFFE91E63);

  // Radius indicator
  static const Color radiusStroke = Color(0xFF00A86B);
  static const Color radiusFill = Color(0x1A00A86B);
}
