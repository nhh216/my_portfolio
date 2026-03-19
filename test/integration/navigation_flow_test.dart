import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/app/app.dart';
import 'package:my_portfolio/features/portfolio/data/models/asset.dart';
import 'package:my_portfolio/features/portfolio/data/repositories/asset_repository.dart';
import 'package:my_portfolio/features/portfolio/presentation/screens/asset_detail_screen.dart';
import 'package:my_portfolio/features/portfolio/presentation/screens/home_screen.dart';

/// Stub repository that returns instantly for widget tests.
class _InstantAssetRepository implements AssetRepository {
  @override
  Future<List<Asset>> getAssets() async => const [
        Asset(
          id: 'aapl',
          name: 'Apple Inc.',
          symbol: 'AAPL',
          quantity: 10,
          buyPrice: 150.0,
          currentPrice: 178.5,
        ),
        Asset(
          id: 'btc',
          name: 'Bitcoin',
          symbol: 'BTC',
          quantity: 0.5,
          buyPrice: 42000.0,
          currentPrice: 51200.0,
        ),
      ];
}

Widget _app() => ProviderScope(
      overrides: [
        assetRepositoryProvider.overrideWithValue(_InstantAssetRepository()),
      ],
      child: const PortfolioTrackerApp(),
    );

void main() {
  group('Navigation Flow Integration Tests', () {
    testWidgets('App starts on HomeScreen', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('HomeScreen shows My Portfolio app bar', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.text('My Portfolio'), findsOneWidget);
    });

    testWidgets('Tapping an asset tile navigates to AssetDetailScreen',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('AAPL').first);
      await tester.pumpAndSettle();

      expect(find.byType(AssetDetailScreen), findsOneWidget);
    });

    testWidgets('Back button on detail screen returns to HomeScreen',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('AAPL').first);
      await tester.pumpAndSettle();
      expect(find.byType(AssetDetailScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Detail screen shows correct asset name', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('AAPL').first);
      await tester.pumpAndSettle();

      expect(find.text('Apple Inc.'), findsWidgets);
    });
  });
}
