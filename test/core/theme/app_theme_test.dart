import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/theme/app_colors.dart';

/// Tests for AppColors constants and ColorScheme generation.
/// AppTheme.light/dark are not tested directly because they trigger
/// google_fonts HTTP fetches which fail in the test environment.
/// Widget-level dark/light mode rendering is covered in individual
/// page test files using AppTheme.light/dark with pumpWidget.
void main() {
  group('AppColors Tests', () {
    test('Seed color is correct', () {
      expect(AppColors.seed, equals(const Color(0xFF6750A4)));
    });

    test('Light surface is white', () {
      expect(AppColors.lightSurface, equals(const Color(0xFFFFFFFF)));
    });

    test('Dark surface is dark gray', () {
      expect(AppColors.darkSurface, equals(const Color(0xFF1C1C24)));
    });

    test('Profit color is green', () {
      expect(AppColors.profit, equals(const Color(0xFF4CAF50)));
    });

    test('Loss color is red', () {
      expect(AppColors.loss, equals(const Color(0xFFF44336)));
    });

    test('Light and dark surface colors are different', () {
      expect(AppColors.lightSurface, isNot(equals(AppColors.darkSurface)));
    });

    test('Light and dark background colors are different', () {
      expect(
        AppColors.lightBackground,
        isNot(equals(AppColors.darkBackground)),
      );
    });
  });

  group('ColorScheme Generation Tests', () {
    test('Light color scheme generates from seed', () {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: Brightness.light,
        surface: AppColors.lightSurface,
      );

      expect(colorScheme.brightness, equals(Brightness.light));
      expect(colorScheme.surface, equals(AppColors.lightSurface));
      expect(colorScheme.primary, isNotNull);
    });

    test('Dark color scheme generates from seed', () {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
      );

      expect(colorScheme.brightness, equals(Brightness.dark));
      expect(colorScheme.surface, equals(AppColors.darkSurface));
      expect(colorScheme.primary, isNotNull);
    });

    test('Light and dark schemes have different brightness', () {
      final light = ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: Brightness.light,
      );
      final dark = ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: Brightness.dark,
      );

      expect(light.brightness, isNot(equals(dark.brightness)));
    });

    test('Light and dark schemes have different onSurface for contrast', () {
      final light = ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: Brightness.light,
        surface: AppColors.lightSurface,
      );
      final dark = ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
      );

      expect(light.onSurface, isNot(equals(dark.onSurface)));
    });
  });
}
