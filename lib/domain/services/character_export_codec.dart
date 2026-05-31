import 'dart:convert';

import '../../core/errors/app_exception.dart';
import '../entities/character.dart';
import '../entities/character_export_document.dart';

/// Codifica e decodifica arquivos .rpgsheet (JSON UTF-8).
class CharacterExportCodec {
  const CharacterExportCodec();

  String encode(Character character) {
    final document = CharacterExportDocument.fromCharacter(character);
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(document.toJson());
  }

  Character decode(String content) {
    try {
      final json = jsonDecode(content);
      if (json is! Map<String, dynamic>) {
        throw const AppException('Arquivo JSON invalido.');
      }
      final document = CharacterExportDocument.fromJson(json);
      return document.character;
    } on AppException {
      rethrow;
    } on FormatException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException('Nao foi possivel ler a ficha: $e');
    }
  }

  List<int> encodeBytes(Character character) {
    return utf8.encode(encode(character));
  }

  Character decodeBytes(List<int> bytes) {
    return decode(utf8.decode(bytes));
  }
}
