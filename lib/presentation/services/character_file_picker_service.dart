import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../core/errors/app_exception.dart';

/// Leitura/gravacao de arquivos .rpgsheet via seletor do sistema.
class CharacterFilePickerService {
  const CharacterFilePickerService();

  static const _extension = 'rpgsheet';

  Future<Uint8List?> pickImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [_extension, 'json'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    if (file.bytes != null) {
      return file.bytes;
    }

    final path = file.path;
    if (path != null) {
      return await File(path).readAsBytes();
    }

    return null;
  }

  /// Grava bytes no disco e confirma que o arquivo existe.
  Future<String> saveExportFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    final pickedPath = await FilePicker.platform.saveFile(
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [_extension],
    );

    if (pickedPath == null) {
      throw const AppException('Exportacao cancelada.');
    }

    final targetPath = _ensureExtension(pickedPath);
    final file = File(targetPath);
    await file.writeAsBytes(bytes, flush: true);

    if (!await file.exists()) {
      throw AppException('Arquivo nao foi criado em $targetPath');
    }

    final size = await file.length();
    if (size == 0) {
      throw AppException('Arquivo exportado esta vazio.');
    }

    return targetPath;
  }

  String _ensureExtension(String path) {
    if (path.toLowerCase().endsWith('.$_extension')) {
      return path;
    }
    return '$path.$_extension';
  }
}
