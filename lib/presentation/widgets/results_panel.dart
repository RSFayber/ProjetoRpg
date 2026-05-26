import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/attribute_keys.dart';
import '../providers/character_stats_provider.dart';

class ResultsPanel extends ConsumerWidget {
  const ResultsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(characterStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: stats.when(
          data: (value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resultados em tempo real',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(label: 'PV inicial', value: '${value.hitPoints}'),
                  _StatChip(
                    label: 'CA sem armadura',
                    value: '${value.armorClass}',
                  ),
                  _StatChip(
                    label: 'Testes de resistencia',
                    value: _formatList(value.savingThrows),
                  ),
                  _StatChip(
                    label: 'Idiomas',
                    value: _formatList(value.languages),
                  ),
                  if (value.spellSlotsLevel1 > 0)
                    _StatChip(
                      label: 'Slots magia nv.1',
                      value: '${value.spellSlotsLevel1}',
                    ),
                ],
              ),
              const Divider(height: 28),
              Text(
                'Modificadores',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in attributeKeys)
                    Chip(
                      label: Text(
                        '${attributeLabels[key]} ${_formatSigned(value.modifiers[key] ?? 0)}',
                      ),
                    ),
                ],
              ),
              const Divider(height: 28),
              Text(
                'Proficiencias',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(_formatList(value.proficiencies)),
            ],
          ),
          error: (error, stackTrace) => Text('Erro ao calcular ficha: $error'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }
}

String _formatList(List<String> values) {
  if (values.isEmpty) {
    return '-';
  }

  return values.map(_humanize).join(', ');
}

String _humanize(String value) {
  final translated = _displayNames[value];
  if (translated != null) {
    return translated;
  }

  return value
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String _formatSigned(int value) {
  return value >= 0 ? '+$value' : '$value';
}

const _displayNames = <String, String>{
  'strength': 'Forca',
  'dexterity': 'Destreza',
  'constitution': 'Constituicao',
  'intelligence': 'Inteligencia',
  'wisdom': 'Sabedoria',
  'charisma': 'Carisma',
  'perception': 'Percepcao',
  'battleaxe': 'Machado de batalha',
  'handaxe': 'Machadinha',
  'light_hammer': 'Martelo leve',
  'warhammer': 'Martelo de guerra',
  'all_armor': 'Todas as armaduras',
  'shields': 'Escudos',
  'simple_weapons': 'Armas simples',
  'martial_weapons': 'Armas marciais',
  'dagger': 'Adaga',
  'dart': 'Dardo',
  'sling': 'Funda',
  'quarterstaff': 'Bordao',
  'light_crossbow': 'Besta leve',
  'light_armor': 'Armadura leve',
  'medium_armor': 'Armadura media',
  'hand_crossbow': 'Besta de mao',
  'longsword': 'Espada longa',
  'rapier': 'Rapieira',
  'shortsword': 'Espada curta',
  'thieves_tools': 'Ferramentas de ladrao',
  'insight': 'Intuicao',
  'religion': 'Religiao',
  'athletics': 'Atletismo',
  'intimidation': 'Intimidacao',
  'deception': 'Enganacao',
  'stealth': 'Furtividade',
  'arcana': 'Arcanismo',
  'history': 'Historia',
};
