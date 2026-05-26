import '../entities/attribute_set.dart';
import '../entities/race.dart';
import '../rules/racial_bonus_rule.dart';

class ApplyRaceUseCase {
  const ApplyRaceUseCase();

  AttributeSet call(AttributeSet attributes, Race race) {
    return applyRacialBonuses(attributes, race);
  }
}
