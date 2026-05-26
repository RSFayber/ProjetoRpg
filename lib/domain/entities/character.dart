import 'attribute_set.dart';
import 'character_sheet_details.dart';

class Character {
  const Character({
    this.id,
    required this.name,
    required this.raceId,
    required this.classId,
    required this.backgroundId,
    required this.level,
    required this.attributes,
    this.sheet = const CharacterSheetDetails(),
  });

  const Character.initial()
    : id = null,
      name = '',
      raceId = 'human',
      classId = 'fighter',
      backgroundId = 'soldier',
      level = 1,
      attributes = const AttributeSet.standard(),
      sheet = const CharacterSheetDetails();

  final String? id;
  final String name;
  final String raceId;
  final String classId;
  final String backgroundId;
  final int level;
  final AttributeSet attributes;
  final CharacterSheetDetails sheet;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'raceId': raceId,
      'classId': classId,
      'backgroundId': backgroundId,
      'level': level,
      'attributes': attributes.toMap(),
      'sheet': sheet.toJson(),
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      raceId: json['raceId'] as String? ?? 'human',
      classId: json['classId'] as String? ?? 'fighter',
      backgroundId: json['backgroundId'] as String? ?? 'soldier',
      level: json['level'] as int? ?? 1,
      attributes: AttributeSet.fromJson(
        json['attributes'] as Map<String, dynamic>? ?? const {},
      ),
      sheet: CharacterSheetDetails.fromJson(
        json['sheet'] as Map<String, dynamic>?,
      ),
    );
  }

  Character copyWith({
    String? id,
    String? name,
    String? raceId,
    String? classId,
    String? backgroundId,
    int? level,
    AttributeSet? attributes,
    CharacterSheetDetails? sheet,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      raceId: raceId ?? this.raceId,
      classId: classId ?? this.classId,
      backgroundId: backgroundId ?? this.backgroundId,
      level: level ?? this.level,
      attributes: attributes ?? this.attributes,
      sheet: sheet ?? this.sheet,
    );
  }
}
