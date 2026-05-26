import 'package:sqflite/sqflite.dart';

import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../datasources/local_database.dart';

class SqliteCharacterRepository implements CharacterRepository {
  SqliteCharacterRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<List<Character>> listCharacters() async {
    final db = await _database.database;
    final rows = await db.query('characters', orderBy: 'updated_at DESC');
    return rows
        .map(
          (row) => Character.fromJson(decodePayload(row['payload'] as String)),
        )
        .toList();
  }

  @override
  Future<Character?> getById(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      'characters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Character.fromJson(decodePayload(rows.first['payload'] as String));
  }

  @override
  Future<Character> save(Character character) async {
    final db = await _database.database;
    final id = character.id ?? 'char_${DateTime.now().millisecondsSinceEpoch}';
    final payload = encodePayload(character.copyWith(id: id).toJson());
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('characters', {
      'id': id,
      'name': character.name.isEmpty ? 'Sem nome' : character.name,
      'payload': payload,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return character.copyWith(id: id);
  }

  @override
  Future<void> delete(String id) async {
    final db = await _database.database;
    await db.delete('characters', where: 'id = ?', whereArgs: [id]);
  }
}
