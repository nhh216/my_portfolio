import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/asset.dart';
import '../../data/models/portfolio.dart';
import 'asset_provider.dart';

/// Derives [Portfolio] aggregate totals from [assetProvider].
/// Returns [AsyncValue<Portfolio>] so screens can handle all three states.
final portfolioProvider = Provider<AsyncValue<Portfolio>>((ref) {
  return ref.watch(assetProvider).whenData(_buildPortfolio);
});

Portfolio _buildPortfolio(List<Asset> assets) {
  final totalValue = assets.fold(0.0, (sum, a) => sum + a.totalValue);
  final totalPnl = assets.fold(0.0, (sum, a) => sum + a.pnl);
  final totalCost = assets.fold(
    0.0,
    (sum, a) => sum + (a.quantity * a.buyPrice),
  );
  final totalPnlPercent = totalCost == 0 ? 0.0 : (totalPnl / totalCost) * 100;

  return Portfolio(
    assets: assets,
    totalValue: totalValue,
    totalPnl: totalPnl,
    totalPnlPercent: totalPnlPercent,
  );
}
