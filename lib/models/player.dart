import 'package:pooker_score/models/turn.dart';

class Player {
  int Id;
  String Name;
  List<Turn> Turns;

  get score =>
      Turns.fold(0, (previousValue, element) => previousValue + element.score);

  Player({required this.Id, required this.Name, required this.Turns});
}
