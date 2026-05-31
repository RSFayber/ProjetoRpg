import '../entities/background.dart';
import '../entities/class_build_data.dart';
import '../entities/character_class.dart';

/// Monta texto de equipamento a partir das escolhas PHB + itens fixos.
String resolveStartingEquipmentText({
  required CharacterClass characterClass,
  required Background background,
  ClassBuildData? buildData,
  Map<String, String> choiceSelections = const {},
  List<String> selectedBackgroundItems = const [],
}) {
  final lines = <String>[];

  if (buildData != null) {
    if (buildData.equipmentChoices.isNotEmpty) {
      lines.add('Equipamento de classe (${characterClass.name}):');
      for (final group in buildData.equipmentChoices) {
        final selectedId = choiceSelections[group.id] ?? group.options.first.id;
        final option = group.options.firstWhere(
          (o) => o.id == selectedId,
          orElse: () => group.options.first,
        );
        lines.add('• ${group.prompt}: ${option.label}');
        for (final item in option.items) {
          lines.add('  - $item');
        }
      }
    }
    if (buildData.fixedItems.isNotEmpty) {
      for (final item in buildData.fixedItems) {
        lines.add('• $item');
      }
    }
  } else if (characterClass.startingEquipment.isNotEmpty) {
    lines.add('Equipamento de classe (${characterClass.name}):');
    lines.addAll(characterClass.startingEquipment.map((e) => '• $e'));
  }

  if (background.startingEquipment.isNotEmpty) {
    if (lines.isNotEmpty) {
      lines.add('');
    }
    lines.add('Equipamento de antecedente (${background.name}):');
    final bgItems = selectedBackgroundItems.isEmpty
        ? background.startingEquipment
        : selectedBackgroundItems;
    lines.addAll(bgItems.map((e) => '• $e'));
  }

  return lines.join('\n');
}

/// Selecoes padrao (primeira opcao de cada grupo).
Map<String, String> defaultEquipmentChoices(ClassBuildData? buildData) {
  if (buildData == null) {
    return const {};
  }
  return {
    for (final group in buildData.equipmentChoices)
      group.id: group.options.first.id,
  };
}
