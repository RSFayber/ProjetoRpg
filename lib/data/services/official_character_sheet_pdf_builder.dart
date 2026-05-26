import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/attribute_keys.dart';
import '../../core/constants/dnd_skills.dart';
import '../../domain/entities/background.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_class.dart';
import '../../domain/entities/character_stats.dart';
import '../../domain/entities/game_catalog.dart';
import '../../domain/entities/race.dart';
import '../../domain/rules/sheet_proficiency_rule.dart';

/// Layout PDF alinhado a ficha oficial D&D 5e (mesma estrutura da UI).
class OfficialCharacterSheetPdfBuilder {
  OfficialCharacterSheetPdfBuilder({
    required this.character,
    required this.stats,
    required this.catalog,
  });

  final Character character;
  final CharacterStats stats;
  final GameCatalog catalog;

  static final _parchment = PdfColor.fromInt(0xFFF3E8D2);
  static final _paper = PdfColor.fromInt(0xFFFFFDF8);
  static final _border = PdfColor.fromInt(0xFF4A3728);
  static final _ink = PdfColor.fromInt(0xFF2C1810);
  Race get _race => catalog.raceById(character.raceId);
  CharacterClass get _class => catalog.classById(character.classId);
  Background get _background => catalog.backgroundById(character.backgroundId);

  int get _profBonus => proficiencyBonusForLevel(character.level);

  pw.Widget build() {
    final sheet = character.sheet;
    final ac = sheet.armorClassOverride ?? stats.armorClass;
    final speed = sheet.speedOverrideMeters ?? stats.speedMeters;
    final maxHp = stats.hitPoints;
    final currentHp = sheet.currentHitPoints ?? maxHp;
    final featuresText = sheet.features.isNotEmpty
        ? sheet.features
        : stats.raceTraits.join('\n');

    return pw.Container(
      color: _parchment,
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          pw.SizedBox(height: 6),
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(width: 155, child: _buildLeftColumn()),
                pw.SizedBox(width: 6),
                pw.Expanded(child: _buildCenterColumn(ac, speed, maxHp, currentHp)),
                pw.SizedBox(width: 6),
                pw.SizedBox(
                  width: 175,
                  child: _buildRightColumn(featuresText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildHeader() {
    final sheet = character.sheet;
    return pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: _fieldBox('Nome do personagem', character.name),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(
              flex: 2,
              child: _fieldBox(
                'Classe e nivel',
                '${_class.name} ${character.level}',
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(
              flex: 2,
              child: _fieldBox('Antecedente', _background.name),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: _fieldBox('Nome do jogador', sheet.playerName),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(flex: 2, child: _fieldBox('Raca', _race.name)),
            pw.SizedBox(width: 4),
            pw.Expanded(
              flex: 2,
              child: _fieldBox(
                'Tendencia',
                sheet.alignment.isEmpty ? '-' : sheet.alignment,
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(
              flex: 1,
              child: _fieldBox('Pontos de experiencia', '${sheet.experiencePoints}'),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildLeftColumn() {
    final sheet = character.sheet;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        ...attributeKeys.map(_buildAbilityBlock),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
              child: _miniBox(
                'Inspiracao',
                sheet.hasInspiration ? 'Sim' : '',
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(
              child: _miniBox('Bonus prof.', _signed(_profBonus)),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        _panel(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('Testes de resistencia'),
              ...attributeKeys.map((key) {
                final bonus = savingThrowBonus(
                  abilityKey: key,
                  modifiers: stats.modifiers,
                  autoSavingThrows: stats.savingThrows,
                  sheet: sheet,
                  proficiencyBonus: _profBonus,
                );
                final proficient = isSavingThrowProficient(
                  abilityKey: key,
                  autoSavingThrows: stats.savingThrows,
                  sheet: sheet,
                );
                return _skillLine(
                  savingThrowLabels[key] ?? key,
                  _signed(bonus),
                  proficient,
                );
              }),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        _panel(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('Pericias'),
              ...dndSkills.map((skill) {
                final total = skillBonus(
                  skillId: skill.id,
                  abilityKey: skill.abilityKey,
                  modifiers: stats.modifiers,
                  autoProficiencies: stats.proficiencies,
                  sheet: sheet,
                  proficiencyBonus: _profBonus,
                );
                final proficient = isSkillProficient(
                  skillId: skill.id,
                  autoProficiencies: stats.proficiencies,
                  sheet: sheet,
                );
                return _skillLine(
                  '${skill.label} (${attributeAbbreviations[skill.abilityKey]})',
                  _signed(total),
                  proficient,
                );
              }),
              pw.SizedBox(height: 2),
              pw.Text(
                'Sabedoria passiva (Percepcao): ${passivePerception(modifiers: stats.modifiers, autoProficiencies: stats.proficiencies, sheet: sheet, proficiencyBonus: _profBonus)}',
                style: _labelStyle(),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        _panel(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('Idiomas e outras proficiencias'),
              if (stats.proficiencies.isNotEmpty)
                pw.Text(
                  'Auto: ${stats.proficiencies.map(_humanize).join(", ")}',
                  style: _labelStyle(),
                ),
              if (stats.languages.isNotEmpty)
                pw.Text(
                  'Idiomas: ${stats.languages.join(", ")}',
                  style: _labelStyle(),
                ),
              if (sheet.extraProficiencies.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(sheet.extraProficiencies, style: _valueStyle()),
              ],
              if (sheet.extraLanguages.isNotEmpty)
                pw.Text(
                  'Extra: ${sheet.extraLanguages}',
                  style: _valueStyle(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildAbilityBlock(String key) {
    final base = character.attributes.valueFor(key);
    final mod = stats.modifiers[key] ?? 0;
    final abbr = attributeAbbreviations[key] ?? key;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: _panel(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 3),
        child: pw.Column(
          children: [
            pw.Text(abbr, style: _sectionTitleStyle(), textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 2),
            pw.Text('$base', style: _valueStyle(), textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 2),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF8F4EC),
                border: pw.Border.all(color: _border, width: 0.8),
              ),
              child: pw.Text(
                _signed(mod),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildCenterColumn(
    int ac,
    double speed,
    int maxHp,
    int currentHp,
  ) {
    final sheet = character.sheet;
    final hdTotal = sheet.hitDiceTotal.isEmpty
        ? defaultHitDiceLabel(_class.hitDice, character.level)
        : sheet.hitDiceTotal;
    final hdRemaining = sheet.hitDiceRemaining.isEmpty ? hdTotal : sheet.hitDiceRemaining;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          children: [
            pw.Expanded(child: _miniBox('Classe de armadura', '$ac')),
            pw.SizedBox(width: 4),
            pw.Expanded(
              child: _miniBox(
                'Iniciativa',
                _signed(stats.modifiers['dexterity'] ?? 0),
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(child: _miniBox('Deslocamento', _formatSpeed(speed))),
          ],
        ),
        pw.SizedBox(height: 4),
        _panel(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('Pontos de vida'),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Expanded(child: _hpBox('Maximo', '$maxHp')),
                  pw.SizedBox(width: 4),
                  pw.Expanded(child: _hpBox('Atual', '$currentHp')),
                  pw.SizedBox(width: 4),
                  pw.Expanded(
                    child: _hpBox(
                      'Temp.',
                      sheet.temporaryHitPoints == 0
                          ? ''
                          : '${sheet.temporaryHitPoints}',
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Expanded(child: _miniBox('Dados de vida (total)', hdTotal)),
                  pw.SizedBox(width: 4),
                  pw.Expanded(child: _miniBox('Dados restantes', hdRemaining)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('Testes contra a morte', style: _sectionTitleStyle()),
              _deathSaveLine('Sucessos', sheet.deathSaveSuccesses),
              _deathSaveLine('Falhas', sheet.deathSaveFailures),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        _panel(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('Ataques e magias'),
              pw.SizedBox(height: 2),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('Nome', style: _labelStyle()),
                  ),
                  pw.Expanded(child: pw.Text('Bonus', style: _labelStyle())),
                  pw.Expanded(child: pw.Text('Dano/Tipo', style: _labelStyle())),
                ],
              ),
              ...sheet.attacks.map(
                (a) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text(a.name, style: _valueStyle())),
                      pw.Expanded(
                        child: pw.Text(a.attackBonus, style: _valueStyle()),
                      ),
                      pw.Expanded(child: pw.Text(a.damage, style: _valueStyle())),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (stats.spellSlotsLevel1 > 0) ...[
          pw.SizedBox(height: 4),
          _panel(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _miniBox('Espacos nv.1', '${stats.spellSlotsLevel1}', width: 52),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  child: pw.Text(
                    sheet.spellNotes.isEmpty ? '-' : sheet.spellNotes,
                    style: _valueStyle(),
                  ),
                ),
              ],
            ),
          ),
        ],
        pw.SizedBox(height: 4),
        _panel(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                children: [
                  _coinLine('PC', sheet.copper),
                  _coinLine('PP', sheet.silver),
                  _coinLine('PE', sheet.electrum),
                  _coinLine('PO', sheet.gold),
                  _coinLine('PL', sheet.platinum),
                ],
              ),
              pw.SizedBox(width: 6),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Equipamento'),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      sheet.equipment.isEmpty ? '-' : sheet.equipment,
                      style: _valueStyle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildRightColumn(String featuresText) {
    final sheet = character.sheet;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _textBlock('Tracos de personalidade', sheet.personalityTraits),
        pw.SizedBox(height: 4),
        _textBlock('Ideais', sheet.ideals),
        pw.SizedBox(height: 4),
        _textBlock('Vinculos', sheet.bonds),
        pw.SizedBox(height: 4),
        _textBlock('Defeitos', sheet.flaws),
        pw.SizedBox(height: 4),
        _textBlock('Caracteristicas e habilidades', featuresText),
      ],
    );
  }

  pw.Widget _textBlock(String label, String value) {
    return _panel(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle(label),
          pw.SizedBox(height: 2),
          pw.Text(value.isEmpty ? '-' : value, style: _valueStyle()),
        ],
      ),
    );
  }

  pw.Widget _fieldBox(String label, String value) {
    return _panel(
      padding: const pw.EdgeInsets.fromLTRB(5, 3, 5, 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label.toUpperCase(), style: _labelStyle()),
          pw.SizedBox(height: 2),
          pw.Text(
            value.isEmpty ? '-' : value,
            style: _valueStyle(),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  pw.Widget _miniBox(String label, String value, {double? width}) {
    final box = _panel(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(label.toUpperCase(), style: _labelStyle(), textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 2),
          pw.Text(value, style: _valueStyle(), textAlign: pw.TextAlign.center),
        ],
      ),
    );
    if (width != null) {
      return pw.SizedBox(width: width, height: 40, child: box);
    }
    return pw.SizedBox(height: 40, child: box);
  }

  pw.Widget _hpBox(String label, String value) {
    return pw.Container(
      height: 36,
      decoration: pw.BoxDecoration(
        color: _paper,
        border: pw.Border.all(color: _border, width: 0.8),
      ),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        children: [
          pw.Text(label.toUpperCase(), style: _labelStyle()),
          pw.Spacer(),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _skillLine(String name, String bonus, bool proficient) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          _proficiencyDot(proficient),
          pw.Expanded(child: pw.Text(name, style: _valueStyle(fontSize: 7))),
          pw.Text(bonus, style: _valueStyle(fontSize: 7)),
        ],
      ),
    );
  }

  pw.Widget _proficiencyDot(bool filled) {
    return pw.Container(
      width: 7,
      height: 7,
      margin: const pw.EdgeInsets.only(right: 4),
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: _border, width: 0.6),
        color: filled ? _border : _paper,
      ),
    );
  }

  pw.Widget _deathSaveLine(String label, int count) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Row(
        children: [
          pw.Text('$label ', style: _labelStyle()),
          for (var i = 0; i < 3; i++) _proficiencyDot(i < count),
        ],
      ),
    );
  }

  pw.Widget _coinLine(String label, int value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 16,
            child: pw.Text(label, style: _labelStyle()),
          ),
          pw.Text(value == 0 ? '-' : '$value', style: _valueStyle(fontSize: 7)),
        ],
      ),
    );
  }

  pw.Widget _panel({
    required pw.Widget child,
    pw.EdgeInsets padding = const pw.EdgeInsets.all(5),
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _paper,
        border: pw.Border.all(color: _border, width: 0.8),
      ),
      padding: padding,
      child: child,
    );
  }

  pw.Widget _sectionTitle(String text) => pw.Text(text.toUpperCase(), style: _sectionTitleStyle());

  pw.TextStyle _sectionTitleStyle() => pw.TextStyle(
    fontSize: 7,
    fontWeight: pw.FontWeight.bold,
    color: _ink,
  );

  pw.TextStyle _labelStyle() => pw.TextStyle(fontSize: 6.5, color: _ink);

  pw.TextStyle _valueStyle({double fontSize = 8}) => pw.TextStyle(
    fontSize: fontSize,
    fontWeight: pw.FontWeight.bold,
    color: _ink,
  );

  String _signed(int value) => value >= 0 ? '+$value' : '$value';

  String _formatSpeed(double meters) {
    final rounded = (meters * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) {
      return '${rounded.toInt()} m';
    }
    return '$rounded m';
  }

  String _humanize(String value) {
    return value
        .split('_')
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }
}
