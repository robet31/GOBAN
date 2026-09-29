import 'package:flutter/material.dart';

/// Goban application color palette
/// Based on AGENTS.md Section 7.1 design tokens
class AppColors {
  AppColors._();

  // ─── Primary Palette ───
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ─── Secondary Palette ───
  static const Color secondary = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFAD42);
  static const Color secondaryDark = Color(0xFFBB4D00);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ─── Status Colors ───
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ─── Neutral Palette ───
  static const Color background = Color(0xFFF8FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onBackground = Color(0xFF1B1B1F);
  static const Color onSurface = Color(0xFF1B1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // ─── Dark Mode Palette ───
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  static const Color darkOnSurface = Color(0xFFE6E1E5);

  // ─── Order Status Colors ───
  static const Color statusWaiting = Color(0xFF9E9E9E);
  static const Color statusAccepted = Color(0xFF2196F3);
  static const Color statusOngoing = Color(0xFFF57C00);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);

  // ─── Gradient Colors ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF60AD5E)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF57C00), Color(0xFFFFAD42)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
  );

  // ─── Shadow ───
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(13),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
