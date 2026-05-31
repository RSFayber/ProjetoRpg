import 'package:flutter/material.dart';

import '../../../core/theme/sheet_theme.dart';
import '../../../domain/entities/class_build_data.dart';
import '../sheet/sheet_primitives.dart';

Future<void> showClassAbilitiesDialog(
  BuildContext context, {
  required String className,
  required ClassBuildData buildData,
  required int level,
}) {
  final entries = buildData.abilitiesUpToLevel(level);
  final features = entries.where((e) => !e.isAttack).toList();
  final attacks = entries.where((e) => e.isAttack).toList();

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: SheetColors.parchment,
      title: Text('Habilidades e ataques - $className (nv $level)'),
      content: SizedBox(
        width: 520,
        child: entries.isEmpty
            ? const Text('Nenhuma habilidade definida para este nivel.')
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (attacks.isNotEmpty) ...[
                      const SheetLabel('Ataques'),
                      const SizedBox(height: 6),
                      ...attacks.map((e) => _AbilityTile(entry: e)),
                      const SizedBox(height: 12),
                    ],
                    if (features.isNotEmpty) ...[
                      const SheetLabel('Habilidades de classe'),
                      const SizedBox(height: 6),
                      ...features.map((e) => _AbilityTile(entry: e)),
                    ],
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}

class _AbilityTile extends StatelessWidget {
  const _AbilityTile({required this.entry});

  final ClassAbilityEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: SheetDecorations.panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SheetColors.headerFill,
                  border: Border.all(color: SheetColors.border),
                ),
                child: Text(
                  'Nv ${entry.level}',
                  style: SheetDecorations.label(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.name,
                  style: SheetDecorations.value(context),
                ),
              ),
              if (entry.isAttack)
                Text(
                  'ATAQUE',
                  style: SheetDecorations.label(context),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(entry.description, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
