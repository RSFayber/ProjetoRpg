import '../entities/character.dart';
import '../repositories/character_repository.dart';

class LoadCharactersUseCase {
  const LoadCharactersUseCase(this.repository);

  final CharacterRepository repository;

  Future<List<Character>> call() {
    return repository.listCharacters();
  }
}
