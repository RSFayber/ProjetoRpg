import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Fontes TTF com suporte a acentuacao (PT) para exportacao PDF.
class PdfFontLoader {
  PdfFontLoader._();

  static pw.Font? regular;
  static pw.Font? bold;

  static Future<void> ensureLoaded() async {
    if (regular != null) {
      return;
    }
    final regularData = await rootBundle.load('assets/fonts/Arial.ttf');
    final boldData = await rootBundle.load('assets/fonts/Arial-Bold.ttf');
    regular = pw.Font.ttf(regularData);
    bold = pw.Font.ttf(boldData);
  }

  static pw.ThemeData theme() {
    final base = regular ?? pw.Font.helvetica();
    final boldFont = bold ?? pw.Font.helveticaBold();
    return pw.ThemeData.withFont(base: base, bold: boldFont);
  }
}
