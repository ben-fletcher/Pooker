import 'dart:convert';
import 'player.dart';

class GameResult {
  final DateTime date;
  final List<PlayerResult> players;

  GameResult({required this.date, required this.players});

  String toJson() {
    final map = toMap();
    return jsonEncode(map);
  }

  static GameResult fromJson(String json) {
    final map = jsonDecode(json);
    return fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'players': players.map((player) => player.toJson()).toList().toString(),
    };
  }

  static GameResult fromMap(Map<String, dynamic> map) {
    return GameResult(
      date: DateTime.parse(map['date']),
      players: (json.decode(map['players']) as List)
          .map((player) => PlayerResult.fromMap(player))
          .toList(),
    );
  }
}

class PlayerResult {
  final String name;
  final int score;

  PlayerResult({required this.name, required this.score});

  String toJson() {
    final map = toMap();
    return jsonEncode(map);
  }

  static PlayerResult fromJson(String json) {
    final map = jsonDecode(json);
    return fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'score': score,
    };
  }

  static PlayerResult fromMap(Map<String, dynamic> map) {
    return PlayerResult(
      name: map['name'],
      score: map['score'],
    );
  }
}
