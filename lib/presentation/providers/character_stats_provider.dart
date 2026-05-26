import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/character_stats.dart';
import '../../domain/usecases/calculate_character_stats_usecase.dart';
import 'catalog_providers.dart';
import 'character_controller.dart';

final characterStatsProvider = Provider<AsyncValue<CharacterStats>>((ref) {
  final catalog = ref.watch(gameCatalogProvider);
  final character = ref.watch(characterControllerProvider);

  return catalog.whenData((value) {
    return CalculateCharacterStatsUseCase(value).call(character);
  });
});
