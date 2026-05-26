import '../entities/background.dart';
import '../entities/character.dart';
import '../entities/game_catalog.dart';

class ApplyBackgroundUseCase {
  const ApplyBackgroundUseCase(this.catalog);

  final GameCatalog catalog;

  Background call(Character character) {
    return catalog.backgroundById(character.backgroundId);
  }
}
