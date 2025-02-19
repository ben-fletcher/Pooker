import 'package:pooker_score/models/turn.dart';

class Player implements PlayerScore {
  int id;
  @override
  String name;
  List<Turn> turns;

  @override
  get score =>
      turns.fold(0, (previousValue, element) => previousValue + element.score);

  Player({required this.id, required this.name, required this.turns});
}

abstract class PlayerScore {
  String name;
  int get score;

  PlayerScore(this.name);
}
