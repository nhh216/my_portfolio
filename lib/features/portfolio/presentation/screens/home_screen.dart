import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/providers/asset_provider.dart';
import '../../domain/providers/portfolio_provider.dart';
import '../widgets/asset_list_tile.dart';
import '../widgets/portfolio_summary_card.dart';

/// Main screen showing portfolio summary and scrollable asset list.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetProvider);
    final portfolioAsync = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Portfolio')),
      body: assetsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(assetProvider),
        ),
        data: (_) => portfolioAsync.when(
          loading: () => const LoadingIndicator(),
          error: (err, _) => ErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(assetProvider),
          ),
          data: (portfolio) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PortfolioSummaryCard(portfolio: portfolio),
              ),
              SliverList.builder(
                itemCount: portfolio.assets.length,
                itemBuilder: (context, index) {
                  final asset = portfolio.assets[index];
                  return AssetListTile(
                    asset: asset,
                    onTap: () => context.go('/asset/${asset.id}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
