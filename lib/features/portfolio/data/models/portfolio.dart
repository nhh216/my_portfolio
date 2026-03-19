import 'package:freezed_annotation/freezed_annotation.dart';
import 'asset.dart';

part 'portfolio.freezed.dart';

/// Aggregate view of all assets — computed at provider level, not stored.
@freezed
class Portfolio with _$Portfolio {
  const factory Portfolio({
    required List<Asset> assets,
    required double totalValue,
    required double totalPnl,
    required double totalPnlPercent,
  }) = _Portfolio;
}
