/// Espacos de magia de nivel 1 (simplificado — nivel 1 do personagem).
int spellSlotsLevel1ForClass(String classId) {
  return switch (classId) {
    'wizard' || 'cleric' || 'bard' || 'druid' || 'sorcerer' || 'warlock' => 2,
    'paladin' || 'ranger' => 0,
    _ => 0,
  };
}
