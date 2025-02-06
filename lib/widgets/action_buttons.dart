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
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<GameModel>(context, listen: false)
                      .submitGameEvent(
                          GameEvent(potted: true, colour: BallColour.Red));
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 100),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white),
                child: const Text("Red"),
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
                    minimumSize: Size(double.infinity, 100),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                child: const Text("Black"),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<GameModel>(context, listen: false)
                      .submitGameEvent(GameEvent(
                          foul: true, colour: BallColour.Red, potted: true));
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 100),
                    backgroundColor: Colors.yellow.shade500,
                    foregroundColor: Colors.black),
                child: const Text("Foul"),
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
                    minimumSize: Size(double.infinity, 100),
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white),
                child: const Text("Miss"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
