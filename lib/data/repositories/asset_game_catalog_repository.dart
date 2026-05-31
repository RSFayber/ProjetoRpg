import '../../domain/entities/background.dart';
import '../../domain/entities/character_class.dart';
import '../../domain/entities/game_catalog.dart';
import '../../domain/entities/race.dart';
import '../../domain/repositories/game_catalog_repository.dart';
import '../datasources/asset_json_datasource.dart';

class AssetGameCatalogRepository implements GameCatalogRepository {
  const AssetGameCatalogRepository(this._datasource);

  final AssetJsonDatasource _datasource;

  @override
  Future<GameCatalog> loadCatalog() async {
    final results = await Future.wait([
      _datasource.loadList('assets/data/races.json'),
      _datasource.loadList('assets/data/classes.json'),
      _datasource.loadList('assets/data/backgrounds.json'),
    ]);

    return GameCatalog(
      races: results[0].map(Race.fromJson).toList(),
      classes: results[1].map(CharacterClass.fromJson).toList(),
      backgrounds: results[2].map(Background.fromJson).toList(),
    );
  }
}
