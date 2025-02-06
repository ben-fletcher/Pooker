import 'package:flutter/material.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/models/turn.dart';

class GameModel extends ChangeNotifier {
  final List<Player> players = [Player(Id: 1, Name: "Ben", Turns: []), Player(Id: 2, Name: "Dan", Turns: [])];
  int _currentPlayerIndex = 0;

  void submitGameEvent(GameEvent event) {
    // Add your code here!
    var turn = Turn(score: _calculateScore(event), event: event, ballIndex: 0);
    players[_currentPlayerIndex].Turns.add(turn);

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

}