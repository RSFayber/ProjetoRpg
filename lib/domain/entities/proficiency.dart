class Proficiency {
  const Proficiency({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final String type;

  factory Proficiency.fromJson(Map<String, dynamic> json) {
    return Proficiency(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }
}
