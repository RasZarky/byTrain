import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF0052CC); // Vibrant Blue
  static const Color primaryLight = Color(0xFF4C8CFF);
  static const Color primaryDark = Color(0xFF003D99);

  // Secondary/Accent colors
  static const Color accent = Color(0xFFC84C2C); // Terra Cotta / Burnt Orange
  static const Color accentLight = Color(0xFFE67E66);
  static const Color accentDark = Color(0xFFA03B22);

  // Neutral colors
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);

  // Text colors
  static const Color onPrimary = Colors.white;
  static const Color onAccent = Colors.white;
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFA0A0A0);

  // Status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFBC02D);
  static const Color info = Color(0xFF0288D1);

  // Deprecated names for backward compatibility if needed,
  // but let's stick to the new naming for consistency.
  static const Color secondary = accent;
  static const Color onSecondary = onAccent;
  static const Color onBackground = textPrimary;
  static const Color onSurface = textPrimary;
  static const Color onError = Colors.white;
}
