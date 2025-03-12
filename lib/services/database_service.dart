import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
// ignore: depend_on_referenced_packages
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
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion == 1) {
          db.execute('CREATE TABLE player(id INTEGER PRIMARY KEY, name TEXT)');
        }
      },
      version: 2,
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

  static Future<void> deleteGameResult(int id) async {
    if (_database == null) return;
    await _database!.delete(
      'game_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> purgeGameHistory() async {
    if (_database == null) return;
    await _database!.delete('game_history');
  }

  static Future<void> insertPlayer(String name) async {
    if (_database == null) return;
    await _database!.insert(
      'player',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  static Future<List<String>> loadPlayers() async {
    if (_database == null) return [];
    final List<Map<String, dynamic>> maps = await _database!.query('player');
    return List.generate(maps.length, (i) {
      return maps[i]['name'] as String;
    });
  }

  static Future<void> deletePlayer(String name) async {
    if (_database == null) return;
    await _database!.delete(
      'player',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  static Future<Map<String, dynamic>> getPlayerStatistics(
      String playerName) async {
    final history = await loadGameHistory();

    final result = history.fold(<String, dynamic>{}, (value, element) {
      for (var player in element.players) {
        if (player.name == playerName) {
          value['gamesPlayed'] = (value['gamesPlayed'] ?? 0) + 1;
          value['gamesWon'] =
              (value['gamesWon'] ?? 0) + (player.score == 0 ? 1 : 0);
          value['totalScore'] = (value['totalScore'] ?? 0) + player.score;

          final highestScore = value['highestScore'] ?? 0;
          value['highestScore'] =
              player.score > highestScore ? player.score : highestScore;
        }
      }
      return value;
    });

    if (result.isEmpty) {
      return result;
    }

    result['averageScore'] =
        (result['totalScore'] / result['gamesPlayed']).toStringAsFixed(4);
    result['winRate'] = ((result['gamesWon'] / result['gamesPlayed']) * 100)
            .toStringAsFixed(2) +
        '%';

    return result;
  }
}
