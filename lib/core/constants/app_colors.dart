import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary gradient
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Background
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFFADB5BD);

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Input
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputFill = Color(0xFFF8FAFC);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEEF2FF), Color(0xFFF8F9FF)],
  );
}
