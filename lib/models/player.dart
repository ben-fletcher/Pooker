import 'package:pooker_score/models/turn.dart';

class Player {
  int Id;
  String Name;
  List<Turn> Turns;

  Player({required this.Id, required this.Name, required this.Turns});
}