import 'dart:io'; // Add this import
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
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion == 1) {
          db.execute('CREATE TABLE player(id INTEGER PRIMARY KEY, name TEXT)');
        }
      },
      version: 2,
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

    final result = history.fold(<String, dynamic>{}, (value, element) {
      final PlayerResult winnerResult = element.players.firstWhere(
        (player) =>
            player.score ==
            element.players.map((e) => e.score).reduce((a, b) => a > b ? a : b),
        orElse: () => PlayerResult('', 0),
      );

      final PlayerResult playerResult = element.players.firstWhere(
        (player) => player.name == playerName,
        orElse: () => PlayerResult('', 0),
      );

      value['gamesPlayed'] = (value['gamesPlayed'] ?? 0) + 1;
      value['gamesWon'] =
          (value['gamesWon'] ?? 0) + playerResult == winnerResult ? 1 : 0;
      value['totalScore'] = (value['totalScore'] ?? 0) + playerResult.score;

      final highestScore = value['highestScore'] ?? 0;
      value['highestScore'] =
          playerResult.score > highestScore ? playerResult.score : highestScore;

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
}
