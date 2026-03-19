import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color seed = Color(0xFF6750A4);

  // Light scheme overrides
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF0F4);

  // Dark scheme overrides
  static const Color darkBackground = Color(0xFF0F0F14);
  static const Color darkSurface = Color(0xFF1C1C24);
  static const Color darkSurfaceVariant = Color(0xFF2A2A35);

  // Semantic
  static const Color profit = Color(0xFF4CAF50);
  static const Color loss = Color(0xFFF44336);
}
