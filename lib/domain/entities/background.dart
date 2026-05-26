class Background {
  const Background({
    required this.id,
    required this.name,
    required this.skillProficiencies,
    this.startingEquipment = const [],
  });

  final String id;
  final String name;
  final List<String> skillProficiencies;
  final List<String> startingEquipment;

  factory Background.fromJson(Map<String, dynamic> json) {
    return Background(
      id: json['id'] as String,
      name: json['name'] as String,
      skillProficiencies: List<String>.from(
        json['skillProficiencies'] as List? ?? const [],
      ),
      startingEquipment: List<String>.from(
        json['startingEquipment'] as List? ?? const [],
      ),
    );
  }
}
