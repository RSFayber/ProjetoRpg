import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/asset_json_datasource.dart';
import '../../data/repositories/asset_game_catalog_repository.dart';
import '../../domain/entities/class_build_data.dart';
import '../../domain/entities/game_catalog.dart';

final gameCatalogProvider = FutureProvider<GameCatalog>((ref) {
  final datasource = AssetJsonDatasource();
  final repository = AssetGameCatalogRepository(datasource);
  return repository.loadCatalog();
});

final classBuildCatalogProvider = FutureProvider<ClassBuildCatalog>((ref) async {
  final datasource = AssetJsonDatasource();
  final raw = await datasource.loadMap('assets/data/class_build.json');
  return ClassBuildCatalog.fromJson(raw);
});
