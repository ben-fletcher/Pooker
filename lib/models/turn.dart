enum BallColour {
  na,
  red,
  black,
}

class GameEvent {
  bool potted;
  bool? foul;
  BallColour colour;

  GameEvent({
    required this.potted,
    this.foul,
    required this.colour,
  });
}

class Turn {
  int score;
  GameEvent event;
  int ballIndex;

  Turn({
    required this.score,
    required this.event,
    required this.ballIndex,
  });

  @override
  String toString() {
    switch (event.colour) {
      case BallColour.red:
        return 'Red';
      case BallColour.black:
        return 'Black';
      default:
        return '';
    }
  }
}

class BallTurn {
  int ballIndex;
  List<PlayerEvent> playerEvents;

  BallTurn({
    required this.ballIndex,
    required this.playerEvents,
  });
}

class PlayerEvent {
  int playerId;
  GameEvent event;

  PlayerEvent({
    required this.playerId,
    required this.event,
  });
}
