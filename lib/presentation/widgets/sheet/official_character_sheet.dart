import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/attribute_keys.dart';
import '../../../core/constants/dnd_alignments.dart';
import '../../../core/constants/dnd_skills.dart';
import '../../../core/theme/sheet_theme.dart';
import '../../../domain/entities/character.dart';
import '../../../domain/entities/character_sheet_details.dart';
import '../../../domain/entities/character_stats.dart';
import '../../../domain/rules/sheet_proficiency_rule.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/character_controller.dart';
import '../../providers/character_stats_provider.dart';
import 'sheet_primitives.dart';
import 'sheet_text_fields.dart';

/// Ficha oficial D&D 5e — campos editaveis e calculo em tempo real.
class OfficialCharacterSheet extends ConsumerWidget {
  const OfficialCharacterSheet({super.key});

  static const double sheetWidth = 980;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(gameCatalogProvider).requireValue;
    final character = ref.watch(characterControllerProvider);
    final controller = ref.read(characterControllerProvider.notifier);
    final statsAsync = ref.watch(characterStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Erro: $error'),
      data: (stats) {
        final profBonus = proficiencyBonusForLevel(character.level);
        final dexMod = stats.modifiers['dexterity'] ?? 0;
        final hitDice = catalog.classById(character.classId).hitDice;
        final ac = character.sheet.armorClassOverride ?? stats.armorClass;
        final speed = character.sheet.speedOverrideMeters ?? stats.speedMeters;
        final maxHp = stats.hitPoints;
        final currentHp = character.sheet.currentHitPoints ?? maxHp;

        return Center(
          child: Container(
            width: sheetWidth,
            decoration: SheetDecorations.panel(fill: SheetColors.parchment),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SheetHeader(
                  character: character,
                  races: catalog.races.map((r) => (id: r.id, name: r.name)).toList(),
                  classes: catalog.classes.map((c) => (id: c.id, name: c.name)).toList(),
                  backgrounds: catalog.backgrounds.map((b) => (id: b.id, name: b.name)).toList(),
                  controller: controller,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: _LeftColumn(
                          character: character,
                          stats: stats,
                          profBonus: profBonus,
                          controller: controller,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CenterColumn(
                          character: character,
                          stats: stats,
                          dexMod: dexMod,
                          ac: ac,
                          speed: speed,
                          maxHp: maxHp,
                          currentHp: currentHp,
                          hitDice: hitDice,
                          controller: controller,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 220,
                        child: _RightColumn(
                          character: character,
                          stats: stats,
                          controller: controller,
                        ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.character,
    required this.races,
    required this.classes,
    required this.backgrounds,
    required this.controller,
  });

  final Character character;
  final List<({String id, String name})> races;
  final List<({String id, String name})> classes;
  final List<({String id, String name})> backgrounds;
  final CharacterController controller;

  @override
  Widget build(BuildContext context) {
    final sheet = character.sheet;
    final levels = List.generate(20, (i) => i + 1);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetFieldBox(
              label: 'Nome do personagem',
              flex: 3,
              child: _SheetTextInput(
                value: character.name,
                onChanged: controller.updateName,
              ),
            ),
            const SizedBox(width: 6),
            SheetFieldBox(
              label: 'Classe e nivel',
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _SheetDropdown(
                      value: character.classId,
                      options: classes,
                      onChanged: controller.selectClass,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _SheetDropdown(
                      value: '${character.level}',
                      options: [
                        for (final l in levels) (id: '$l', name: 'Nv $l'),
                      ],
                      onChanged: (v) => controller.updateLevel(int.parse(v)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            SheetFieldBox(
              label: 'Antecedente',
              flex: 2,
              child: _SheetDropdown(
                value: character.backgroundId,
                options: backgrounds,
                onChanged: controller.selectBackground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            SheetFieldBox(
              label: 'Nome do jogador',
              flex: 2,
              child: _SheetTextInput(
                value: sheet.playerName,
                onChanged: controller.updatePlayerName,
              ),
            ),
            const SizedBox(width: 6),
            SheetFieldBox(
              label: 'Raca',
              flex: 2,
              child: _SheetDropdown(
                value: character.raceId,
                options: races,
                onChanged: controller.selectRace,
              ),
            ),
            const SizedBox(width: 6),
            SheetFieldBox(
              label: 'Tendencia',
              flex: 2,
              child: _SheetDropdown(
                value: sheet.alignment.isEmpty ? dndAlignments.last : sheet.alignment,
                options: [
                  for (final a in dndAlignments) (id: a, name: a),
                ],
                onChanged: controller.updateAlignment,
              ),
            ),
            const SizedBox(width: 6),
            SheetFieldBox(
              label: 'Pontos de experiencia',
              flex: 1,
              child: _SheetTextInput(
                value: '${sheet.experiencePoints}',
                keyboardType: TextInputType.number,
                onChanged: (v) => controller.updateExperiencePoints(int.tryParse(v) ?? 0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn({
    required this.character,
    required this.stats,
    required this.profBonus,
    required this.controller,
  });

  final Character character;
  final CharacterStats stats;
  final int profBonus;
  final CharacterController controller;

  @override
  Widget build(BuildContext context) {
    final sheet = character.sheet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...attributeKeys.map((key) {
          final base = character.attributes.valueFor(key);
          final modifier = stats.modifiers[key] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _AbilityScoreBlock(
              abbreviation: attributeAbbreviations[key] ?? key,
              score: base,
              modifier: modifier,
              onDecrease: () => controller.decrementAttribute(key),
              onIncrease: () => controller.incrementAttribute(key),
            ),
          );
        }),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: controller.toggleInspiration,
                child: SheetMiniBox(
                  label: 'Inspiracao',
                  value: sheet.hasInspiration ? 'Sim' : '',
                  height: 42,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SheetMiniBox(
                label: 'Bonus prof.',
                value: formatModifier(profBonus),
                height: 42,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SheetPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetLabel('Testes de resistencia'),
              const SizedBox(height: 6),
              ...attributeKeys.map((key) {
                final auto = stats.savingThrows.contains(key);
                final proficient = isSavingThrowProficient(
                  abilityKey: key,
                  autoSavingThrows: stats.savingThrows,
                  sheet: sheet,
                );
                final bonus = savingThrowBonus(
                  abilityKey: key,
                  modifiers: stats.modifiers,
                  autoSavingThrows: stats.savingThrows,
                  sheet: sheet,
                  proficiencyBonus: profBonus,
                );
                return _SkillRow(
                  label: savingThrowLabels[key] ?? key,
                  modifier: formatModifier(bonus),
                  proficient: proficient,
                  onToggle: () => controller.toggleSavingThrow(key, autoProficient: auto),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SheetPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetLabel('Pericias'),
              const SizedBox(height: 6),
              ...dndSkills.map((skill) {
                final auto = stats.proficiencies.contains(skill.id);
                final proficient = isSkillProficient(
                  skillId: skill.id,
                  autoProficiencies: stats.proficiencies,
                  sheet: sheet,
                );
                final total = skillBonus(
                  skillId: skill.id,
                  abilityKey: skill.abilityKey,
                  modifiers: stats.modifiers,
                  autoProficiencies: stats.proficiencies,
                  sheet: sheet,
                  proficiencyBonus: profBonus,
                );
                return _SkillRow(
                  label: skill.label,
                  modifier: formatModifier(total),
                  proficient: proficient,
                  onToggle: () => controller.toggleSkillProficiency(
                    skill.id,
                    autoProficient: auto,
                  ),
                  trailing: Text(
                    attributeAbbreviations[skill.abilityKey] ?? '',
                    style: SheetDecorations.label(context),
                  ),
                );
              }),
              const SizedBox(height: 6),
              Text(
                'Sabedoria passiva (Percepcao): ${passivePerception(modifiers: stats.modifiers, autoProficiencies: stats.proficiencies, sheet: sheet, proficiencyBonus: profBonus)}',
                style: SheetDecorations.label(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SheetPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetLabel('Idiomas e outras proficiencias'),
              if (stats.proficiencies.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Auto: ${stats.proficiencies.map(_humanize).join(", ")}',
                  style: SheetDecorations.label(context),
                ),
              ],
              if (stats.languages.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Idiomas: ${stats.languages.join(", ")}',
                  style: SheetDecorations.label(context),
                ),
              ],
              const SizedBox(height: 6),
              SheetTextArea(
                label: 'Outras proficiencias',
                value: sheet.extraProficiencies,
                minLines: 2,
                maxLines: 4,
                compact: true,
                onChanged: controller.updateExtraProficiencies,
              ),
              const SizedBox(height: 6),
              SheetTextArea(
                label: 'Idiomas adicionais',
                value: sheet.extraLanguages,
                minLines: 1,
                maxLines: 3,
                compact: true,
                onChanged: controller.updateExtraLanguages,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AbilityScoreBlock extends StatelessWidget {
  const _AbilityScoreBlock({
    required this.abbreviation,
    required this.score,
    required this.modifier,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String abbreviation;
  final int score;
  final int modifier;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SheetDecorations.panel(),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Column(
        children: [
          SheetLabel(abbreviation, align: TextAlign.center),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TinyButton(icon: Icons.remove, onPressed: onDecrease),
              Container(
                width: 36,
                alignment: Alignment.center,
                child: Text('$score', style: SheetDecorations.score()),
              ),
              _TinyButton(icon: Icons.add, onPressed: onIncrease),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: SheetColors.modifierFill,
              border: Border.all(color: SheetColors.border),
            ),
            alignment: Alignment.center,
            child: Text(formatModifier(modifier), style: SheetDecorations.modifier()),
          ),
        ],
      ),
    );
  }
}

class _TinyButton extends StatelessWidget {
  const _TinyButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 14,
        style: IconButton.styleFrom(
          backgroundColor: SheetColors.headerFill,
          foregroundColor: SheetColors.ink,
        ),
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.label,
    required this.modifier,
    required this.proficient,
    required this.onToggle,
    this.trailing,
  });

  final String label;
  final String modifier;
  final bool proficient;
  final VoidCallback onToggle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SheetTappableDot(filled: proficient, onTap: onToggle),
          Expanded(
            child: Text(label, style: SheetDecorations.value(context)),
          ),
          ?trailing,
          Text(modifier, style: SheetDecorations.value(context)),
        ],
      ),
    );
  }
}

class _CenterColumn extends StatelessWidget {
  const _CenterColumn({
    required this.character,
    required this.stats,
    required this.dexMod,
    required this.ac,
    required this.speed,
    required this.maxHp,
    required this.currentHp,
    required this.hitDice,
    required this.controller,
  });

  final Character character;
  final CharacterStats stats;
  final int dexMod;
  final int ac;
  final double speed;
  final int maxHp;
  final int currentHp;
  final int hitDice;
  final CharacterController controller;

  @override
  Widget build(BuildContext context) {
    final sheet = character.sheet;
    final defaultHd = defaultHitDiceLabel(hitDice, character.level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _EditableMiniBox(
                label: 'Classe de armadura',
                value: '$ac',
                onChanged: (v) => controller.updateArmorClassOverride(int.tryParse(v)),
                height: 56,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SheetMiniBox(
                label: 'Iniciativa',
                value: formatModifier(dexMod),
                height: 56,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _EditableMiniBox(
                label: 'Deslocamento',
                value: formatSpeedMeters(speed).replaceAll(' m', ''),
                suffix: 'm',
                onChanged: (v) {
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  controller.updateSpeedOverride(parsed);
                },
                height: 56,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SheetPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetLabel('Pontos de vida'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _HpBox(label: 'Maximo', value: '$maxHp', readOnly: true),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _HpBox(
                      label: 'Atual',
                      value: '$currentHp',
                      onChanged: (v) => controller.updateCurrentHitPoints(int.tryParse(v)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _HpBox(
                      label: 'Temp.',
                      value: sheet.temporaryHitPoints == 0
                          ? ''
                          : '${sheet.temporaryHitPoints}',
                      onChanged: (v) => controller.updateTemporaryHitPoints(
                        int.tryParse(v) ?? 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _EditableMiniBox(
                      label: 'Dados de vida (total)',
                      value: sheet.hitDiceTotal.isEmpty ? defaultHd : sheet.hitDiceTotal,
                      onChanged: controller.updateHitDiceTotal,
                      height: 42,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _EditableMiniBox(
                      label: 'Dados restantes',
                      value: sheet.hitDiceRemaining.isEmpty
                          ? defaultHd
                          : sheet.hitDiceRemaining,
                      onChanged: controller.updateHitDiceRemaining,
                      height: 42,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SheetPanel(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SheetLabel('Testes contra a morte'),
                    const SizedBox(height: 6),
                    SheetDeathSaveRow(
                      label: 'Sucessos: ',
                      count: sheet.deathSaveSuccesses,
                      onChanged: controller.updateDeathSaveSuccesses,
                    ),
                    SheetDeathSaveRow(
                      label: 'Falhas: ',
                      count: sheet.deathSaveFailures,
                      onChanged: controller.updateDeathSaveFailures,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SheetPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetLabel('Ataques e magias'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: SheetColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text('Nome', style: SheetDecorations.label(context)),
                    ),
                    Expanded(
                      child: Text('Bonus', style: SheetDecorations.label(context)),
                    ),
                    Expanded(
                      child: Text('Dano/Tipo', style: SheetDecorations.label(context)),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < sheet.attacks.length; i++)
                _AttackRow(
                  attack: sheet.attacks[i],
                  onChanged: (a) => controller.updateAttack(i, a),
                ),
            ],
          ),
        ),
        if (stats.spellSlotsLevel1 > 0) ...[
          const SizedBox(height: 8),
          SheetPanel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetMiniBox(
                  label: 'Espacos nv.1',
                  value: '${stats.spellSlotsLevel1}',
                  width: 80,
                  height: 48,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SheetTextArea(
                    label: 'Magias e truques',
                    value: sheet.spellNotes,
                    minLines: 2,
                    maxLines: 4,
                    onChanged: controller.updateSpellNotes,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoinColumn(
              copper: sheet.copper,
              silver: sheet.silver,
              electrum: sheet.electrum,
              gold: sheet.gold,
              platinum: sheet.platinum,
              onChanged: controller.updateCoin,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SheetTextArea(
                label: 'Equipamento',
                value: sheet.equipment,
                minLines: 6,
                maxLines: 10,
                onChanged: controller.updateEquipment,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CoinColumn extends StatelessWidget {
  const _CoinColumn({
    required this.copper,
    required this.silver,
    required this.electrum,
    required this.gold,
    required this.platinum,
    required this.onChanged,
  });

  final int copper;
  final int silver;
  final int electrum;
  final int gold;
  final int platinum;
  final void Function({
    int? copper,
    int? silver,
    int? electrum,
    int? gold,
    int? platinum,
  }) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: Column(
        children: [
          _CoinField('PC', copper, (v) => onChanged(copper: v)),
          _CoinField('PP', silver, (v) => onChanged(silver: v)),
          _CoinField('PE', electrum, (v) => onChanged(electrum: v)),
          _CoinField('PO', gold, (v) => onChanged(gold: v)),
          _CoinField('PL', platinum, (v) => onChanged(platinum: v)),
        ],
      ),
    );
  }
}

class _CoinField extends StatelessWidget {
  const _CoinField(this.label, this.value, this.onChanged);

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          Text(label, style: SheetDecorations.label(context)),
          SheetControlledTextField(
            value: value == 0 ? '' : '$value',
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 2),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: SheetColors.borderLight),
              ),
            ),
            onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
          ),
        ],
      ),
    );
  }
}

class _HpBox extends StatelessWidget {
  const _HpBox({
    required this.label,
    required this.value,
    this.onChanged,
    this.readOnly = false,
  });

  final String label;
  final String value;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: SheetDecorations.panel(),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          SheetLabel(label, align: TextAlign.center),
          Expanded(
            child: Center(
              child: readOnly
                  ? Text(value, style: SheetDecorations.modifier())
                  : SheetControlledTextField(
                      value: value,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: SheetDecorations.modifier(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: onChanged!,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableMiniBox extends StatelessWidget {
  const _EditableMiniBox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.height = 48,
    this.suffix,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final double height;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        decoration: SheetDecorations.panel(),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SheetLabel(label, align: TextAlign.center),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SheetControlledTextField(
                      value: value,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                  if (suffix != null)
                    Text(suffix!, style: SheetDecorations.value(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttackRow extends StatelessWidget {
  const _AttackRow({required this.attack, required this.onChanged});

  final CharacterAttack attack;
  final ValueChanged<CharacterAttack> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _SheetTextInput(
              value: attack.name,
              onChanged: (v) => onChanged(attack.copyWith(name: v)),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SheetTextInput(
              value: attack.attackBonus,
              onChanged: (v) => onChanged(attack.copyWith(attackBonus: v)),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SheetTextInput(
              value: attack.damage,
              onChanged: (v) => onChanged(attack.copyWith(damage: v)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightColumn extends StatelessWidget {
  const _RightColumn({
    required this.character,
    required this.stats,
    required this.controller,
  });

  final Character character;
  final CharacterStats stats;
  final CharacterController controller;

  @override
  Widget build(BuildContext context) {
    final sheet = character.sheet;
    final autoFeatures = stats.raceTraits.join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTextArea(
          label: 'Tracos de personalidade',
          value: sheet.personalityTraits,
          minLines: 2,
          maxLines: 4,
          onChanged: controller.updatePersonalityTraits,
        ),
        const SizedBox(height: 6),
        SheetTextArea(
          label: 'Ideais',
          value: sheet.ideals,
          minLines: 2,
          maxLines: 3,
          onChanged: controller.updateIdeals,
        ),
        const SizedBox(height: 6),
        SheetTextArea(
          label: 'Vinculos',
          value: sheet.bonds,
          minLines: 2,
          maxLines: 3,
          onChanged: controller.updateBonds,
        ),
        const SizedBox(height: 6),
        SheetTextArea(
          label: 'Defeitos',
          value: sheet.flaws,
          minLines: 2,
          maxLines: 3,
          onChanged: controller.updateFlaws,
        ),
        const SizedBox(height: 8),
        SheetTextArea(
          label: 'Caracteristicas e habilidades',
          value: sheet.features.isEmpty ? autoFeatures : sheet.features,
          minLines: 4,
          maxLines: 8,
          onChanged: controller.updateFeatures,
        ),
      ],
    );
  }
}

String _humanize(String value) {
  return value
      .split('_')
      .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
      .join(' ');
}

class _SheetTextInput extends StatelessWidget {
  const _SheetTextInput({
    required this.value,
    required this.onChanged,
    this.keyboardType,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SheetControlledTextField(
      value: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: SheetColors.borderLight),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: SheetColors.borderLight),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: SheetColors.border, width: 1.5),
        ),
      ),
    );
  }
}

class _SheetDropdown extends StatelessWidget {
  const _SheetDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<({String id, String name})> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = options.any((o) => o.id == value) ? value : options.first.id;

    return DropdownButtonFormField<String>(
      key: ValueKey('dropdown-$selected'),
      initialValue: selected,
      isDense: true,
      isExpanded: true,
      style: SheetDecorations.value(context),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: SheetColors.borderLight),
        ),
      ),
      items: [
        for (final o in options)
          DropdownMenuItem(value: o.id, child: Text(o.name, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (v) {
        if (v != null) {
          onChanged(v);
        }
      },
    );
  }
}
