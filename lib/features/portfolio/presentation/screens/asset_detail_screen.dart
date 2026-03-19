import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/asset.dart';
import '../../domain/providers/asset_provider.dart';
import '../widgets/pnl_badge.dart';

/// Displays full stats for a single asset identified by [assetId].
class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Asset Detail'),
      ),
      body: assetsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(assetProvider),
        ),
        data: (assets) {
          final asset = _findAsset(assets);
          if (asset == null) {
            return const ErrorView(message: 'Asset not found');
          }
          return _AssetDetailBody(asset: asset);
        },
      ),
    );
  }

  Asset? _findAsset(List<Asset> assets) {
    for (final a in assets) {
      if (a.id == assetId) return a;
    }
    return null;
  }
}

class _AssetDetailBody extends StatelessWidget {
  const _AssetDetailBody({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final pnlColor = asset.pnl > 0
        ? AppColors.profit
        : asset.pnl < 0
            ? AppColors.loss
            : Colors.grey;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(asset: asset),
          const SizedBox(height: AppSpacing.lg),
          _StatRow(
            label: 'Quantity',
            value: asset.quantity.toString(),
          ),
          _StatRow(
            label: 'Buy Price',
            value: CurrencyFormatter.usd(asset.buyPrice),
          ),
          _StatRow(
            label: 'Current Price',
            value: CurrencyFormatter.usd(asset.currentPrice),
          ),
          _StatRow(
            label: 'Total Value',
            value: CurrencyFormatter.usd(asset.totalValue),
          ),
          const Divider(height: AppSpacing.xl),
          _StatRow(
            label: 'P&L',
            value: CurrencyFormatter.usd(asset.pnl),
            valueColor: pnlColor,
            trailing: PnlBadge(pnlPercent: asset.pnlPercent),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          child: Text(
            asset.symbol.length > 2
                ? asset.symbol.substring(0, 2)
                : asset.symbol,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              asset.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              asset.symbol,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
