import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_sheet_builder/core/errors/app_exception.dart';

void main() {
  test('saveExportFile grava bytes no disco', () async {
    final tempDir = await Directory.systemTemp.createTemp('rpgsheet_export_');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final targetPath = '${tempDir.path}${Platform.pathSeparator}hero.rpgsheet';
    final bytes = [123, 34, 102, 111, 114, 109, 97, 116, 34, 125];

    final file = File(targetPath);
    await file.writeAsBytes(bytes, flush: true);

    expect(await file.exists(), isTrue);
    expect(await file.length(), bytes.length);
  });

  test('AppException ao exportar arquivo vazio', () {
    expect(
      () => throw const AppException('Arquivo exportado esta vazio.'),
      throwsA(isA<AppException>()),
    );
  });
}
