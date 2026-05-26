/// Pericias na ordem da ficha oficial D&D 5e (PT).
class DndSkill {
  const DndSkill({
    required this.id,
    required this.label,
    required this.abilityKey,
  });

  final String id;
  final String label;
  final String abilityKey;
}

const dndSkills = <DndSkill>[
  DndSkill(id: 'acrobatics', label: 'Acrobacia', abilityKey: 'dexterity'),
  DndSkill(id: 'arcana', label: 'Arcanismo', abilityKey: 'intelligence'),
  DndSkill(id: 'athletics', label: 'Atletismo', abilityKey: 'strength'),
  DndSkill(id: 'performance', label: 'Atuacao', abilityKey: 'charisma'),
  DndSkill(id: 'deception', label: 'Blefar', abilityKey: 'charisma'),
  DndSkill(id: 'stealth', label: 'Furtividade', abilityKey: 'dexterity'),
  DndSkill(id: 'history', label: 'Historia', abilityKey: 'intelligence'),
  DndSkill(id: 'intimidation', label: 'Intimidacao', abilityKey: 'charisma'),
  DndSkill(id: 'insight', label: 'Intuicao', abilityKey: 'wisdom'),
  DndSkill(id: 'investigation', label: 'Investigacao', abilityKey: 'intelligence'),
  DndSkill(
    id: 'animal_handling',
    label: 'Lidar com Animais',
    abilityKey: 'wisdom',
  ),
  DndSkill(id: 'medicine', label: 'Medicina', abilityKey: 'wisdom'),
  DndSkill(id: 'nature', label: 'Natureza', abilityKey: 'intelligence'),
  DndSkill(id: 'perception', label: 'Percepcao', abilityKey: 'wisdom'),
  DndSkill(id: 'persuasion', label: 'Persuasao', abilityKey: 'charisma'),
  DndSkill(
    id: 'sleight_of_hand',
    label: 'Prestidigitacao',
    abilityKey: 'dexterity',
  ),
  DndSkill(id: 'religion', label: 'Religiao', abilityKey: 'intelligence'),
  DndSkill(id: 'survival', label: 'Sobrevivencia', abilityKey: 'wisdom'),
];

const attributeAbbreviations = <String, String>{
  'strength': 'FOR',
  'dexterity': 'DES',
  'constitution': 'CON',
  'intelligence': 'INT',
  'wisdom': 'SAB',
  'charisma': 'CAR',
};

const savingThrowLabels = <String, String>{
  'strength': 'Forca',
  'dexterity': 'Destreza',
  'constitution': 'Constituicao',
  'intelligence': 'Inteligencia',
  'wisdom': 'Sabedoria',
  'charisma': 'Carisma',
};

int proficiencyBonusForLevel(int level) {
  return 2 + ((level - 1) ~/ 4);
}
