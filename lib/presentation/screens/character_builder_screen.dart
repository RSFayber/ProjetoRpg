import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/sheet_theme.dart';
import '../providers/catalog_providers.dart';
import '../widgets/build/class_build_panel.dart';
import '../widgets/character_actions_bar.dart';
import '../widgets/sheet/official_character_sheet.dart';

class CharacterBuilderScreen extends ConsumerWidget {
  const CharacterBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(gameCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha de Personagem D&D 5e'),
        backgroundColor: SheetColors.headerFill,
        foregroundColor: SheetColors.ink,
      ),
      backgroundColor: SheetColors.parchment,
      body: catalog.when(
        data: (_) => const _CharacterBuilderContent(),
        error: (error, stackTrace) =>
            Center(child: Text('Erro ao carregar dados locais: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _CharacterBuilderContent extends StatelessWidget {
  const _CharacterBuilderContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CharacterActionsBar(),
          const SizedBox(height: 12),
          const ClassBuildPanel(),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: const OfficialCharacterSheet(),
          ),
        ],
      ),
    );
  }
}
