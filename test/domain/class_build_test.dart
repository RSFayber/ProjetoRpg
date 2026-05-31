import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_sheet_builder/domain/entities/background.dart';
import 'package:rpg_sheet_builder/domain/entities/character_class.dart';
import 'package:rpg_sheet_builder/domain/entities/class_build_data.dart';
import 'package:rpg_sheet_builder/domain/rules/class_build_rule.dart';

void main() {
  test('resolve equipamento com escolhas de classe e antecedente', () {
    const fighter = CharacterClass(
      id: 'fighter',
      name: 'Guerreiro',
      hitDice: 10,
      savingThrows: [],
      proficiencies: [],
    );
    const soldier = Background(
      id: 'soldier',
      name: 'Soldado',
      skillProficiencies: [],
      startingEquipment: ['Insignia', '10 po'],
    );
    const build = ClassBuildData(
      attributeTips: AttributeTips(summary: '', primary: ['strength']),
      equipmentChoices: [
        EquipmentChoiceGroup(
          id: 'armor',
          prompt: 'Armadura',
          options: [
            EquipmentOption(
              id: 'chain',
              label: 'Cota de malha',
              items: ['Cota de malha'],
            ),
            EquipmentOption(
              id: 'leather',
              label: 'Couro',
              items: ['Armadura de couro'],
            ),
          ],
        ),
      ],
      fixedItems: ['Pacote'],
    );

    final text = resolveStartingEquipmentText(
      characterClass: fighter,
      background: soldier,
      buildData: build,
      choiceSelections: {'armor': 'chain'},
      selectedBackgroundItems: ['Insignia'],
    );

    expect(text, contains('Cota de malha'));
    expect(text, contains('Insignia'));
    expect(text, isNot(contains('10 po')));
  });

  test('filtra habilidades ate o nivel do personagem', () {
    const build = ClassBuildData(
      attributeTips: AttributeTips(summary: '', primary: []),
      abilities: [
        ClassAbilityEntry(level: 1, name: 'A', description: 'd'),
        ClassAbilityEntry(level: 3, name: 'B', description: 'd'),
        ClassAbilityEntry(level: 5, name: 'C', description: 'd'),
      ],
    );

    expect(build.abilitiesUpToLevel(2).map((e) => e.name), ['A']);
    expect(build.abilitiesUpToLevel(5).length, 3);
  });
}
