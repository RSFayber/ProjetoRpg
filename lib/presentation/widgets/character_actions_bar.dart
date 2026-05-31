import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/errors/app_exception.dart';
import '../../data/services/character_pdf_service.dart';
import '../../domain/entities/character.dart';
import '../../domain/usecases/export_character_file_usecase.dart';
import '../../domain/usecases/import_character_file_usecase.dart';
import '../providers/catalog_providers.dart';
import '../providers/character_controller.dart';
import '../providers/character_stats_provider.dart';
import '../providers/persistence_providers.dart';
import '../services/character_file_picker_service.dart';

class CharacterActionsBar extends ConsumerWidget {
  const CharacterActionsBar({super.key});

  static const _filePicker = CharacterFilePickerService();
  static const _exportFile = ExportCharacterFileUseCase();
  static const _importFile = ImportCharacterFileUseCase();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(characterControllerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _save(context, ref, controller),
              icon: const Icon(Icons.save),
              label: const Text('Salvar ficha'),
            ),
            OutlinedButton.icon(
              onPressed: () => _exportFileAction(context, ref),
              icon: const Icon(Icons.upload_file),
              label: const Text('Exportar arquivo'),
            ),
            OutlinedButton.icon(
              onPressed: () => _importFileAction(context, ref, controller),
              icon: const Icon(Icons.download),
              label: const Text('Importar arquivo'),
            ),
            OutlinedButton.icon(
              onPressed: () => _exportPdf(context, ref),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar PDF'),
            ),
            OutlinedButton.icon(
              onPressed: () => _openLoadDialog(context, ref, controller),
              icon: const Icon(Icons.folder_open),
              label: const Text('Abrir ficha'),
            ),
            TextButton.icon(
              onPressed: controller.resetToNew,
              icon: const Icon(Icons.add),
              label: const Text('Nova ficha'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    CharacterController controller,
  ) async {
    try {
      final saved = await controller.saveCurrent();
      ref.invalidate(savedCharactersProvider);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ficha salva (${saved.id}).')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $error')),
      );
    }
  }

  Future<void> _exportFileAction(BuildContext context, WidgetRef ref) async {
    try {
      final character = ref.read(characterControllerProvider);
      final bytes = _exportFile.call(character);
      final fileName = _exportFile.suggestedFileName(character);

      final path = await _filePicker.saveExportFile(
        fileName: fileName,
        bytes: bytes,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arquivo exportado: $path')),
      );
    } on AppException catch (error) {
      if (!context.mounted || error.message == 'Exportacao cancelada.') {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar arquivo: ${error.message}')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar arquivo: $error')),
      );
    }
  }

  Future<void> _importFileAction(
    BuildContext context,
    WidgetRef ref,
    CharacterController controller,
  ) async {
    try {
      final bytes = await _filePicker.pickImportFile();
      if (bytes == null) {
        return;
      }

      final imported = _importFile.call(bytes);
      controller.loadCharacter(imported);
      final saved = await controller.saveCurrent();
      ref.invalidate(savedCharactersProvider);

      if (!context.mounted) {
        return;
      }

      final label = saved.name.isEmpty ? 'Sem nome' : saved.name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ficha "$label" importada e salva neste dispositivo.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao importar arquivo: $error')),
      );
    }
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final stats = ref.read(characterStatsProvider).value;
    if (stats == null) {
      return;
    }

    try {
      final character = ref.read(characterControllerProvider);
      final catalog = ref.read(gameCatalogProvider).requireValue;
      final bytes = await const CharacterPdfService().buildSheetPdf(
        character: character,
        stats: stats,
        catalog: catalog,
      );
      final name = character.name.isEmpty ? 'ficha' : character.name;
      await Printing.sharePdf(bytes: bytes, filename: '$name.pdf');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar PDF: $error')),
      );
    }
  }

  Future<void> _openLoadDialog(
    BuildContext context,
    WidgetRef ref,
    CharacterController controller,
  ) async {
    final characters = await ref
        .read(characterRepositoryProvider)
        .listCharacters();
    if (!context.mounted) {
      return;
    }

    if (characters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma ficha salva encontrada.')),
      );
      return;
    }

    final selected = await showDialog<Character>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir ficha salva'),
        content: SizedBox(
          width: 360,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final item = characters[index];
              return ListTile(
                title: Text(item.name.isEmpty ? 'Sem nome' : item.name),
                subtitle: Text('${item.raceId} / ${item.classId}'),
                onTap: () => Navigator.pop(context, item),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selected != null) {
      controller.loadCharacter(selected);
    }
  }
}
