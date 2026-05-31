import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_sheet_builder/data/services/character_pdf_service.dart';
import 'package:rpg_sheet_builder/domain/entities/attribute_set.dart';
import 'package:rpg_sheet_builder/domain/entities/background.dart';
import 'package:rpg_sheet_builder/domain/entities/character.dart';
import 'package:rpg_sheet_builder/domain/entities/character_class.dart';
import 'package:rpg_sheet_builder/domain/entities/character_stats.dart';
import 'package:rpg_sheet_builder/domain/entities/game_catalog.dart';
import 'package:rpg_sheet_builder/domain/entities/race.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('gera PDF da ficha oficial com cabecalho PDF valido', () async {
    const character = Character(
      name: 'Aragorn',
      raceId: 'human',
      classId: 'fighter',
      backgroundId: 'soldier',
      level: 3,
      attributes: AttributeSet.standard(),
    );

    const stats = CharacterStats(
      finalAttributes: AttributeSet.standard(),
      modifiers: {
        'strength': 0,
        'dexterity': 0,
        'constitution': 0,
        'intelligence': 0,
        'wisdom': 0,
        'charisma': 0,
      },
      hitPoints: 24,
      armorClass: 10,
      proficiencies: ['athletics'],
      savingThrows: ['strength', 'constitution'],
      languages: ['Comum'],
      spellSlotsLevel1: 0,
      speedMeters: 9.144,
    );

    const catalog = GameCatalog(
      races: [
        Race(
          id: 'human',
          name: 'Humano',
          bonuses: {},
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
          proficiencies: [],
        ),
      ],
      backgrounds: [
        Background(
          id: 'soldier',
          name: 'Soldado (PHB)',
          skillProficiencies: [],
        ),
      ],
    );

    final bytes = await const CharacterPdfService().buildSheetPdf(
      character: character,
      stats: stats,
      catalog: catalog,
    );

    expect(bytes.length, greaterThan(500));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
