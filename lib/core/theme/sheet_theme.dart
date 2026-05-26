import 'package:flutter/material.dart';

/// Paleta inspirada na ficha oficial do Livro do Jogador (papel + marrom).
class SheetColors {
  static const parchment = Color(0xFFF3E8D2);
  static const paper = Color(0xFFFFFDF8);
  static const border = Color(0xFF4A3728);
  static const borderLight = Color(0xFF8B7355);
  static const ink = Color(0xFF2C1810);
  static const headerFill = Color(0xFFE8D4B8);
  static const modifierFill = Color(0xFFF8F4EC);
}

class SheetDecorations {
  static BoxDecoration panel({Color? fill}) => BoxDecoration(
    color: fill ?? SheetColors.paper,
    border: Border.all(color: SheetColors.border, width: 1.2),
  );

  static BoxDecoration headerBand() => BoxDecoration(
    color: SheetColors.headerFill,
    border: Border.all(color: SheetColors.border, width: 1.2),
  );

  static TextStyle label(BuildContext context) => TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: SheetColors.ink,
    letterSpacing: 0.3,
  );

  static TextStyle value(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: SheetColors.ink,
  );

  static TextStyle modifier() => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: SheetColors.ink,
    height: 1,
  );

  static TextStyle score() => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: SheetColors.ink,
  );
}
