import 'background.dart';
import 'character_class.dart';
import 'race.dart';

class GameCatalog {
  const GameCatalog({
    required this.races,
    required this.classes,
    required this.backgrounds,
  });

  final List<Race> races;
  final List<CharacterClass> classes;
  final List<Background> backgrounds;

  Race raceById(String id) {
    return races.firstWhere((race) => race.id == id);
  }

  CharacterClass classById(String id) {
    return classes.firstWhere((characterClass) => characterClass.id == id);
  }

  Background backgroundById(String id) {
    return backgrounds.firstWhere((background) => background.id == id);
  }
}
