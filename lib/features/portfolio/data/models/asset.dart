import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset.freezed.dart';
part 'asset.g.dart';

/// Immutable model representing a single investment asset.
@freezed
class Asset with _$Asset {
  const factory Asset({
    required String id,
    required String name,
    required String symbol,
    required double quantity,
    required double buyPrice,
    required double currentPrice,
  }) = _Asset;

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
}

/// Computed P&L values derived from [Asset] fields.
extension AssetComputed on Asset {
  double get totalValue => quantity * currentPrice;

  double get pnl => totalValue - (quantity * buyPrice);

  /// Returns 0.0 when buyPrice is 0 to prevent division by zero.
  double get pnlPercent {
    final cost = quantity * buyPrice;
    if (cost == 0) return 0.0;
    return (pnl / cost) * 100;
  }
}
