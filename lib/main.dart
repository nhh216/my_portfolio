import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'app/app.dart';

void main() {
  setUrlStrategy(HashUrlStrategy());
  runApp(
    const ProviderScope(
      child: PortfolioTrackerApp(),
    ),
  );
}
