import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Colored chip displaying a P&L percentage with directional arrow.
/// Green = positive, red = negative, grey = zero.
class PnlBadge extends StatelessWidget {
  const PnlBadge({super.key, required this.pnlPercent});

  final double pnlPercent;

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor;
    final icon = pnlPercent >= 0
        ? Icons.arrow_drop_up_rounded
        : Icons.arrow_drop_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          Text(
            CurrencyFormatter.percent(pnlPercent),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Color get _badgeColor {
    if (pnlPercent > 0) return AppColors.profit;
    if (pnlPercent < 0) return AppColors.loss;
    return Colors.grey;
  }
}
