import '../entities/character.dart';
import '../services/character_export_codec.dart';

class ExportCharacterFileUseCase {
  const ExportCharacterFileUseCase([CharacterExportCodec? codec])
      : _codec = codec ?? const CharacterExportCodec();

  final CharacterExportCodec _codec;

  List<int> call(Character character) => _codec.encodeBytes(character);

  String suggestedFileName(Character character) {
    final base = _sanitize(character.name.isEmpty ? 'ficha' : character.name);
    return '$base.rpgsheet';
  }

  String _sanitize(String value) {
    return value
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}
