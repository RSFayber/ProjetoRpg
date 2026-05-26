import '../entities/background.dart';
import '../entities/character_class.dart';

String buildStartingEquipmentText({
  required CharacterClass characterClass,
  required Background background,
}) {
  final lines = <String>[];

  if (characterClass.startingEquipment.isNotEmpty) {
    lines.add('Equipamento de classe (${characterClass.name}):');
    lines.addAll(characterClass.startingEquipment.map((e) => '• $e'));
  }

  if (background.startingEquipment.isNotEmpty) {
    if (lines.isNotEmpty) {
      lines.add('');
    }
    lines.add('Equipamento de antecedente (${background.name}):');
    lines.addAll(background.startingEquipment.map((e) => '• $e'));
  }

  return lines.join('\n');
}
