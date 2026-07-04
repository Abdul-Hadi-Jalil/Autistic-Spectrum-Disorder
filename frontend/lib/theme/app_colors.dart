import 'package:flutter/material.dart';

/// Central color palette for the ASD CARE app UI.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2A3F9D);
  static const Color primaryDark = Color(0xFF1E2E73);
  static const Color heading = Color(0xFF1F3A6B);

  // Surfaces
  static const Color background = Color(0xFFF3F4F6);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color selectedFill = Color(0xFFD6E4F5);
  static const Color selectedBorder = Color(0xFF9DB6E0);

  // Text
  static const Color textPrimary = Color(0xFF1F3A6B);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textFaint = Color(0xFF9CA3AF);

  // Status
  static const Color lowRisk = Color(0xFF2E7D5B);
  static const Color moderateRisk = Color(0xFFB7791F);
  static const Color highRisk = Color(0xFF8E2C4D);
  static const Color danger = Color(0xFFD64545);

  // Risk result gradients
  static const List<Color> lowGradient = [Color(0xFFF0B90B), Color(0xFFE6C200)];
  static const List<Color> moderateGradient = [
    Color(0xFFC79A6B),
    Color(0xFFB7A02E),
  ];
  static const List<Color> highGradient = [
    Color(0xFF7E2B49),
    Color(0xFF8E2C4D),
  ];
  static const List<Color> splashGradient = [
    Color(0xFF6E91C2),
    Color(0xFFC7D6E8),
  ];
}
