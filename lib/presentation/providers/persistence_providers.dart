import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_database.dart';
import '../../data/repositories/sqlite_character_repository.dart';
import '../../domain/repositories/character_repository.dart';
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase.instance;
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final database = ref.watch(localDatabaseProvider);
  return SqliteCharacterRepository(database);
});

final savedCharactersProvider = FutureProvider((ref) async {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.listCharacters();
});
