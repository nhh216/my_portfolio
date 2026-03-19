import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/asset.dart';
import '../../data/repositories/asset_repository.dart';

/// Loads the asset list from [AssetRepository] on first read.
/// Exposes [AsyncValue<List<Asset>>] so screens handle loading/error/data.
class AssetNotifier extends AsyncNotifier<List<Asset>> {
  @override
  Future<List<Asset>> build() {
    return ref.read(assetRepositoryProvider).getAssets();
  }
}

final assetProvider =
    AsyncNotifierProvider<AssetNotifier, List<Asset>>(AssetNotifier.new);
