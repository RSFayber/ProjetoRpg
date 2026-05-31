import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/attribute_keys.dart';
import '../../../core/theme/sheet_theme.dart';
import '../../../domain/entities/class_build_data.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/character_controller.dart';
import '../sheet/sheet_primitives.dart';
import 'class_abilities_dialog.dart';

/// Dicas de atributos, equipamento inicial selecionavel e link para habilidades.
class ClassBuildPanel extends ConsumerWidget {
  const ClassBuildPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(characterControllerProvider);
    final controller = ref.read(characterControllerProvider.notifier);
    final catalog = ref.watch(gameCatalogProvider);
    final buildCatalog = ref.watch(classBuildCatalogProvider);

    return catalog.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (game) {
        return buildCatalog.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Erro ao carregar dados de classe: $e'),
          data: (build) {
            final className = game.classById(character.classId).name;
            final background = game.backgroundById(character.backgroundId);
            final buildData = build.forClass(character.classId);
            if (buildData == null) {
              return const SizedBox.shrink();
            }

            return Card(
              color: SheetColors.paper,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Criacao: $className (nv ${character.level})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _AttributeTipsSection(tips: buildData.attributeTips),
                    const SizedBox(height: 12),
                    if (buildData.equipmentChoices.isNotEmpty) ...[
                      const SheetLabel('Equipamento de classe (PHB)'),
                      const SizedBox(height: 6),
                      ...buildData.equipmentChoices.map((group) {
                        final selected = character.sheet.equipmentChoiceSelections[group.id] ??
                            group.options.first.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('eq-${group.id}-$selected'),
                            initialValue: selected,
                            decoration: InputDecoration(
                              labelText: group.prompt,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              for (final opt in group.options)
                                DropdownMenuItem(
                                  value: opt.id,
                                  child: Text(opt.label, overflow: TextOverflow.ellipsis),
                                ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                controller.selectEquipmentChoice(group.id, v);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                    if (background.startingEquipment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const SheetLabel('Equipamento de antecedente (PHB)'),
                      const SizedBox(height: 4),
                      ...background.startingEquipment.map((item) {
                        final selected = character.sheet.selectedBackgroundItems;
                        final included = selected.isEmpty || selected.contains(item);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(item, style: const TextStyle(fontSize: 13)),
                          value: included,
                          onChanged: (v) {
                            if (v != null) {
                              controller.toggleBackgroundItem(item, v);
                            }
                          },
                        );
                      }),
                    ],
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => showClassAbilitiesDialog(
                        context,
                        className: className,
                        buildData: buildData,
                        level: character.level,
                      ),
                      icon: const Icon(Icons.menu_book),
                      label: Text(
                        'Habilidades e ataques (ate nv ${character.level})',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AttributeTipsSection extends StatelessWidget {
  const _AttributeTipsSection({required this.tips});

  final AttributeTips tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: SheetDecorations.panel(fill: SheetColors.headerFill),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetLabel('Dicas de atributos (PHB)'),
          const SizedBox(height: 4),
          Text(tips.summary, style: SheetDecorations.value(context)),
          if (tips.primary.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final key in tips.primary)
                  _AttrChip(label: attributeLabels[key] ?? key, primary: true),
                for (final key in tips.secondary)
                  _AttrChip(label: attributeLabels[key] ?? key, primary: false),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AttrChip extends StatelessWidget {
  const _AttrChip({required this.label, required this.primary});

  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: primary ? SheetColors.border : SheetColors.paper,
      labelStyle: TextStyle(
        color: primary ? SheetColors.paper : SheetColors.ink,
        fontWeight: FontWeight.bold,
      ),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
