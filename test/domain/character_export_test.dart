import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_sheet_builder/core/errors/app_exception.dart';
import 'package:rpg_sheet_builder/domain/entities/attribute_set.dart';
import 'package:rpg_sheet_builder/domain/entities/character.dart';
import 'package:rpg_sheet_builder/domain/entities/character_export_document.dart';
import 'package:rpg_sheet_builder/domain/services/character_export_codec.dart';
import 'package:rpg_sheet_builder/domain/usecases/export_character_file_usecase.dart';
import 'package:rpg_sheet_builder/domain/usecases/import_character_file_usecase.dart';

void main() {
  const character = Character(
    id: 'char_old',
    name: 'Aragorn',
    raceId: 'human',
    classId: 'fighter',
    backgroundId: 'soldier',
    level: 3,
    attributes: AttributeSet.standard(),
  );

  test('codifica e decodifica ficha em roundtrip', () {
    const codec = CharacterExportCodec();
    final json = codec.encode(character);
    final decoded = codec.decode(json);

    expect(decoded.name, 'Aragorn');
    expect(decoded.raceId, 'human');
    expect(decoded.level, 3);
    expect(json, contains(CharacterExportDocument.formatId));
  });

  test('import remove id para nova gravacao local', () {
    final bytes = const ExportCharacterFileUseCase().call(character);
    final imported = const ImportCharacterFileUseCase().call(bytes);

    expect(imported.id, isNull);
    expect(imported.name, 'Aragorn');
  });

  test('rejeita arquivo com formato invalido', () {
    const codec = CharacterExportCodec();
    final bad = utf8.encode('{"format":"outro_app","version":1,"character":{}}');

    expect(
      () => codec.decodeBytes(bad),
      throwsA(isA<AppException>()),
    );
  });
}
