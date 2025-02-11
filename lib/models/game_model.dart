import 'package:flutter/material.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:pooker_score/pages/finish.dart';
import 'package:pooker_score/models/player_turn.dart';

class GameModel extends ChangeNotifier {
  final List<Player> players = [];
  get activePlayer => players[_currentPlayerIndex];
  int _currentPlayerIndex = 0;
  BallColour _nextTargetBall = BallColour.red;
  final List<PlayerTurn> _turnHistory = [];

  BallColour get nextTargetBall => _nextTargetBall;

  void submitGameEvent(GameEvent event, NavigatorState navigator) {
    if (event.colour != _nextTargetBall && event.potted) {
      event = GameEvent(foul: true, colour: event.colour, potted: true);
    }

    var turn = PlayerTurn(
      playerIndex: _currentPlayerIndex,
      score: _calculateScore(event),
      event: event,
      ballIndex: 0,
    );
    players[_currentPlayerIndex].turns.add(turn);
    _turnHistory.add(turn);

    if (event.foul == true || event.potted == false) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % players.length;
      _nextTargetBall = BallColour.red;
    } else {
      _nextTargetBall =
          _nextTargetBall == BallColour.red ? BallColour.black : BallColour.red;
    }

    if (remainingBalls == 0) {
      _nextTargetBall = BallColour.black;

      if (event.potted && event.colour == BallColour.black) {
        // End game
        navigator.push(MaterialPageRoute(builder: (_) => FinishPage()));
      }
    }

    notifyListeners();
  }

  void undoLastEvent() {
    if (_turnHistory.isNotEmpty) {
      PlayerTurn lastTurn = _turnHistory.removeLast();
      Player player = players[lastTurn.playerIndex];
      player.turns.removeLast();

      if (lastTurn.event.potted) {
        _nextTargetBall = lastTurn.event.colour;
      }

      _currentPlayerIndex = lastTurn.playerIndex;
      notifyListeners();
    }
  }

  int get remainingBalls {
    int totalBalls = 14;
    int pottedBalls = players.fold(0, (sum, player) {
      return sum +
          player.turns
              .where((turn) =>
                  turn.event.potted && turn.event.colour == BallColour.red)
              .length;
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

    if (event.potted && event.colour == BallColour.red) {
      return 1;
    }

    if (event.potted && event.colour == BallColour.black) {
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
