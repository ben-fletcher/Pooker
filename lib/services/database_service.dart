import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:flutter/foundation.dart';

class GameDatabaseService {
  static Database? _database;

  static Future<void> initDatabase() async {
    String path = await getDatabasePath();

    _database = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE game_history(id INTEGER PRIMARY KEY, date TEXT, players TEXT)');
        await db
            .execute('CREATE TABLE player(id INTEGER PRIMARY KEY, name TEXT)');
        await db.execute(
            'CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT)');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion == 1) {
          db.execute('CREATE TABLE player(id INTEGER PRIMARY KEY, name TEXT)');
        }
        if (oldVersion < 3) {
          db.execute('CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT)');
        }
      },
      version: 3,
    );
  }

  static Future<String> getDatabasePath() async {
    String path;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      path = 'pooker.db';
    } else {
      path = join(await getDatabasesPath(), 'pooker.db');
    }
    return path;
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

    int gamesPlayed = 0;
    int gamesWon = 0;
    int totalScore = 0;
    int highestScore = 0;

    for (final game in history) {
      // Consider only games where the player actually participated
      final matching =
          game.players.where((player) => player.name == playerName).toList();
      if (matching.isEmpty) continue;

      final playerResult = matching.first;

      gamesPlayed += 1;
      totalScore += playerResult.score;
      if (playerResult.score > highestScore) {
        highestScore = playerResult.score;
      }

      // Determine the winner of this game
      final PlayerResult winner = game.players.reduce(
          (a, b) => a.score > b.score ? a : b);
      if (winner.name == playerName) {
        gamesWon += 1;
      }
    }

    if (gamesPlayed == 0) {
      return {
        'gamesPlayed': 0,
        'gamesWon': 0,
        'totalScore': 0,
        'averageScore': '0.0000',
        'highestScore': 0,
        'winRate': '0.00%'
      };
    }

    final average = (totalScore / gamesPlayed).toStringAsFixed(4);
    final winRate = ((gamesWon / gamesPlayed) * 100).toStringAsFixed(2) + '%';

    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'totalScore': totalScore,
      'averageScore': average,
      'highestScore': highestScore,
      'winRate': winRate,
    };
  }

  static Future<void> exportDatabase() async {
    if (_database == null) return;

    try {
      final String dbPath = await getDatabasePath();
      final File dbFile = File(dbPath);

      String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Export Database',
          fileName: 'pooker.db',
          bytes: await dbFile.readAsBytes());

      debugPrint("Database exported successfully to $outputPath");
    } catch (e) {
      debugPrint("Error exporting database: $e");
    }
  }

  static Future<void> importDatabase(String sourcePath) async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    try {
      String dbPath = await getDatabasePath();

      // Replace the current database file with the imported file
      final File sourceFile = File(sourcePath);
      final File destinationFile = File(dbPath);

      if (await sourceFile.exists()) {
        await destinationFile.writeAsBytes(await sourceFile.readAsBytes(),
            flush: true);
        debugPrint("Database imported successfully from $sourcePath");

        // Reinitialize the database
        await initDatabase();
      } else {
        debugPrint("Source database file does not exist at $sourcePath");
      }
    } catch (e) {
      debugPrint("Error importing database: $e");
    }
  }

  static Future<void> resetDatabase() async {
    if (_database != null) {
      _database!.close();
      _database = null;
    }

    await deleteDatabase(await getDatabasesPath());
    await initDatabase();
  }

  // Settings methods
  static Future<void> setSetting(String key, String value) async {
    if (_database == null) return;
    await _database!.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getSetting(String key) async {
    if (_database == null) return null;
    final List<Map<String, dynamic>> maps = await _database!.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  static Future<bool> getSkillShotEnabled() async {
    final value = await getSetting('skill_shot_enabled');
    return value == 'true';
  }

  static Future<void> setSkillShotEnabled(bool enabled) async {
    await setSetting('skill_shot_enabled', enabled.toString());
  }
}
