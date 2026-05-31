import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../platform/app_platform.dart';

bool _initialized = false;

Future<void> initializeDatabase() async {
  if (_initialized) {
    return;
  }

  // Android usa sqflite nativo; Windows usa FFI.
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else if (!Platform.isAndroid) {
    throw UnsupportedError(
      'Plataforma nao suportada. Use Windows ou Android.',
    );
  }

  _initialized = true;
}

String get databaseModeLabel =>
    isDesktopPlatform ? 'SQLite (FFI)' : 'SQLite (nativo)';
