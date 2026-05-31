import '../entities/character.dart';
import '../services/character_export_codec.dart';

class ImportCharacterFileUseCase {
  const ImportCharacterFileUseCase([CharacterExportCodec? codec])
      : _codec = codec ?? const CharacterExportCodec();

  final CharacterExportCodec _codec;

  /// Remove o id local para gravar como nova ficha neste dispositivo.
  Character call(List<int> fileBytes) {
    final character = _codec.decodeBytes(fileBytes);
    return Character(
      name: character.name,
      raceId: character.raceId,
      classId: character.classId,
      backgroundId: character.backgroundId,
      level: character.level,
      attributes: character.attributes,
      sheet: character.sheet,
    );
  }
}
