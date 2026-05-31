/// Dica de atributos recomendados (PHB).
class AttributeTips {
  const AttributeTips({
    required this.summary,
    required this.primary,
    this.secondary = const [],
  });

  final String summary;
  final List<String> primary;
  final List<String> secondary;

  factory AttributeTips.fromJson(Map<String, dynamic> json) {
    return AttributeTips(
      summary: json['summary'] as String? ?? '',
      primary: List<String>.from(json['primary'] as List? ?? const []),
      secondary: List<String>.from(json['secondary'] as List? ?? const []),
    );
  }
}

class EquipmentOption {
  const EquipmentOption({
    required this.id,
    required this.label,
    required this.items,
  });

  final String id;
  final String label;
  final List<String> items;

  factory EquipmentOption.fromJson(Map<String, dynamic> json) {
    return EquipmentOption(
      id: json['id'] as String,
      label: json['label'] as String,
      items: List<String>.from(json['items'] as List? ?? const []),
    );
  }
}

class EquipmentChoiceGroup {
  const EquipmentChoiceGroup({
    required this.id,
    required this.prompt,
    required this.options,
  });

  final String id;
  final String prompt;
  final List<EquipmentOption> options;

  factory EquipmentChoiceGroup.fromJson(Map<String, dynamic> json) {
    return EquipmentChoiceGroup(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      options: (json['options'] as List)
          .map((e) => EquipmentOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Habilidade ou ataque de classe por nivel (PHB).
class ClassAbilityEntry {
  const ClassAbilityEntry({
    required this.level,
    required this.name,
    required this.description,
    this.type = 'feature',
  });

  final int level;
  final String name;
  final String description;
  final String type;

  bool get isAttack => type == 'attack';

  factory ClassAbilityEntry.fromJson(Map<String, dynamic> json) {
    return ClassAbilityEntry(
      level: json['level'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String? ?? 'feature',
    );
  }
}

class ClassBuildData {
  const ClassBuildData({
    required this.attributeTips,
    this.equipmentChoices = const [],
    this.fixedItems = const [],
    this.abilities = const [],
  });

  final AttributeTips attributeTips;
  final List<EquipmentChoiceGroup> equipmentChoices;
  final List<String> fixedItems;
  final List<ClassAbilityEntry> abilities;

  List<ClassAbilityEntry> abilitiesUpToLevel(int level) {
    return abilities.where((a) => a.level <= level).toList()
      ..sort((a, b) => a.level.compareTo(b.level));
  }

  factory ClassBuildData.fromJson(Map<String, dynamic> json) {
    return ClassBuildData(
      attributeTips: AttributeTips.fromJson(
        json['attributeTips'] as Map<String, dynamic>? ?? const {},
      ),
      equipmentChoices: (json['equipmentChoices'] as List? ?? const [])
          .map((e) => EquipmentChoiceGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      fixedItems: List<String>.from(json['fixedItems'] as List? ?? const []),
      abilities: (json['abilities'] as List? ?? const [])
          .map((e) => ClassAbilityEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ClassBuildCatalog {
  const ClassBuildCatalog(this.byClassId);

  final Map<String, ClassBuildData> byClassId;

  ClassBuildData? forClass(String classId) => byClassId[classId];

  factory ClassBuildCatalog.fromJson(Map<String, dynamic> json) {
    return ClassBuildCatalog(
      json.map(
        (key, value) => MapEntry(
          key,
          ClassBuildData.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }
}
