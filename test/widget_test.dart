import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_sheet_builder/main.dart';

void main() {
  testWidgets('exibe a ficha oficial do personagem', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: RpgSheetBuilderApp()));
    await tester.pumpAndSettle();

    expect(find.text('Ficha de Personagem D&D 5e'), findsOneWidget);
    expect(find.text('NOME DO PERSONAGEM'), findsOneWidget);
    expect(find.text('PERICIAS'), findsOneWidget);
    expect(find.text('DEFEITOS'), findsOneWidget);
    expect(find.text('FOR'), findsWidgets);
  });
}
