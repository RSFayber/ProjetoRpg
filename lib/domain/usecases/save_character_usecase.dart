import '../entities/character.dart';
import '../repositories/character_repository.dart';

class SaveCharacterUseCase {
  const SaveCharacterUseCase(this.repository);

  final CharacterRepository repository;

  Future<Character> call(Character character) {
    return repository.save(character);
  }
}
