import 'package:flutter/material.dart';

/// Application Color Constants
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary Colors
  static const Color secondary = Color(0xFF764BA2);
  static const Color secondaryDark = Color(0xFF6B4190);
  static const Color secondaryLight = Color(0xFF8B5BB5);

  // Accent Colors
  static const Color accent = Color(0xFFF093FB);
  static const Color accentDark = Color(0xFFE080E8);
  static const Color accentLight = Color(0xFFFFB3FF);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF131A2E);

  /// Slightly lighter dark surface for nested cards / inputs that need to read
  /// above [surfaceDark] (e.g. the URL input on the dashboard).
  static const Color surfaceDarkElevated = Color(0xFF1A2138);

  /// Subtle border/outline used on dark surfaces.
  static const Color borderDark = Color(0xFF252D45);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDAA5D);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF74B9FF);

  // Border & Divider Colors
  static const Color border = Color(0xFFDFE6E9);
  static const Color divider = Color(0xFFECF0F1);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFF5576C)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark, surfaceDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  // ---------------------------------------------------------------------------
  // Theme-aware resolvers
  //
  // Use these inside widgets (they need a [BuildContext]) so colors adapt to
  // light/dark mode. The plain constants above remain the light-mode values and
  // are still valid for brand colors that don't change between modes
  // (primary, secondary, error, success, ...).
  // ---------------------------------------------------------------------------

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Scaffold / page background.
  static Color bg(BuildContext context) =>
      _isDark(context) ? backgroundDark : background;

  /// Card / elevated surface background.
  static Color surfaceColor(BuildContext context) =>
      _isDark(context) ? surfaceDark : surface;

  /// Primary, high-emphasis text.
  static Color textPrimaryColor(BuildContext context) =>
      _isDark(context) ? textLight : textPrimary;

  /// Secondary, lower-emphasis text. The light-mode grey (textSecondary) is too
  /// dark to read on the dark background, so use the lighter grey there.
  static Color textSecondaryColor(BuildContext context) =>
      _isDark(context) ? textLight : textSecondary;

  /// Borders / outlines.
  static Color borderColor(BuildContext context) =>
      _isDark(context) ? borderDark : border;

  /// Dividers.
  static Color dividerColor(BuildContext context) =>
      _isDark(context) ? borderDark : divider;
}
