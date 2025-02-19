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
      'date': date.toIso8601String(),
      'players': players.map((player) => player.toJson()).toList().toString(),
    };
  }

  static GameResult fromMap(Map<String, dynamic> map) {
    return GameResult(
      id: map['id'],
      date: DateTime.parse(map['date']),
      players: (json.decode(map['players']) as List)
          .map((player) => PlayerResult.fromMap(player))
          .toList(),
    );
  }
}

class PlayerResult implements PlayerScore {
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
  
  @override
  set name(String _name) {
    throw ErrorDescription("Can't change name of PlayerResult");
  }
}
