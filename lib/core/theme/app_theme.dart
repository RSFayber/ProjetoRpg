import 'package:flutter/material.dart';

import 'sheet_theme.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4A3728),
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: SheetColors.parchment,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: SheetColors.headerFill,
      foregroundColor: SheetColors.ink,
    ),
  );
}
