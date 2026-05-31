/// Campos editaveis da ficha oficial (alem de raca/classe/atributos).
class CharacterAttack {
  const CharacterAttack({
    this.name = '',
    this.attackBonus = '',
    this.damage = '',
  });

  final String name;
  final String attackBonus;
  final String damage;

  Map<String, dynamic> toJson() => {
    'name': name,
    'attackBonus': attackBonus,
    'damage': damage,
  };

  factory CharacterAttack.fromJson(Map<String, dynamic> json) {
    return CharacterAttack(
      name: json['name'] as String? ?? '',
      attackBonus: json['attackBonus'] as String? ?? '',
      damage: json['damage'] as String? ?? '',
    );
  }

  CharacterAttack copyWith({
    String? name,
    String? attackBonus,
    String? damage,
  }) {
    return CharacterAttack(
      name: name ?? this.name,
      attackBonus: attackBonus ?? this.attackBonus,
      damage: damage ?? this.damage,
    );
  }
}

class CharacterSheetDetails {
  const CharacterSheetDetails({
    this.playerName = '',
    this.alignment = '',
    this.experiencePoints = 0,
    this.hasInspiration = false,
    this.armorClassOverride,
    this.currentHitPoints,
    this.temporaryHitPoints = 0,
    this.hitDiceTotal = '',
    this.hitDiceRemaining = '',
    this.speedOverrideMeters,
    this.deathSaveSuccesses = 0,
    this.deathSaveFailures = 0,
    this.attacks = const [
      CharacterAttack(),
      CharacterAttack(),
      CharacterAttack(),
      CharacterAttack(),
    ],
    this.equipment = '',
    this.copper = 0,
    this.silver = 0,
    this.electrum = 0,
    this.gold = 0,
    this.platinum = 0,
    this.personalityTraits = '',
    this.ideals = '',
    this.bonds = '',
    this.flaws = '',
    this.features = '',
    this.extraProficiencies = '',
    this.extraLanguages = '',
    this.spellNotes = '',
    this.skillProficiencyOverrides = const {},
    this.savingThrowOverrides = const {},
    this.equipmentChoiceSelections = const {},
    this.selectedBackgroundItems = const [],
  });

  final String playerName;
  final String alignment;
  final int experiencePoints;
  final bool hasInspiration;
  final int? armorClassOverride;
  final int? currentHitPoints;
  final int temporaryHitPoints;
  final String hitDiceTotal;
  final String hitDiceRemaining;
  final double? speedOverrideMeters;
  final int deathSaveSuccesses;
  final int deathSaveFailures;
  final List<CharacterAttack> attacks;
  final String equipment;
  final int copper;
  final int silver;
  final int electrum;
  final int gold;
  final int platinum;
  final String personalityTraits;
  final String ideals;
  final String bonds;
  final String flaws;
  final String features;
  final String extraProficiencies;
  final String extraLanguages;
  final String spellNotes;
  final Map<String, bool> skillProficiencyOverrides;
  final Map<String, bool> savingThrowOverrides;
  final Map<String, String> equipmentChoiceSelections;
  final List<String> selectedBackgroundItems;

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'alignment': alignment,
    'experiencePoints': experiencePoints,
    'hasInspiration': hasInspiration,
    if (armorClassOverride != null) 'armorClassOverride': armorClassOverride,
    if (currentHitPoints != null) 'currentHitPoints': currentHitPoints,
    'temporaryHitPoints': temporaryHitPoints,
    'hitDiceTotal': hitDiceTotal,
    'hitDiceRemaining': hitDiceRemaining,
    if (speedOverrideMeters != null) 'speedOverrideMeters': speedOverrideMeters,
    'deathSaveSuccesses': deathSaveSuccesses,
    'deathSaveFailures': deathSaveFailures,
    'attacks': attacks.map((a) => a.toJson()).toList(),
    'equipment': equipment,
    'copper': copper,
    'silver': silver,
    'electrum': electrum,
    'gold': gold,
    'platinum': platinum,
    'personalityTraits': personalityTraits,
    'ideals': ideals,
    'bonds': bonds,
    'flaws': flaws,
    'features': features,
    'extraProficiencies': extraProficiencies,
    'extraLanguages': extraLanguages,
    'spellNotes': spellNotes,
    'skillProficiencyOverrides': skillProficiencyOverrides,
    'savingThrowOverrides': savingThrowOverrides,
    'equipmentChoiceSelections': equipmentChoiceSelections,
    'selectedBackgroundItems': selectedBackgroundItems,
  };

  factory CharacterSheetDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const CharacterSheetDetails();
    }
    final attacksJson = json['attacks'] as List?;
    final attacks = <CharacterAttack>[
      if (attacksJson != null)
        for (final item in attacksJson)
          CharacterAttack.fromJson(item as Map<String, dynamic>),
    ];
    while (attacks.length < 4) {
      attacks.add(const CharacterAttack());
    }

    return CharacterSheetDetails(
      playerName: json['playerName'] as String? ?? '',
      alignment: json['alignment'] as String? ?? '',
      experiencePoints: json['experiencePoints'] as int? ?? 0,
      hasInspiration: json['hasInspiration'] as bool? ?? false,
      armorClassOverride: json['armorClassOverride'] as int?,
      currentHitPoints: json['currentHitPoints'] as int?,
      temporaryHitPoints: json['temporaryHitPoints'] as int? ?? 0,
      hitDiceTotal: json['hitDiceTotal'] as String? ?? '',
      hitDiceRemaining: json['hitDiceRemaining'] as String? ?? '',
      speedOverrideMeters: (json['speedOverrideMeters'] as num?)?.toDouble(),
      deathSaveSuccesses: json['deathSaveSuccesses'] as int? ?? 0,
      deathSaveFailures: json['deathSaveFailures'] as int? ?? 0,
      attacks: attacks.take(4).toList(),
      equipment: json['equipment'] as String? ?? '',
      copper: json['copper'] as int? ?? 0,
      silver: json['silver'] as int? ?? 0,
      electrum: json['electrum'] as int? ?? 0,
      gold: json['gold'] as int? ?? 0,
      platinum: json['platinum'] as int? ?? 0,
      personalityTraits: json['personalityTraits'] as String? ?? '',
      ideals: json['ideals'] as String? ?? '',
      bonds: json['bonds'] as String? ?? '',
      flaws: json['flaws'] as String? ?? '',
      features: json['features'] as String? ?? '',
      extraProficiencies: json['extraProficiencies'] as String? ?? '',
      extraLanguages: json['extraLanguages'] as String? ?? '',
      spellNotes: json['spellNotes'] as String? ?? '',
      skillProficiencyOverrides: Map<String, bool>.from(
        json['skillProficiencyOverrides'] as Map? ?? const {},
      ),
      savingThrowOverrides: Map<String, bool>.from(
        json['savingThrowOverrides'] as Map? ?? const {},
      ),
      equipmentChoiceSelections: Map<String, String>.from(
        json['equipmentChoiceSelections'] as Map? ?? const {},
      ),
      selectedBackgroundItems: List<String>.from(
        json['selectedBackgroundItems'] as List? ?? const [],
      ),
    );
  }

  CharacterSheetDetails copyWith({
    String? playerName,
    String? alignment,
    int? experiencePoints,
    bool? hasInspiration,
    int? Function()? armorClassOverride,
    int? Function()? currentHitPoints,
    int? temporaryHitPoints,
    String? hitDiceTotal,
    String? hitDiceRemaining,
    double? Function()? speedOverrideMeters,
    int? deathSaveSuccesses,
    int? deathSaveFailures,
    List<CharacterAttack>? attacks,
    String? equipment,
    int? copper,
    int? silver,
    int? electrum,
    int? gold,
    int? platinum,
    String? personalityTraits,
    String? ideals,
    String? bonds,
    String? flaws,
    String? features,
    String? extraProficiencies,
    String? extraLanguages,
    String? spellNotes,
    Map<String, bool>? skillProficiencyOverrides,
    Map<String, bool>? savingThrowOverrides,
    Map<String, String>? equipmentChoiceSelections,
    List<String>? selectedBackgroundItems,
  }) {
    return CharacterSheetDetails(
      playerName: playerName ?? this.playerName,
      alignment: alignment ?? this.alignment,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      hasInspiration: hasInspiration ?? this.hasInspiration,
      armorClassOverride: armorClassOverride != null
          ? armorClassOverride()
          : this.armorClassOverride,
      currentHitPoints: currentHitPoints != null
          ? currentHitPoints()
          : this.currentHitPoints,
      temporaryHitPoints: temporaryHitPoints ?? this.temporaryHitPoints,
      hitDiceTotal: hitDiceTotal ?? this.hitDiceTotal,
      hitDiceRemaining: hitDiceRemaining ?? this.hitDiceRemaining,
      speedOverrideMeters: speedOverrideMeters != null
          ? speedOverrideMeters()
          : this.speedOverrideMeters,
      deathSaveSuccesses: deathSaveSuccesses ?? this.deathSaveSuccesses,
      deathSaveFailures: deathSaveFailures ?? this.deathSaveFailures,
      attacks: attacks ?? this.attacks,
      equipment: equipment ?? this.equipment,
      copper: copper ?? this.copper,
      silver: silver ?? this.silver,
      electrum: electrum ?? this.electrum,
      gold: gold ?? this.gold,
      platinum: platinum ?? this.platinum,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      ideals: ideals ?? this.ideals,
      bonds: bonds ?? this.bonds,
      flaws: flaws ?? this.flaws,
      features: features ?? this.features,
      extraProficiencies: extraProficiencies ?? this.extraProficiencies,
      extraLanguages: extraLanguages ?? this.extraLanguages,
      spellNotes: spellNotes ?? this.spellNotes,
      skillProficiencyOverrides:
          skillProficiencyOverrides ?? this.skillProficiencyOverrides,
      savingThrowOverrides:
          savingThrowOverrides ?? this.savingThrowOverrides,
      equipmentChoiceSelections:
          equipmentChoiceSelections ?? this.equipmentChoiceSelections,
      selectedBackgroundItems:
          selectedBackgroundItems ?? this.selectedBackgroundItems,
    );
  }
}
