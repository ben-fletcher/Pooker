import 'package:pooker_score/models/turn.dart';

class PlayerTurn extends Turn {
  final int playerIndex;

  PlayerTurn({
    required this.playerIndex,
    required super.score,
    required super.event,
    required super.ballIndex,
  });
}
