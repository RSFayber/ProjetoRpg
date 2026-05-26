import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/character.dart';
import '../../domain/entities/character_stats.dart';
import '../../domain/entities/game_catalog.dart';
import 'official_character_sheet_pdf_builder.dart';
import 'pdf_font_loader.dart';

class CharacterPdfService {
  const CharacterPdfService();

  Future<Uint8List> buildSheetPdf({
    required Character character,
    required CharacterStats stats,
    required GameCatalog catalog,
  }) async {
    await PdfFontLoader.ensureLoaded();

    final builder = OfficialCharacterSheetPdfBuilder(
      character: character,
      stats: stats,
      catalog: catalog,
    );

    final doc = pw.Document(
      title: character.name.isEmpty ? 'Ficha D&D 5e' : character.name,
      author: 'RPG Sheet Builder',
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(10),
        theme: PdfFontLoader.theme(),
        build: (context) => builder.build(),
      ),
    );

    return doc.save();
  }
}
