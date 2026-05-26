import '../entities/attribute_set.dart';
import '../entities/race.dart';

AttributeSet applyRacialBonuses(AttributeSet attributes, Race race) {
  return attributes.addBonuses(race.bonuses);
}
