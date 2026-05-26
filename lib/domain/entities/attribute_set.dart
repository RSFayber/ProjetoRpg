import '../../core/constants/attribute_keys.dart';

class AttributeSet {
  const AttributeSet({
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  });

  const AttributeSet.standard()
    : strength = 10,
      dexterity = 10,
      constitution = 10,
      intelligence = 10,
      wisdom = 10,
      charisma = 10;

  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  int valueFor(String key) {
    return switch (key) {
      'strength' => strength,
      'dexterity' => dexterity,
      'constitution' => constitution,
      'intelligence' => intelligence,
      'wisdom' => wisdom,
      'charisma' => charisma,
      _ => throw ArgumentError.value(key, 'key', 'Unknown attribute key'),
    };
  }

  AttributeSet setValue(String key, int value) {
    return copyWith(
      strength: key == 'strength' ? value : null,
      dexterity: key == 'dexterity' ? value : null,
      constitution: key == 'constitution' ? value : null,
      intelligence: key == 'intelligence' ? value : null,
      wisdom: key == 'wisdom' ? value : null,
      charisma: key == 'charisma' ? value : null,
    );
  }

  AttributeSet addBonuses(Map<String, int> bonuses) {
    var result = this;
    for (final entry in bonuses.entries) {
      result = result.setValue(
        entry.key,
        result.valueFor(entry.key) + entry.value,
      );
    }
    return result;
  }

  Map<String, int> toMap() {
    return {for (final key in attributeKeys) key: valueFor(key)};
  }

  factory AttributeSet.fromJson(Map<String, dynamic> json) {
    return AttributeSet(
      strength: json['strength'] as int? ?? 10,
      dexterity: json['dexterity'] as int? ?? 10,
      constitution: json['constitution'] as int? ?? 10,
      intelligence: json['intelligence'] as int? ?? 10,
      wisdom: json['wisdom'] as int? ?? 10,
      charisma: json['charisma'] as int? ?? 10,
    );
  }

  AttributeSet copyWith({
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
  }) {
    return AttributeSet(
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
    );
  }
}
