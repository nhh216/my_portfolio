import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/portfolio.dart';
import 'pnl_badge.dart';

/// Top-of-screen card showing total portfolio value and aggregate P&L.
class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({super.key, required this.portfolio});

  final Portfolio portfolio;

  @override
  Widget build(BuildContext context) {
    final pnlColor = portfolio.totalPnl > 0
        ? AppColors.profit
        : portfolio.totalPnl < 0
            ? AppColors.loss
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Portfolio Value',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              CurrencyFormatter.usd(portfolio.totalValue),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  CurrencyFormatter.usd(portfolio.totalPnl),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: pnlColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PnlBadge(pnlPercent: portfolio.totalPnlPercent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
