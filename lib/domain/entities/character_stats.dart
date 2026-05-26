import 'attribute_set.dart';

class CharacterStats {
  const CharacterStats({
    required this.finalAttributes,
    required this.modifiers,
    required this.hitPoints,
    required this.armorClass,
    required this.proficiencies,
    required this.savingThrows,
    required this.languages,
    required this.spellSlotsLevel1,
    required this.speedMeters,
    this.raceTraits = const [],
  });

  final AttributeSet finalAttributes;
  final Map<String, int> modifiers;
  final int hitPoints;
  final int armorClass;
  final List<String> proficiencies;
  final List<String> savingThrows;
  final List<String> languages;
  final int spellSlotsLevel1;
  final double speedMeters;
  final List<String> raceTraits;
}
