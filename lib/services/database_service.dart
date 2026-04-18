import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:pooker_score/models/high_score_leaderboard_entry.dart';
import 'package:flutter/foundation.dart';

/// Result of importing games from JSON (merge). No existing data is deleted.
class ImportResult {
  final int gamesImported;
  final int playersAdded;

  const ImportResult({required this.gamesImported, required this.playersAdded});
}

class GameDatabaseService {
  static Database? _database;

  static Future<void> initDatabase() async {
    String path = await getDatabasePath();

    _database = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE game_history(id INTEGER PRIMARY KEY, date TEXT, sorted TEXT, players TEXT)');
        await db
            .execute('CREATE TABLE player(id INTEGER PRIMARY KEY, name TEXT)');
        await db
            .execute('CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT)');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion == 1) {
          db.execute('CREATE TABLE player(id INTEGER PRIMARY KEY, name TEXT)');
        }
        if (oldVersion < 3) {
          db.execute('CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT)');
        }
        if (oldVersion < 4) {
          db.execute('ALTER TABLE game_history ADD COLUMN sorted text');
        }
      },
      version: 4,
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

    final mapGameResult = gameResult.toMap();
    // Delete existing record if the game had already been saved once.
    await _database!.delete('game_history',
        where: 'date = ?', whereArgs: [mapGameResult['date']]);

    await _database!.insert(
      'game_history',
      mapGameResult,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static const int _exportFormatVersion = 1;

  /// Returns a JSON string of games for sharing. Does not include internal ids.
  static String exportGamesAsJson(List<GameResult> games) {
    final list = games.map((g) {
      final m = Map<String, dynamic>.from(g.toMap());
      m.remove('id');
      return m;
    }).toList();
    final envelope = {
      'version': _exportFormatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'games': list,
    };
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// Parses JSON from export and merges games into the database. Adds any
  /// missing players. Returns counts of games imported and new players added.
  static Future<ImportResult> importGamesFromJson(String jsonString) async {
    if (_database == null) {
      return const ImportResult(gamesImported: 0, playersAdded: 0);
    }

    final envelope = jsonDecode(jsonString) as Map<String, dynamic>;
    final gamesList = envelope['games'] as List<dynamic>? ?? [];
    int playersAdded = 0;

    for (final item in gamesList) {
      final gameMap = item as Map<String, dynamic>;
      final game = GameResult.fromMap(gameMap);
      for (final playerResult in game.players) {
        final inserted = await insertPlayer(playerResult.name);
        if (inserted) playersAdded++;
      }
      await insertGameResult(game);
    }

    return ImportResult(
      gamesImported: gamesList.length,
      playersAdded: playersAdded,
    );
  }

  /// Returns true if the string looks like a Pooker games export (has version + games).
  static bool looksLikeExportJson(String jsonString) {
    try {
      final envelope = jsonDecode(jsonString) as Map<String, dynamic>?;
      return envelope != null &&
          envelope.containsKey('version') &&
          envelope.containsKey('games') &&
          envelope['games'] is List;
    } catch (_) {
      return false;
    }
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

  static Future<bool> insertPlayer(String name) async {
    if (_database == null) return false;

    final existingPlayer =
        await _database!.query('player', where: 'name = ?', whereArgs: [name]);
    if (existingPlayer.isNotEmpty) {
      return false;
    }

    await _database!.insert(
      'player',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    return true;
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
    int? highestScore;

    for (final game in history) {
      // Consider only games where the player actually participated
      final matching =
          game.players.where((player) => player.name == playerName).toList();
      if (matching.isEmpty) continue;

      final playerResult = matching.first;

      gamesPlayed += 1;
      totalScore += playerResult.score;
      if (highestScore == null || playerResult.score > highestScore) {
        highestScore = playerResult.score;
      }

      // Determine the winner of this game
      final PlayerResult winner =
          game.players.reduce((a, b) => a.score > b.score ? a : b);
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
    final winRate = '${((gamesWon / gamesPlayed) * 100).toStringAsFixed(2)}%';

    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'totalScore': totalScore,
      'averageScore': average,
      'highestScore': highestScore,
      'winRate': winRate,
    };
  }

  /// Players ranked by highest single-game score. Tie-break: more games played, then name A–Z.
  static Future<List<HighScoreLeaderboardEntry>>
      getHighScoreLeaderboard() async {
    final history = await loadGameHistory();
    final Map<String, int> maxScore = {};
    final Map<String, int> gamesCount = {};

    for (final game in history) {
      for (final p in game.players) {
        gamesCount[p.name] = (gamesCount[p.name] ?? 0) + 1;
        final m = maxScore[p.name];
        if (m == null || p.score > m) {
          maxScore[p.name] = p.score;
        }
      }
    }

    final entries = maxScore.entries
        .map(
          (e) => HighScoreLeaderboardEntry(
            name: e.key,
            highScore: e.value,
            gamesPlayed: gamesCount[e.key] ?? 0,
          ),
        )
        .toList();

    entries.sort((a, b) {
      final byScore = b.highScore.compareTo(a.highScore);
      if (byScore != 0) return byScore;
      final byGames = b.gamesPlayed.compareTo(a.gamesPlayed);
      if (byGames != 0) return byGames;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return entries;
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

  static Future<bool> getDeveloperModeEnabled() async {
    final value = await getSetting('developer_mode');
    return value == 'true';
  }

  static Future<void> setDeveloperModeEnabled(bool enabled) async {
    await setSetting('developer_mode', enabled.toString());
  }
}
