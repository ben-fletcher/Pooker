import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:provider/provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: <Widget>[
        Row(
          spacing: -50,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<GameModel>(context, listen: false)
                      .submitGameEvent(
                          GameEvent(potted: true, colour: BallColour.Red));
                },
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    minimumSize: Size(150, 150),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 10,
                    side: BorderSide(color: Colors.black, width: 3)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.sports_soccer_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                    Text(
                      "Red",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<GameModel>(context, listen: false)
                      .submitGameEvent(
                          GameEvent(potted: true, colour: BallColour.Black));
                },
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    minimumSize: Size(150, 150),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black54,
                    elevation: 10,
                    side: BorderSide(color: Colors.black, width: 3)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "8",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Black",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: -50,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<GameModel>(context, listen: false)
                      .submitGameEvent(GameEvent(
                          foul: true, colour: BallColour.Red, potted: true));
                },
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    minimumSize: Size(150, 150),
                    backgroundColor: Colors.yellow.shade700,
                    foregroundColor: Colors.black,
                    shadowColor: Colors.yellowAccent,
                    elevation: 10,
                    side: BorderSide(color: Colors.black, width: 3)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.close,
                      size: 50,
                      color: Colors.black,
                    ),
                    Text(
                      "Foul",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<GameModel>(context, listen: false)
                      .submitGameEvent(
                          GameEvent(potted: false, colour: BallColour.Na));
                },
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    minimumSize: Size(150, 150),
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.purpleAccent,
                    elevation: 10,
                    side: BorderSide(color: Colors.black, width: 3)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.next_plan,
                      size: 50,
                      color: Colors.white,
                    ),
                    Text(
                      "Miss",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
