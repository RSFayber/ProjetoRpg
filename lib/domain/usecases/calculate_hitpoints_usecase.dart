import '../entities/character_class.dart';
import '../rules/hit_points_rule.dart';

class CalculateHitPointsUseCase {
  const CalculateHitPointsUseCase();

  int call(CharacterClass characterClass, int constitutionModifier) {
    return calculateInitialHitPoints(
      hitDice: characterClass.hitDice,
      constitutionModifier: constitutionModifier,
    );
  }
}
