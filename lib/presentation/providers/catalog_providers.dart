import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/asset_json_datasource.dart';
import '../../data/repositories/asset_game_catalog_repository.dart';
import '../../domain/entities/game_catalog.dart';

final gameCatalogProvider = FutureProvider<GameCatalog>((ref) {
  final datasource = AssetJsonDatasource();
  final repository = AssetGameCatalogRepository(datasource);
  return repository.loadCatalog();
});
