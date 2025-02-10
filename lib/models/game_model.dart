import 'package:flutter/material.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:pooker_score/pages/finish.dart';

class GameModel extends ChangeNotifier {
  final List<Player> players = [];
  get activePlayer => players[_currentPlayerIndex];
  int _currentPlayerIndex = 0;
  BallColour _nextTargetBall = BallColour.Red;

  BallColour get nextTargetBall => _nextTargetBall;

  void submitGameEvent(GameEvent event, NavigatorState navigator) {
    if (event.colour != _nextTargetBall && event.potted) {
      event = GameEvent(foul: true, colour: event.colour, potted: true);
    }

    var turn = Turn(score: _calculateScore(event), event: event, ballIndex: 0);
    players[_currentPlayerIndex].Turns.add(turn);

    if (event.foul == true || event.potted == false) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % players.length;
      _nextTargetBall = BallColour.Red;
    } else {
      _nextTargetBall =
          _nextTargetBall == BallColour.Red ? BallColour.Black : BallColour.Red;
    }

    if (remainingBalls == 0) {
      _nextTargetBall = BallColour.Black;

      if (event.potted && event.colour == BallColour.Black) {
        // End game
        navigator.push(MaterialPageRoute(builder: (_) => FinishPage()));
      }
    }

    notifyListeners();
  }

  int get remainingBalls {
    int totalBalls = 14;
    int pottedBalls = players.fold(0, (sum, player) {
      return sum +
          player.Turns.where((turn) =>
              turn.event.potted && turn.event.colour == BallColour.Red).length;
    });
    return totalBalls - pottedBalls;
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
