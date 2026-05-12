import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pooker_score/models/player.dart';

class GameResult {
  int? id;
  final DateTime date;
  final List<PlayerResult> players;

  GameResult({required this.date, required this.players, this.id});

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
      'id': id,
      'sorted': 'true',
      'date': date.toIso8601String(),
      'players': players.map((player) => player.toJson()).toList().toString(),
    };
  }

  static GameResult fromMap(Map<String, dynamic> map) {
    final players = (json.decode(map['players']) as List)
        .map((player) => PlayerResult.fromMap(player))
        .toList();

    if (map['sorted'] != 'true') {
      players.sort((a, b) => b.score.compareTo(a.score));
    }

    return GameResult(
      id: map['id'],
      date: DateTime.parse(map['date']),
      players: players,
    );
  }
}

class PlayerResult extends PlayerScore {
  @override
  final int score;

  PlayerResult(super.name, this.score);

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
      map['name'],
      map['score'],
    );
  }

  @override
  set name(String name) {
    throw ErrorDescription("Can't change name of PlayerResult");
  }
}
