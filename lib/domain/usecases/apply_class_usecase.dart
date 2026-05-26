import '../entities/character.dart';
import '../entities/character_class.dart';
import '../entities/game_catalog.dart';

class ApplyClassUseCase {
  const ApplyClassUseCase(this.catalog);

  final GameCatalog catalog;

  CharacterClass call(Character character) {
    return catalog.classById(character.classId);
  }
}
