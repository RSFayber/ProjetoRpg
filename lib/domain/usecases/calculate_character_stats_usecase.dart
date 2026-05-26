import '../../core/constants/attribute_keys.dart';
import '../entities/character.dart';
import '../entities/character_stats.dart';
import '../entities/game_catalog.dart';
import '../rules/armor_class_rule.dart';
import '../rules/attribute_modifier_rule.dart';
import '../rules/hit_points_rule.dart';
import '../rules/proficiency_rule.dart';
import '../rules/racial_bonus_rule.dart';
import '../rules/spell_slot_rule.dart';

class CalculateCharacterStatsUseCase {
  const CalculateCharacterStatsUseCase(this.catalog);

  final GameCatalog catalog;

  CharacterStats call(Character character) {
    final race = catalog.raceById(character.raceId);
    final characterClass = catalog.classById(character.classId);
    final background = catalog.backgroundById(character.backgroundId);
    final finalAttributes = applyRacialBonuses(character.attributes, race);
    final modifiers = {
      for (final key in attributeKeys)
        key: calculateAttributeModifier(finalAttributes.valueFor(key)),
    };
    final constitutionModifier = modifiers['constitution'] ?? 0;
    final dexterityModifier = modifiers['dexterity'] ?? 0;

    return CharacterStats(
      finalAttributes: finalAttributes,
      modifiers: modifiers,
      hitPoints: calculateInitialHitPoints(
        hitDice: characterClass.hitDice,
        constitutionModifier: constitutionModifier,
      ),
      armorClass: calculateUnarmoredArmorClass(dexterityModifier),
      proficiencies: mergeProficiencies([
        race.proficiencies,
        characterClass.proficiencies,
        background.skillProficiencies,
      ]),
      savingThrows: characterClass.savingThrows,
      languages: race.languages,
      spellSlotsLevel1: spellSlotsLevel1ForClass(character.classId),
      speedMeters: race.speedMeters,
      raceTraits: race.traits,
    );
  }
}
