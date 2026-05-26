import '../entities/game_catalog.dart';

abstract class GameCatalogRepository {
  Future<GameCatalog> loadCatalog();
}
