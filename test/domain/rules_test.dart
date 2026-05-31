import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_sheet_builder/domain/entities/background.dart';
import 'package:rpg_sheet_builder/domain/entities/character.dart';
import 'package:rpg_sheet_builder/domain/entities/character_class.dart';
import 'package:rpg_sheet_builder/domain/entities/game_catalog.dart';
import 'package:rpg_sheet_builder/domain/entities/race.dart';
import 'package:rpg_sheet_builder/domain/rules/attribute_modifier_rule.dart';
import 'package:rpg_sheet_builder/domain/usecases/calculate_character_stats_usecase.dart';

void main() {
  group('Modificadores de atributo', () {
    test('seguem a formula de D&D 5e', () {
      expect(calculateAttributeModifier(10), 0);
      expect(calculateAttributeModifier(8), -1);
      expect(calculateAttributeModifier(15), 2);
      expect(calculateAttributeModifier(20), 5);
    });
  });

  group('Estatisticas do personagem', () {
    test('Elfo aplica +2 Destreza e Guerreiro tem PV 10 + CON', () {
      final stats = const CalculateCharacterStatsUseCase(
        _catalog,
      ).call(const Character.initial().copyWith(raceId: 'elf'));

      expect(stats.finalAttributes.dexterity, 12);
      expect(stats.modifiers['dexterity'], 1);
      expect(stats.hitPoints, 10);
      expect(stats.proficiencies, contains('athletics'));
      expect(stats.proficiencies, contains('simple_weapons'));
    });

    test('Humano aplica +1 em todos os atributos', () {
      final stats = const CalculateCharacterStatsUseCase(
        _catalog,
      ).call(const Character.initial().copyWith(raceId: 'human'));

      expect(stats.finalAttributes.strength, 11);
      expect(stats.finalAttributes.dexterity, 11);
      expect(stats.finalAttributes.constitution, 11);
      expect(stats.finalAttributes.intelligence, 11);
      expect(stats.finalAttributes.wisdom, 11);
      expect(stats.finalAttributes.charisma, 11);
    });

    test('Mago tem PV 6 + CON e Sabio aplica Arcanismo + Historia', () {
      final stats = const CalculateCharacterStatsUseCase(_catalog).call(
        const Character.initial().copyWith(
          classId: 'wizard',
          backgroundId: 'sage',
        ),
      );

      expect(stats.hitPoints, 6);
      expect(stats.speedMeters, greaterThan(8));
      expect(stats.spellSlotsLevel1, 2);
      expect(stats.savingThrows, containsAll(['intelligence', 'wisdom']));
      expect(stats.proficiencies, contains('arcana'));
      expect(stats.proficiencies, contains('history'));
    });
  });
}

const _catalog = GameCatalog(
  races: [
    Race(
      id: 'elf',
      name: 'Elfo',
      bonuses: {'dexterity': 2},
      proficiencies: ['perception'],
      languages: ['Comum', 'Elfico'],
      speedFeet: 30,
    ),
    Race(
      id: 'human',
      name: 'Humano',
      bonuses: {
        'strength': 1,
        'dexterity': 1,
        'constitution': 1,
        'intelligence': 1,
        'wisdom': 1,
        'charisma': 1,
      },
      proficiencies: [],
      languages: ['Comum'],
    ),
  ],
  classes: [
    CharacterClass(
      id: 'fighter',
      name: 'Guerreiro',
      hitDice: 10,
      savingThrows: ['strength', 'constitution'],
      proficiencies: ['simple_weapons', 'martial_weapons'],
    ),
    CharacterClass(
      id: 'wizard',
      name: 'Mago',
      hitDice: 6,
      savingThrows: ['intelligence', 'wisdom'],
      proficiencies: ['dagger', 'quarterstaff'],
    ),
  ],
  backgrounds: [
    Background(
      id: 'soldier',
      name: 'Soldado',
      skillProficiencies: ['athletics', 'intimidation'],
    ),
    Background(
      id: 'sage',
      name: 'Sabio',
      skillProficiencies: ['arcana', 'history'],
    ),
  ],
);
