import 'package:pooker_score/models/turn.dart';

class Player {
  int id;
  String name;
  List<Turn> turns;

  get score =>
      turns.fold(0, (previousValue, element) => previousValue + element.score);

  Player({required this.id, required this.name, required this.turns});
}
