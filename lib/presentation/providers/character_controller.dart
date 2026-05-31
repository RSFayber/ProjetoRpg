import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/attribute_set.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_sheet_details.dart';
import '../../domain/entities/class_build_data.dart';
import '../../domain/entities/game_catalog.dart';
import '../../domain/rules/class_build_rule.dart';
import '../../domain/rules/sheet_proficiency_rule.dart';
import '../../domain/usecases/save_character_usecase.dart';
import 'catalog_providers.dart';
import 'persistence_providers.dart';

final characterControllerProvider =
    NotifierProvider<CharacterController, Character>(CharacterController.new);

class CharacterController extends Notifier<Character> {
  Timer? _autosaveTimer;

  @override
  Character build() {
    ref.onDispose(() => _autosaveTimer?.cancel());
    ref.listen(gameCatalogProvider, (previous, next) {
      next.whenData((_) {
        if (state.id == null && state.sheet.equipment.isEmpty) {
          state = _applyClassOrBackgroundChange(resetSelections: true);
        }
      });
    });
    ref.listen(classBuildCatalogProvider, (previous, next) {
      next.whenData((_) {
        if (state.id == null && state.sheet.equipment.isEmpty) {
          state = _applyClassOrBackgroundChange(resetSelections: true);
        }
      });
    });
    return const Character.initial();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), () {
      unawaited(saveCurrent(silent: true));
    });
  }

  void _patchSheet(CharacterSheetDetails Function(CharacterSheetDetails) patch) {
    state = state.copyWith(sheet: patch(state.sheet));
    _scheduleAutosave();
  }

  Future<Character> saveCurrent({bool silent = false}) async {
    final repository = ref.read(characterRepositoryProvider);
    final saved = await SaveCharacterUseCase(repository).call(state);
    state = saved;
    return saved;
  }

  void loadCharacter(Character character) {
    state = character;
  }

  void resetToNew() {
    state = const Character.initial();
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
    _scheduleAutosave();
  }

  void selectRace(String raceId) {
    state = state.copyWith(raceId: raceId);
    _scheduleAutosave();
  }

  void selectClass(String classId) {
    state = _applyClassOrBackgroundChange(classId: classId, resetSelections: true);
    _scheduleAutosave();
  }

  void selectBackground(String backgroundId) {
    state = _applyClassOrBackgroundChange(
      backgroundId: backgroundId,
      resetSelections: true,
    );
    _scheduleAutosave();
  }

  GameCatalog? _catalogOrNull() {
    final async = ref.read(gameCatalogProvider);
    return async.when(
      data: (catalog) => catalog,
      loading: () => null,
      error: (_, _) => null,
    );
  }

  ClassBuildCatalog? _buildCatalogOrNull() {
    final async = ref.read(classBuildCatalogProvider);
    return async.when(
      data: (catalog) => catalog,
      loading: () => null,
      error: (_, _) => null,
    );
  }

  Character _applyClassOrBackgroundChange({
    String? classId,
    String? backgroundId,
    bool resetSelections = false,
  }) {
    var next = state.copyWith(
      classId: classId,
      backgroundId: backgroundId,
    );
    final catalog = _catalogOrNull();
    if (catalog == null) {
      return next;
    }

    final characterClass = catalog.classById(next.classId);
    final background = catalog.backgroundById(next.backgroundId);
    final buildData = _buildCatalogOrNull()?.forClass(next.classId);

    var choices = next.sheet.equipmentChoiceSelections;
    if (resetSelections || choices.isEmpty) {
      choices = defaultEquipmentChoices(buildData);
    }

    var bgItems = next.sheet.selectedBackgroundItems;
    if (resetSelections || bgItems.isEmpty) {
      bgItems = List<String>.from(background.startingEquipment);
    }

    final equipment = resolveStartingEquipmentText(
      characterClass: characterClass,
      background: background,
      buildData: buildData,
      choiceSelections: choices,
      selectedBackgroundItems: bgItems,
    );
    final hd = defaultHitDiceLabel(characterClass.hitDice, next.level);

    return next.copyWith(
      sheet: next.sheet.copyWith(
        equipment: equipment,
        equipmentChoiceSelections: choices,
        selectedBackgroundItems: bgItems,
        hitDiceTotal: hd,
        hitDiceRemaining: hd,
        currentHitPoints: () => null,
      ),
    );
  }

  void selectEquipmentChoice(String groupId, String optionId) {
    final catalog = _catalogOrNull();
    if (catalog == null) {
      return;
    }
    final buildData = _buildCatalogOrNull()?.forClass(state.classId);
    final choices = Map<String, String>.from(state.sheet.equipmentChoiceSelections);
    choices[groupId] = optionId;

    final equipment = resolveStartingEquipmentText(
      characterClass: catalog.classById(state.classId),
      background: catalog.backgroundById(state.backgroundId),
      buildData: buildData,
      choiceSelections: choices,
      selectedBackgroundItems: state.sheet.selectedBackgroundItems,
    );

    _patchSheet(
      (s) => s.copyWith(
        equipmentChoiceSelections: choices,
        equipment: equipment,
      ),
    );
  }

  void toggleBackgroundItem(String item, bool included) {
    final catalog = _catalogOrNull();
    if (catalog == null) {
      return;
    }
    final background = catalog.backgroundById(state.backgroundId);
    var items = List<String>.from(state.sheet.selectedBackgroundItems);
    if (items.isEmpty) {
      items = List<String>.from(background.startingEquipment);
    }
    if (included) {
      if (!items.contains(item)) {
        items.add(item);
      }
    } else {
      items.remove(item);
    }

    final buildData = _buildCatalogOrNull()?.forClass(state.classId);
    final equipment = resolveStartingEquipmentText(
      characterClass: catalog.classById(state.classId),
      background: background,
      buildData: buildData,
      choiceSelections: state.sheet.equipmentChoiceSelections,
      selectedBackgroundItems: items,
    );

    _patchSheet(
      (s) => s.copyWith(
        selectedBackgroundItems: items,
        equipment: equipment,
      ),
    );
  }

  void updateLevel(int level) {
    state = state.copyWith(level: level.clamp(1, 20));
    _scheduleAutosave();
  }

  void setAttribute(String key, int value) {
    final clamped = value.clamp(1, 20).toInt();
    state = state.copyWith(attributes: state.attributes.setValue(key, clamped));
    _scheduleAutosave();
  }

  void incrementAttribute(String key) {
    setAttribute(key, state.attributes.valueFor(key) + 1);
  }

  void decrementAttribute(String key) {
    setAttribute(key, state.attributes.valueFor(key) - 1);
  }

  void resetAttributes() {
    state = state.copyWith(attributes: const AttributeSet.standard());
    _scheduleAutosave();
  }

  void updatePlayerName(String value) =>
      _patchSheet((s) => s.copyWith(playerName: value));

  void updateAlignment(String value) =>
      _patchSheet((s) => s.copyWith(alignment: value));

  void updateExperiencePoints(int value) =>
      _patchSheet((s) => s.copyWith(experiencePoints: value.clamp(0, 9999999)));

  void toggleInspiration() =>
      _patchSheet((s) => s.copyWith(hasInspiration: !s.hasInspiration));

  void updateArmorClassOverride(int? value) =>
      _patchSheet((s) => s.copyWith(armorClassOverride: () => value));

  void updateCurrentHitPoints(int? value) =>
      _patchSheet((s) => s.copyWith(currentHitPoints: () => value));

  void updateTemporaryHitPoints(int value) =>
      _patchSheet((s) => s.copyWith(temporaryHitPoints: value.clamp(0, 9999)));

  void updateHitDiceTotal(String value) =>
      _patchSheet((s) => s.copyWith(hitDiceTotal: value));

  void updateHitDiceRemaining(String value) =>
      _patchSheet((s) => s.copyWith(hitDiceRemaining: value));

  void updateSpeedOverride(double? meters) =>
      _patchSheet((s) => s.copyWith(speedOverrideMeters: () => meters));

  void updateDeathSaveSuccesses(int count) => _patchSheet(
    (s) => s.copyWith(deathSaveSuccesses: count.clamp(0, 3)),
  );

  void updateDeathSaveFailures(int count) => _patchSheet(
    (s) => s.copyWith(deathSaveFailures: count.clamp(0, 3)),
  );

  void updateAttack(int index, CharacterAttack attack) {
    final attacks = List<CharacterAttack>.from(state.sheet.attacks);
    if (index < 0 || index >= attacks.length) {
      return;
    }
    attacks[index] = attack;
    _patchSheet((s) => s.copyWith(attacks: attacks));
  }

  void updateEquipment(String value) =>
      _patchSheet((s) => s.copyWith(equipment: value));

  void updateCoin({int? copper, int? silver, int? electrum, int? gold, int? platinum}) {
    _patchSheet(
      (s) => s.copyWith(
        copper: copper ?? s.copper,
        silver: silver ?? s.silver,
        electrum: electrum ?? s.electrum,
        gold: gold ?? s.gold,
        platinum: platinum ?? s.platinum,
      ),
    );
  }

  void updatePersonalityTraits(String value) =>
      _patchSheet((s) => s.copyWith(personalityTraits: value));

  void updateIdeals(String value) => _patchSheet((s) => s.copyWith(ideals: value));

  void updateBonds(String value) => _patchSheet((s) => s.copyWith(bonds: value));

  void updateFlaws(String value) => _patchSheet((s) => s.copyWith(flaws: value));

  void updateFeatures(String value) =>
      _patchSheet((s) => s.copyWith(features: value));

  void updateExtraProficiencies(String value) =>
      _patchSheet((s) => s.copyWith(extraProficiencies: value));

  void updateExtraLanguages(String value) =>
      _patchSheet((s) => s.copyWith(extraLanguages: value));

  void updateSpellNotes(String value) =>
      _patchSheet((s) => s.copyWith(spellNotes: value));

  void toggleSkillProficiency(String skillId, {required bool autoProficient}) {
    final overrides = Map<String, bool>.from(state.sheet.skillProficiencyOverrides);
    final current = overrides[skillId] ?? autoProficient;
    overrides[skillId] = !current;
    _patchSheet((s) => s.copyWith(skillProficiencyOverrides: overrides));
  }

  void toggleSavingThrow(String abilityKey, {required bool autoProficient}) {
    final overrides = Map<String, bool>.from(state.sheet.savingThrowOverrides);
    final current = overrides[abilityKey] ?? autoProficient;
    overrides[abilityKey] = !current;
    _patchSheet((s) => s.copyWith(savingThrowOverrides: overrides));
  }

  void syncHitDiceFromClass(int hitDice, int level) {
    final label = defaultHitDiceLabel(hitDice, level);
    _patchSheet(
      (s) => s.copyWith(
        hitDiceTotal: s.hitDiceTotal.isEmpty ? label : s.hitDiceTotal,
        hitDiceRemaining:
            s.hitDiceRemaining.isEmpty ? label : s.hitDiceRemaining,
      ),
    );
  }
}
