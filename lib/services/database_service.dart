import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:flutter/foundation.dart';

class GameDatabaseService {
  static Database? _database;

  static Future<void> initDatabase() async {
    String path;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      path = 'pooker.db';
    } else {
      path = join(await getDatabasesPath(), 'pooker.db');
    }

    _database = await openDatabase(
      path,
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
