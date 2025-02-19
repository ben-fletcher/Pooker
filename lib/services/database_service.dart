import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pooker_score/models/game_result.dart';

class GameDatabaseService {
  static Database? _database;

  static Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'pooker.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE game_history(id INTEGER PRIMARY KEY, date TEXT, players TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertGameResult(GameResult gameResult) async {
    if (_database == null) return;

    await _database!.insert(
      'game_history',
      gameResult.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<GameResult>> loadGameHistory() async {
    if (_database == null) return [];
    final List<Map<String, dynamic>> maps =
        await _database!.query('game_history', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return GameResult.fromMap(maps[i]);
    });
  }
}
