import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_sheet_builder/domain/entities/background.dart';
import 'package:rpg_sheet_builder/domain/entities/character_class.dart';
import 'package:rpg_sheet_builder/domain/rules/starting_equipment_rule.dart';

void main() {
  test('monta texto de equipamento inicial de classe e antecedente', () {
    const fighter = CharacterClass(
      id: 'fighter',
      name: 'Guerreiro',
      hitDice: 10,
      savingThrows: ['strength', 'constitution'],
      proficiencies: [],
      startingEquipment: ['Cota de malha', 'Espada longa'],
    );
    const soldier = Background(
      id: 'soldier',
      name: 'Soldado',
      skillProficiencies: [],
      startingEquipment: ['Insignia de patente', '10 po'],
    );

    final text = buildStartingEquipmentText(
      characterClass: fighter,
      background: soldier,
    );

    expect(text, contains('Guerreiro'));
    expect(text, contains('Cota de malha'));
    expect(text, contains('Soldado'));
    expect(text, contains('10 po'));
  });
}
