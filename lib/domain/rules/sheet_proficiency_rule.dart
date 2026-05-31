import '../entities/character_sheet_details.dart';

bool isSkillProficient({
  required String skillId,
  required List<String> autoProficiencies,
  required CharacterSheetDetails sheet,
}) {
  if (sheet.skillProficiencyOverrides.containsKey(skillId)) {
    return sheet.skillProficiencyOverrides[skillId]!;
  }
  return autoProficiencies.contains(skillId);
}

bool isSavingThrowProficient({
  required String abilityKey,
  required List<String> autoSavingThrows,
  required CharacterSheetDetails sheet,
}) {
  if (sheet.savingThrowOverrides.containsKey(abilityKey)) {
    return sheet.savingThrowOverrides[abilityKey]!;
  }
  return autoSavingThrows.contains(abilityKey);
}

int skillBonus({
  required String skillId,
  required String abilityKey,
  required Map<String, int> modifiers,
  required List<String> autoProficiencies,
  required CharacterSheetDetails sheet,
  required int proficiencyBonus,
}) {
  final mod = modifiers[abilityKey] ?? 0;
  final proficient = isSkillProficient(
    skillId: skillId,
    autoProficiencies: autoProficiencies,
    sheet: sheet,
  );
  return mod + (proficient ? proficiencyBonus : 0);
}

int passivePerception({
  required Map<String, int> modifiers,
  required List<String> autoProficiencies,
  required CharacterSheetDetails sheet,
  required int proficiencyBonus,
}) {
  final wis = modifiers['wisdom'] ?? 0;
  final proficient = isSkillProficient(
    skillId: 'perception',
    autoProficiencies: autoProficiencies,
    sheet: sheet,
  );
  return 10 + wis + (proficient ? proficiencyBonus : 0);
}

int savingThrowBonus({
  required String abilityKey,
  required Map<String, int> modifiers,
  required List<String> autoSavingThrows,
  required CharacterSheetDetails sheet,
  required int proficiencyBonus,
}) {
  final mod = modifiers[abilityKey] ?? 0;
  final proficient = isSavingThrowProficient(
    abilityKey: abilityKey,
    autoSavingThrows: autoSavingThrows,
    sheet: sheet,
  );
  return mod + (proficient ? proficiencyBonus : 0);
}

String defaultHitDiceLabel(int hitDice, int level) => '${level}d$hitDice';
