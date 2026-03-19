import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset.dart';
import 'mock_asset_repository.dart';

/// Contract for fetching asset data.
/// Swap [MockAssetRepository] for a real HTTP implementation without
/// changing any provider or screen code.
abstract class AssetRepository {
  Future<List<Asset>> getAssets();
}

/// Riverpod provider — resolves to [MockAssetRepository] in v1.
final assetRepositoryProvider = Provider<AssetRepository>(
  (ref) => MockAssetRepository(),
);
