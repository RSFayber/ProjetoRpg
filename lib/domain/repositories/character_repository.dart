import '../entities/character.dart';

abstract class CharacterRepository {
  Future<List<Character>> listCharacters();

  Future<Character?> getById(String id);

  Future<Character> save(Character character);

  Future<void> delete(String id);
}
