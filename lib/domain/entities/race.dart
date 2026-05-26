class Race {
  const Race({
    required this.id,
    required this.name,
    required this.bonuses,
    required this.proficiencies,
    required this.languages,
    this.speedFeet = 30,
    this.traits = const [],
  });

  final String id;
  final String name;
  final Map<String, int> bonuses;
  final List<String> proficiencies;
  final List<String> languages;
  final int speedFeet;
  final List<String> traits;

  double get speedMeters => speedFeet * 0.3048;

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['id'] as String,
      name: json['name'] as String,
      bonuses: (json['bonuses'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
      proficiencies: List<String>.from(
        json['proficiencies'] as List? ?? const [],
      ),
      languages: List<String>.from(json['languages'] as List? ?? const []),
      speedFeet: json['speedFeet'] as int? ?? 30,
      traits: List<String>.from(json['traits'] as List? ?? const []),
    );
  }
}
