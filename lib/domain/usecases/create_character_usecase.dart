import '../entities/character.dart';

class CreateCharacterUseCase {
  const CreateCharacterUseCase();

  Character call() {
    return const Character.initial();
  }
}
