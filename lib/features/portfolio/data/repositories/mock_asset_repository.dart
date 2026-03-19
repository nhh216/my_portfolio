import '../models/asset.dart';
import 'asset_repository.dart';

/// In-memory implementation of [AssetRepository] with 5 mock assets.
/// Simulates a 300 ms network round-trip.
class MockAssetRepository implements AssetRepository {
  static final List<Asset> _mockAssets = [
    // Positive P&L
    const Asset(
      id: 'aapl',
      name: 'Apple Inc.',
      symbol: 'AAPL',
      quantity: 10,
      buyPrice: 150.0,
      currentPrice: 178.5,
    ),
    // Positive P&L (crypto)
    const Asset(
      id: 'btc',
      name: 'Bitcoin',
      symbol: 'BTC',
      quantity: 0.5,
      buyPrice: 42000.0,
      currentPrice: 51200.0,
    ),
    // Negative P&L (VN stock)
    const Asset(
      id: 'vic',
      name: 'VinGroup',
      symbol: 'VIC',
      quantity: 100,
      buyPrice: 85000.0,
      currentPrice: 72000.0,
    ),
    // Positive P&L
    const Asset(
      id: 'tsla',
      name: 'Tesla Inc.',
      symbol: 'TSLA',
      quantity: 5,
      buyPrice: 220.0,
      currentPrice: 248.0,
    ),
    // Positive P&L (crypto)
    const Asset(
      id: 'eth',
      name: 'Ethereum',
      symbol: 'ETH',
      quantity: 2.0,
      buyPrice: 2200.0,
      currentPrice: 2650.0,
    ),
  ];

  @override
  Future<List<Asset>> getAssets() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_mockAssets);
  }
}
