import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/asset.dart';
import 'pnl_badge.dart';

/// Single row in the asset list showing symbol, name, current price and P&L.
class AssetListTile extends StatelessWidget {
  const AssetListTile({
    super.key,
    required this.asset,
    required this.onTap,
  });

  final Asset asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(asset.id),
      onTap: onTap,
      leading: CircleAvatar(
        child: Text(
          asset.symbol.length > 2
              ? asset.symbol.substring(0, 2)
              : asset.symbol,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(asset.symbol),
      subtitle: Text(
        asset.name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            CurrencyFormatter.usd(asset.currentPrice),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          PnlBadge(pnlPercent: asset.pnlPercent),
        ],
      ),
    );
  }
}
