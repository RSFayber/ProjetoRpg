class CharacterClass {
  const CharacterClass({
    required this.id,
    required this.name,
    required this.hitDice,
    required this.savingThrows,
    required this.proficiencies,
    this.startingEquipment = const [],
  });

  final String id;
  final String name;
  final int hitDice;
  final List<String> savingThrows;
  final List<String> proficiencies;
  final List<String> startingEquipment;

  factory CharacterClass.fromJson(Map<String, dynamic> json) {
    return CharacterClass(
      id: json['id'] as String,
      name: json['name'] as String,
      hitDice: json['hitDice'] as int,
      savingThrows: List<String>.from(
        json['savingThrows'] as List? ?? const [],
      ),
      proficiencies: List<String>.from(
        json['proficiencies'] as List? ?? const [],
      ),
      startingEquipment: List<String>.from(
        json['startingEquipment'] as List? ?? const [],
      ),
    );
  }
}
