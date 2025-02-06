import 'package:flutter/material.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/models/turn.dart';

class GameModel extends ChangeNotifier {
  final List<Player> players = [];
  get activePlayer => players[_currentPlayerIndex];
  int _currentPlayerIndex = 0;

  void submitGameEvent(GameEvent event) {
    // Add your code here!
    var turn = Turn(score: _calculateScore(event), event: event, ballIndex: 0);
    players[_currentPlayerIndex].Turns.add(turn);

    if (event.foul == true || event.potted == false) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % players.length;
    }

    notifyListeners();
  }

  void addPlayer(Player player) {
    players.add(player);
    notifyListeners();
  }

  void removePlayer(int index) {
    players.removeAt(index);
    notifyListeners();
  }

  int _calculateScore(GameEvent event) {
    if (event.foul == true) {
      return -1;
    }

    if (event.potted && event.colour == BallColour.Red) {
      return 1;
    }

    if (event.potted && event.colour == BallColour.Black) {
      return 3;
    }

    return 0;
  }

  void reset() {
    players.clear();
    _currentPlayerIndex = 0;
    notifyListeners();
  }
}
