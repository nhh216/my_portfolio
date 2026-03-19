import 'package:flutter/material.dart';

/// Named text styles used throughout the Portfolio Tracker.
/// All styles reference the ambient [TextTheme] — callers pass [context].
abstract final class AppTextStyles {
  static TextStyle headingLarge(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge!.copyWith(
            fontWeight: FontWeight.w700,
          );

  static TextStyle headingMedium(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w600,
          );

  static TextStyle titleLarge(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
          );

  static TextStyle bodyLarge(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!;

  static TextStyle bodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  static TextStyle labelMedium(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!;
}
