import 'character.dart';

/// Arquivo portavel de ficha para troca entre maquinas (.rpgsheet).
class CharacterExportDocument {
  const CharacterExportDocument({
    required this.version,
    required this.exportedAt,
    required this.character,
  });

  static const formatId = 'rpg_sheet_builder';
  static const currentVersion = 1;

  final int version;
  final DateTime exportedAt;
  final Character character;

  Map<String, dynamic> toJson() {
    return {
      'format': formatId,
      'version': version,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'character': character.toJson(),
    };
  }

  factory CharacterExportDocument.fromJson(Map<String, dynamic> json) {
    final format = json['format'] as String?;
    if (format != formatId) {
      throw FormatException('Formato de arquivo invalido: $format');
    }

    final version = json['version'] as int? ?? 0;
    if (version > currentVersion) {
      throw FormatException(
        'Versao do arquivo ($version) nao suportada. Atualize o aplicativo.',
      );
    }

    final exportedRaw = json['exportedAt'] as String?;
    final exportedAt = exportedRaw != null
        ? DateTime.tryParse(exportedRaw) ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();

    final characterJson = json['character'];
    if (characterJson is! Map<String, dynamic>) {
      throw const FormatException('Campo "character" ausente ou invalido.');
    }

    return CharacterExportDocument(
      version: version,
      exportedAt: exportedAt,
      character: Character.fromJson(characterJson),
    );
  }

  factory CharacterExportDocument.fromCharacter(Character character) {
    return CharacterExportDocument(
      version: currentVersion,
      exportedAt: DateTime.now().toUtc(),
      character: character,
    );
  }
}
