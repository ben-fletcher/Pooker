import 'package:flutter/material.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:pooker_score/pages/finish.dart';
import 'package:pooker_score/models/player_turn.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:pooker_score/pages/start.dart';
import 'package:pooker_score/services/database_service.dart';

class GameModel extends ChangeNotifier {
  final List<Player> players = [];
  int totalBalls = 15;
  get activePlayer => players[_currentPlayerIndex];
  int _currentPlayerIndex = 0;
  BallColour _nextTargetBall = BallColour.red;
  bool hasSaved = false;
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

    // Always ensure next target is black if no reds remain
    if (remainingBalls <= 0) {
      _nextTargetBall = BallColour.black;

      if (event.potted && event.colour == BallColour.black) {
        navigator.push(MaterialPageRoute(builder: (_) => FinishPage()));
      }
    }

    notifyListeners();
  }

  void saveGame() {
    if (players.isEmpty) {
      return;
    }

    var playerResults = players.map((player) {
      return PlayerResult(player.name, player.score);
    }).toList();

    var gameResult = GameResult(date: DateTime.now(), players: playerResults);
    GameDatabaseService.insertGameResult(gameResult);
    hasSaved = true;
  }

  void undoLastEvent(BuildContext context) {
    if (_turnHistory.isNotEmpty) {
      PlayerTurn lastTurn = _turnHistory.removeLast();
      Player player = players[lastTurn.playerIndex];
      player.turns.removeLast();

      if (lastTurn.event.potted) {
        _nextTargetBall = lastTurn.event.colour;
      }

      _currentPlayerIndex = lastTurn.playerIndex;
      
      // Ensure next target is black if no reds remain
      if (remainingBalls <= 0) {
        _nextTargetBall = BallColour.black;
      }
      
      notifyListeners();
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Exit Game'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Would you like to exit this game?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => StartPage()),
                      (_) => false);
                },
                child: const Text('Exit'),
              ),
            ],
          );
        },
      );
    }
  }

  int get remainingBalls {
    int pottedBalls = players.fold(0, (sum, player) {
      return sum +
          player.turns
              .where((turn) =>
                  turn.event.potted && turn.event.colour == BallColour.red)
              .fold(0, (turnSum, turn) => turnSum + turn.event.count);
    });

    // Subtract the black ball
    return totalBalls - 1 - pottedBalls;
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
      return 1 * event.count; // Handle multiple reds
    }

    if (event.potted && event.colour == BallColour.black) {
      return 3;
    }

    return 0;
  }

  void reset() {
    players.clear();
    _currentPlayerIndex = 0;
    _nextTargetBall = BallColour.red;
    hasSaved = false;
    _turnHistory.clear();

    notifyListeners();
  }

  void setTotalBalls(int balls) {
    totalBalls = balls;
    notifyListeners();
  }

  void shufflePlayers() {
    players.shuffle();
    notifyListeners();
  }

  void orderPlayersAlphabetically() {
    players.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void adjustPlayerScore(Player player, int newScore) {
    int currentScore = player.score;
    int adjustment = newScore - currentScore;
    
    if (adjustment != 0) {
      // Create a manual adjustment turn
      var adjustmentTurn = PlayerTurn(
        playerIndex: players.indexOf(player),
        score: adjustment,
        event: GameEvent(
          colour: BallColour.red,
          potted: false,
          foul: false,
        ),
        ballIndex: 0,
      );
      
      player.turns.add(adjustmentTurn);
      _turnHistory.add(adjustmentTurn);
      
      // Ensure next target is black if no reds remain
      if (remainingBalls <= 0) {
        _nextTargetBall = BallColour.black;
      }
      
      notifyListeners();
    }
  }
}
