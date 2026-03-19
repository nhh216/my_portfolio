import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

/// Root widget for the Portfolio Tracker app.
/// Wraps everything in a [ProviderScope] for Riverpod state management.
class PortfolioTrackerApp extends StatelessWidget {
  const PortfolioTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Portfolio Tracker',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: trackerRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
