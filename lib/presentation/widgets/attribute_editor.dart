import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/attribute_keys.dart';
import '../providers/character_controller.dart';
import '../providers/character_stats_provider.dart';

class AttributeEditor extends ConsumerWidget {
  const AttributeEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(characterControllerProvider);
    final stats = ref.watch(characterStatsProvider);
    final currentStats = switch (stats) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final controller = ref.read(characterControllerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Atributos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: controller.resetAttributes,
                  child: const Text('Resetar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final key in attributeKeys)
              _AttributeRow(
                label: attributeLabels[key] ?? key,
                baseValue: character.attributes.valueFor(key),
                finalValue: currentStats?.finalAttributes.valueFor(key),
                modifier: currentStats?.modifiers[key],
                onDecrease: () => controller.decrementAttribute(key),
                onIncrease: () => controller.incrementAttribute(key),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({
    required this.label,
    required this.baseValue,
    required this.finalValue,
    required this.modifier,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final int baseValue;
  final int? finalValue;
  final int? modifier;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
          IconButton.filledTonal(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 42,
            child: Text(
              '$baseValue',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton.filledTonal(
            onPressed: onIncrease,
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 94,
            child: Text(
              'Final: ${finalValue ?? '-'}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              'Mod: ${modifier == null ? '-' : _formatSigned(modifier!)}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatSigned(int value) {
  return value >= 0 ? '+$value' : '$value';
}
